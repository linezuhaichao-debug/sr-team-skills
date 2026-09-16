# skill-up judge script -- case: gdd-ui-wireframes
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

function Count-FencedBlocks {
    param([string]$Text)
    return ([regex]::Matches($Text, '(?ms)^[ \t]*```[^\r\n]*\r?\n.*?^[ \t]*```[ \t]*$')).Count
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

$uiNeedles = @('界面清单', '界面流程', '全局交互规范', '不属于本功能')
$foreignScreens = @('货币详情弹窗', '英雄详情')
$wireChars = @('┌', '└', '│', '─', '├', '┐', '┘')
$uiHeading = '用户体验与界面流程'

$docs = Get-GddDocs
if ($docs.Count -eq 0) {
    Add-Check -Name 'gdd-exists' -Ok $false -Detail 'no GDD markdown found under any proposals/ directory (searched <cwd>/**/proposals/*.md, excluding .claude/skills)'
    Finish -Title 'GDD UI chapter: one wireframe per screen'
}
$doc = $docs[0]
$text = Get-Content -LiteralPath $doc.FullName -Raw -Encoding UTF8
$body = Get-TextAfterBanner -Text $text

Add-Check -Name 'gdd-exists' -Ok $true -Detail $doc.FullName

$uiSection = Get-SectionByHeading -Text $body -Needle $uiHeading
if ($null -eq $uiSection) {
    $uiSection = $body
    $scopeNote = ' (UI chapter heading not found: fell back to the whole body)'
}
else {
    $scopeNote = " (UI chapter only, $($uiSection.Length) chars)"
}

foreach ($n in $uiNeedles) {
    $hit = [regex]::IsMatch($body, [regex]::Escape($n))
    Add-Check -Name "ui-required:$n" -Ok $hit -Detail $(if ($hit) { 'present' } else { 'MISSING' })
}

# Screen identifiers declared anywhere in the document.
$ids = @([regex]::Matches($body, 'UI-[A-Za-z0-9]+') | ForEach-Object { $_.Value } | Sort-Object -Unique)
Add-Check -Name 'ui:screen-count(>=3)' -Ok ($ids.Count -ge 3) -Detail "screen ids: $($ids -join ', ')$scopeNote"

# Each screen OWNED by this feature needs its own section plus one wireframe block.
# A screen id that the document lists and then declares as belonging to another system
# (e.g. "UI-M4 遗迹商店 —— 归属商店系统，不属于本功能") correctly has no section of its own,
# so sections are counted directly rather than required to cover every referenced id.
$sectionsFor = New-Object System.Collections.Generic.List[string]
foreach ($id in $ids) {
    if ([regex]::IsMatch($body, "(?m)^#{1,6}[^\r\n]*$([regex]::Escape($id))")) { $sectionsFor.Add($id) }
}
Add-Check -Name 'ui:one-section-per-own-screen(>=3)' -Ok ($sectionsFor.Count -ge 3) -Detail "sections found for $($sectionsFor.Count) of $($ids.Count) referenced screen id(s): $($sectionsFor -join ', ')"

$blocks = Count-FencedBlocks -Text $uiSection
Add-Check -Name 'ui:wireframe-block-per-screen' -Ok ($sectionsFor.Count -ge 3 -and $blocks -ge $sectionsFor.Count) -Detail "fenced blocks in UI chapter: $blocks for $($sectionsFor.Count) screen section(s)"

$withoutSection = @($ids | Where-Object { $sectionsFor -notcontains $_ })
Add-Check -Name 'ui:screens-without-section(declared external?)' -Ok ($withoutSection.Count -eq 0) -Warn $true -Detail $(if ($withoutSection.Count -eq 0) { 'every referenced screen id has its own section' } else { 'screen ids without a dedicated section (fine if declared as belonging to another system): ' + ($withoutSection -join ', ') })

$wireHits = @($wireChars | Where-Object { $uiSection.Contains($_) })
Add-Check -Name 'ui:ascii-wireframe' -Ok ($wireHits.Count -ge 2) -Detail ('box-drawing chars present: ' + ($wireHits -join ' '))

$ue = @([regex]::Matches($uiSection, 'UE\d+') | ForEach-Object { $_.Value } | Sort-Object -Unique)
Add-Check -Name 'ui:UE-rules(>=3)' -Ok ($ue.Count -ge 3) -Detail "distinct UE rules: $($ue.Count) ($($ue -join ', '))"

# Screens owned by other systems may only be referenced, never designed here.
foreach ($n in $foreignScreens) {
    $asHeading = [regex]::IsMatch($body, "(?m)^#{1,6}[^\r\n]*$([regex]::Escape($n))")
    Add-Check -Name "boundary:no-section-for-$n" -Ok (-not $asHeading) -Detail $(if ($asHeading) { Get-HitDetail -Text $body -Pattern "(?m)^#{1,6}[^\r\n]*$([regex]::Escape($n))" -IsRegex $true } else { 'no dedicated section (correct)' })
    $mentioned = [regex]::IsMatch($body, [regex]::Escape($n))
    Add-Check -Name "boundary:referenced-$n" -Ok $mentioned -Warn $true -Detail $(if ($mentioned) { 'referenced' } else { 'never mentioned' })
}

Finish -Title 'GDD UI chapter: one wireframe per screen'
