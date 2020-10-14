<#
    .SYNOPSIS
      Change username, user home directory, and password

    .DESCRIPTION
      This script takes the name of a user that exists, and the name to change it to
      The user will be prompted to enter a password to set for the new username
      The home directory is changed to C:\Users\{new username}
      If any stage other than password fails, the previous changes will be reverted.
#>
param(
  $OldUserName = $env:UserName,
  [Parameter(Mandatory=$true)]
  $NewUserName
)

# Parse root directory
$Path = $MyInvocation.MyCommand.Path
$Path = $Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"
Import-Module -Name "$Path\classes\LocalUser.ps1"
Import-Module -Name "$Path\modules\AsAdmin"
Import-Module -Name "$Path\modules\ColourText"

# Elevate Priveleges
As-Admin $Path "Change-Username.ps1" "-OldUserName", $OldUserName, "-NewUserName", $NewUserName

$Password = Read-Host "Enter Password" -AsSecureString
$user = [LocalUser]::new($OldUserName)
Colour-Text 1 "Beginning user-migration sequence for Username: $OldUserName SID: $UserSID, one moment..."

try {
  $user.SetUsername($NewUserName)
}
catch
{
  throw "Failed to locate or rename old user"
}
try {
  $user.SetHomeDir("C:\Users\$NewUserName")
}
catch
{
  # Revert changes
  $user.SetUsername($OldUserName)
  throw "Failed to change users home directory, reverting changes."
}
try {
  $user.SetPassword($Password)
}
catch{
  throw "Failed to update password. Login with old password and change manually."
}

Colour-Text 1 "Finished. Log out and back in with $NewUserName"
Read-Host "Press enter to exit... "
