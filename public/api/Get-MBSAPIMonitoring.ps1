function Get-MBSAPIMonitoring {
    <#
    .SYNOPSIS
    Returns a list of monitoring structures that are available to users
    
    .DESCRIPTION
    Calls GET reqest to api/Monitoring
    
    .PARAMETER ID
    User ID
    
    .PARAMETER ProfileName
    Profile name used with MSP360 PowerShell for MBS API (set via Set-MBSApiCredential)
    
    .EXAMPLE
    Get-MBSAPIMonitoring -profile profile | FT

    Get monitored backup plans and format output as a table.

    .EXAMPLE
    Get-MBSAPIMonitoring -ID bf3206df-ad73-4cdc-96ad-d4e3afa66ebc -profile profile | FT

    Get backup plans statuses for the specified user ID and format output as a table.
    
    .INPUTS
    System.Management.Automation.PSCustomObject
    String

    .OUTPUTS
    System.Management.Automation.PSCustomObject
    
    .NOTES
        Author: Alex Volkov
    .LINK

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="User ID", ValueFromPipelineByPropertyName)]
        [string]$ID,
        #
        [Parameter(Mandatory=$false, HelpMessage="The profile name, which must be unique.")]
        [string]
        $ProfileName
    )
    
    begin {
       
    }
    
    process {
        if ($ID) {
            Write-Verbose -Message ("URL: " + ((Get-MBSApiUrl).Monitoring+"/"+$ID))
            Write-Verbose -Message "GET Request"
            #[MBS.API.Monitoring[]]
            $Monitoring = Invoke-RestMethod -Uri ((Get-MBSApiUrl).Monitoring+"/"+$ID) -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }else{
            Write-Verbose -Message ("URL: " + (Get-MBSApiUrl).Monitoring)
            Write-Verbose -Message "GET Request"
            #[MBS.API.Monitoring[]]
            $Monitoring = Invoke-RestMethod -Uri (Get-MBSApiUrl).Monitoring -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }
        return $Monitoring
    }
    
    end {
        
    }
}
