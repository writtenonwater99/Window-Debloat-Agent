#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$report = (. (Join-Path $PSScriptRoot 'Review-Windows.ps1')) | ConvertFrom-Json
if ($report.schema -ne 2) { throw 'Unexpected schema' }
foreach ($section in $report.sections) {
    if ($section.status -notin 'read','incomplete' -or $section.items -isnot [array]) {
        throw "Invalid section: $($section.section)"
    }
}
$partial = Read-Section 'fixture' { 'first'; throw 'private fixture detail' }
if ($partial.status -ne 'incomplete' -or $partial.items.Count -ne 1 -or $partial.items[0] -ne 'first') {
    throw 'Partial results were lost'
}
if (($partial | ConvertTo-Json) -match 'private fixture detail') { throw 'Raw error disclosed' }
$empty = Read-Section 'fixture' {}
if ($empty.status -ne 'read' -or $empty.items.Count -ne 0) { throw 'Empty section misreported' }
$report.sections | Group-Object status | Select-Object Name,Count
