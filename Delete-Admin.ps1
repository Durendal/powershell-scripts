<#
    .SYNOPSIS
      Remove an administrator account

    .DESCRIPTION
      This script will remove $Username from the Administrators group then delete the account
      Optionally if the -RemoveHomeDir flag is passed an attempt will be made to remove
      the users home directory, however the user executing the script must have adequate
      permissions
#>
param(
  [string] $Username = "bhewitt",
  [switch] $RemoveHomeDir = $False
)

# Parse root directory
$Path = $MyInvocation.MyCommand.Path
$Path = $Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"
Import-Module -Name "$Path\modules\AsAdmin" #-Verbose
Import-Module -Name "$Path\modules\SetAdmin" #-Verbose

# Elevate to admin priveleges
As-Admin $Path "Delete-Admin.ps1" "-Username", $Username, $(If($RemoveHomeDir.IsPresent) { "-RemoveHomeDir" } Else { "" })
Set-Admin $Username $False
Write-Output "Removing user $Username, one moment..."
Remove-LocalUser -Name $Username -ErrorAction Stop

if($RemoveHomeDir.IsPresent)
{
  $HomeDir = "C:\Users\$Username"
  Write-Output "Removing $Username's home directory: $HomeDir"
  Remove-Item -path $HomeDir -Recurse -Force -ErrorAction Stop
}

Write-Output "Finished. $Username has been removed from the system."
Read-Host "Press enter to exit... "
