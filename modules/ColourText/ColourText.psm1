<#
    .SYNOPSIS
      Outputs coloured text

    .DESCRIPTION
      Takes a message type -  1: Info
                              2: Debug
                              3: Warning
                              4: Error
      and a message to print
#>
function Colour-Text {
  param(
    [Parameter(
      Mandatory=$true,
      Position=0
    )]
    [int]
    $MsgType,
    [Parameter(
      Mandatory=$true,
      Position=1
    )][string]
    $Msg
  )
  switch($MsgType)
  {
    1 {
      Write-Color -Text "[", "+", "]", " - $Msg" -Color DarkCyan,Green,DarkCyan,Green
    }
    2 {
      Write-Color -Text "[", "*", "]", " - $Msg" -Color DarkCyan,Blue,DarkCyan,White
    }
    3 {
      Write-Color -Text "[", "-", "]", " - $Msg" -Color DarkCyan,Yellow,DarkCyan,White
    }
    4 {
      Write-Color -Text "[", "x", "]", " - $Msg" -Color DarkCyan,Red,DarkCyan,Red
    }
  }
}

Export-ModuleMember -Function 'Colour-Text'
