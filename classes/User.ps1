class User {
    [string] $_username                  #0x01
    [string] $_homedir                   #0x02
    [string] $_sid                       #0x04
    [Security.SecureString] $_password   #0x08
    [int] $UpdateFlag
    $FlagTable = @{
        0x01  = $this.SaveUsername #USERNAME
        0x02  = $this.SaveHomeDir #HOMEDIR
        0x04  = $this.SaveSID #SID
        0x08  = $this.SavePassword #PASSWORD
    }
    $LastValue = @{
        'Username'  = $NULL
        'HomeDir'   = $NULL
        'SID'       = $NULL
        'Password'  = $NULL
    }
    hidden UpdateFlags([int] $UF)
    {
      foreach($UpdatedFlag in $this.FlagTable.Keys | Sort-Object){
        # Check if flag is already set
        if($UF -band $UpdatedFlag -ne 0){
            $this.UpdateFlag -band $UpdatedFlag
        }
      }
    }

    hidden SaveUsername()
    {
      try {
        Rename-LocalUser -Name $this.LastValue.Username -NewName $this.Username -ErrorAction Stop
      } catch {
        Write-Output "Failed to update $($this.LastValue.Username) to $($this.Username)"
      }
    }

    hidden SaveHomeDir()
    {
      Rename-Item $this.LastValue.HomeDir $this.HomeDirectory -ErrorAction Stop
      Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($this.SID)" -Name 'ProfileImagePath' -value "C:\Users\$($this.Username)" -ErrorAction Stop
    }

    hidden SavePassword()
    {

    }

    hidden Init([string] $UN, [string] $HD, [string] $S, [Security.SecureString] $P)
    {
      $this | Add-Member -Name Username -MemberType ScriptProperty -Value {
          # This is the getter
          return $this._username
      } -SecondValue {
          param($value)
          # This is the setter
          $this.LastValue.Username = $this._username
          $this._username = $value
      }
      $this | Add-Member -Name HomeDirectory -MemberType ScriptProperty -Value {
          # This is the getter
          return $this._homedir
      } -SecondValue {
          param($value)
          # This is the setter
          $this.LastValue.HomeDir = $this._homedir
          $this._homedir = $value
      }
      $this | Add-Member -Name SID -MemberType ScriptProperty -Value {
          # This is the getter
          return $this._sid
      } -SecondValue {
          param($value)
          # This is the setter
          $this.LastValue.SID = $this._sid
          $this._sid = $value
      }
      $this | Add-Member -Name Password -MemberType ScriptProperty -Value {
          # This is the getter
          return $this._password
      } -SecondValue {
          param($value)
          # This is the setter
          $this.LastValue.Password = $this._password
          $this._password = $value
      }
      
      $this.Username = $UN
      $this.HomeDir = $HD
      $this.SID = $S
      $this.Password = $P
      $this.UpdateFlag = 0
    }

    User ([string] $UN, [string] $HD, [string] $S, [Security.SecureString] $P){
      $this.Init($UN, $HD, $S, $P)
    }

    User ([string] $UN, [string] $HD, [string] $S){
      $this.Init($UN, $HD, $S, $NULL)
    }

    User ([string] $UN, [string] $HD){
      $this.Init($UN, $HD, $NULL, $NULL)
    }

    User([string] $UN){
      $this.Init($UN, $NULL, $NULL, $NULL)
    }

    User()
    {
      $this.Init()
    }

    [void]SetUsername([string]$UN)
    {
      $this.LastValue.Username = $this.Username
      $this.Username = $UN
      $this.UpdateFlag(1)
    }

    [void]SetSID([string]$SID)
    {
      $this.LastValue.SID = $this.SID
      $this.SID = $SID
      $this.UpdateFlag(4)
    }

    [void]SetHomeDirectory($HD)
    {
      $this.LastValue.HomeDir = $this.HomeDirectory
      $this.HomeDirectory = $HD
      $this.UpdateFlag(2)
    }

    [void]SetPassword([Security.SecurePassword]$P)
    {
      $this.LastValue.Password = $this.Password
      $this.Password = $P
      $this.UpdateFlag(8)
    }

    [void]Save()
    {
      foreach($Flag in $this.FlagTable.Keys | Sort-Object){
        # Check if flag is already set
        if($this.UpdateFlag -band $Flag -ne 0){
            $this.UpdateFlag -band $UpdatedFlag
        }
      }
    }
}
