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
            if ((Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -ne "" -and $null -ne (Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -and -not $MasterPassword) {
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
                (Start-MBSProcess -CMDPath $CBB.CBBCLIPath -CMDArguments $Arguments -Output full).result
            }else{
                $Result = Start-MBSProcess -CMDPath $CBB.CBBCLIPath -CMDArguments $Arguments -Output json
                if ($Result.Result -eq "Success") {
                    Write-Verbose "$($PSCmdlet.MyInvocation.MyCommand.Name): $($Result.Messages | Out-String -stream)"
                }
            }
            
        }
    }
    
    end {
    }
}

# SIG # Begin signature block
# MIIbfAYJKoZIhvcNAQcCoIIbbTCCG2kCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAvMeHZ8YkCSnC6
# 6fQH4R9/AsPvaKuBuQTiwPxPro0OK6CCC04wggVmMIIETqADAgECAhEA3VtfmfWb
# K32tKkM2xJo7CjANBgkqhkiG9w0BAQsFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQK
# ExFDT01PRE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNp
# Z25pbmcgQ0EwHhcNMTcxMjE0MDAwMDAwWhcNMjExMjE0MjM1OTU5WjCBqDELMAkG
# A1UEBhMCQ1kxDTALBgNVBBEMBDEwOTUxETAPBgNVBAgMCExlZmNvc2lhMRAwDgYD
# VQQHDAdOaWNvc2lhMRUwEwYDVQQJDAxMYW1wb3VzYXMsIDExJjAkBgNVBAoMHVRy
# aWNoaWxpYSBDb25zdWx0YW50cyBMaW1pdGVkMSYwJAYDVQQDDB1UcmljaGlsaWEg
# Q29uc3VsdGFudHMgTGltaXRlZDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAJC5Ak9MZHfMGygnL9B+2OcFRvnTeYAJPa4tJS/ES3eSBBge9BiBUa6f+QlX
# lIjt+NBD9QrewScUj9EnaguKzc8NFonBJAgT43jD5rCuuj3GljTIHftLDF9vgetf
# 7KUYhwMypqxRP8pLMAuXzIzw5Yxjh1Quy92dZyJYpOuGbz1PQVRMj2fhRqeerP4J
# OiRktwnykjrxDsRNm+Iuas1BM+vjVA7B9Cj0Wf5NsMxSegJezvs0yqwHrsngEQrY
# GXDKHstfsxd8KM5LxJdYN1neIAO8v6AuM6yjQT1z1ZwVSCHu2swNCA3T3M26fkk9
# 9TIZZI/LvfR++FJCUvJkPoPbOKUCAwEAAaOCAbMwggGvMB8GA1UdIwQYMBaAFCmR
# YP+KTfrr+aZquM/55ku9Sc4SMB0GA1UdDgQWBBRqlxdnVxjIxF6fnOYUd7LOYeNe
# rjAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEF
# BQcDAzARBglghkgBhvhCAQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIB
# AwIwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMw
# QwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RP
# UlNBQ29kZVNpZ25pbmdDQS5jcmwwdAYIKwYBBQUHAQEEaDBmMD4GCCsGAQUFBzAC
# hjJodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FDb2RlU2lnbmluZ0NB
# LmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMCQGA1Ud
# EQQdMBuBGWNvbnRhY3RAY2xvdWRiZXJyeWxhYi5jb20wDQYJKoZIhvcNAQELBQAD
# ggEBAEeInauUdqKYV4ncwGMqz5+frptASCXVnCMLI7j3JK0KCzmJkwHHmkIk3P0A
# Rzedj5+1aFuXANtT42IACVf00tqq0IHO2KT2vHHJHNnx3ht6kMcCmKmUlnkZMjEK
# +0WJD0JSP7lBRQBf5QJpDLmpbBTVvlbe/3nzpUZ95O5reaPekoQ1xC4Ossu06ba0
# djKhwk0HgeqZz7ZruWOVY/YRDfnlZ3it5+4Ck2JTXIVcUcXzT/ZdwNTkUiIqmh4T
# HwOj+k/Yej7Q13ILWTNZMELs3Iec6FSSGXUijHV65pPI0dUXnq8pWYMfutgwlBaL
# 78yXl4ihf46TXsnAMottH+ld8lAwggXgMIIDyKADAgECAhAufIfMDpNKUv6U/Ry3
# zTSvMA0GCSqGSIb3DQEBDAUAMIGFMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3Jl
# YXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01P
# RE8gQ0EgTGltaXRlZDErMCkGA1UEAxMiQ09NT0RPIFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0xMzA1MDkwMDAwMDBaFw0yODA1MDgyMzU5NTlaMH0xCzAJ
# BgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcT
# B1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSMwIQYDVQQDExpD
# T01PRE8gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAKaYkGN3kTR/itHd6WcxEevMHv0xHbO5Ylc/k7xb458eJDIRJ2u8
# UZGnz56eJbNfgagYDx0eIDAO+2F7hgmz4/2iaJ0cLJ2/cuPkdaDlNSOOyYruGgxk
# x9hCoXu1UgNLOrCOI0tLY+AilDd71XmQChQYUSzm/sES8Bw/YWEKjKLc9sMwqs0o
# GHVIwXlaCM27jFWM99R2kDozRlBzmFz0hUprD4DdXta9/akvwCX1+XjXjV8QwkRV
# PJA8MUbLcK4HqQrjr8EBb5AaI+JfONvGCF1Hs4NB8C4ANxS5Eqp5klLNhw972GIp
# pH4wvRu1jHK0SPLj6CH5XkxieYsCBp9/1QsCAwEAAaOCAVEwggFNMB8GA1UdIwQY
# MBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1UdDgQWBBQpkWD/ik366/mmarjP
# +eZLvUnOEjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNV
# HSUEDDAKBggrBgEFBQcDAzARBgNVHSAECjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBB
# oD+gPYY7aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQ2VydGlmaWNh
# dGlvbkF1dGhvcml0eS5jcmwwcQYIKwYBBQUHAQEEZTBjMDsGCCsGAQUFBzAChi9o
# dHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FBZGRUcnVzdENBLmNydDAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEB
# DAUAA4ICAQACPwI5w+74yjuJ3gxtTbHxTpJPr8I4LATMxWMRqwljr6ui1wI/zG8Z
# wz3WGgiU/yXYqYinKxAa4JuxByIaURw61OHpCb/mJHSvHnsWMW4j71RRLVIC4nUI
# BUzxt1HhUQDGh/Zs7hBEdldq8d9YayGqSdR8N069/7Z1VEAYNldnEc1PAuT+89r8
# dRfb7Lf3ZQkjSR9DV4PqfiB3YchN8rtlTaj3hUUHr3ppJ2WQKUCL33s6UTmMqB9w
# ea1tQiCizwxsA4xMzXMHlOdajjoEuqKhfB/LYzoVp9QVG6dSRzKp9L9kR9GqH1NO
# MjBzwm+3eIKdXP9Gu2siHYgL+BuqNKb8jPXdf2WMjDFXMdA27Eehz8uLqO8cGFjF
# BnfKS5tRr0wISnqP4qNS4o6OzCbkstjlOMKo7caBnDVrqVhhSgqXtEtCtlWdvpnn
# cG1Z+G0qDH8ZYF8MmohsMKxSCZAWG/8rndvQIMqJ6ih+Mo4Z33tIMx7XZfiuyfiD
# FJN2fWTQjs6+NX3/cjFNn569HmwvqI8MBlD7jCezdsn05tfDNOKMhyGGYf6/VXTh
# IXcDCmhsu+TJqebPWSXrfOxFDnlmaOgizbjvmIVNlhE8CYrQf7woKBP7aspUjZJc
# zcJlmAaezkhb1LU3k0ZBfAfdz/pD77pnYf99SeC7MH1cgOPmFjlLpzGCD4Qwgg+A
# AgEBMIGSMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVk
# MSMwIQYDVQQDExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQQIRAN1bX5n1myt9
# rSpDNsSaOwowDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAvBgkqhkiG9w0BCQQxIgQgNQJmPFrKsnmkM+Mg80JqC/OhExx0VwwR4Bzw
# LIsYNeYwDQYJKoZIhvcNAQEBBQAEggEAE+5Ckds8btSM9apWwDfDEMU7x8IZlqI3
# 4Xg+55LvV+Slx+ImbmEu5OZWye6zzs7QhZSSNBIQSU8gt1lat0HyjsqCrDtaBhkQ
# akTCbUUjRKAyM/o36l7Fl1V7IwZ/8oG9e32L9lWBNwJfwhdj4YPKtpo72UKz2Xlo
# Hs+UXoKxaW93LxnycFSahXy7b81hYdYlFYjcCTInXC7iweqO9DufFsmOXm+rCXl+
# Ia5ndOcos9y6/xfjfbvRF9fgDt9idn91vRxg9VH2KwwnHWlNPqqfoK/oSfPrJnkZ
# u8nFK5tvX477xa8SYh7phXitnH/rynPBkFYEebJeu12kiiyFa73R06GCDUQwgg1A
# BgorBgEEAYI3AwMBMYINMDCCDSwGCSqGSIb3DQEHAqCCDR0wgg0ZAgEDMQ8wDQYJ
# YIZIAWUDBAIBBQAwdwYLKoZIhvcNAQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAx
# MA0GCWCGSAFlAwQCAQUABCCXUZtziJ4aO1+W+msdkyD7A4CL8E324bdrh+ZCqa/Z
# rAIQTS3+jLK9x2P+Fn8Z7EFMVxgPMjAyMTAxMjYwODExMzdaoIIKNzCCBP4wggPm
# oAMCAQICEA1CSuC+Ooj/YEAhzhQA8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVz
# dGFtcGluZyBDQTAeFw0yMTAxMDEwMDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGln
# aUNlcnQgVGltZXN0YW1wIDIwMjEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDC5mGEZ8WK9Q0IpEXKY2tR1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpc
# SO9E5b+bYc0VkWJauP9nC5xj/TZqgfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mK
# vfiEXR52yeTGdnY6U9HR01o2j8aj4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3Vobc
# kyON91Al6GTm3dOPL1e1hyDrDo4s1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSv
# FV9sQ0kJ/SYjU/aNY+gaq1uxHTDCm2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL6
# 1mOLTqVyHO6fegFz+BnW/g1JhL0BAgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAE
# OjA4MDYGCWCGSAGG/WwHATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2lj
# ZXJ0LmNvbS9DUFMwHwYDVR0jBBgwFoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYD
# VR0OBBYEFDZEho6kurBmvrwoLR1ENt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAu
# hixodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCB
# hQYIKwYBBQUHAQEEeTB3MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wTwYIKwYBBQUHMAKGQ2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFNIQTJBc3N1cmVkSURUaW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcN
# AQELBQADggEBAEgc3LXpmiO85xrnIA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeB
# pU0UFRkHefDRBMOG2Tu9/kQCZk3taaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOe
# e+e03UEiifuHokYDTvz0/rdkd2NfI1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np7
# 2gy8PTLQG8v1Yfx1CAB2vIEO+MDhXM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS
# +1zgYSQlT7LfySmoc0NR2r1j1h9bm/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/
# Vs+6WXZhiV9+p7SOZ3j5NpjhyyjaW4emii8wggUxMIIEGaADAgECAhAKoSXW1jIb
# fkHkBdo2l8IVMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBa
# Fw0zMTAxMDcxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
# ZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQC90DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQ
# fdD5fU1ofue2oPSNs4jkl79jIZCYvxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9l
# P+Cb6+NGRwYaVX4LJ37AovWg4N4iPw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3I
# mgtU46gJcWvgzyIQD3XPcXJOCq3fQDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDq
# R9mIUF79Zm5WYScpiYRR5oLnRlD9lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZ
# chfxFwbvPc3WTe8GQv2iUypPhR3EHTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIB
# yjAdBgNVHQ4EFgQU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReui
# r/SSy4IxLVGLp6chnfNtyA8wEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8E
# BAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0g
# BEkwRzA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBx
# lRLpUYdWac3v3dp8qmN6s3jPBjdAhO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3
# BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy
# 23UC4HLHmNY8ZOUfSBAYX4k4YU1iRiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWT
# hZN+tpJn+1Nhiaj1a5bA9FhpDXzIAbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZs
# pe6HUSHkWGCbugwtK22ixH67xCUrRwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VW
# MyIvIjayS6JKldj1po5SMYICTTCCAkkCAQEwgYYwcjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
# MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBD
# QQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKCBmDAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIxMDEyNjA4MTEzN1ow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJ
# KoZIhvcNAQkEMSIEIGV1UYJdTNt/QeuZAnhCQU0UnQRxXzlDQseOpB6ON/m0MA0G
# CSqGSIb3DQEBAQUABIIBAHqT9qRlqurUXJBaRtvC7OlsYonnetb0PIh2rFmSuR3U
# WtEueq1hbNzsP1JYNPQj+b5vAYAURBrdMSiNiM3CPoqQXREB0i1G6Maiq1iFo6rM
# 3xi+vX5ngb6ieKGRAPqYFGkpDE/EwFo5/G8mfYDib8L/Bbv5ZkKM3Wy6mLFUL7r6
# OE1HQ4xdxTJk2tiIU8mRBOVMyiOKiv48p7b3oPhF+FzS7SEgO5o448+6lD/x6zHd
# nDI5EKIjee7w4sBDTxCjq6G1+5OgJjY7TrVWybMcnJjJtbnYRZ/hwbLp61vouz+e
# OcoGGKWux96rD1lXSVVvdYz3Jfjblm/PCg5ZfgYMHHo=
# SIG # End signature block
