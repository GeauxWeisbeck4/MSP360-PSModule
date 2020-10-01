function ProcessMBSFirewallRuleSet {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Action
    )

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $IsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($IsAdmin) {
        if ($CBB = Get-MBSAgent -ErrorAction SilentlyContinue) {
            $CBBPath = $CBB.CBBPath
            $Exec = $CBB.CBBName,"CBBackupPlan","Cloud.Backup.Scheduler","Cloud.Backup.RM.Service","cbb"
            $Directions = "In","Out"
            $FirewallRules = (New-object -ComObject HNetCfg.FwPolicy2).rules
            $RulesPresent = 0
            $RulesProcessedSuccessfully = 0
            foreach ($ExecValue in $Exec)
            {
                foreach ($DirectionValue in $Directions)
                {
                    $CurrentRulePresent=$false
                    $CurrentRuleName=""
                    $DirectionID = $(If ($DirectionValue -eq "In") {1} ElseIf ($DirectionValue -eq "Out") {2})
                    foreach ($Rule in $FirewallRules) {
                        if (($Rule.ApplicationName -eq "$CBBPath\$ExecValue.exe") -And ($Rule.Direction -eq $DirectionID)) {
                            $RulesPresent++
                            $CurrentRulePresent=$true
                            $CurrentRuleName=$Rule.Name
                            break
                        }
                    }
                    try {
                        if (($CurrentRulePresent) -And ($Action -eq "Remove")) {
                            NetSH AdvFirewall Firewall Delete Rule Name=$CurrentRuleName Dir=$DirectionValue | Out-Null
                            if ($LASTEXITCODE -eq 0) {
                                $RulesProcessedSuccessfully++
                            }
                            else {
                                throw $LASTEXITCODE
                            }
                        }
                        ElseIf ((!$CurrentRulePresent) -And ($Action -eq "Add")) {
                            NetSH AdvFirewall Firewall Add Rule Name="Online Backup - $ExecValue" Program="$CBBPath\$ExecValue.exe" Dir=$DirectionValue Action=Allow Enable=Yes | Out-Null
                            if ($LASTEXITCODE -eq 0) {
                                $RulesProcessedSuccessfully++
                            }
                            else {
                                throw $LASTEXITCODE
                            }
                        }
                    }
                    catch {
                        $description = "ERROR: An error occured - not all Firewall rules have been processed. Exitcode = $LASTEXITCODE"
                        return $false,$description
                    }
                }
            }
        }
        else {
            $description = "ERROR: MSP360 Online backup agent is not installed on this machine."
            return $false,$description
        }
    }
    else {
        $description = "ERROR: Processing Firewall rules requires administrator rights."
        return $false,$description
    }
    return $true,$RulesProcessedSuccessfully,$RulesPresent
}
