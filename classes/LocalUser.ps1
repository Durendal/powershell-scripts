 Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

Import-Module -Name "$Path\modules\SetAdmin" #-Verbose
Import-Module -Name "$Path\classes\LocalGroup.ps1" -Verbose

class LocalUser {
  [object] $SID
  [string] $_registry

  hidden [void] Init($Identifier) {
    try {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        $this.SID = $(Get-LocalUser -SID $Identifier -ErrorAction Stop).SID
      } else {
        $this.SID = $(Get-LocalUser -Name $Identifier -ErrorAction Stop).SID
      }
    }
    catch #[Microsoft.PowerShell.Commands.NotFoundException], [Microsoft.PowerShell.Commands.UserNotFoundException]
    {
      #Write-Host $error[0].exception
      #Write-Host $error[4] | (Select –Property *)
      Write-Host $Error[0] | fl * -Force
      Write-Host $_.Exception.GetType().Name
      Write-Host $error[0].exception.gettype().fullname
      Exit
    }

    $this._registry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($this.GetSID())"
  }

  # Pull an existing user constructor
  LocalUser([string] $Identifier){
    $this.Init($Identifier)
  }

  # Create a new user constructor
  LocalUser([string] $Username, [System.Security.SecureString] $Password) {
    New-LocalUser -Name $Username -Password $Password -ErrorAction Stop
    $this.Init($Username)
  }

  [string] GetUsername() {
    return $(Get-LocalUser -SID $this.GetSID()).Name
  }

  [string] GetSID() {
    return $this.SID.Value
  }

  [string] GetHomeDir() {
    return $(Get-ItemProperty -path $this._registry).ProfileImagePath
  }

  [bool] GetIsAdmin() {
    $administratorsAccount = Get-WmiObject Win32_Group -filter "LocalAccount=True AND SID='S-1-5-32-544'"
    $administratorQuery = "GroupComponent = `"Win32_Group.Domain='" + $administratorsAccount.Domain + "',NAME='" + $administratorsAccount.Name + "'`""
    $users = Get-WmiObject Win32_GroupUser -filter $administratorQuery | select PartComponent |where {$_ -match $this.GetUsername()}
    forEach($user in $users) {
      $name = $($user.PartComponent -split ",")[-1]
      $name = $name[6..$($name.Length-2)] -join ""
      if($this.GetUsername() -eq $name)
      {
        return $True
      }
    }
    return $False
  }

  [void] SetUsername([string] $NewName) {
    if($this.GetUsername() -ne $NewName) {
      Rename-LocalUser -Name $this.GetUsername() -NewName $NewName -ErrorAction Stop
    }
  }

  [void] SetHomeDir([string] $DirName) {
    if($this.GetHomeDir() -ne $DirName){
      Rename-Item $this.GetHomeDir() $DirName -ErrorAction Stop
      Set-Itemproperty -path $this._registry -Name 'ProfileImagePath' -value $DirName -ErrorAction Stop
    }
  }

  [void] SetAdmin([bool] $IsAdmin) {
    if(!$this.GetIsAdmin() -eq $IsAdmin){
      Set-Admin $this.GetUsername() $IsAdmin
    }
  }

  [void] AddToGroup([object] $Group) {
    $Group.AddMember($this.GetUsername())
  }

  [void] AddToGroup([string] $GroupName) {
    $this.AddToGroup([LocalGroup]::new($GroupName))
  }

  [void] RemoveFromGroup([object] $Group) {
    $Group.RemoveMember($this.GetUsername())
  }

  [void] RemoveFromGroup([string] $GroupName) {
    $this.RemoveFromGroup([LocalGroup]::new($GroupName))
  }

  [void] GrantAdmin() {
    $this.SetAdmin($True)
  }

  [void] RevokeAdmin() {
    $this.SetAdmin($False)
  }

  [void] SetPassword([Security.SecureString] $Password) {
    Get-LocalUser -Name $this.GetUsername() | Set-LocalUser -Password $Password -ErrorAction Stop
  }

  [void] SetPassword([string] $Password) {
    $this.SetPassword($(ConvertTo-SecureString $Password -AsPlainText -Force))
  }

  [void] Remove() {
    Get-LocalUser -Name $this.GetUsername() | Remove-LocalUser
  }

  [bool] IsEnabled() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty Enabled)
  }

  [void] Enable() {
    if(!$this.IsEnabled()){
      Get-LocalUser -Name $this.GetUsername() | Enable-LocalUser
    }
  }

  [void] Disable() {
    if($this.IsEnabled()) {
      Get-LocalUser -Name $this.GetUsername() | Disable-LocalUser
    }
  }

  [string] GetFullName() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty FullName)
  }

  [void] SetFullName([string] $FullName) {
    Get-LocalUser -Name $this.GetUsername() | Set-LocalUser -FullName $FullName
  }

  [string] GetDescription() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty Description)
  }

  [void] SetDescription([string] $Description) {
    Get-LocalUser -Name $this.GetUsername() | Set-LocalUser -Description $Description
  }

  [System.Nullable[datetime]] GetAccountExpires() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty AccountExpires)
  }

  [System.Nullable[datetime]] GetLastLogon() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty LastLogon)
  }

  [System.Nullable[datetime]] GetPasswordChangeableDate() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordChangeableDate)
  }

  [System.Nullable[datetime]] GetPasswordExpires() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordExpires)
  }

  [System.Nullable[datetime]] GetPasswordLastSet() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordLastSet)
  }

  [bool] GetPasswordRequired() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordRequired)
  }

  #[System.Nullable[PrincipalSource]] GetPrincipalSource() {
  [string] GetPrincipalSource() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PrincipalSource)
  }

  [bool] GetUserMayChangePassword() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty UserMayChangePassword)
  }

}
