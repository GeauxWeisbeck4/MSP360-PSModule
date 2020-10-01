function Get-MBSAPIUserComputer {
    <#
    .SYNOPSIS
    Lists backed up computers.
    
    .DESCRIPTION
    Calls GET request to api/Users/{userid}/Computers
    
    .PARAMETER ID
    Backup User ID
    
    .PARAMETER ProfileName
    Profile name used with MSP360 PowerShell for MBS API (set via Set-MBSApiCredential)
    
    .EXAMPLE
    Get-MBSAPIUserComputer -ID 7c7044bb-313b-4b1b-900e-76d652246f4d -ProfileName profile
    
    .INPUTS
    System.Management.Automation.PSCustomObject

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
        Author: Alex Volkov
    .LINK

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="ID", ValueFromPipelineByPropertyName, ValueFromPipeline=$true)]
        [string]$ID,
        #
        [Parameter(Mandatory=$false, HelpMessage="The profile name, which must be unique.")]
        [string]
        $ProfileName
    )
    
    begin {
        
    }
    
    process {
        Write-Verbose -Message ("URL: " + ((Get-MBSApiUrl).Users+"/"+$ID+"/Computers"))
        Write-Verbose -Message "GET Request"
        #[MBS.API.UserComputer[]]
        $Computers = Invoke-RestMethod -Uri ((Get-MBSApiUrl).Users+"/"+$ID+"/Computers") -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        $Computers | Add-Member -MemberType NoteProperty -Name UserID -Value $ID
        return $Computers
    }
    
    end {
        
    }
}
