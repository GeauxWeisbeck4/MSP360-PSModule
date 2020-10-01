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
        [switch]
        $FileLevelParameterSet,
        #
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to Image-Based backup plan type", ParameterSetName='ImageBased')]
        [switch]
        $ImageBasedParameterSet,
        #
        [Parameter(Mandatory=$True, HelpMessage="Backup plan settings related to any backup plan type. Like Encryption, Compression, Retention policy, Schedule, etc.", ParameterSetName='Common')]
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
        #[Parameter(Mandatory=$False, HelpMessage="Specify force full time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfterForceFull ""20:30"" or -stopAfterForceFull ""100:00"" etc.", ParameterSetName='Common')]
        #[Parameter(Mandatory=$False, HelpMessage="Specify force full time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfterForceFull ""20:30"" or -stopAfterForceFull ""100:00"" etc.", ParameterSetName='ImageBased')]
        #[Parameter(Mandatory=$False, HelpMessage="Specify force full time in HH:MM to stop the plan if it runs for HH hours MM minutes. Example -stopAfterForceFull ""20:30"" or -stopAfterForceFull ""100:00"" etc.", ParameterSetName='FileLevel')]
        #[string]
        #$stopAfterForceFull,
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
            if ((Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -ne "" -and (Get-MBSAgentSetting -ErrorAction SilentlyContinue).MasterPassword -ne $null -and -not $MasterPassword) {
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
                        Write-Verbose -Message "Arguments: $Argument"
                        $Argument += " -v $_"
                        Write-Verbose -Message "Arguments: $Argument"
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
                            if ($MasterPassword) {
                                if ($MasterPassword){$Arguments += " -mp """+([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterPassword)))+""""}
                            }
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
                                Write-Verbose -Message "Arguments: $Arguments"
                                Start-Process -FilePath $CBB.CBBCLIPath -ArgumentList $Arguments -NoNewWindow -Wait
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
                }else{
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

                if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent){
                    $Arguments += ' -output full'
                }else{
                    $Arguments += ' -output short'
                }

                Write-Verbose -Message "Arguments: $($Arguments -replace  '-mp "\w*"','-mp "****"')"
                Start-Process -FilePath $CBB.CBBCLIPath -ArgumentList $Arguments -Wait -NoNewWindow #-WindowStyle Hidden
            }
        }
    }
    
    end {
        
    }
}
