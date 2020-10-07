<#
    .SYNOPSIS
      Create an administrator account

    .DESCRIPTION
      This script will create a user with $Username and add it to the Administrators group
#>
param(
  $Username = "bhewitt",
  $FullName = "Brian Hewitt",
  [switch] $Admin = $False
)

# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-2)] -join "\"

Import-Module -Name "$Path\modules\AsAdmin" #-Verbose
Import-Module -Name "$Path\modules\SetAdmin" #-Verbose
Import-Module -Name "$Path\modules\ColourText"

# Elevate to admin priveleges
As-Admin $Path "Create-User.ps1" "-Username", $Username, "-FullName", $FullName, $(If($Admin.IsPresent) { "-Admin" } Else { "" })
$Password = Read-Host "Enter Password" -AsSecureString
Colour-Text 1 "Creating user $Username, one moment..."
New-LocalUser -Name $Username -Password $Password -FullName $FullName -ErrorAction Stop | Out-Null
if($Admin.IsPresent) {
  Colour-Text 1 "Adding $Username to the Administrators group"
  Set-Admin $Username $True
}
Colour-Text 1 "Finished. Log out and back in with $Username"

Read-Host "Press enter to exit... "
