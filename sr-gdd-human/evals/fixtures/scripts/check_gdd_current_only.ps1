# skill-up judge script -- case: gdd-current-scope-only
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

$historyNeedles = @('曾经', '原先', '旧稿', '旧版', '上版', '变更前', '本次已改', '本次改动', '原方案', '旧方案', '此前', '过去', '已废弃')
$deprecatedHeading = '已废弃口径'

$docs = Get-GddDocs
if ($docs.Count -eq 0) {
    Add-Check -Name 'gdd-exists' -Ok $false -Detail 'no GDD markdown found under any proposals/ directory (searched <cwd>/**/proposals/*.md, excluding .claude/skills)'
    Finish -Title 'GDD keeps only the current scope'
}
$doc = $docs[0]
$text = Get-Content -LiteralPath $doc.FullName -Raw -Encoding UTF8
$body = Get-TextAfterBanner -Text $text

Add-Check -Name 'gdd-exists' -Ok $true -Detail $doc.FullName

# The deprecated-scope appendix is the only place where historical wording may live.
$appendix = Get-SectionByHeading -Text $body -Needle $deprecatedHeading
if ($null -eq $appendix) {
    $bodyMain = $body
    $appendixNote = 'no deprecated-scope appendix (acceptable)'
}
else {
    $idx = $body.IndexOf($appendix)
    if ($idx -lt 0) { $bodyMain = $body } else { $bodyMain = $body.Substring(0, $idx) }
    $appendixNote = "appendix present ($($appendix.Length) chars), excluded from the scan"
}

# Blockquote lines carry the template's own authoring guidance ("do not write 曾经/原先/..."),
# which is instruction text rather than rule content, so they are excluded from the history scan
# and reported separately below.
$bodyLines = @($bodyMain -split "`r?`n")
$bodyScan = (@($bodyLines | Where-Object { -not $_.TrimStart().StartsWith('>') }) -join "`n")

foreach ($n in $historyNeedles) {
    $hit = [regex]::IsMatch($bodyScan, [regex]::Escape($n))
    Add-Check -Name "current-scope-only:$n" -Ok (-not $hit) -Detail $(if ($hit) { Get-HitDetail -Text $bodyScan -Pattern $n } else { 'absent' })
}

# The deliverable must not ship the template's authoring hints, neither as HTML comments
# nor as "写法要求" style blockquotes.
$guidanceMarkers = @('写法要求', '规则编号两级制', '正文只写当前口径', '数值不写进规则', '不得把配置值当规则', '模板写作提示', '成稿前删除', '界面章写作提示', '数值待定项写作提示')
$leftover = New-Object System.Collections.Generic.List[string]
foreach ($mk in $guidanceMarkers) {
    $inComment = [regex]::IsMatch($text, '(?s)<!--.*?' + [regex]::Escape($mk) + '.*?-->')
    $inQuote = $false
    foreach ($line in $bodyLines) {
        if ($line.TrimStart().StartsWith('>') -and $line.Contains($mk)) { $inQuote = $true; break }
    }
    if ($inComment) { $leftover.Add("$mk (html comment)") }
    elseif ($inQuote) { $leftover.Add("$mk (blockquote)") }
}
Add-Check -Name 'deliverable:no-template-guidance(html-comments-or-blockquotes)' -Ok ($leftover.Count -eq 0) -Detail $(if ($leftover.Count -eq 0) { 'no template authoring hint carried over' } else { 'template guidance left in the deliverable: ' + (($leftover | Sort-Object -Unique) -join ', ') })

# The deprecated-scope appendix must be one sentence, not a table and not a comparison section.
if ($null -eq $appendix) {
    Add-Check -Name 'appendix:one-liner-not-a-table' -Ok $true -Detail 'no deprecated-scope appendix (acceptable)'
}
else {
    $tableRows = @(($appendix -split "`r?`n") | Where-Object { $_.TrimStart().StartsWith('|') })
    $contentLines = @(($appendix -split "`r?`n") | Where-Object { $t = $_.Trim(); $t -ne '' -and -not $t.StartsWith('#') -and -not $t.StartsWith('>') })
    Add-Check -Name 'appendix:one-liner-not-a-table' -Ok ($tableRows.Count -eq 0) -Detail $(if ($tableRows.Count -eq 0) { "$($contentLines.Count) content line(s), no table" } else { "appendix uses a $($tableRows.Count)-row table; it must be a single sentence" })
    Add-Check -Name 'appendix:short(<=3 content lines)' -Ok ($contentLines.Count -le 3) -Warn $true -Detail "$($contentLines.Count) content line(s)"
}

Finish -Title 'GDD keeps only the current scope'
