function Add-WFUMonitoringJob {
    <#
    .SYNOPSIS
        Add status monitoring task to windows task scheduler for Windows Firewall, Windows Defender, Third party antivirus, and Windows Update Services.
    .DESCRIPTION
        Admin permissions are required.
    .EXAMPLE
        Add monitoring task with default options. Specify mandatory parameters only.

        PS C:\> .\Add-WFUMonitoringJob.ps1 `
        -JobUserName "Domain\MyUser" `
        -JobUserPwd 'MyUserPassword' `
        -MessageFrom "My_email@gmail.com" `
        -MessageTo "My_email@gmail.com" `
        -MessageSMTPServer "smtp.gmail.com" `
        -MessagePort 587 `
        -MessageUseSSL $true `
        -MessageUserName "My_email@gmail.com" `
        -MessageCredsPassword 'MyEmailPassword'
    .EXAMPLE
        Add monitoring task for Windows Firewall, Windows Defender and Windows Update services only.

        PS C:\> .\Add-WFUMonitoringJob.ps1 `
        -JobName "Monitoring Windows Security services" `
        -JobUserName "domain\user" `
        -JobUserPwd 'MyUserPassword' `
        -MessageFrom "My_email@gmail.com" `
        -MessageTo "My_Email@gmail.com" `
        -MessageSubject "Security Alert" `
        -MessageSMTPServer smtp.gmail.com `
        -MessagePort 587 `
        -MessageUseSSL $true `
        -MessageUserName "My_email@gmail.com" `
        -MessageCredsPassword 'MyEmailPassword' `
        -IsFirewallMonitored $true `
        -IsWindowsDefenderMonitored $true `
        -Is3PartyAntivirusMonitored $False `
        -IsWindowsUpdateMonitored $True `
        -WindowsUpdateNotificationLevel 3 `
        -MonitoringJobSchedule (New-ScheduledTaskTrigger -At 07:00:00 -Daily) 
    .INPUTS
        None
    .OUTPUTS
        Microsoft.Management.Infrastructure.CimInstance#Root/Microsoft/Windows/TaskScheduler/MSFT_ScheduledTask
    .NOTES
        Author: Alex Volkov
    .LINK

    #>
    [CmdletBinding()]
    param (
        # Task scheduler monitoring job name
        [Parameter(Mandatory=$False)]
        [string]$JobName = "Monitor Windows Security services" ,
        # Local admin username.
        [Parameter(Mandatory=$True)]
        [string]$JobUserName,
        # Local admin password
        [Parameter(Mandatory=$True)]
        [string]$JobUserPwd,
        # Sender email address
        [Parameter(Mandatory=$True)]
        [string]$MessageFrom,
        # Recepient email address
        [Parameter(Mandatory=$True)]
        [string]$MessageTo,
        # Email subject
        [Parameter(Mandatory=$False)]
        [string]$MessageSubject = "Security Alert",
        # SMTP server address
        [Parameter(Mandatory=$True)]
        [string]$MessageSMTPServer,
        # SMTP server port
        [Parameter(Mandatory=$True)]
        [int32]$MessagePort,
        # Use SSL?
        [Parameter(Mandatory=$True)]
        [bool]$MessageUseSSL,
        # SMTP server user
        [Parameter(Mandatory=$True)]
        [string]$MessageUserName,
        # SMTP server user password
        [Parameter(Mandatory=$True)]
        [string]$MessageCredsPassword,
        # Set $true to monitor Firewall settings or $false to skip
        [Parameter(Mandatory=$False)]
        [bool]$IsFirewallMonitored = $true,
        # Set $true to monitor Windows Defender settings or $false to skip
        [Parameter(Mandatory=$False)]
        [bool]$IsWindowsDefenderMonitored = $true,
        # Set $true to monitor 3 party antivirus settings or $false to skip
        [Parameter(Mandatory=$False)]
        [bool]$Is3PartyAntivirusMonitored = $true,
        # Set $true to monitor Windows Update service or $false to skip
        [Parameter(Mandatory=$False)]
        [bool]$IsWindowsUpdateMonitored = $true,
        # Sends email if notification level equal or less than the specified number. {0='NotВ configured';В 1='NeverВ checkВ forВ updates'В ;В 2='CheckВ forВ updatesВ butВ letВ meВ chooseВ whetherВ toВ downloadВ andВ installВ them';В 3='DownloadВ updatesВ butВ letВ meВ chooseВ whetherВ toВ installВ them';В 4='InstallВ updatesВ automatically'}
        [Parameter(Mandatory=$False)]
        [int32]$WindowsUpdateNotificationLevel = 3,
        # Get more about task trigger https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasktrigger
        [Parameter(Mandatory=$False)]
        $MonitoringJobSchedule = (New-ScheduledTaskTrigger -At 07:00:00 -Daily)
    )

    
    begin {
        
    }
    
    process {
        $MessageCredsPassword = $MessageCredsPassword | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
        $Script = "
        `$MessagePwd = '$MessageCredsPassword' | ConvertTo-SecureString
        `$MessageCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $MessageUserName, `$MessagePwd
        `$AutoUpdateNotificationLevels= @{0='Not configured'; 1='Never check for updates' ; 2='Check for updates but let me choose whether to download and install them'; 3='Download updates but let me choose whether to install them'; 4='Install updates automatically'}
        `$FirewallStatus = Get-NetFirewallProfile | Select -property Name, Enabled
        try {`$AVStatus = Get-MpComputerStatus | select -Property RealTimeProtectionEnabled, OnAccessProtectionEnabled, NISEnabled, IoavProtectionEnabled, BehaviorMonitorEnabled, AntivirusEnabled, AntispywareEnabled}
            catch { `$NoAntivirusDetected = `$true }
        try{`$AV3PartyStatus = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | where {`$_.displayName -ne 'Windows Defender'};`$AV3PartyProductState = '{0:x}' -f `$AV3PartyStatus.productState}
            catch{`$No3PartyAntivirusDetected = `$true }

        `$AVStatus = Get-MpComputerStatus | select -Property RealTimeProtectionEnabled, OnAccessProtectionEnabled, NISEnabled, IoavProtectionEnabled, BehaviorMonitorEnabled, AntivirusEnabled, AntispywareEnabled  
        `$WUStatus = get-service wuauserv | select -Property name, starttype, status
        `$WUStatusLevel = (New-Object -com 'Microsoft.Update.AutoUpdate').Settings.NotificationLevel

        if ((`$$IsFirewallMonitored -and (-not `$FirewallStatus[0].Enabled)) -or (`$$IsFirewallMonitored -and (-not `$FirewallStatus[1].Enabled)) -or (`$$IsFirewallMonitored -and (-not `$FirewallStatus[2].Enabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.RealTimeProtectionEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.OnAccessProtectionEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.NISEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.IoavProtectionEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.BehaviorMonitorEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.AntivirusEnabled)) -or (`$$IsWindowsDefenderMonitored -and (-not `$AVStatus.AntispywareEnabled)) -or (`$$IsWindowsUpdateMonitored  -and (-not(`$WUStatus.StartType -ne 'Disabled'))) -or (`$$IsWindowsUpdateMonitored  -and (-not(`$WUStatusLevel -gt $WindowsUpdateNotificationLevel))) -or (`$$Is3PartyAntivirusMonitored  -and (-not(`$AV3PartyProductState[`$AV3PartyProductState.length - 4] -ne '1'))) -or (`$$Is3PartyAntivirusMonitored  -and (-not(`$AV3PartyProductState[`$AV3PartyProductState.length - 2] -ne '0')))){
            if(`$$IsFirewallMonitored){
                `$MessageBody = ""<H3>Windows Firewall Profile Status</H3>""
                if(`$FirewallStatus[0].Enabled){`$MessageBody += ""<b>Domain: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>Domain: </b><font color=red>Disabled</font><br>""}
                if(`$FirewallStatus[1].Enabled){`$MessageBody += ""<b>Private: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>Private: </b><font color=red>Disabled</font><br>""}
                if(`$FirewallStatus[2].Enabled){`$MessageBody += ""<b>Public: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>Public: </b><font color=red>Disabled</font><br>""}

            }
            if(`$$IsWindowsDefenderMonitored){
                `$MessageBody += ""<H3>Windows Defender Protection Status</H3>""
                if(-not (`$NoAntivirusDetected)){
                    if(`$AVStatus.RealTimeProtectionEnabled){`$MessageBody += ""<b>RealTimeProtection: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>RealTimeProtection: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.OnAccessProtectionEnabled){`$MessageBody +=  ""<b>OnAccessProtection: </b><font color=green>Enabled</font><br>""}else{`$MessageBody += ""<b>OnAccessProtection: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.NISEnabled){`$MessageBody += ""<b>NIS: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>NIS: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.IoavProtectionEnabled){`$MessageBody += ""<b>IoavProtection: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>IoavProtection: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.BehaviorMonitorEnabled){`$MessageBody += ""<b>BehaviorMonitor: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>BehaviorMonitor: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.AntivirusEnabled){`$MessageBody += ""<b>Antivirus: </b><font color=green>Enabled</font><br>""}else{`$MessageBody +=""<b>Antivirus: </b><font color=red>Disabled</font><br>""}
                    if(`$AVStatus.AntispywareEnabled){`$MessageBody += ""<b>Antispyware: </b><font color=green>Enabled</font><br>""}else{`$MessageBody += ""<b>Antispyware: </b><font color=red>Disabled</font><br>""}
                }else{
                    `$MessageBody += ""<b>No Antivirus detected</b>""
                }
            }
            if(`$$Is3PartyAntivirusMonitored){
                
                if(`$AV3PartyStatus){
                    `$MessageBody += ""<H3>""+`$AV3PartyStatus.displayName+"" Protection Status</H3>""
                    if(`$AV3PartyProductState[`$AV3PartyProductState.length - 4] -eq '1'){`$MessageBody += ""<b>Antivirus status: </b><font color=green>Enabled</font><br>""}else{`$MessageBody += ""<b>Antivirus: </b><font color=red>Disabled</font><br>""}
                    if(`$AV3PartyProductState[`$AV3PartyProductState.length - 2] -eq '0'){`$MessageBody += ""<b>Antivirus databases: </b><font color=green>Up to date</font><br>""}else{`$MessageBody += ""<b>Antivirus databases: </b><font color=red>Outdated</font><br>""}
                }else{
                    `$MessageBody += ""<H3>Third Party Antivirus Protection Status</H3>""
                    `$MessageBody += ""<b>No Antivirus detected</b>""
                }
            }
            if(`$$IsWindowsUpdateMonitored ){
                `$MessageBody += ""<H3>Windows Update Service Status</H3>""
                if(`$WUStatus.starttype -ne 'Disabled'){`$MessageBody += ""<b>Start type: </b><font color=green>""+`$WUStatus.starttype+""</font><br>""}else{`$MessageBody +=""<b>Start type: </b><font color=red>Disabled</font><br>""}
                if(`$WUStatusLevel -gt $WindowsUpdateNotificationLevel){`$MessageBody += ""<b>Notification Level: </b><font color=green>""+`$AutoUpdateNotificationLevels[`$WUStatusLevel]+""</font><br>""}else{`$MessageBody +=""<b>Notification Level: </b><font color=red>""+`$AutoUpdateNotificationLevels[`$WUStatusLevel]+""</font><br>""}
            }
            
            Send-MailMessage -From "+$MessageFrom+" -To "+$MessageTo+" -Subject ""`$env:computername $MessageSubject"" -Body `$MessageBody -SmtpServer "+$MessageSMTPServer+" -UseSsl:$"+$MessageUseSSL+" -Port "+$MessagePort+" -Credential `$MessageCreds -BodyAsHtml}"

        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Script))
        $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -encodedCommand $encoded"
        if(Get-ScheduledTask -TaskName $JobName -ErrorAction SilentlyContinue) {Unregister-ScheduledTask -TaskName $JobName -Confirm:$false}
        Register-ScheduledTask -Action $action -Trigger $MonitoringJobSchedule -TaskName $JobName -User $JobUserName -password $JobUserPwd
    }
    
    end {
        
    }
}

# SIG # Begin signature block
# MIIbfQYJKoZIhvcNAQcCoIIbbjCCG2oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBuO98ENmyKk4dB
# D+GgfWeNlHWWWbNYEAGtMsFfqOes/KCCC04wggVmMIIETqADAgECAhEA3VtfmfWb
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
# zcJlmAaezkhb1LU3k0ZBfAfdz/pD77pnYf99SeC7MH1cgOPmFjlLpzGCD4Uwgg+B
# AgEBMIGSMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVk
# MSMwIQYDVQQDExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQQIRAN1bX5n1myt9
# rSpDNsSaOwowDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAvBgkqhkiG9w0BCQQxIgQgG6sdL9PvbPmj22xYevmt/RnJTKm+FuhYn6m/
# kL66c7gwDQYJKoZIhvcNAQEBBQAEggEAbOk7eIFvXCxMZQKP8bj5Oc8KKuyeAJTZ
# KDY/VApb3lFlwM0XG0BgLuZVmZVR9+aVZdWamSM+EXuBaKryZK0eJeh8fwoymMGU
# Oqz8mdadtdfB8TPGeIbcV7zos1UwqueMcVNzD0Pq/bWNOxtczP+gIkL362TYy+LH
# /8NlAsN8mKD6usYAq+MpYrWHmKKeMKzQJY57s1BPAB/XALGJnkauPtf26cmG++p9
# aLHNidC+jKQIBePFgXotJujkbHj2e6lMpQPGJJgZvXLs1XpwakRTgwBb9428w7NK
# mkvElgoekg4kiFUlJ1tk+7n2KU0rp3+Y9pRcp0g1BoBRa8Kg5mbNnKGCDUUwgg1B
# BgorBgEEAYI3AwMBMYINMTCCDS0GCSqGSIb3DQEHAqCCDR4wgg0aAgEDMQ8wDQYJ
# YIZIAWUDBAIBBQAweAYLKoZIhvcNAQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAx
# MA0GCWCGSAFlAwQCAQUABCAhbdabj8USC3LxPpI+tPGCF3YZUTNp5w3fBjTzTOQT
# 2gIRAPBpdk/zztRfm750ZMrTLV0YDzIwMjEwMTI2MDgxMTQwWqCCCjcwggT+MIID
# 5qADAgECAhANQkrgvjqI/2BAIc4UAPDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1l
# c3RhbXBpbmcgQ0EwHhcNMjEwMTAxMDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0Rp
# Z2lDZXJ0IFRpbWVzdGFtcCAyMDIxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEAwuZhhGfFivUNCKRFymNrUdc6EUK9CnV1TZS0DFC1JhD+HchvkWsMluca
# XEjvROW/m2HNFZFiWrj/ZwucY/02aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofp
# ir34hF0edsnkxnZ2OlPR0dNaNo/Go+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG
# 3JMjjfdQJehk5t3Tjy9XtYcg6w6OLNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkU
# rxVfbENJCf0mI1P2jWPoGqtbsR0wwptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y
# +tZji06lchzun3oBc/gZ1v4NSYS9AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQD
# AgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0g
# BDowODA2BglghkgBhv1sBwEwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMB8GA1UdIwQYMBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0G
# A1UdDgQWBBQ2RIaOpLqwZr68KC0dRDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCg
# LoYsaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmww
# gYUGCCsGAQUFBwEBBHkwdzAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tME8GCCsGAQUFBzAChkNodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRTSEEyQXNzdXJlZElEVGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3
# DQEBCwUAA4IBAQBIHNy16ZojvOca5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUn
# gaVNFBUZB3nw0QTDhtk7vf5EAmZN7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1D
# nnvntN1BIon7h6JGA0789P63ZHdjXyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6
# e9oMvD0y0BvL9WH8dQgAdryBDvjA4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0
# Uvtc4GEkJU+y38kpqHNDUdq9Y9YfW5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6n
# v1bPull2YYlffqe0jmd4+TaY4cso2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYy
# G35B5AXaNpfCFTANBgkqhkiG9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYD
# VQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAw
# WhcNMzEwMTA3MTIwMDAwWjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdp
# Q2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNR
# EH3Q+X1NaH7ntqD0jbOI5Je/YyGQmL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5f
# ZT/gm+vjRkcGGlV+Cyd+wKL1oODeIj8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5d
# yJoLVOOoCXFr4M8iEA91z3FyTgqt30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w
# 6kfZiFBe/WZuVmEnKYmEUeaC50ZQ/ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCE
# GXIX8RcG7z3N1k3vBkL9olMqT4UdxB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCC
# AcowHQYDVR0OBBYEFPS24SAd/imu0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXr
# oq/0ksuCMS1Ri6enIZ3zbcgPMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/
# BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1Ud
# IARJMEcwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5k
# aWdpY2VydC5jb20vQ1BTMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEA
# cZUS6VGHVmnN793afKpjerN4zwY3QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoq
# twU0HWqumfgnoma/Capg33akOpMP+LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRo
# stt1AuByx5jWPGTlH0gQGF+JOGFNYkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XV
# k4WTfraSZ/tTYYmo9WuWwPRYaQ18yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2
# bKXuh1Eh5Fhgm7oMLSttosR+u8QlK0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1
# VjMiLyI2skuiSpXY9aaOUjGCAk0wggJJAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcg
# Q0ECEA1CSuC+Ooj/YEAhzhQA8N0wDQYJYIZIAWUDBAIBBQCggZgwGgYJKoZIhvcN
# AQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMTAxMjYwODExNDBa
# MCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8G
# CSqGSIb3DQEJBDEiBCA/QgwWr0VzBbu81zLvuhxGdYnk6jWi/qibEhg6cQIUCDAN
# BgkqhkiG9w0BAQEFAASCAQAJXaiQfwV+9BhUc/+CbJK1R6IDMp5lIsDVqZddFSQu
# HOtplVkv4FgiQTmaEau9JRxJIu8xQdd/a9iPOH+JvA+l97tDs7VF/4761KZuelfk
# awRQnL3RUbbPzemf0zCjCzBL/3GuGw2HMHATHnzyTcmzoiJKLnOpQ6J7EZn6VEEA
# IBOMRjlgSHlbVLibKw8dhSK2LmSvDJQSJexeo0r6jndRzkkkReNUDgKMI5IUdH7T
# zFYZoCndx8xngODe9Yy5CK4ckbX065gL8GHaJ50ggtKedAKP5n/8BVLd4MfXZDST
# rdqXaGNSJyhVKWhAHAzD0lbp+gXa76nLezR24MZkFY5I
# SIG # End signature block
