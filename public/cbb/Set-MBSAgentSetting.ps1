function Set-MBSAgentSetting {
    <#
    .SYNOPSIS
        Change MBS backup agent options
    
    .DESCRIPTION
        Change MBS backup agent options
    
    .PARAMETER Edition
        Specify backup agent edition
    
    .PARAMETER Bandwidth
        Bandwidth for a plan. Possible values: u(unlimited), value in kB
    
    .PARAMETER Proxy
        Proxy type. Possible values: no, auto, manual
    
    .PARAMETER ProxyAddress
        Proxy address
    
    .PARAMETER ProxyPort
        Proxy port
    
    .PARAMETER ProxyAuthentication
        Proxy authentication
    
    .PARAMETER ProxyDomain
        Proxy domain
    
    .PARAMETER ProxyUser
        Proxy user
    
    .PARAMETER ProxyPassword
        Proxy password
    
    .PARAMETER ChunkSize
        Specify chunk size in KBs. Possible values: 1024-5242880
    
    .PARAMETER ThreadCount
        Thread count. Possible values: 1-99
    
    .PARAMETER Purge
        Purge versions that are older than period (except lastest version). Possible values: no, 1d(day), 1w(week), 1m(month)
    
    .PARAMETER DelayPurge
        Specify purge delay. Possible values: no, 1d(day), 1w(week), 1m(month)
    
    .PARAMETER Keep
        Keep limited number of versions. Possible values: all, number
    
    .PARAMETER HistoryPurge
        Purge history records that are older than value. Possible values: no, 1d(day), 1w(week), 1m(month)
    
    .PARAMETER HistoryLimit
        Keep limited number of records in history. Possible values: all, number
    
    .PARAMETER Logging
        Logging level.
    
    .PARAMETER RepositoryLocation
        Change database location. By default database is located in user profile. Database will be moved to specified directory for saving space on system drive or other reasons
    
    .PARAMETER IgnoreSSLValidation
        Ignore SSL validation
    
    .PARAMETER MasterPassword
        Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string "Your_Password" -AsPlainText -Force)
    
    .PARAMETER ProtectCLI
        Use master password to protect CLI
    
    .PARAMETER ConfirmMasterPassword
        Confirm master password. Use -ConfirmMasterPassword (ConvertTo-SecureString -string "Your_Password" -AsPlainText -Force)
    
    .PARAMETER DisableMasterPassword
        Disable GUI/CLI master password protection
    
    .EXAMPLE
        PS C:\> Set-MBSAgentSetting -ThreadCount 10

        Set thread count to 10.

    .EXAMPLE
        PS C:\> Set-MBSAgentSetting -Keep 5 -Logging high

        Change default retention policy to keep 5 versions and set logging level to high.
    
    .EXAMPLE
        PS C:\> Set-MBSAgentSetting -ProtectCLI $true -MasterPassword (ConvertTo-SecureString -string "12345" -AsPlainText -Force)

        Enable CLI protection with master passowrd if it is already enabled for GUI

    .EXAMPLE
        PS C:\> Set-MBSAgentSetting -ProtectCLI $true -MasterPassword (ConvertTo-SecureString -string "12345" -AsPlainText -Force) -ConfirmMasterPassword (ConvertTo-SecureString -string "12345" -AsPlainText -Force)

        Set master password protection for CLI and GUI.

    .EXAMPLE
        Set-MBSAgentSetting -DisableMasterPassword -MasterPassword (ConvertTo-SecureString -string "12345" -AsPlainText -Force)

        Disable GUI/CLI master password protection

    .INPUTS
        None

    .OUTPUTS
        System.String[]
        
    .NOTES
        Author: Alex Volkov

    .LINK
        https://kb.msp360.com/managed-backup-service/powershell-module/cmdlets/set-mbsagentsettings

    #>
    [CmdletBinding()]
    param (
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify backup agent edition.", ParameterSetName='Settings')]
        [ValidateSet("desktop", "baremetal", "mssql", "msexchange", "mssqlexchange", "ultimate", "vmedition")]
        [String]
        $Edition,
        #
        [Parameter(Mandatory=$False, HelpMessage="Bandwidth for a plan. Possible values: u(unlimited), value in kB", ParameterSetName='Settings')]
        [String]
        $Bandwidth,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy type. Possible values: no, auto, manual", ParameterSetName='Settings')]
        [ValidateSet("no", "auto","manual")]
        [String]
        $Proxy,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy address", ParameterSetName='Settings')]
        [String]
        $ProxyAddress,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy port", ParameterSetName='Settings')]
        [Int32][ValidateRange(1,65535)]
        $ProxyPort,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy authentication.", ParameterSetName='Settings')]
        [Nullable[boolean]]
        $ProxyAuthentication,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy domain", ParameterSetName='Settings')]
        [String]
        $ProxyDomain,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy user", ParameterSetName='Settings')]
        [String]
        $ProxyUser,
        #
        [Parameter(Mandatory=$False, HelpMessage="Proxy password", ParameterSetName='Settings')]
        [String]
        $ProxyPassword,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify chunk size in KBs. Possible values: 1024-5242880", ParameterSetName='Settings')]
        [Int32][ValidateRange(5120,5242880)]
        $ChunkSize,
        #
        [Parameter(Mandatory=$False, HelpMessage="Thread count. Possible values: 1-99", ParameterSetName='Settings')]
        [Int32][ValidateRange(1,99)]
        $ThreadCount,
        #
        [Parameter(Mandatory=$False, HelpMessage="Purge versions that are older than period (except lastest version). Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='Settings')]
        [String]
        $Purge,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify purge delay. Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='Settings')]
        [String]
        $DelayPurge,
        #
        [Parameter(Mandatory=$False, HelpMessage="Keep limited number of versions. Possible values: all, number", ParameterSetName='Settings')]
        [String]
        $Keep,
        #
        [Parameter(Mandatory=$False, HelpMessage="Purge history records that are older than value. Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='Settings')]
        [String]
        $HistoryPurge,
        #
        [Parameter(Mandatory=$False, HelpMessage="Keep limited number of records in history. Possible values: all, number", ParameterSetName='Settings')]
        [String]
        $HistoryLimit,
        #
        [Parameter(Mandatory=$False, HelpMessage="Logging level.", ParameterSetName='Settings')]
        [ValidateSet("no", "low","high","debug")]
        [String]
        $Logging,
        #
        [Parameter(Mandatory=$False, HelpMessage="Change database location. By default database is located in user profile. Database will be moved to specified directory for saving space on system drive or other reasons.", ParameterSetName='Settings')]
        [Alias("DatabaseLocation")]
        [String]
        $RepositoryLocation,
        #
        [Parameter(Mandatory=$False, HelpMessage="Ignore SSL validation.", ParameterSetName='Settings')]
        [Nullable[boolean]]
        $IgnoreSSLValidation,
        #
        [Parameter(Mandatory=$False, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='Settings')]
        [Parameter(Mandatory=$true, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='ProtectCLI')]
        [Parameter(Mandatory=$true, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='SetMasterPassword')]
        [Parameter(Mandatory=$true, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='DisableMasterPassword')]
        [SecureString]
        $MasterPassword,
        #
        [Parameter(Mandatory=$true, HelpMessage="Use master password to protect CLI.", ParameterSetName='ProtectCLI')]
        [Parameter(Mandatory=$False, HelpMessage="Use master password to protect CLI.", ParameterSetName='SetMasterPassword')]
        [bool]
        $ProtectCLI = $true,
        #
        [Parameter(Mandatory=$true, HelpMessage="Confirm master password. Use -ConfirmMasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='SetMasterPassword')]
        [SecureString]
        $ConfirmMasterPassword,
        #
        [Parameter(Mandatory=$true, HelpMessage="Disable GUI/CLI master password protection", ParameterSetName='DisableMasterPassword')]
        [switch]
        $DisableMasterPassword
        
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
        if (Get-MBSAgent -ErrorAction SilentlyContinue) {
            if($PsCmdlet.ParameterSetName -eq "Settings"){
                $Arguments = " option"
            }else{
                $Arguments = " consolemanager"
                if ($ProtectCLI){
                    $Arguments += " -mpCLI yes"
                }else{
                    $Arguments += " -mpCLI no"
                }
            }
            
            if ($Edition){$Arguments += " -edition $Edition"}
            if ($Bandwidth){$Arguments += " -bandwidth $Bandwidth"}
            if ($Proxy){$Arguments += " -proxy $Proxy"}
            if ($ProxyAddress){$Arguments += " -pa $ProxyAddress"}
            if ($ProxyPort){$Arguments += " -pp $ProxyPort"}
            if ($ProxyAuthentication){$Arguments += " -pt $ProxyAuthentication"}
            if ($ProxyDomain){$Arguments += " -pd $ProxyDomain"}
            if ($ProxyUser){$Arguments += " -pu $ProxyUser"}
            if ($ProxyPassword){$Arguments += " -ps $ProxyPassword"}
            if ($ChunkSize){$Arguments += " -cs $ChunkSize"}
            if ($ThreadCount){$Arguments += " -threads $ThreadCount"}
            if ($Purge){$Arguments += " -purge $Purge"}
            if ($DelayPurge){$Arguments += " -delayPurge $DelayPurge"}
            if ($Keep){$Arguments += " -keep $Keep"}
            if ($HistoryPurge){$Arguments += " -hp $HistoryPurge"}
            if ($HistoryLimit){$Arguments += " -hk $HistoryLimit"}
            if ($Logging){$Arguments += " -logging $Logging"}

            if ($RepositoryLocation){$Arguments += " -repositoryLocation $RepositoryLocation"}
            if ($IgnoreSSLValidation -ne $null){
                if ($IgnoreSSLValidation) {
                    $Arguments += " -ignoreSSLValidation yes"
                }else{
                    $Arguments += " -ignoreSSLValidation no"
                }
            }

            if ($MasterPassword){
                if($PsCmdlet.ParameterSetName -eq "Settings"){
                    $Arguments += " -mp "
                }elseif($PsCmdlet.ParameterSetName -eq "SetMasterPassword"){
                    $Arguments += " -p "
                }else{
                    $Arguments += " -cp "
                }
                $Arguments += """"+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterPassword)))+""""
            }
            if ($ConfirmMasterPassword){$Arguments += " -c """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConfirmMasterPassword)))+""""}
            
            if ($DisableMasterPassword){$Arguments += " -rmp $Logging"}

            if($PsCmdlet.ParameterSetName -eq "Settings"){
                $Result = (Start-MBSProcess -CMDPath (Get-MBSAgent).CBBCLIPath -CMDArguments $Arguments -Output full).stdout
                $Result -split "`n" | Select-Object -Skip 1
            }else{
                $Result = (Start-MBSProcess -CMDPath (Get-MBSAgent).CBBCLIPath -CMDArguments $Arguments -Output json).stdout.replace("Content-Type: application/json; charset=UTF-8","") | ConvertFrom-Json
                if ($Result.Result -eq "Success") {
                    $Result.Messages | Out-String -stream | Write-Verbose
                } else {
                    if ('' -ne $Result.Warnings) {
                        Write-Warning -Message $Result.Warnings[0]
                    } 
                    if ('' -ne $Result.Errors) {
                        Write-Error -Message $Result.Errors[0] 
                    }
                }
            }
            
        }
    }
    
    end {
    }
}
