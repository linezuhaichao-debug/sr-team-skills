# skill-up judge script -- case: gdd-result-only-no-process
# NOTE: skill-up copies this file ALONE into a temp directory before executing it,
# so it must stay self-contained: no dot-sourcing and no external needle files.
# Stored as UTF-8 WITH BOM so Windows PowerShell 5.1 parses the Chinese needles correctly.
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$report = New-Object System.Collections.Generic.List[string]
$failures = 0

function Add-Check {
    param([string]$Name, [bool]$Ok, [string]$Detail, [bool]$Warn = $false)
    $tag = 'PASS'
    if (-not $Ok) { $tag = 'FAIL' }
    if ((-not $Ok) -and $Warn) { $tag = 'WARN' }
    if ($tag -eq 'FAIL') { $script:failures++ }
    $script:report.Add("[$tag] $Name -- $Detail")
}

function Get-GddDocs {
    $hits = New-Object System.Collections.Generic.List[object]
    foreach ($f in (Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue)) {
        if ($f.Extension -ne '.md') { continue }
        if ($f.FullName -match '[\\/]\.claude[\\/]') { continue }
        if ($f.DirectoryName -notmatch '[\\/]proposals$') { continue }
        $hits.Add($f)
    }
    return @($hits | Sort-Object LastWriteTime -Descending)
}

function Get-TextAfterBanner {
    param([string]$Text)
    $m = [regex]::Match($Text, '(?m)^##\s')
    if ($m.Success) { return $Text.Substring($m.Index) }
    return $Text
}

function Get-SectionByHeading {
    param([string]$Text, [string]$Needle)
    $rx = [regex]"(?m)^(?<h>#{1,6})[ \t]*(?<t>[^\r\n]*)$"
    $ms = $rx.Matches($Text)
    $start = -1
    $level = 0
    $end = $Text.Length
    for ($i = 0; $i -lt $ms.Count; $i++) {
        $m = $ms[$i]
        if ($start -lt 0) {
            if ($m.Groups['t'].Value -like "*$Needle*") {
                $start = $m.Index
                $level = $m.Groups['h'].Value.Length
            }
        }
        elseif ($m.Groups['h'].Value.Length -le $level) {
            $end = $m.Index
            break
        }
    }
    if ($start -lt 0) { return $null }
    return $Text.Substring($start, $end - $start)
}

function Get-HitDetail {
    param([string]$Text, [string]$Pattern, [bool]$IsRegex = $false)
    if ($IsRegex) { $m = [regex]::Match($Text, $Pattern) }
    else { $m = [regex]::Match($Text, [regex]::Escape($Pattern)) }
    if (-not $m.Success) { return '' }
    $start = [Math]::Max(0, $m.Index - 25)
    $len = [Math]::Min(90, $Text.Length - $start)
    return ('...' + ($Text.Substring($start, $len) -replace "`r?`n", ' ') + '...')
}

function Finish {
    param([string]$Title)
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add("== $Title ==")
    $out.Add("cwd=$root")
    foreach ($line in $report) { $out.Add($line) }
    $out.Add("summary: failed=$failures")
    $text = ($out -join "`r`n")
    Write-Output $text
    try { Set-Content -LiteralPath (Join-Path $root 'judge-report.txt') -Value $text -Encoding UTF8 } catch { }
    if ($failures -gt 0) { exit 1 }
    exit 0
}

$processNeedles = @('来源材料清单', '证据编号', '证据索引', '拍板编号', '拍板记录', '裁决表', '假设台账', '风险台账', '治理引用', '配置契约', '未支持声明', '待配表')
$structureNeedles = @('功能规则', '界面清单', '数值待定项', '验收标准')
$rulesHeading = '功能规则'

$docs = Get-GddDocs
if ($docs.Count -eq 0) {
    Add-Check -Name 'gdd-exists' -Ok $false -Detail 'no GDD markdown found under any proposals/ directory (searched <cwd>/**/proposals/*.md, excluding .claude/skills)'
    Finish -Title 'GDD result-only (no process noise)'
}
$doc = $docs[0]
$text = Get-Content -LiteralPath $doc.FullName -Raw -Encoding UTF8
# The document banner legitimately quotes the writing rules, so it is excluded from the noise scan.
$body = Get-TextAfterBanner -Text $text

Add-Check -Name 'gdd-exists' -Ok $true -Detail $doc.FullName

