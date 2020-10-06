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
Import-Module -Name "$Path\modules\AsAdmin" #-Verbose
Import-Module -Name "$Path\modules\ColourText"
# Elevate Priveleges
As-Admin $Path "Change-Username.ps1" "-OldUserName", $OldUserName, "-NewUserName", $NewUserName

$Password = Read-Host "Enter Password" -AsSecureString

# Generate additional variables
$UserSID = (New-Object System.Security.Principal.NTAccount($OldUserName)).Translate([System.Security.Principal.SecurityIdentifier]).value
$UserHomeDir =  (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID\").ProfileImagePath
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID\"

# Change currently set username to $NewName
function Change-Username($OldName, $NewName) {
  Colour-Text 2 "Changing $OldName to $NewName one moment..."
  Rename-LocalUser -Name $OldName -NewName $NewName -ErrorAction Stop
}

# Change currently set home directory to $NewDir
function Change-HomeDirectory($OldDir, $NewDir) {
  Colour-Text 2 "Changing $OldDir to $NewDir, one moment..."
  Rename-Item $OldDir $NewDir -ErrorAction Stop
}

# Update path to users home directory in registry by appending $UserName to C:\Users\
function Update-Registry($SID, $UserName) {
  Colour-Text 2 "Updating $UserName's home directory in Registry, one moment..."
  Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID" -Name 'ProfileImagePath' -value "C:\Users\$UserName" -ErrorAction Stop
}

# Update the users password
function Change-Password($UserName, $Pass) {
  Colour-Text 2 "Updating $UserName's password, one moment..."
  Set-LocalUser -Name $UserName -Password $Pass -ErrorAction Stop
}

Colour-Text 2 "Beginning user-migration sequence for Username: $OldUserName SID: $UserSID, one moment..."

# Verify the user profile exists in registry
if(Test-Path $RegistryPath)
{
  try {
    Change-Username $OldUserName $NewUserName
  }
  catch
  {
    throw "Failed to locate or rename old user"
  }
  try {
    Change-HomeDirectory $UserHomeDir "C:\Users\$NewUserName"
  }
  catch
  {
    # Revert changes
    Change-Username $NewUserName $OldUserName
    throw "Failed to change users home directory, reverting changes."
  }
  try {
    Update-Registry $UserSID $NewUserName
  }
  catch {
    # Revert changes
    Change-Username $NewUserName $OldUserName
    Change-HomeDirectory "C:\Users\$NewUserName" $UserHomeDir
    throw "Failed to update registry with new home directory, reverting changes."
  }
  try {
    Change-Password $NewUserName $Password
  }
  catch{
    throw "Failed to update password. Login with old password and change manually."
  }
  Colour-Text 1 "Finished. Log out and back in with $NewUserName"
}
else
{
  Colour-Text 3 "Unable to locate user: $OldUserName SID: $UserSID in the registry. Please investigate."
}

Colour-Text 2 "Press enter to exit... "
