<#
    .SYNOPSIS
      Add or Remove a user from the Administrators group

    .DESCRIPTION
      This script will add or remove $Username from the Administrators group based on the value of $Admin
#>
function Set-Admin {
  param(
    [Parameter(
      Mandatory=$true,
      Position=0
    )]
    [string]
    $Username,
    [Parameter(
      Mandatory=$true,
      Position=1
    )][bool]
    $Admin
  )
  if($Admin -eq $true)
  {
    Add-LocalGroupMember -Group "Administrators" -Member $Username -ErrorAction Stop | Out-Null
  }
  else
  {
    Remove-LocalGroupMember -Group "Administrators" -Member $Username -ErrorAction Stop
  }
}

Export-ModuleMember -Function 'Set-Admin'
