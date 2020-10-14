Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

Import-Module -Name "$Path\modules\SetAdmin" #-Verbose

class Computer {
  [string] $SID

  Computer() {
    $sid = $(get-localuser)[0].SID.Value
    $this.SID = $sid.Substring(0, $sid.Length-4)
  }

  [void] CreateRestorePoint([string] $Description="Creating system restore point", [string] $Type = "MODIFY_SETTINGS") {
    Checkpoint-Computer -Description "Testing powershell checkpoint" -RestorePointType $Type
  }

  [string] GetHostname() {
    return Get-ComputerInfo | select -ExpandProperty CsName
  }

  [void] SetHostname($NewName) {
    Rename-Computer -NewName $NewName -Force -ErrorAction Stop
  }

  [string] GetDomain() {
    return Get-ComputerInfo | select -ExpandProperty CsDomain
  }

  [string] GetDomainRole() {
    return Get-ComputerInfo | select -ExpandProperty CsDomainRole
  }

  [string] GetMotherBoardModel() {
    return Get-ComputerInfo | select -ExpandProperty CsModel
  }

  [string] GetMotherBoardManufacturer() {
    return Get-ComputerInfo | select -ExpandProperty CsManufacturer
  }

  [string] GetProcessors() {
    return Get-ComputerInfo | select -ExpandProperty CsProcessors
  }

  [string] GetOSName() {
    return Get-ComputerInfo | select -ExpandProperty OsName
  }

  [string] GetOSType() {
    return Get-ComputerInfo | select -ExpandProperty OsType
  }

  [string] GetOSVersion() {
    return Get-ComputerInfo | select -ExpandProperty OsVersion
  }

  [string] GetOSBuildNum() {
    return Get-ComputerInfo | select -ExpandProperty OsBuildNumber
  }

  [string] GetOSBuildName() {
    return Get-ComputerInfo | select -ExpandProperty OsBuildName
  }

  [string] GetHotFixes() {
    return Get-ComputerInfo | select -ExpandProperty OsHotFixes
  }

  [string] GetBootDevice() {
    return Get-ComputerInfo | select -ExpandProperty OsBootDevice
  }

  [string] GetSystemDevice() {
    return Get-ComputerInfo | select -ExpandProperty OsSystemDevice
  }

  [string] GetSystemDir() {
    return Get-ComputerInfo | select -ExpandProperty OsSystemDirectory
  }

  [string] GetSystemDrive() {
    return Get-ComputerInfo | select -ExpandProperty OsSystemDrive
  }

  [string] GetWinDir() {
    return Get-ComputerInfo | select -ExpandProperty OsWindowsDirectory
  }

  [string] GetUptime() {
    return Get-ComputerInfo | select -ExpandProperty OsUptime
  }

  [string] GetNetworkAdapters() {
    return Get-ComputerInfo | select -ExpandProperty CsNetworkAdapters
  }
}
