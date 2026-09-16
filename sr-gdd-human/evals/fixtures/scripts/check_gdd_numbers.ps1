# skill-up judge script -- case: gdd-no-config-numbers
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

# Concrete config values must not appear in the rules chapter: change every number in the
# config table and the prose should not need a single edit.
# A literal count of "1" is a logical minimum ("at least 1 floor"), not a tunable value, and
# "the probabilities add up to 100%" is a tautology the skill itself endorses, so both are exempt.
$unitRegex = '(\d+(?:\.\d+)?)\s*(钻石|元|级|层|天|秒|次|张)'
$exemptCounts = @('1')
$percentRegex = '(\d+(?:\.\d+)?)\s*%'
$percentExempt = @('100')
$idRegex = '\d{4,}'
$literalRegex = '\b(?:50|12|15|30)\b|2\.5'
$rulesHeading = '功能规则'
$pendingHeading = '数值待定项'
$placeholderWord = '参考值'

$docs = Get-GddDocs
if ($docs.Count -eq 0) {
    Add-Check -Name 'gdd-exists' -Ok $false -Detail 'no GDD markdown found under any proposals/ directory (searched <cwd>/**/proposals/*.md, excluding .claude/skills)'
    Finish -Title 'GDD keeps config numbers out of the rules'
}
$doc = $docs[0]
$text = Get-Content -LiteralPath $doc.FullName -Raw -Encoding UTF8
$body = Get-TextAfterBanner -Text $text

Add-Check -Name 'gdd-exists' -Ok $true -Detail $doc.FullName

$rules = Get-SectionByHeading -Text $body -Needle $rulesHeading
if ($null -eq $rules) {
    $rules = $body
    $scopeNote = ' (rules chapter heading not found: fell back to the whole body)'
}
else {
    $scopeNote = " (rules chapter only, $($rules.Length) chars)"
}

# Identifiers such as R4 / UE4 / AC1 / P0 are document structure, not configuration values:
# strip them first so a heading like "### R4 层内倒计时" is not misread as the value "4 层".
$scan = [regex]::Replace($rules, '\b(?:UI-M|UI|UE|AC|R|P|OPT|DEC)\d+\b', 'ID')

$unitHits = New-Object System.Collections.Generic.List[string]
foreach ($m in [regex]::Matches($scan, $unitRegex)) {
    if ($exemptCounts -contains $m.Groups[1].Value) { continue }
    $unitHits.Add($m.Value)
}
Add-Check -Name 'no-config-number:measure+unit(钻石/元/级/层/天/秒/次/张)' -Ok ($unitHits.Count -eq 0) -Detail $(if ($unitHits.Count -eq 0) { 'absent' + $scopeNote } else { 'found: ' + (($unitHits | Select-Object -First 6) -join ', ') + $scopeNote })

$pctHits = New-Object System.Collections.Generic.List[string]
foreach ($m in [regex]::Matches($scan, $percentRegex)) {
    if ($percentExempt -contains $m.Groups[1].Value) { continue }
    $pctHits.Add($m.Value)
}
Add-Check -Name 'no-config-number:percentage(other than 100%)' -Ok ($pctHits.Count -eq 0) -Detail $(if ($pctHits.Count -eq 0) { 'absent' + $scopeNote } else { 'found: ' + (($pctHits | Select-Object -First 6) -join ', ') + $scopeNote })

$idHits = New-Object System.Collections.Generic.List[string]
foreach ($m in [regex]::Matches($scan, $idRegex)) { $idHits.Add($m.Value) }
Add-Check -Name 'no-config-number:id-like-number(4+ digits)' -Ok ($idHits.Count -eq 0) -Detail $(if ($idHits.Count -eq 0) { 'absent' + $scopeNote } else { 'found: ' + (($idHits | Select-Object -First 6) -join ', ') + $scopeNote })

$litHits = New-Object System.Collections.Generic.List[string]
foreach ($m in [regex]::Matches($scan, $literalRegex)) { $litHits.Add($m.Value) }
Add-Check -Name 'no-config-number:values-copied-from-the-material(50/12/15/30/2.5)' -Ok ($litHits.Count -eq 0) -Detail $(if ($litHits.Count -eq 0) { 'absent' + $scopeNote } else { 'found: ' + (($litHits | Select-Object -First 6) -join ', ') + $scopeNote })

$pending = [regex]::IsMatch($body, [regex]::Escape($pendingHeading))
Add-Check -Name 'pending-values-section-present' -Ok $pending -Detail $(if ($pending) { 'present' } else { 'MISSING' })

$placeholder = ([regex]::Matches($text, [regex]::Escape($placeholderWord))).Count
Add-Check -Name 'mechanism-phrasing:reference-value-placeholder' -Ok ($placeholder -ge 1) -Detail "found $placeholder occurrence(s) of the reference-value phrasing"

# The pending-values section lists item names only: no draft values, no initial numbers.
# The 编号 column is the single place where digits are legitimate there.
$pendingSection = Get-SectionByHeading -Text $body -Needle $pendingHeading
$pendingDigits = New-Object System.Collections.Generic.List[string]
if ($null -ne $pendingSection) {
    foreach ($line in ($pendingSection -split "`r?`n")) {
        $t = $line.Trim()
        if ($t -eq '') { continue }
        if ($t.StartsWith('#')) { continue }
        if ($t -match '^\|[\s\-\|:]+\|$') { continue }
        $rest = $t
        if ($t.StartsWith('|')) {
            $cells = @($t.Trim('|') -split '\|')
            if ($cells.Count -gt 1) { $rest = ($cells[1..($cells.Count - 1)] -join '|') }
        }
        if ($rest -match '\d') { $pendingDigits.Add($t) }
    }
}
Add-Check -Name 'pending-values:no-concrete-numbers(outside the id column)' -Ok ($pendingDigits.Count -eq 0) -Detail $(if ($pendingDigits.Count -eq 0) { 'the pending-values section carries item names only' } else { 'concrete value(s) found: ' + (($pendingDigits | Select-Object -First 3) -join ' ; ') })

Finish -Title 'GDD keeps config numbers out of the rules'