foreach ($n in $processNeedles) {
    $hit = [regex]::IsMatch($body, [regex]::Escape($n))
    Add-Check -Name "no-process-noise:$n" -Ok (-not $hit) -Detail $(if ($hit) { Get-HitDetail -Text $body -Pattern $n } else { 'absent' })
}

foreach ($p in @('\bE\d{3}\b', '\bT\d{2}\b')) {
    $hit = [regex]::IsMatch($body, $p)
    Add-Check -Name "no-process-noise-id:$p" -Ok (-not $hit) -Detail $(if ($hit) { Get-HitDetail -Text $body -Pattern $p -IsRegex $true } else { 'absent' })
}

foreach ($n in $structureNeedles) {
    $hit = [regex]::IsMatch($body, [regex]::Escape($n))
    Add-Check -Name "structure:$n" -Ok $hit -Detail $(if ($hit) { 'present' } else { 'MISSING' })
}

$sub = [regex]::IsMatch($body, '\bR\d+\.\d+')
Add-Check -Name 'rule-numbering:no-sub-numbers(R1.1)' -Ok (-not $sub) -Detail $(if ($sub) { Get-HitDetail -Text $body -Pattern '\bR\d+\.\d+' -IsRegex $true } else { 'absent' })

# Rule groups must stay at group level. Count headings first; if the document formats its
# group titles inline (bold text instead of a heading), fall back to counting R-tokens.
$groupHeadings = ([regex]::Matches($body, '(?m)^#{1,6}\s*R\d+\b')).Count
$groupTokens = @([regex]::Matches($body, '\bR\d+\b') | ForEach-Object { $_.Value } | Sort-Object -Unique)
$groupCount = [Math]::Max($groupHeadings, $groupTokens.Count)
Add-Check -Name 'rule-numbering:has-R-groups(>=2)' -Ok ($groupCount -ge 2) -Detail "found $groupHeadings R-group heading(s), $($groupTokens.Count) distinct R group id(s)"

$ue = ([regex]::Matches($body, 'UE\d+')).Count
Add-Check -Name 'ui:UE-numbering' -Ok ($ue -ge 2) -Detail "found $ue UE reference(s)"

$wireChars = @('┌', '└', '│', '─', '├', '┐', '┘')
$wireHits = @($wireChars | Where-Object { $body.Contains($_) })
Add-Check -Name 'ui:ascii-wireframe' -Ok ($wireHits.Count -ge 2) -Detail ('box-drawing chars present: ' + ($wireHits -join ' '))

$ac = ([regex]::Matches($body, 'AC\d+')).Count
Add-Check -Name 'acceptance:AC-numbering' -Ok ($ac -ge 1) -Detail "found $ac AC reference(s)"

# Config field names must not reach the rules chapter: neither snake_case identifiers
# nor "table.field" style source annotations (the doc refers to the concept in Chinese instead).
$fieldPatterns = @('\b[a-z][a-z0-9]*_[a-z0-9_]+\b', '\b[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\b')
$fieldHits = New-Object System.Collections.Generic.List[string]
$rulesSection = Get-SectionByHeading -Text $body -Needle $rulesHeading
if ($null -eq $rulesSection) { $rulesSection = $body }
foreach ($p in $fieldPatterns) {
    foreach ($m in [regex]::Matches($rulesSection, $p)) { $fieldHits.Add($m.Value) }
}
Add-Check -Name 'no-config-field-names-in-rules' -Ok ($fieldHits.Count -eq 0) -Detail $(if ($fieldHits.Count -eq 0) { 'no snake_case / table.field identifier in the rules chapter' } else { 'found: ' + (($fieldHits | Select-Object -First 6) -join ', ') })

# Authoring hints shipped with the template are not document content and must not survive.
$guidanceMarkers = @('写法要求', '规则编号两级制', '数值不写进规则', '不得把配置值当规则', '模板写作提示', '成稿前删除', '正文只写当前口径', '界面章写作提示', '数值待定项写作提示')
$leftover = New-Object System.Collections.Generic.List[string]
foreach ($mk in $guidanceMarkers) {
    if ($text.Contains($mk)) { $leftover.Add($mk) }
}
Add-Check -Name 'deliverable:no-template-guidance(html-comments-or-blockquotes)' -Ok ($leftover.Count -eq 0) -Detail $(if ($leftover.Count -eq 0) { 'no template authoring hint carried over' } else { 'template guidance left in the deliverable: ' + (($leftover | Sort-Object -Unique) -join ', ') })

Finish -Title 'GDD result-only (no process noise)'
