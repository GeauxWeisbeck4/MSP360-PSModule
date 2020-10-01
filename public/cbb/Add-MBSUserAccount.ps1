function Add-MBSUserAccount {
    <#
    .SYNOPSIS
    Login backup agent with MBS user credentials or Windows authentication.
    
    .DESCRIPTION
    The cmdlet uses to login backup agent to MBS with MBS user credentials or with simple Windows authentication mode.
    
    .PARAMETER User
    MBS User account name
    
    .PARAMETER Password
    MBS User account password

    .PARAMETER SSL
    Use SSL for user backup storages. 
    
    .PARAMETER WindowsAuth
    Use Windows authorization
    
    .PARAMETER WindowsAuthDirectMode
    Use Windows authorization (direct mode)
    
    .PARAMETER ADBridgeEndpoint
    Active Directory Bridge endpoint
    
    .PARAMETER MasterPassword
    Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string "Your_Password" -AsPlainText -Force)
    
    .EXAMPLE
    PS C:\> Add-MBSUserAccount -User backupuser -Password (ConvertTo-SecureString -string 'My_Password' -AsPlainText -Force)

    Login with MBS backup user.
    
    .EXAMPLE
    PS C:\> Add-MBSUserAccount -User backupuser -Password (ConvertTo-SecureString -string 'My_Password' -AsPlainText -Force) -SSL $false

    Login with MBS backup user and disable using SSL for backup storages.

    .EXAMPLE
    PS C:\> Add-MBSUserAccount -WindowsAuth -ADBridgeEndpoint http://ADBRIDGE-PC:8900/ADGateway/Service/

    Login using Windows authentication.

    .EXAMPLE
    PS C:\> Add-MBSUserAccount -WindowsAuthD

    Login using Windows authentication in direct mode.

    .INPUTS
        None

    .OUTPUTS
        String

    .NOTES
        Author: Alex Volkov

    .LINK
        https://kb.msp360.com/managed-backup-service/powershell-module/cmdlets/backup-agent/add-mbsuseraccount
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="MBS User account name", ParameterSetName='MBSUser')]
        [String]
        $User,
        [Parameter(Mandatory=$true, HelpMessage="MBS User account password. Use -Password (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='MBSUser')]
        [SecureString]
        $Password,
        [Parameter(Mandatory=$false, HelpMessage="Use SSL.", ParameterSetName='MBSUser')]
        [Nullable[boolean]]
        $SSL,
        [Parameter(Mandatory=$true, HelpMessage="Use Windows authorization", ParameterSetName='WindowsAuth')]
        [Switch]
        $WindowsAuth,
        [Parameter(Mandatory=$false, HelpMessage="Use Windows authorization (direct mode)", ParameterSetName='WindowsAuthDirectMode')]
        [Switch]
        $WindowsAuthDirectMode,
        [Parameter(Mandatory=$true, HelpMessage="Active Directory Bridge endpoint", ParameterSetName='WindowsAuth')]
        [String]
        $ADBridgeEndpoint,
        [Parameter(Mandatory=$false, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='MBSUser')]
        [Parameter(Mandatory=$false, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='WindowsAuth')]
        [Parameter(Mandatory=$false, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='WindowsAuthDirectMode')]
        [SecureString]
        $MasterPassword
    )
    
    begin {
        if (-not($CBB = Get-MBSAgent)) {
            Break
        }
        try {
            if ((Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -ne "" -and (Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -ne $null -and -not $MasterPassword) {
                $MasterPassword = Read-Host Master Password -AsSecureString
            }
        }
        catch {
            
        }
    }
    
    process {
        function Set-Argument {
            if ($User){$Argument += " -e $User"}
            if ($Password){$Argument += " -p """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))+""""}
            if ($WindowsAuth){$Argument += " -winauth"}
            if ($null -ne $SSL){
                if ($SLL) {
                    $Argument += " -ssl yes"
                }else{
                    $Argument += " -ssl no"
                }
            }
            if ($WindowsAuthDirectMode){$Argument += " -winauthD"}
            if ($ADBridgeEndpoint){$Argument += " -adep $ADBridgeEndpoint"}
            if ($MasterPassword){$Argument += " -mp """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterPassword)))+""""}
                
            return $Argument
        }

        if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent){
            $Arguments = 'addaccount -output full'
        }else{
            $Arguments = 'addaccount -output short'
        }
        $Arguments += Set-Argument
        $Result = (Start-MBSProcess -CMDPath (Get-MBSAgent).CBBCLIPath -CMDArguments $Arguments -Output json).stdout.replace("Content-Type: application/json; charset=UTF-8","") | ConvertFrom-Json
        if ($Result.Result -eq "Success") {
            #$Result.Messages | Out-String -stream | Write-Output
        } else {
            if ('' -ne $Result.Warnings) {
                Write-Warning -Message $Result.Warnings[0]
            } 
            if ('' -ne $Result.Errors) {
                Write-Error -Message $Result.Errors[0] 
            }
        }
    }
    
    end {
        
    }
}