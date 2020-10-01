function Get-MBSAPILicense {
    <#
    .SYNOPSIS
    List MBS licenses
    
    .DESCRIPTION
    Calls GET request to api/Licenses
    
    .PARAMETER ID
    License ID
    
    .PARAMETER ProfileName
    Profile name used with MSP360 PowerShell for MBS API (set via Set-MBSApiCredential)
    
    .EXAMPLE
    Get-MBSAPILicense -ProfileName profile

    List all licenses.

    .EXAMPLE
    Get-MBSAPILicense -ID ec315596-ab48-4360-aee4-e725b5746a42 -ProfileName profile

    Get license details by specific license ID
    
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
        #
        [Parameter(Mandatory=$false, HelpMessage="License ID", ValueFromPipelineByPropertyName, ValueFromPipeline=$true)]
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
            Write-Verbose -Message ("URL: " + ((Get-MBSApiUrl).Licenses+"/"+$ID))
            Write-Verbose -Message "GET Request"
            #[MBS.API.License[]]
            $Licenses = Invoke-RestMethod -Uri ((Get-MBSApiUrl).Licenses+"/"+$ID) -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }else{
            Write-Verbose -Message ("URL: " + (Get-MBSApiUrl).Licenses)
            Write-Verbose -Message "GET Request"
            #[MBS.API.License[]]
            $Licenses = Invoke-RestMethod -Uri (Get-MBSApiUrl).Licenses -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }
        return $Licenses
    }
    
    end {
        
    }
}
