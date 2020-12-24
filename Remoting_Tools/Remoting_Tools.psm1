function Get-UserSession {
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
    Param (
        [Parameter (
            Mandatory = $true
        )]
        [string] $ComputerName,

        [Parameter (
            Mandatory = $true
        )]
        [int] $ID,

        [switch] $Control
    )

    Try {
        if ($Control) {
            mstsc.exe /v:$ComputerName /Shadow:$ID /Control
        }
        else {
            mstsc.exe /v:$ComputerName /Shadow:$ID
        }
    }
    Catch [System.Management.Automation.RemoteException] {
        Write-Warning "Machine is either not online or unreachable."
    }
}
