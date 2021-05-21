<#
    .Synopsis
        Functions to assist with remotely administering a machine
    .NOTES
        Version:        1.0
        Author:         Robert Owens
        Creation Date:  01/05/2021
#>
function Get-UserSession {
<#
        .Synopsis
            Gets user sessions from remote computer.
        .PARAMETER ComputerName
            Name or IP of computer.
        .EXAMPLE
            Get-UserSession -ComputerName Computer1            
    #>

    param (
        [Parameter (
            Mandatory = $true
        )]
        [string] $ComputerName
    )

    $ErrorActionPreference = "Stop"
    Try {
        $Users = query user /server:$ComputerName
        $Users = $Users | ForEach-Object {
            (($_.trim() -replace ">" -replace "(?m)^([A-Za-z0-9]{3,})\s+(\d{1,2}\s+\w+)", '$1  none  $2' -replace "\s{2,}", "," -replace "none", $null))
        } | ConvertFrom-Csv
    }
    Catch [System.Management.Automation.RemoteException] {
        Write-Warning "Machine is either not online or unreachable."
    }

    return $Users
}

function Start-RDPSession {
<#
        .Synopsis
            Initiates an rdp session.
        .PARAMETER ComputerName
            Name or IP of computer.
        .PARAMETER ID
            Session ID of user you wish to shadow.
        .PARAMETER Control
            If specified session will be able to be controlled.
        .EXAMPLE
            Start-RDPSession -ComputerName Computer1            
        .EXAMPLE
            Start-RDPSession -ComputerName Computer2 -ID 1
        .EXAMPLE
            Start-RDPSession -ComputerName Computer2 -ID 1 -Control
    #>

    Param (
        [Parameter (
            Mandatory = $true
        )]
        [string] $ComputerName,

        [Parameter (
            Mandatory = $false
        )]
        [int] $ID = $null,

        [switch] $Control
    )

    Try {
        if ($Control) {
            mstsc.exe /v:$ComputerName /Shadow:$ID /Control
        }
        elseif ($ID){
            mstsc.exe /v:$ComputerName /Shadow:$ID
        }
        else {
            mstsc.exe /v:$ComputerName
        }
    }
    Catch [System.Management.Automation.RemoteException] {
        Write-Warning "Machine is either not online or unreachable."
    }
}
