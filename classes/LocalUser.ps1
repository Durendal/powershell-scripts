 Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

Import-Module -Name "$Path\modules\SetAdmin" #-Verbose

class LocalUser {
  [object] $_self
  [string] $_registry

  # Pull an existing user constructor
  LocalUser([string] $Identifier){
    try {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        $this._self = Get-LocalUser -SID $Identifier -ErrorAction Stop
      } else {
        $this._self = Get-LocalUser -Name $Identifier -ErrorAction Stop
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

  # Create a new user constructor
  LocalUser([string] $Username, [System.Security.SecureString] $Password) {
    New-LocalUser -Name $Username -Password $Password -ErrorAction Stop
    LocalUser($Username)
  }

  [string] GetUsername() {
    return $this._self.Name
  }

  [string] GetSID() {
    return $this._self.SID.Value
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
      $this._self = Get-LocalUser -SID $this.GetSID()
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
    $this._self = $NULL
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

  [string] GetAccountExpires() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty AccountExpires)
  }

  [string] GetLastLogon() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty LastLogon)
  }

  [string] GetPasswordChangeableDate() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordChangeableDate)
  }

  [string] GetPasswordExpires() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordExpires)
  }

  [string] GetPasswordLastSet() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordLastSet)
  }

  [bool] GetPasswordRequired() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PasswordRequired)
  }

  [string] GetPrincipalSource() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty PrincipalSource)
  }

  [bool] GetUserMayChangePassword() {
    return $(Get-LocalUser -Name $this.GetUsername() | select -ExpandProperty UserMayChangePassword)
  }

}
