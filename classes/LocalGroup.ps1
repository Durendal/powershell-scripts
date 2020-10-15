Start-Sleep -Milliseconds 1
# Parse root directory
$Path = $MyInvocation.MyCommand.Path -split "\\"
$Path = $Path[0..($Path.Length-3)] -join "\"

class Group {
  [object] $SID

  Group([string] $Identifier, [string] $Description="") {
    try {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        $this.SID = $(Get-LocalGroup -SID $Identifier -ErrorAction Stop).SID
      } else {
        $this.SID = $(Get-LocalGroup -Name $Identifier -ErrorAction Stop).SID
      }
    }
    catch
    {
      if($(Select-String -Pattern 'S-\d-(?:\d+-){1,14}\d+' -InputObject $Identifier).Matches) {
        throw "Invalid group name"
      } else {
        New-LocalGroup -Name $Identifier -Description $Description -ErrorAction Stop
        $this.SID = $(Get-LocalGroup -Name $Identifier -ErrorAction Stop).SID
      }
    }
  }

  [string] GetSID() {
    return $this.SID.Value
  }

  [string] GetGroupName() {
    return Get-LocalGroup -SID $this.GetSID() | select -ExpandProperty Name
  }

  [string] GetDescription() {
    return Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty Description
  }

  [string] GetObjectClass() {
    return Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty ObjectClass
  }

  [string] GetPrincipalSource() {
    return Get-LocalGroup -Name $this.GetGroupName() | select -ExpandProperty PrincipalSource
  }

}
