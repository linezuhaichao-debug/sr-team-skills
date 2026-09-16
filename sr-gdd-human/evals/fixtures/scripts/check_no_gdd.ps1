# skill-up judge script -- case: bare-invocation-asks-back
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

$topicNeedles = @('主题', '题目', '哪个功能', '什么功能', '功能名', '要做哪个', 'topic', 'which feature')
$materialNeedles = @('材料', '素材', '上游', '路径', '参考', 'material', 'source', 'reference')

$docs = Get-GddDocs
$names = @($docs | ForEach-Object { $_.FullName })
Add-Check -Name 'no-gdd-written-before-knowing-the-topic' -Ok ($docs.Count -eq 0) -Detail $(if ($docs.Count -eq 0) { 'no markdown produced under any proposals/ directory (correct)' } else { 'unexpected draft(s): ' + ($names -join '; ') })

$final = "$($env:EVAL_FINAL_MESSAGE)"
if ($final.Length -eq 0) {
    Add-Check -Name 'final-message-available' -Ok $false -Warn $true -Detail 'EVAL_FINAL_MESSAGE was empty in the judge environment, so the ask-back wording could not be verified'
}
else {
    $topicHit = $null
    foreach ($n in $topicNeedles) {
        if ([regex]::IsMatch($final, [regex]::Escape($n), 'IgnoreCase')) { $topicHit = $n; break }
    }
    $matHit = $null
    foreach ($n in $materialNeedles) {
        if ([regex]::IsMatch($final, [regex]::Escape($n), 'IgnoreCase')) { $matHit = $n; break }
    }
    Add-Check -Name 'asks-for-topic' -Ok ($null -ne $topicHit) -Detail $(if ($topicHit) { "matched '$topicHit'" } else { 'final message does not ask which feature the GDD is for' })
    Add-Check -Name 'asks-for-upstream-material' -Ok ($null -ne $matHit) -Detail $(if ($matHit) { "matched '$matHit'" } else { 'final message does not ask for upstream material' })
}

Finish -Title 'Bare invocation must ask back and not invent a topic'
