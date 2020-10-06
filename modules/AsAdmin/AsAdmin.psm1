<#
    .SYNOPSIS
      Elevates to admin priveleges and executes the calling script

    .DESCRIPTION
      This script takes the base directory as well as the filename of the calling script
      any additional parameters sent to it are concatenated into the set of arguments
      to pass to the script upon execution
#>
function As-Admin {
  param(
    [Parameter(
      Mandatory=$True,
      Position=0
    )]
    [string]
    $Path,
    [Parameter(
      Mandatory=$True,
      Position=1
    )][string]
    $File,
    [Parameter(
        Mandatory=$True,
        ValueFromRemainingArguments=$True,
        Position = 2
    )][string[]]
    $ListArgs
  )
  $Arguments = $ListArgs -join " "

  if (
    !([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  )
  {
      Start-Process powershell.exe "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$Path\$File`" $Arguments" -Verb RunAs;
      exit;
  }
}

Export-ModuleMember -Function 'As-Admin'
