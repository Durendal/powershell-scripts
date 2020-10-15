Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

class LocalGroup {
  [object] $_SID
  hidden [void] Init([string] $Identifier, [string] $Description) {
    if($Description.Length -gt 0) {
      New-LocalGroup -Name $Identifier -ErrorAction Stop
      $this._SID = Get-LocalGroup -Name $Identifier | select -ExpandProperty SID
    } else {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        $this._SID = Get-LocalGroup -SID $Identifier | select -ExpandProperty SID
      } else {
        $this._SID = Get-LocalGroup -Name $Identifier | select -ExpandProperty SID
      }
    }
  }

  LocalGroup([string] $Identifier) {
    $this.Init($Identifier, "")
  }

  LocalGroup([string] $Identifier, [string] $Description) {
    $this.Init($Identifier, $Description)
  }

  [object] GetSID() {
    return $this._SID
  }

  [string] GetGroupName() {
    return $(Get-LocalGroup -SID $this.GetSID() | select -ExpandProperty Name)
  }

  [string] GetDescription() {
    return $(Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty Description)
  }

  [string] GetObjectClass() {
    return $(Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty ObjectClass)
  }

  [string] GetPrincipalSource() {
    return $(Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty PrincipalSource)
  }

  [void] AddMember([string] $Username) {
    Add-LocalGroupMember -Name $this.GetGroupName() -Member $Username
  }

  [void] AddMember([object] $User) {
    $this.AddMember($User.GetUsername())
  }

  [void] AddMembers([string[]] $Usernames) {
    forEach($Username in $Usernames) {
      $this.AddMember($Username)
    }
  }

  [void] AddMembers([object[]] $Users) {
    forEach($User in $Users) {
      $this.AddMember($User)
    }
  }

  [void] RemoveMember([string] $Username) {
    Remove-LocalGroupMember -Name $this.GetGroupName() -Member $Username
  }

  [void] RemoveMember([object] $User) {
    $this.RemoveMember($User.GetUsername())
  }

  [void] RemoveMembers([string[]] $Usernames) {
    forEach($Username in $Usernames) {
      $this.RemoveMember($Username)
    }
  }

  [void] RemoveMembers([object[]] $Users) {
    forEach($User in $Users) {
      $this.RemoveMember($User)
    }
  }

  [void] SetDescription([string] $Description) {
    Set-LocalGroup -Name $this.GetGroupName() -Description $Description
  }

  [void] Rename([string] $NewName) {
    Rename-LocalGroup -Name $this.GetGroupName() -NewName $NewName
  }

  [void] Delete() {
    Remove-LocalGroup -Name $this.GetGroupName()
  }

  [string[]] static GetGroups() {
    [string[]] $names = @()
    forEach($group in Get-LocalGroup) {
      $names += $group.Name
    }
    return $names
  }
}
