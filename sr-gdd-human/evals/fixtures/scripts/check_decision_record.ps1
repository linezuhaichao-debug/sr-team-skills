# skill-up judge script -- case: decision-record-on-approve
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

$requiredFields = @('decision_id', 'title', 'decision_question', 'owner', 'status', 'decision_type', 'boundary_status', 'stakes', 'reversibility', 'current_default_action', 'options', 'evidence_refs', 'assumption_refs', 'experiment_refs', 'gate_refs', 'rollback_trigger')
$refFields = @('evidence_refs', 'assumption_refs', 'experiment_refs', 'gate_refs')
$allowedKeys = @('schema_version', 'decision_id', 'title', 'decision_question', 'owner', 'status', 'decision_type', 'boundary_status', 'stakes', 'reversibility', 'current_default_action', 'options', 'evidence_refs', 'assumption_refs', 'experiment_refs', 'gate_refs', 'decision_result', 'rollback_trigger', 'accepted_by', 'accepted_reason', 'supersedes', 'created_at', 'updated_at')

# The human-readable GDD must exist before the Human Gate can be approved.
$docs = Get-GddDocs
Add-Check -Name 'gdd-written-in-turn-1' -Ok ($docs.Count -ge 1) -Detail $(if ($docs.Count -ge 1) { $docs[0].FullName } else { 'no GDD markdown found under proposals/' })

$records = @()
foreach ($f in (Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue)) {
    if ($f.Extension -ne '.json') { continue }
    if ($f.FullName -match '[\\/]\.claude[\\/]') { continue }
    if ($f.DirectoryName -notmatch '[\\/]decisions$') { continue }
    $records += $f
}
$records = @($records | Sort-Object LastWriteTime -Descending)

Add-Check -Name 'decision-record-written-under-decisions/' -Ok ($records.Count -ge 1) -Detail $(if ($records.Count -ge 1) { ($records | ForEach-Object { $_.FullName }) -join '; ' } else { 'no decisions/*.json found' })

if ($records.Count -ge 1) {
    $record = $records[0]
    Add-Check -Name 'decision-record:filename-decision_<topic>_<YYYYMMDD>.json' -Ok ($record.Name -match '^decision_.+_\d{8}\.json$') -Warn $true -Detail "filename='$($record.Name)'"

    $json = $null
    try { $json = Get-Content -LiteralPath $record.FullName -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { Add-Check -Name 'decision-record:valid-json' -Ok $false -Detail "parse error: $_" }

    if ($null -ne $json) {
        Add-Check -Name 'decision-record:valid-json' -Ok $true -Detail $record.Name

        $present = @($json.PSObject.Properties.Name)
        $missing = @($requiredFields | Where-Object { $present -notcontains $_ })
        Add-Check -Name 'decision-record:required-fields' -Ok ($missing.Count -eq 0) -Detail $(if ($missing.Count -eq 0) { "all $($requiredFields.Count) required fields present" } else { 'missing: ' + ($missing -join ', ') })

        Add-Check -Name 'decision-record:status-accepted' -Ok ("$($json.status)" -eq 'accepted') -Detail "status='$($json.status)' (the Human Gate option approve must map to accepted)"

        Add-Check -Name 'decision-record:decision_id-pattern' -Ok ("$($json.decision_id)" -match '^DEC-[A-Z0-9-]{3,}$') -Detail "decision_id='$($json.decision_id)'"

        $optCount = 0
        if ($null -ne $json.options) { $optCount = @($json.options).Count }
        Add-Check -Name 'decision-record:options(>=2)' -Ok ($optCount -ge 2) -Detail "$optCount option(s)"

        $badRefs = @()
        foreach ($k in $refFields) {
            $prop = $json.PSObject.Properties[$k]
            if ($null -eq $prop) { continue }
            $val = $prop.Value
            if ($null -eq $val) { $badRefs += "$k=null"; continue }
            if (-not ($val -is [System.Array])) { $badRefs += "$k=not-array" }
        }
        Add-Check -Name 'decision-record:ref-fields-are-arrays' -Ok ($badRefs.Count -eq 0) -Detail $(if ($badRefs.Count -eq 0) { 'all ref fields are arrays (possibly empty)' } else { $badRefs -join ', ' })

        $extra = @($present | Where-Object { $allowedKeys -notcontains $_ })
        Add-Check -Name 'decision-record:no-extra-keys(schema additionalProperties)' -Ok ($extra.Count -eq 0) -Warn $true -Detail $(if ($extra.Count -eq 0) { 'no unknown keys' } else { 'extra keys: ' + ($extra -join ', ') })
    }
}

Finish -Title 'Decision record after Human Gate approve'
