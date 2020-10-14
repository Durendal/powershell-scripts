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
  [switch] $RemoveHomeDir = $False,
  [switch] $Admin = $False
)

# Parse root directory
$Path = $MyInvocation.MyCommand.Path
$Path = $Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"
Import-Module -Name "$Path\modules\AsAdmin" #-Verbose
Import-Module -Name "$Path\modules\ColourText"
Import-Module -Name "$Path\classes\LocalUser.ps1"

# Elevate to admin priveleges
As-Admin $Path "Delete-Admin.ps1" "-Username", $Username, $(If($RemoveHomeDir.IsPresent) { "-RemoveHomeDir" } Else { "" }), $(If($Admin.IsPresent) { "-Admin" } Else { "" })
$user = [LocalUser]::new($Username)

if($Admin.IsPresent -and $user.GetIsAdmin())
{
  Colour-Text 1 "Removing $Username from the Administrators group"
  $user.RevokeAdmin()
}
Colour-Text 1 "Removing user $Username, one moment..."
$user.Delete()

if($RemoveHomeDir.IsPresent)
{
  $HomeDir = "C:\Users\$Username"
  Colour-Text 1 "Removing $Username's home directory: $HomeDir"
  Remove-Item -path $HomeDir -Recurse -Force -ErrorAction Stop
}

Colour-Text 1 "Finished. $Username has been removed from the system."
Read-Host "Press enter to exit... "
