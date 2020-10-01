function Get-MBSAPIUser {
    
    <#
    .SYNOPSIS
        Get backup user list.
    .DESCRIPTION
        Calls the GET request to https://api.mspbackups.com/api/Users. 
    
    .PARAMETER ID
        MBS User ID. Specify to filter by MBS User ID.

    .PARAMETER ProfileName
	    Profile name used with MSP360 PowerShell for MBS API (set via Set-MBSApiCredential)

    .EXAMPLE
        PS C:\> Get-MBSAPIUser | ft
        
        Get all MBS users and format output as table

    .EXAMPLE
        PS C:\> Get-MBSAPIUser -ID 6970973d-e245-4bbf-a766-dc65a96549c9
        
        Get MBS users with ID 6970973d-e245-4bbf-a766-dc65a96549c9
    .INPUTS
        None

    .OUTPUTS
        MBS.API.User

    .NOTES
        Author: Alex Volkov

    .LINK
        https://kb.msp360.com/managed-backup-service/powershell-module/cmdlets/api/get-mbsapiuser
    #>

    

    [CmdletBinding()]
    param (
        #
        [Parameter(Mandatory=$false, HelpMessage="User ID")]
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
            Write-Verbose -Message ("URL: " + ((Get-MBSApiUrl).Users+"/"+$ID))
            Write-Verbose -Message "GET Request"
            #[MBS.API.User[]]
            $Users = Invoke-RestMethod -Uri ((Get-MBSApiUrl).Users+"/"+$ID) -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }else{
            Write-Verbose -Message ("URL: " + (Get-MBSApiUrl).Users)
            Write-Verbose -Message "GET Request"
            #[MBS.API.User[]]
            $Users = Invoke-RestMethod -Uri (Get-MBSApiUrl).Users -Method Get -Headers (Get-MBSAPIHeader -ProfileName $ProfileName)
        }
        return $Users
    }
    
    end {
        
    }
}
