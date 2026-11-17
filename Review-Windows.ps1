#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
function Read-Section($name, [scriptblock]$query) {
    $items = [System.Collections.Generic.List[object]]::new()
    try {
        & $query | ForEach-Object { $items.Add($_) }
        [pscustomobject]@{section=$name; status='read'; items=$items.ToArray()}
    } catch {
        [pscustomobject]@{section=$name; status='incomplete'; items=$items.ToArray(); reason=$_.Exception.GetType().Name}
    }
}
$sections = @(
    Read-Section 'Windows' {
        Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
            Select-Object EditionID, DisplayVersion, CurrentBuildNumber, UBR, InstallationType
    }
    Read-Section 'Operating system architecture' {
        $native = $env:PROCESSOR_ARCHITEW6432
        if (!$native) { $native = $env:PROCESSOR_ARCHITECTURE }
        [pscustomobject]@{NativeArchitectureHint=$native; Process64Bit=[Environment]::Is64BitProcess}
    }
    Read-Section 'System drive space' {
        $drive = [System.IO.DriveInfo]::new($env:SystemDrive + '\')
        [pscustomobject]@{TotalBytes=$drive.TotalSize; AvailableBytes=$drive.AvailableFreeSpace}
    }
    Read-Section 'Domain membership (partial management indicator)' {
        Get-CimInstance Win32_ComputerSystem | Select-Object PartOfDomain
    }
    foreach ($scope in 'HKLM','HKCU') {
        foreach ($branch in 'SOFTWARE','SOFTWARE\Wow6432Node') {
            Read-Section "$scope $branch registered desktop software" {
                $path = "${scope}:\$branch\Microsoft\Windows\CurrentVersion\Uninstall"
                if (Test-Path $path) {
                    Get-ItemProperty "$path\*" | Where-Object DisplayName |
                        Select-Object DisplayName, DisplayVersion, Publisher, PSChildName, SystemComponent, EstimatedSize
                }
            }
        }
    }
    Read-Section 'Current-user app packages' {
        Get-AppxPackage | Select-Object Name, PackageFamilyName, PackageFullName, Version, IsFramework, NonRemovable
    }
    Read-Section 'Packages provisioned for new accounts' {
        Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName
    }
    Read-Section 'Optional features' {
        Get-WindowsOptionalFeature -Online | Select-Object FeatureName, @{n='State';e={[string]$_.State}}
    }
    foreach ($scope in 'HKCU','HKLM') {
        Read-Section "$scope native-view Run registry value names" {
            $path = "${scope}:\Software\Microsoft\Windows\CurrentVersion\Run"
            if (Test-Path -LiteralPath $path) {
                (Get-Item -LiteralPath $path).GetValueNames() | ForEach-Object {
                    [pscustomobject]@{Name=$_}
                }
            }
        }
    }
    Read-Section 'Startup entries visible through WMI' {
        Get-CimInstance Win32_StartupCommand | Select-Object Name, Location
    }
)
[pscustomobject]@{schema=2; sections=$sections} | ConvertTo-Json -Depth 6
