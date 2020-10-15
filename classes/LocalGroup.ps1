Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

class LocalGroup {
  [object] $_SID
  hidden [void] Init([string] $Identifier, [string] $Description) {
    if($Description.Length > 0) {
      New-LocalGroup -Name $Identifier -ErrorAction Stop
      $this._SID = $(Get-LocalGroup -Name $Identifier).SID
    } else {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        $this._SID = $(Get-LocalGroup -SID $Identifier).SID
      } else {
        $this._SID = $(Get-LocalGroup -Name $Identifier).SID
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

}
