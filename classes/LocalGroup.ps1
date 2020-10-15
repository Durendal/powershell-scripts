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
        Write-Host $(Get-LocalGroup -SID $Identifier).SID
        $this._SID = $(Get-LocalGroup -SID $Identifier).SID
      } else {
        Write-Host $(Get-LocalGroup -Name $Identifier).SID
        $this._SID = $(Get-LocalGroup -Name $Identifier).SID
      }
    }
  }

  LocalGroup([string] $Identifier) {
    Write-Host "Identifier: $Identifier"
    $this.Init($Identifier, "")
  }

  LocalGroup([string] $Identifier, [string] $Description) {
    Write-Host "Identifier: $Identifier"
    Write-Host "Description: $Description"
    $this.Init($Identifier, $Description)
  }

  [object] GetSID() {
    return $this._SID
  }

  [string] GetGroupName() {
    $s = $this.GetSID()
    Write-Output "SID: $s"
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
