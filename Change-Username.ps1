<#
    .SYNOPSIS
      Change username, user home directory, and password

    .DESCRIPTION
      This script takes the name of a user that exists, and the name to change it to
      The user will be prompted to enter a password to set for the new username
      The home directory is changed to C:\Users\{new username}
      If any stage other than password fails, the previous changes will be reverted.
#>
using namespace Classes
[CmdletBinding()]
param(
  $OldUserName = $env:UserName,
  [Parameter(Mandatory=$true)]
  $NewUserName,
  [switch]$Password=$False
)

Import-Module SetAdmin -Force
Import-Module Classes -Force
Import-Module ColourText -Force

$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"
$computer = [Computer]::new()
$computer.CreateRestorePoint("Changing username and homedirectory restore point", "MODIFY_SETTINGS")

# Elevate Priveleges
As-Admin $Path "Change-Username.ps1" "-OldUserName", $OldUserName, "-NewUserName", $NewUserName, $(if($Password.IsPresent) {"-Password"} else {""})


$user = [LocalUser]::new($OldUserName)
Colour-Text 1 "Beginning user-migration sequence for Username: $OldUserName SID: $($user.GetSID()), one moment..."

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
if($Password.IsPresent)
{
  try {
    $Pass = Read-Host "Enter Password" -AsSecureString
    $user.SetPassword($Pass)
  }
  catch{
    throw "Failed to update password. Login with old password and change manually."
  }
}

Colour-Text 1 "Finished. Log out and back in with $NewUserName"
Read-Host "Press enter to exit... "
