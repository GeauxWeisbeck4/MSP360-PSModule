function Sync-MBSStorageAccount {
    <#
    .SYNOPSIS
    Runs syncronization of the local repository with the specified storage account.
    
    .DESCRIPTION
    This cmdlet allows you to synchronize the local repository with the specified storage account. The software sends a request to the storage to list all objects on it and writes down the info about them to the local repository.
    
    .PARAMETER Name
    Storage account name to run the synchronization with
    
    .PARAMETER Password
    The encryption password to syncronize encrypted filenames. Use -Password (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)
    
    .PARAMETER MasterPassword
    Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string "Your_Password" -AsPlainText -Force)
    
    .EXAMPLE
    Sync-MBSStorageAccount -StorageAccount (Get-MBSStorageAccount -Name "FSS1")

    Start sync process for the storage account with name FSS1
    
    .INPUTS
    MBS.Agent.StorageAccount

    .OUTPUTS
    String

    .NOTES
    Author: Ivan Skorin

    .LINK
    https://kb.msp360.com/managed-backup-service/powershell-module/cmdlets/backup-agent/sync-mbsstorageaccount/
    #>
    [CmdletBinding()]
    param (
        # Parameter - Storage account
        [Parameter(Mandatory=$true, HelpMessage="Specify storage account object. Use Get-MBSStorageAccount cmdlet to list storages. Example: (Get-MBSStorageAccount -Name ""AWS S3"")", ValueFromPipeline)]
        [MBS.Agent.StorageAccount]
        $StorageAccount,
        # Parameter - Encryption password
        [Parameter(Mandatory=$false, HelpMessage="Specify the encryption password to syncronize encrypted filenames. Use -Password (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)")]
        [SecureString]
        $Password,
        # Parameter - Master password
        [Parameter(Mandatory=$false, HelpMessage="Specify Master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)")]
        [SecureString]
        $MasterPassword
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
        $Arguments = " account -s $($StorageAccount.DisplayName)"
        $null = Start-MBSProcess -CMDPath $CBB.CBBCLIPath -CMDArguments $Arguments -Output short -MasterPassword $MasterPassword
    }
    
    end {
        
    }
}