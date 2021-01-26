function Edit-MBSBackupPlan {
    <#
    .SYNOPSIS
        Edit MBS backup plan.
    .DESCRIPTION
        Edit MBS supported backup plan. File-Level and Image-Based backup plan type are supported.
    .EXAMPLE
        PS C:\> Get-MBSBackupPlan | Edit-MBSBackupPlan -CommonParameterSet -Compression $true
        Enable compression option for all supported backup plans.
    .EXAMPLE
        PS C:\> Get-MBSBackupPlan -PlanType File-Level | Edit-MBSBackupPlan -FileLevelParameterSet -ntfs $true
        Enable backup NTFS permissions option for all file-level backup plans.
    .EXAMPLE
        PS C:\> Get-MBSBackupPlan -PlanType Image-Based | Edit-MBSBackupPlan -ImageBasedParameterSet -BackupVolumes SystemRequired
        Add only system required volumes to all image-based backup plans.
    .EXAMPLE
        PS C:\> Get-MBSBackupPlan -StorageType Cloud -PlanType Image-Based | Edit-MBSBackupPlan -ImageBasedParameterSet -BackupVolumes SystemRequired
        Add only system required volumes to cloud image-based backup plans.
    .EXAMPLE
        PS C:\> Get-MBSBackupPlan -StorageType Cloud | Edit-MBSBackupPlan -ImageBasedParameterSet -KeepBitLocker $true
        Enable KeepBitLocker option for all cloud backup plans.
    .INPUTS
        System.Management.Automation.PSCustomObject
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Alex Volkov
    .LINK
        https://kb.msp360.com/managed-backup-service/powershell-module/cmdlets/edit-mbsbackupplan
    #>

    [CmdletBinding(DefaultParameterSetName='Common')]
    param (
        #
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to File-Level backup plan type", ParameterSetName='FileLevel')]
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to File-Level backup plan type", ParameterSetName='FileLevelChainedPlan')]
        
        [switch]
        $FileLevelParameterSet,
        #
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to Image-Based backup plan type", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to Image-Based backup plan type", ParameterSetName='ImageBasedChainedPlan')]
        [switch]
        $ImageBasedParameterSet,
        #
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to any backup plan type. Like Encryption, Compression, Retention policy, Schedule, etc.", ParameterSetName='Common')]
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to any backup plan type. Like Encryption, Compression, Retention policy, Schedule, etc.", ParameterSetName='CommonChainedPlan')]
        [switch]
        $CommonParameterSet,
        #
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ID,
        #
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify to change storage account. Use Get-MBSStorageAccount to list storages", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to change storage account. Use Get-MBSStorageAccount to list storages", ParameterSetName='FileLevel')]
        [ValidateSet("ExcludeEncryptedFiles", "ExcludeTempWindowsAppsFolders","ExcludeOneDriveFolders","AddFixedDrivesToIBB", "AddFixedDrivesToFileLevel", "DisablePreAction")]
        [string]
        $SpecialFunction,
        # 
        [Parameter(Mandatory=$False, HelpMessage="Specify to change storage account. Use Get-MBSStorageAccount to list storages", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to change storage account. Use Get-MBSStorageAccount to list storages", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to change storage account. Use Get-MBSStorageAccount to list storages", ParameterSetName='FileLevel')]
        [string]
        $StorageAccountID,
        # 
        [Parameter(Mandatory=$False, HelpMessage="Specify to rename plan", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to rename plan", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to rename plan", ParameterSetName='FileLevel')]
        [String]
        $NewName,
        # 
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable encryption", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable encryption", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable encryption", ParameterSetName='FileLevel')]
        [switch]
        $DisableEncryption,
        # 
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule", ParameterSetName='FileLevel')]
        [switch]
        $DisableSchedule,
        #
        [Parameter(Mandatory=$False, HelpMessage="Sync before run.", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Sync before run.", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Sync before run.", ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $SyncBeforeRun,
        #
        [Parameter(Mandatory=$False, HelpMessage="Use server side encryption (valid only for Amazon S3)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Use server side encryption (valid only for Amazon S3)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Use server side encryption (valid only for Amazon S3)", ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $ServerSideEncryption,
        #
        [Parameter(Mandatory=$False, HelpMessage="Encryption algorithm. Possible values: AES128-256", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Encryption algorithm. Possible values: AES128-256", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Encryption algorithm. Possible values: AES128-256", ParameterSetName='FileLevel')]
        [ValidateSet("AES128", "AES192","AES256")]
        [String]
        $EncryptionAlgorithm,
        #
        [Parameter(Mandatory=$False, HelpMessage="Encryption password. Use -EncryptionPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Encryption password. Use -EncryptionPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Encryption password. Use -EncryptionPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='FileLevel')]
        [SecureString]
        $EncryptionPassword,
        #
        [Parameter(Mandatory=$False, HelpMessage="Compress files", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Compress files", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Compress files", ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $Compression,
        #
        [Parameter(Mandatory=$False, HelpMessage="Storage Class (valid only for Amazon S3)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Storage Class (valid only for Amazon S3)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Storage Class (valid only for Amazon S3)", ParameterSetName='FileLevel')]
        [ValidateSet("Standard", "IntelligentTiering", "StandardIA", "OneZoneIA", "Glacier", "GlacierDeepArchive")]
        [String]
        $StorageClass,
        #
        [Parameter(Mandatory=$False, HelpMessage="Save backup plan configuration to the backup storage", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Save backup plan configuration to the backup storage", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Save backup plan configuration to the backup storage", ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $SaveBPConfiguration,
        #
        [Parameter(Mandatory=$False, HelpMessage="Output format. Possible values: short, full(default)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Output format. Possible values: short, full(default)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Output format. Possible values: short, full(default)", ParameterSetName='FileLevel')]
        [ValidateSet("short", "full")]
        [String]
        $output,
        #
        [Parameter(Mandatory=$False, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Master password. Should be specified if configuration is protected by master password. Use -MasterPassword (ConvertTo-SecureString -string ""Your_Password"" -AsPlainText -Force)", ParameterSetName='FileLevel')]
        [SecureString]
        $MasterPassword,
        # ------------------------- Schedule -----------------------------
        [Parameter(Mandatory=$False, HelpMessage="Specify schedule recurring type", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify schedule recurring type", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify schedule recurring type", ParameterSetName='FileLevel')]
        [ValidateSet("day", "week", "month", "dayofmonth", "real-time")]
        [String]
        $RecurringType,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of schedule. Example -at ""06/09/19 7:43 AM"" , or -at ""7:43 AM"" for every day schedule", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of schedule. Example -at ""06/09/19 7:43 AM"" , or -at ""7:43 AM"" for every day schedule", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of schedule. Example -at ""06/09/19 7:43 AM"" , or -at ""7:43 AM"" for every day schedule", ParameterSetName='FileLevel')]
        [String]
        $At,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' schedule (1..31)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' schedule (1..31)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' schedule (1..31)", ParameterSetName='FileLevel')]
        [Int32][ValidateRange(1,31)]
        $DayOfMonth,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify day(s) of week for weekly schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly schedule", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day(s) of week for weekly schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly schedule", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day(s) of week for weekly schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly schedule", ParameterSetName='FileLevel')]
        [ValidateSet("su", "mo", "tu", "we", "th", "fr", "sa")]
        [string[]]
        $WeekDay,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='FileLevel')]
        [ValidateSet("First", "Second", "Third", "Fourth", "Penultimate", "Last")]
        [string]
        $WeekNumber,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring from value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring from value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring from value", ParameterSetName='FileLevel')]
        [string]
        $DailyFrom,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring till value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring till value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily recurring till value", ParameterSetName='FileLevel')]
        [string]
        $DailyTill,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period type. Possible values: hour, min", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period type. Possible values: hour, min", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period type. Possible values: hour, min", ParameterSetName='FileLevel')]
        [ValidateSet("hour", "min")]
        [string]
        $Occurs,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify recurring period value", ParameterSetName='FileLevel')]
        [Alias("OccursValue")]
        [string]
        $OccurValue,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify repeat period value. Possible values: 1..31", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify repeat period value. Possible values: 1..31", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify repeat period value. Possible values: 1..31", ParameterSetName='FileLevel')]
        [Int32][ValidateRange(1,31)]
        $RepeatEvery,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify start date of repetitions", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify start date of repetitions", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify start date of repetitions", ParameterSetName='FileLevel')]
        [string]
        $repeatStartDate,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfter ""20:30"" or -stopAfter ""100:00"" etc.", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfter ""20:30"" or -stopAfter ""100:00"" etc.", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfter ""20:30"" or -stopAfter ""100:00"" etc.", ParameterSetName='FileLevel')]
        [string]
        $stopAfter,
        # ------------------ Pre / Post actions ----------------------------
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed before backup completes.", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed before backup completes.", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed before backup completes.", ParameterSetName='FileLevel')]
        [string]
        $preActionCommand,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to continue backup plan if pre-backup action failed. Possible values: $true/$false', ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to continue backup plan if pre-backup action failed. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to continue backup plan if pre-backup action failed. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Alias("pac")]
        [Nullable[boolean]]
        $preActionContinueAnyway,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed after backup has been successfully completed.", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed after backup has been successfully completed.", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify command to be executed after backup has been successfully completed.", ParameterSetName='FileLevel')]
        [string]
        $postActionCommand,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute post-backup action in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute post-backup action in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute post-backup action in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Alias("paa")]
        [Nullable[boolean]]
        $postActionRunAnyway,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify to receive notification email when backup fails (errorOnly) or in all cases (on). Prior to turn on the notification settings must be configured. Possible values: errorOnly, on, off", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to receive notification email when backup fails (errorOnly) or in all cases (on). Prior to turn on the notification settings must be configured. Possible values: errorOnly, on, off", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to receive notification email when backup fails (errorOnly) or in all cases (on). Prior to turn on the notification settings must be configured. Possible values: errorOnly, on, off", ParameterSetName='FileLevel')]
        [ValidateSet("errorOnly", "on", "off")]
        [string]
        $notification,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify to add entry to Windows Event Log when backup fails (errorOnly) or in all cases (on). Possible values: errorOnly, on, off", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to add entry to Windows Event Log when backup fails (errorOnly) or in all cases (on). Possible values: errorOnly, on, off", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to add entry to Windows Event Log when backup fails (errorOnly) or in all cases (on). Possible values: errorOnly, on, off", ParameterSetName='FileLevel')]
        [ValidateSet("errorOnly", "on", "off")]
        [string]
        $winLog,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to enable/disable next/chained plan execution. Possible values: $true/$false', ParameterSetName='CommonChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to enable/disable next/chained plan execution. Possible values: $true/$false', ParameterSetName='ImageBasedChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to enable/disable next/chained plan execution. Possible values: $true/$false', ParameterSetName='FileLevelChainedPlan')]
        [Nullable[boolean]]
        $ExecuteChainedPlan,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify chained plan ID. Use (Get-MBSBackupPlan | Where-Object Name -eq 'Backup plans name').ID or (Get-MBSRestorePlan | Where-Object Name -eq 'Backup plans name').ID", ParameterSetName='CommonChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage="Specify chained plan ID. Use (Get-MBSBackupPlan | Where-Object Name -eq 'Backup plans name').ID or (Get-MBSRestorePlan | Where-Object Name -eq 'Backup plans name').ID", ParameterSetName='ImageBasedChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage="Specify chained plan ID. Use (Get-MBSBackupPlan | Where-Object Name -eq 'Backup plans name').ID or (Get-MBSRestorePlan | Where-Object Name -eq 'Backup plans name').ID", ParameterSetName='FileLevelChainedPlan')]
        [string]
        $ChainedPlanID,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute chained plan in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='CommonChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute chained plan in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='ImageBasedChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute chained plan in any case (regardless the backup result). Possible values: $true/$false', ParameterSetName='FileLevelChainedPlan')]
        [Nullable[boolean]]
        $ExecuteChainedPlanAnyway,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute a chained plan in force full mode. Possible values: $true/$false', ParameterSetName='CommonChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute a chained plan in force full mode. Possible values: $true/$false', ParameterSetName='ImageBasedChainedPlan')]
        [Parameter(Mandatory=$False, HelpMessage='Specify to execute a chained plan in force full mode. Possible values: $true/$false', ParameterSetName='FileLevelChainedPlan')]
        [Nullable[boolean]]
        $ForceFullChainedPlan,
        # ---------------------------- Retention Policy -------------------------
        
        [Parameter(Mandatory=$False, HelpMessage="Purge versions that are older than period (except lastest version). Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Purge versions that are older than period (except lastest version). Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Purge versions that are older than period (except lastest version). Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='FileLevel')]
        [string]
        $purge,
        #
        [Parameter(Mandatory=$False, HelpMessage="Keep limited number of versions. Possible values: all, number", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Keep limited number of versions. Possible values: all, number", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Keep limited number of versions. Possible values: all, number", ParameterSetName='FileLevel')]
        [string]
        $keep,
        #
        [Parameter(Mandatory=$False, HelpMessage='Always keep the last version. Possible values: $true/$false', ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage='Always keep the last version. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage='Always keep the last version. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $keepLastVersion,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify purge delay. Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify purge delay. Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify purge delay. Possible values: no, 1d(day), 1w(week), 1m(month)", ParameterSetName='FileLevel')]
        [string]
        $delayPurge,
        #-------------------------Full schedule -----------------------------------
        [Parameter(Mandatory=$False, HelpMessage='Run missed scheduled backup immediately when computer starts up. Possible values: $true/$false', ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage='Run missed scheduled backup immediately when computer starts up. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage='Run missed scheduled backup immediately when computer starts up. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $runMissed,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify force full schedule recurring type. Possible values: day, week, month, dayofmonth, real-time", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full schedule recurring type. Possible values: day, week, month, dayofmonth, real-time", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full schedule recurring type. Possible values: day, week, month, dayofmonth, real-time", ParameterSetName='FileLevel')]
        [ValidateSet("day", "week", "month", "dayofmonth", "real-time")]
        [string]
        $RecurringTypeForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of force full schedule. Example -atForceFull ""06/09/19 7:43 AM"" , or -atForceFull ""7:43 AM"" for every day force full schedule", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of force full schedule. Example -atForceFull ""06/09/19 7:43 AM"" , or -atForceFull ""7:43 AM"" for every day force full schedule", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify datetime or time of force full schedule. Example -atForceFull ""06/09/19 7:43 AM"" , or -atForceFull ""7:43 AM"" for every day force full schedule", ParameterSetName='FileLevel')]
        [string]
        $atForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' force full schedule (1..31)", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' force full schedule (1..31)", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify day for 'dayofmonth' force full schedule (1..31)", ParameterSetName='FileLevel')]
        [Int32][ValidateRange(1,31)]
        [Alias("dayForceFull")]
        $DayOfMonthForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="listOfWeekDays. Specify day(s) of week for weekly force full schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly force full schedule", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="listOfWeekDays. Specify day(s) of week for weekly force full schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly force full schedule", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="listOfWeekDays. Specify day(s) of week for weekly force full schedule. Example: ""su, mo, tu, we, th, fr, sa"". Or specify day of week for monthly force full schedule", ParameterSetName='FileLevel')]
        [string]
        $weekdayForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify number of week. Possible values: First, Second, Third, Fourth, Penultimate, Last", ParameterSetName='FileLevel')]
        [ValidateSet("First", "Second", "Third", "Fourth", "Penultimate", "Last")]
        [string]
        $weeknumberForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring from value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring from value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring from value", ParameterSetName='FileLevel')]
        [string]
        $dailyFromForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring till value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring till value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify daily force full recurring till value", ParameterSetName='FileLevel')]
        [string]
        $dailyTillForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period type. Possible values: hour, min", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period type. Possible values: hour, min", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period type. Possible values: hour, min", ParameterSetName='FileLevel')]
        [ValidateSet("hour", "min")]
        [string]
        $occursForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period value", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period value", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full recurring period value", ParameterSetName='FileLevel')]
        [string]
        $occurValueForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify force full repeat period value. Possible values: 1..31", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full repeat period value. Possible values: 1..31", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full repeat period value. Possible values: 1..31", ParameterSetName='FileLevel')]
        [Int32][ValidateRange(1,31)]
        $repeatEveryForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify force full start date of repetitions", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full start date of repetitions", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify force full start date of repetitions", ParameterSetName='FileLevel')]
        [string]
        $repeatStartDateForceFull,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify rebackup datetime. Example: ""06/09/19 7:43 AM""", ParameterSetName='FileLevel')]
        [string]
        $rebackupDate,
        #
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule force full", ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule force full", ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage="Specify to disable schedule force full", ParameterSetName='FileLevel')]
        [switch]
        $DisableForceFullSchedule,
        #---------------------------- Block Level ------------------
        [Parameter(Mandatory=$False, HelpMessage='Use block level backup. Possible values: $true/$false', ParameterSetName='Common')]
        [Parameter(Mandatory=$False, HelpMessage='Use block level backup. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Parameter(Mandatory=$False, HelpMessage='Use block level backup. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $useBlockLevelBackup,
        # --------------------------- File Backup settings ------------

        [Parameter(Mandatory=$False, HelpMessage="Backup NTFS permissions", ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $ntfs,
        #
        [Parameter(Mandatory=$False, HelpMessage='Force using VSS (Volume Shadow Copy Service). Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $ForceUsingVSS,
        #
        [Parameter(Mandatory=$False, HelpMessage='Use share read/write mode on errors. Can help if file is open in share read/write mode. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $sharerw,
        #
        [Parameter(Mandatory=$False, HelpMessage="Delete files that have been deleted locally after specified number of days. Example: ""-df 30""", ParameterSetName='FileLevel')]
        [Alias("df")]        
        [string]
        $DeleteLocallyDeletedFilesAfter,
        #
        [Parameter(Mandatory=$False, HelpMessage='Backup empty folders. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $BackupEmptyFolders,
        #
        [Parameter(Mandatory=$False, HelpMessage="Backup files only after specific date. Example: ""06/09/19 7:43 AM""", ParameterSetName='FileLevel')]
        [Alias("oa")]        
        [string]
        $BackupOnlyAfter,
        #
        [Parameter(Mandatory=$False, HelpMessage='Except system and hidden files. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Alias("es")]        
        [Nullable[boolean]]
        $ExcludeSystemHiddenFiles,
        #
        [Parameter(Mandatory=$False, HelpMessage="Skip folders. Example: -skipfolder ""bin;*temp*;My*""", ParameterSetName='FileLevel')]
        [string]
        $SkipFolders,
        #
        [Parameter(Mandatory=$False, HelpMessage="Include files mask. Example: -ifm ""*.doc;*.xls""", ParameterSetName='FileLevel')]
        [string]
        $IncludeFilesMask,
        #
        [Parameter(Mandatory=$False, HelpMessage="Exclude files mask. Example: -efm ""*.bak;*.tmp""", ParameterSetName='FileLevel')]
        [string]
        $ExcludeFilesMask,
        #
        [Parameter(Mandatory=$False, HelpMessage='Ignore errors path not found. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Alias("iepnf")]        
        [Nullable[boolean]]
        $IgnoreErrorPathNotFound,
        #
        [Parameter(Mandatory=$False, HelpMessage='Track deleted files data. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $TrackDeletedFiles,
        #
        [Parameter(Mandatory=$False, HelpMessage="Add a new file to backup plan", ParameterSetName='FileLevel')]
        [string]
        $AddNewFile,
        #
        [Parameter(Mandatory=$False, HelpMessage="Add a new directory to backup plan", ParameterSetName='FileLevel')]
        [string]
        $AddNewFolder,
        #
        [Parameter(Mandatory=$False, HelpMessage="Exclude a file from backup plan", ParameterSetName='FileLevel')]
        [Parameter(Mandatory=$False, HelpMessage="Exclude a file from backup plan", ParameterSetName='ImageBased')]
        [string[]]
        $ExcludeFile,
        #
        [Parameter(Mandatory=$False, HelpMessage="Exclude a directory from backup plan", ParameterSetName='FileLevel')]
        [Parameter(Mandatory=$False, HelpMessage="Exclude a directory from backup plan", ParameterSetName='ImageBased')]
        [string[]]
        $ExcludeDirectory,
        #
        [Parameter(Mandatory=$False, HelpMessage="Backup file", ParameterSetName='FileLevel')]
        [string]
        $BackupFile,
        #
        [Parameter(Mandatory=$False, HelpMessage="Backup directory", ParameterSetName='FileLevel')]
        [string]
        $BackupDirectory,
        #
        [Parameter(Mandatory=$False, HelpMessage='Specify to generate detailed report. Possible values: $true/$false', ParameterSetName='FileLevel')]
        [Nullable[boolean]]
        $GenerateDetailedReport,
        # ------------------------- Image-Based --------------------------------------
        [Parameter(Mandatory=$False, HelpMessage="Backup Volumes type", ParameterSetName='ImageBased')]
        [ValidateSet("AllVolumes", "SystemRequired", "SelectedVolumes")]
        [string]
        $BackupVolumes,
        #
        [Parameter(Mandatory=$False, HelpMessage="Backup selected volumes with the specified ids.", ParameterSetName='ImageBased')]
        [string[]]
        $Volumes,
        #
        [Parameter(Mandatory=$False, HelpMessage='Disable VSS, use direct access to NTFS volume. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Nullable[boolean]]
        $disableVSS,
        #
        [Parameter(Mandatory=$False, HelpMessage='Enable or disable KeepBitLocker option for all partitions. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Nullable[boolean]]
        $KeepBitLocker,
        #
        [Parameter(Mandatory=$False, HelpMessage='Ignore bad sectors. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Nullable[boolean]]
        $ignoreBadSectors,
        #
        [Parameter(Mandatory=$False, HelpMessage='Use system VSS provider. Possible values: $true/$false', ParameterSetName='ImageBased')]
        [Nullable[boolean]]
        $useSystemVSS,
        #
        [Parameter(Mandatory=$False, HelpMessage="Prefetch block count (0 - 100, 0 without prefetch)", ParameterSetName='ImageBased')]
        [Int32][ValidateRange(0,100)]
        $prefetchBlockCount,
        #
        [Parameter(Mandatory=$False, HelpMessage="Block size. Possible values: 128, 256, 512, 1024", ParameterSetName='ImageBased')]
        [ValidateSet("128", "256", "512", "1024")]
        [string]
        $blockSize
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
        function Set-Arguments {
            if ($StorageAccountID){$Argument += " -aid $StorageAccountID"}
            if ($NewName){$Argument += " -nn ""$NewName"""}
            if ($null -ne $SyncBeforeRun){
                if ($SyncBeforeRun) {
                    $Argument += " -sync yes"
                }else{
                    $Argument += " -sync no"
                }
            }
            if ($null -ne $Compression){
                if ($Compression) {
                    $Argument += " -c yes"
                }else{
                    $Argument += " -c no"
                }
            }
            if ($DisableEncryption){$Argument += " -ed"}
            if ($DisableSchedule){$Argument += " -sd"}
            if ($null -ne $ServerSideEncryption){
                if ($ServerSideEncryption) {
                    $Argument += " -sse yes"
                }else{
                    $Argument += " -sse no"
                }
            }
            if ($EncryptionAlgorithm){$Argument += " -ea $EncryptionAlgorithm"}
            if ($EncryptionPassword){$Argument += " -ep """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($EncryptionPassword)))+""""}
            if ($StorageClass){$Argument += " -sc $StorageClass"}
            if ($null -ne $SaveBPConfiguration){
                if ($SaveBPConfiguration) {
                    $Argument += " -sp yes"
                }else{
                    $Argument += " -sp no"
                }
            }
            if ($RecurringType){$Argument += " -every $RecurringType"}
            if ($At){$Argument += " -at $At"}
            if ($DayOfMonth){$Argument += " -day $DayOfMonth"}
            if ($Weekday){$Argument += " -weekday "+($Weekday -join ",")}
            if ($Weeknumber){$Argument += " -weeknumber $Weeknumber"}
            if ($DailyFrom){$Argument += " -dailyFrom $DailyFrom"}
            if ($DailyTill){$Argument += " -dailyTill $DailyTill"}
            if ($Occurs){$Argument += " -occurs $Occurs"}
            if ($OccurValue){$Argument += " -occurValue $OccurValue"}
            if ($repeatStartDate){$Argument += " -repeatStartDate $repeatStartDate"}
            if ($stopAfter){$Argument += " -stopAfter $stopAfter"}
            if ($preActionCommand){$Argument += " -preAction ""$preActionCommand"""}
            if ($null -ne $preActionContinueAnyway){
                if ($preActionContinueAnyway) {
                    $Argument += " -pac yes"
                }else{
                    $Argument += " -pac no"
                }
            }
            if ($postActionCommand){$Argument += " -postAction ""$postActionCommand"""}
            if ($null -ne $postActionRunAnyway){
                if ($postActionRunAnyway) {
                    $Argument += " -paa yes"
                }else{
                    $Argument += " -paa no"
                }
            }
            if ($notification){$Argument += " -notification $notification"}
            if ($winLog){$Argument += " -winLog $winLog"}
            if ($purge){$Argument += " -purge $purge"}
            if ($keep){$Argument += " -keep $keep"}
            if ($null -ne $keepLastVersion){
                if ($keepLastVersion) {
                    $Argument += " -keepLastVersion yes"
                }else{
                    $Argument += " -keepLastVersion no"
                }
            }
            if ($delayPurge){$Argument += " -delayPurge $delayPurge"}
            if ($null -ne $runMissed){
                if ($runMissed) {
                    $Argument += " -runMissed yes"
                }else{
                    $Argument += " -runMissed no"
                }
            }
            if ($RecurringTypeForceFull){$Argument += " -everyForceFull $RecurringTypeForceFull"}
            if ($atForceFull){$Argument += " -atForceFull $atForceFull"}
            if ($DayOfMonthForceFull){$Argument += " -dayForceFull $DayOfMonthForceFull"}
            if ($weekdayForceFull){$Argument += " -weekdayForceFull $weekdayForceFull"}
            if ($weeknumberForceFull){$Argument += " -weeknumberForceFull $weeknumberForceFull"}
            if ($dailyFromForceFull){$Argument += " -dailyFromForceFull $dailyFromForceFull"}
            if ($dailyTillForceFull){$Argument += " -dailyTillForceFull $dailyTillForceFull"}
            if ($occursForceFull){$Argument += " -occursForceFull $occursForceFull"}
            if ($occurValueForceFull){$Argument += " -occurValueForceFull $occurValueForceFull"}
            if ($repeatEveryForceFull){$Argument += " -repeatEveryForceFull $repeatEveryForceFull"}
            if ($repeatStartDateForceFull){$Argument += " -repeatStartDateForceFull $repeatStartDateForceFull"}
            if ($stopAfterForceFull){$Argument += " -stopAfterForceFull $stopAfterForceFull"}
            if ($rebackupDate){$Argument += " -rebackupDate $rebackupDate"}
            if ($DisableForceFullSchedule){$Argument += " -sdForce"}
            if ($null -ne $useBlockLevelBackup){
                if ($useBlockLevelBackup) {
                    $Argument += " -useBlockLevelBackup yes"
                }else{
                    $Argument += " -useBlockLevelBackup no"
                }
            }

            # --------- File-Level ------------
            if ($null -ne $ntfs){
                if ($ntfs) {
                    $Argument += " -ntfs yes"
                }else{
                    $Argument += " -ntfs no"
                }
            }
            if ($null -ne $ForceUsingVSS){
                if ($ForceUsingVSS) {
                    $Argument += " -vss yes"
                }else{
                    $Argument += " -vss no"
                }
            }
            if ($null -ne $sharerw){
                if ($sharerw) {
                    $Argument += " -sharerw yes"
                }else{
                    $Argument += " -sharerw no"
                }
            }
            if ($DeleteLocallyDeletedFilesAfter){$Argument += " -df $DeleteLocallyDeletedFilesAfter"}
            if ($null -ne $BackupEmptyFolders){
                if ($BackupEmptyFolders) {
                    $Argument += " -bef yes"
                }else{
                    $Argument += " -bef no"
                }
            }
            if ($BackupOnlyAfter){$Argument += " -oa $BackupOnlyAfter"}
            if ($null -ne $ExcludeSystemHiddenFiles){
                if ($ExcludeSystemHiddenFiles) {
                    $Argument += " -es yes"
                }else{
                    $Argument += " -es no"
                }
            }
            if ($SkipFolders){$Argument += " -skipf ""$SkipFolders"""}
            if ($IncludeFilesMask){$Argument += " -ifm ""$IncludeFilesMask"""}
            if ($ExcludeFilesMask){$Argument += " -efm ""$ExcludeFilesMask"""}
            if ($null -ne $IgnoreErrorPathNotFound){
                if ($IgnoreErrorPathNotFound) {
                    $Argument += " -iepnf yes"
                }else{
                    $Argument += " -iepnf no"
                }
            }
            if ($null -ne $TrackDeletedFiles){
                if ($TrackDeletedFiles) {
                    $Argument += " -trackdeleted yes"
                }else{
                    $Argument += " -trackdeleted no"
                }
            }
            if ($AddNewFile){$Argument += " -af ""$AddNewFile"""}
            if ($AddNewFolder){$Argument += " -ad ""$AddNewFolder"""}
            if ($ExcludeFile){$Argument += " -rf ""$ExcludeFile"""}
            if ($ExcludeDirectory){$Argument += " -rd ""$ExcludeDirectory"""}
            if ($BackupFile){$Argument += " -f ""$BackupFile"""}
            if ($BackupDirectory){$Argument += " -d ""$BackupDirectory"""}
            if ($null -ne $GenerateDetailedReport){
                if ($GenerateDetailedReport) {
                    $Argument += " -dr yes"
                }else{
                    $Argument += " -dr no"
                }
            }
            if ($output){$Argument += " -output $output"}
            if ($MasterPassword){$Argument += " -mp """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterPassword)))+""""}

            # ------------- Image-Based -------------

            switch ($BackupVolumes) {
                'AllVolumes' {$Argument += " -av"}
                'SystemRequired' {$Argument += " -r"}
                'SelectedVolumes' {
                    ForEach-Object -InputObject $Volumes -Process {
                        Write-Verbose -Message "$($PSCmdlet.MyInvocation.MyCommand.Name): Arguments: $Argument"
                        $Argument += " -v $_"
                        Write-Verbose -Message "$($PSCmdlet.MyInvocation.MyCommand.Name): Arguments: $Argument"
                    }
                }
                Default {}
            }

            if ($null -ne $disableVSS){
                if ($disableVSS) {
                    $Argument += " -disableVSS yes"
                }else{
                    $Argument += " -disableVSS no"
                }
            }
            if ($null -ne $ignoreBadSectors){
                if ($ignoreBadSectors) {
                    $Argument += " -ignoreBadSectors yes"
                }else{
                    $Argument += " -ignoreBadSectors no"
                }
            }
            if ($null -ne $useSystemVSS){
                if ($useSystemVSS) {
                    $Argument += " -useSystemVSS yes"
                }else{
                    $Argument += " -useSystemVSS no"
                }
            }
            if ($prefetchBlockCount){$Argument += " -prefetchBlockCount $prefetchBlockCount"}
            if ($blockSize){$Argument += " -blockSize $blockSize"}
            
            Return $Argument
        }

        if ($_){
            $BackupPlan = $_
        }else{
            if($ID){
                $BackupPlan = Get-MBSBackupPlan | Where-Object {$_.ID -eq $ID}
            }else{
                $BackupPlan = Get-MBSBackupPlan | Where-Object {$_.Name -eq $Name}
            }
        }

        if ($CBB = Get-MBSAgent -ErrorAction SilentlyContinue){
            if ($SpecialFunction) {
                switch ($SpecialFunction) {
                    "ExcludeEncryptedFiles" {
                        if ($BackupPlan.Type -eq "Plan") {
                            Write-Host "Searching for encrypted files in plan:" $BackupPlan.Name -ForegroundColor Green
                            $Arguments = "editBackupPlan -id "+$ID
                            $FoundFlag = $false
                            foreach ($Item in $BackupPlan.Items)
                            {
                                
                                foreach ($File in (get-childitem ($Item) -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {$_.Attributes -ge "Encrypted"}))
                                {
                                    Write-Host "File "$File.FullName "is encrypted and added to exclusion list"
                                    $Arguments += " -rf """+$File.FullName+""""
                                    $FoundFlag = $True
                                }
                                
                            }
                            if ($FoundFlag) {
                                (Start-MBSProcess -CMDPath $CBB.CBBCLIPath -CMDArguments $Arguments -Output short -MasterPassword $MasterPassword).result
                            }
                        }else{
                            Write-Host "ExcludeEncryptedFiles option supports only File-Level backup plans."
                        }
                    }
                    "ExcludeTempWindowsAppsFolders" {
                        $versionMinimum = [Version]'3.0'
                        if ($versionMinimum -le $PSVersionTable.PSVersion){
                            if ($BackupPlan.Type -eq "Plan") {
                                $Exclusions = '%USERPROFILE%\AppData\Local\Microsoft\WindowsApps', '%USERPROFILE%\AppData\Local\Packages', '%USERPROFILE%\AppData\Local\Temp'
                                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                                Write-Host "Adding exclusions to plan:" $BackupPlan.Name -ForegroundColor Green
                                foreach($exclusion in $Exclusions){
                                    $element = ((($BackupPlanXml.BasePlan.SelectSingleNode("//ExcludedItems")).AppendChild($BackupPlanXml.CreateElement("PlanItem"))).AppendChild($BackupPlanXml.CreateElement("Path"))).AppendChild($BackupPlanXml.CreateTextNode($exclusion))
                                }
                                Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                            }else{
                                Write-Host "ExcludeTempWindowsAppsFolders option supports only File-Level backup plans."
                            }
                        }else{
                            "This script requires PowerShell $versionMinimum. Update PowerShell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell"
                        }
                    }
                    "ExcludeOneDriveFolders" {
                        $versionMinimum = [Version]'3.0'
                        if ($versionMinimum -le $PSVersionTable.PSVersion){
                            if ($BackupPlan.Type -eq "Plan") {
                                $UserProf = Get-ChildItem -Path Registry::HKEY_USERS -ErrorAction SilentlyContinue | Select-Object Name
                                $OneDrivePathArray = @()
                                $OneDriveRegKeys = @("\Software\Microsoft\OneDrive\Accounts\Business1\ScopeIdToMountPointPathCache","\Software\Microsoft\OneDrive\Accounts\Personal\ScopeIdToMountPointPathCache")
                                $UserProf  | ForEach-Object {
                                    foreach ($OneDriveRegKey in $OneDriveRegKeys) {
                                        if (Test-Path -Path ("Registry::"+$_.Name+$OneDriveRegKey)){
                                            $UserProfile = $_.Name
                                            $OneDriveFolder = Get-Item -Path  ("Registry::"+$UserProfile+$OneDriveRegKey)| Select-Object -ExpandProperty Property 
                                            $OneDriveFolder | Foreach-Object {$OneDrivePathArray +=(Get-ItemProperty -Path ("Registry::"+$UserProfile+$OneDriveRegKey) -Name $_)."$_"}
                                        }
                                    }
                                }
                                
                                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                                Write-Host "Adding exclusions to plan:" $BackupPlan.Name -ForegroundColor Green
                                foreach($exclusion in $OneDrivePathArray){
                                    $element = ((($BackupPlanXml.BasePlan.SelectSingleNode("//ExcludedItems")).AppendChild($BackupPlanXml.CreateElement("PlanItem"))).AppendChild($BackupPlanXml.CreateElement("Path"))).AppendChild($BackupPlanXml.CreateTextNode($exclusion))
                                }
                                Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                            }else{
                                Write-Host "ExcludeOneDriveFolders option supports only File-Level backup plans."
                            }
                        }else{
                            "This script requires PowerShell $versionMinimum. Update PowerShell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell"
                        }
                    }
                    "AddFixedDrivesToIBB" {
                        $versionMinimum = [Version]'3.0'
                        if ($versionMinimum -le $PSVersionTable.PSVersion){
                            if ($BackupPlan.Type -eq "BackupDiskImagePlan") {
                                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                                $BackupPlanXml.BasePlan.BackupVolumes = "SelectedOnly"
                                $BackupPlanXml.BasePlan.DiskInfo.DiskInfoCommunication | ForEach-Object {
                                    if ($_.DriveType -eq "Fixed"){
                                        $_.Enabled = "true"
                                        $_.Volumes.VolumeInfoCommunication | ForEach-Object { $_.Enabled = "true"}
                                    }
                                }
                                $BackupPlanXml.BasePlan.DiskInfo.DiskInfoCommunication | ForEach-Object {
                                    if ($_.DriveType -eq "Removable"){
                                        $_.Enabled = "false"
                                        $_.Volumes.VolumeInfoCommunication | ForEach-Object { $_.Enabled = "false"}
                                    }
                                }
                                Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                            }else{
                                Write-Host "AddFixedDrivesToIBB option supports only Image-Based backup plans."
                            }
                        }else{
                            "This script requires PowerShell $versionMinimum. Update PowerShell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell"
                        }
                    }
                    "AddFixedDrivesToFileLevel" {
                        $versionMinimum = [Version]'3.0'
                        if ($versionMinimum -le $PSVersionTable.PSVersion){
                            if ($BackupPlan.Type -eq "Plan") {
                                Get-WmiObject Win32_LogicalDisk | ForEach-Object {$BackupPlan | Edit-MBSBackupPlan -FileLevelParameterSet -ExcludeDirectory ($_.DeviceID+'\')}
                                Get-WmiObject Win32_LogicalDisk | Where-Object {($_.DriveType -eq 3) -and ($_.VolumeName -notlike 'Google Drive*')} | ForEach-Object {
                                        $BackupPlan | Edit-MBSBackupPlan  -FileLevelParameterSet -AddNewFolder ($_.DeviceID+'\')
                                }
                            }else{
                                Write-Host "AddFixedDrivesToFileLevel option supports only File-Level backup plans."
                            }
                        }else{
                            "This script requires PowerShell $versionMinimum. Update PowerShell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell"
                        }
                    }
                    "DisablePreAction" {
                        $versionMinimum = [Version]'3.0'
                        if ($versionMinimum -le $PSVersionTable.PSVersion){
                            $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                                $BackupPlanXml.BasePlan.Actions.Pre.Enabled = "false"
                                $BackupPlanXml.BasePlan.Actions.Pre.CommandLine = ""
                                $BackupPlanXml.BasePlan.Actions.Pre.Arguments = ""
                                Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                        }else{
                            "This script requires PowerShell $versionMinimum. Update PowerShell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell"
                        }
                    }
                    Default {}
                }
            }elseif (($ExcludeFile -or $ExcludeDirectory) -and $ImageBasedParameterSet){
                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                
                foreach ($ExcludePath in $ExcludeFile) {
                    $BackupPlanXml.BasePlan.DiskInfo.DiskInfoCommunication.Volumes.VolumeInfoCommunication | Where-Object {$_.MountPoints.string -eq $ExcludePath.Substring(0,3)} | ForEach-Object -Process {
                        if (-not ($_.BackupOptions.ExcludeRules.FileExcludeRule | Where-Object Folder -eq $ExcludePath.Remove(0,2))){
                            $element = ($_.BackupOptions.SelectSingleNode(".//ExcludeRules")).AppendChild($BackupPlanXml.CreateElement("FileExcludeRule"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Folder")).AppendChild($BackupPlanXml.CreateTextNode($ExcludePath.Remove(0,2)))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Mask")).AppendChild($BackupPlanXml.CreateTextNode("*"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Recursive")).AppendChild($BackupPlanXml.CreateTextNode("true"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("DeleteFolder")).AppendChild($BackupPlanXml.CreateTextNode("true"))
                        }
                    }
                }

                foreach ($ExcludePath in $ExcludeDirectory) {
                    $BackupPlanXml.BasePlan.DiskInfo.DiskInfoCommunication.Volumes.VolumeInfoCommunication | Where-Object {$_.MountPoints.string -eq $ExcludePath.Substring(0,3)} | ForEach-Object -Process {
                        if (-not ($_.BackupOptions.ExcludeRules.FileExcludeRule | Where-Object Folder -eq $ExcludePath.Remove(0,2))){
                            $element = ($_.BackupOptions.SelectSingleNode(".//ExcludeRules")).AppendChild($BackupPlanXml.CreateElement("FileExcludeRule"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Folder")).AppendChild($BackupPlanXml.CreateTextNode($ExcludePath.Remove(0,2)))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Mask")).AppendChild($BackupPlanXml.CreateTextNode("*"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("Recursive")).AppendChild($BackupPlanXml.CreateTextNode("true"))
                            $null = $element.AppendChild($BackupPlanXml.CreateElement("DeleteFolder")).AppendChild($BackupPlanXml.CreateTextNode("true"))
                        }
                    }
                }
                $BackupPlanXml.BasePlan.ExcludeEnabled = "true"

                Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
            }elseif ($null -ne $ExecuteChainedPlan){
                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                if($ExecuteChainedPlan){
                    $null = $BackupPlanXml.BasePlan.RemoveChild($BackupPlanXml.BasePlan.selectSingleNode("//NextExectutionPlan"))
                    $null = ($BackupPlanXml.selectSingleNode("//BasePlan")).AppendChild($BackupPlanXml.CreateElement("NextExectutionPlan")).AppendChild($BackupPlanXml.CreateTextNode("$ChainedPlanID"))
                    $BackupPlanXml.BasePlan.ExecuteNextPlanOnlyIfSucces = $ExecuteChainedPlanAnyway.ToString().ToLower()
                    $BackupPlanXml.BasePlan.ForceFullNextPlan = $ForceFullChainedPlan.ToString().ToLower()
                    $BackupPlanXml.BasePlan.ExecuteNextPlan = $ExecuteChainedPlan.ToString().ToLower()
                    $Null = Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                }else{
                    $BackupPlanXml.BasePlan.ExecuteNextPlan = "false"
                    $Null = Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
                }
            }else{
                if($_ -ne $null){
                    if($_.Type -eq "Plan" -and $FileLevelParameterSet){
                        $Arguments = " editBackupPlan"
                    }elseif ($_.Type -eq "BackupDiskImagePlan" -and $ImageBasedParameterSet) {
                        $Arguments = " editBackupIBBPlan"
                    }elseif ($CommonParameterSet) {
                        switch ($_.Type) {
                            'Plan' {$Arguments = " editBackupPlan"}
                            'BackupDiskImagePlan' {$Arguments = " editBackupIBBPlan"}
                            Default {
                                Write-host "$_ type is not supported by the Cmdlet" -ForegroundColor Red
                                return 
                            }
                        }
                    }else{
                        Write-host "Backup plan """($_.Name)""" is skipped" -ForegroundColor Red 
                        return 
                    }
                }
                else{
                    if ($FileLevelParameterSet) {
                        $Arguments = " editBackupPlan"
                    }elseif ($ImageBasedParameterSet) {
                        $Arguments = " editBackupIBBPlan"
                    }elseif ($CommonParameterSet) {
                        switch ($BackupPlan.Type) {
                            'Plan' {$Arguments = " editBackupPlan"}
                            'BackupDiskImagePlan' {$Arguments = " editBackupIBBPlan"}
                            Default {
                                Write-host "$($BackupPlan.Type) type is not supported by the Cmdlet" -ForegroundColor Red
                                return 
                            }
                        }
                    }
                }
            
                if ($ID){
                    $Arguments += " -id $ID"
                    $Arguments += Set-Arguments  # -Arguments $Arguments
                }else{
                    $Arguments += " -n ""$Name"""
                    $Arguments += Set-Arguments #($Arguments)
                }
                if($Arguments -notmatch '^( editBackupPlan| editBackupIBBPlan) (-id [0-9A-Fa-f]{8}(?:-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}|-n "[^"]*")$'){
                    (Start-MBSProcess -CMDPath $CBB.CBBCLIPath -CMDArguments $Arguments -Output short -MasterPassword $MasterPassword).result
                }
            }
            if ($null -ne $KeepBitLocker){
                $BackupPlanXml = [xml](Get-Content ($CBB.CBBProgramData+"\"+$BackupPlan.ID+".cbb"))
                $BackupPlanXml.BasePlan.DiskInfo.DiskInfoCommunication.Volumes.VolumeInfoCommunication | ForEach-Object -Process {
                    $_.BackupOptions.KeepBitLocker = $KeepBitLocker.ToString().ToLower()
                }
                $Null = Import-Configuration -BackupPlanXml $BackupPlanXml -MasterPassword $MasterPassword
            }
        }
    }
    
    end {
        
    }
}
# SIG # Begin signature block
# MIIbfQYJKoZIhvcNAQcCoIIbbjCCG2oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBGebDyfzmAr7Oy
# 8cGyLgLqWKqxNoa+8xW47DYvS9GkPaCCC04wggVmMIIETqADAgECAhEA3VtfmfWb
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
# NwIBFTAvBgkqhkiG9w0BCQQxIgQgGxCVERX6f5BWk3mTU3wl8FFijrmtnWFkt3DT
# iqH3YWEwDQYJKoZIhvcNAQEBBQAEggEAYp6kSU2Y42mGWGeeWPgWupMvtR4ztmAY
# MwyOOMuz5QoAOydhKhM4Kx9kgFGJottqqBiyOVxjPwOMOa6EDwxGFEX5kgsgq7oc
# n3lFJIMxBJ/3PWOvJnNZECfWHQ0tb+nBmlwG5gksiELPAM8uue69l5yi1KiBTPmN
# ASzeRRdC6GOEC/NLC0cRzN+MdvREGL2+elnrLRlJEhiP6p9+nPBADDRgbO8gW7hT
# T+fhjLWk3w+YNDkTkWXjpTl5kLN88rgiCfbrkxn+Qa/WoFWFvoe6GkMlLFJPgMx5
# feSUm0ho5lfFx8mc15rTVsrPfAH3tx6Rd+KSsWFPbLRu7OpFk3ayuqGCDUUwgg1B
# BgorBgEEAYI3AwMBMYINMTCCDS0GCSqGSIb3DQEHAqCCDR4wgg0aAgEDMQ8wDQYJ
# YIZIAWUDBAIBBQAweAYLKoZIhvcNAQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAx
# MA0GCWCGSAFlAwQCAQUABCBz4yBUlKCfAiEZPwbAN5BHEifYvtDU39X92kfKHx7M
# SgIRAK6Fe3OO6cNYCWUlrzer+N4YDzIwMjEwMTI2MDgxMTIwWqCCCjcwggT+MIID
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
# AQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMTAxMjYwODExMjBa
# MCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8G
# CSqGSIb3DQEJBDEiBCByK58PqWXumld7Cacrbe4e+NOb0g/JmohcA9gE2/zJiTAN
# BgkqhkiG9w0BAQEFAASCAQBNQs+4UIMZWup24mWBk6h1bCYYlToyNRNEDveYauoc
# tPCisHtMZVKXcbIzv7wVBNgTyt7SLmTPXlbu5AecWFdrPyRrE8cae8aJGSc+NPq2
# evMW2SGPA2uIaUQygUmecyoAxT0DBSko/pBcWGcFwH8V7T+WHZ/Uj4/4NEyqZc/V
# q9T01eSvabueOvU7UcjrXJOmP+0ZyI2tAbKyzBuFZ+YKtE3Up+3vfl7Bwm1PpDj3
# gcA/fJIDu/q7cK3k0uu+jq7yzIotfKuFYbe7WbtPS+yu9hsiHM5mHkM1y83DPg4A
# rebI5eMv4Pgjk20FJKB83K2qcfcRGHwwQUvkuPNY/tXP
# SIG # End signature block
