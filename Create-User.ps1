<#
    .SYNOPSIS
      Create an administrator account

    .DESCRIPTION
      This script will create a user with $Username and add it to the Administrators group
#>
param(
  $Username = "bhewitt",
  $FullName = "Brian Hewitt",
  $Description = "",
  [switch] $Admin = $False,
  [switch] $Enabled = $False
)

Import-Module Classes
Import-Module AsAdmin
Import-Module ColourText

$computer = [Computer]::new()
$computer.CreateRestorePoint("Creating user: $Username restore point", "MODIFY_SETTINGS")

$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"

# Elevate to admin priveleges
As-Admin $Path "Create-User.ps1" "-Username", $Username, "-FullName", $FullName, $(If($Admin.IsPresent) { "-Admin" } Else { "" })
$Password = Read-Host "Enter Password" -AsSecureString

Colour-Text 1 "Creating user $Username, one moment..."

$user = [LocalUser]::new($Username, $Password)
$user.SetFullName($FullName)
$user.SetDescription($Description)
if($Enabled) { $user.Enable() } else { $user.Disable() }
if($Admin.IsPresent) {
  Colour-Text 1 "Adding $Username to the Administrators group"
  $user.GrantAdmin()
}
Colour-Text 1 "Finished. Log out and back in with $Username"

Read-Host "Press enter to exit... "
