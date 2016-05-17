$date = (Get-Date).tostring("yyyyMMdd")
$dag = Get-DatabaseAvailabilityGroup | select -ExpandProperty name
$folder = ($date + "-" + $dag + "-EXDK")
New-Item -ItemType Directory -Path .\ -Name $folder

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Get-EASDeviceReport.ps1
.\Get-ExchangeEnvironmentReport.ps1 -HTMLReport .\$folder\EnvironmentReport.html
.\Get-MailboxReport.ps1 -all
.\Get-PublicFolderReport.ps1
.\Get-PublicFolderReplicationReport.ps1 -AsHTML -Filename .\$folder\PublicFolderReplicationReport.html
.\Get-ExchangeCertificateReport.ps1
.\Get-MailboxPermissionsReport.ps1 -HTMLReport .\$folder\MailboxPermissionReport.html
.\DistributionGroupMemberReport.ps1
.\DynamicDistributionGroupMemberReport.ps1

Get-Mailbox -Filter {LitigationHoldEnabled -eq $True} -resultsize unlimited | Get-MailboxStatistics | ft DisplayName > .\$folder\LitHoldMailboxes.txt
Get-TransportConfig | Select-Object MaxReceiveSize,MaxSendSize | fl > .\$folder\EnvConfig.txt
Get-SendConnector | Select-Object Name,MaxMessageSize >> .\$folder\EnvConfig.txt
Get-ReceiveConnector | Select Server,Name,MaxMessageSize >> .\$folder\EnvConfig.txt
Get-MailboxDatabase -IncludePreExchange2010 | Select Name,ProhibitSend*,IssueWarning* >> .\$folder\EnvConfig.txt
Get-OwaVirtualDirectory >> .\$folder\EnvConfig.txt
Get-OabVirtualDirectory >> .\$folder\EnvConfig.txt
Get-ActiveSyncVirtualDirectory >> .\$folder\EnvConfig.txt
Get-EcpVirtualDirectory >> .\$folder\EnvConfig.txt

Get-SendConnector | fl > .\$folder\EnvConfigDetailed.txt
Get-ReceiveConnector | fl >> .\$folder\EnvConfigDetailed.txt
Get-OwaVirtualDirectory | fl >> .\$folder\EnvConfigDetailed.txt
Get-OabVirtualDirectory | fl >> .\$folder\EnvConfigDetailed.txt
Get-ActiveSyncVirtualDirectory | fl >> .\$folder\EnvConfigDetailed.txt
Get-EcpVirtualDirectory | fl >> .\$folder\EnvConfigDetailed.txt

Get-MailboxDatabase -Status | select Name,EdbFilePath,LogFolderPath,@{Name='DB Size (Gb)';Expression={$_.DatabaseSize.ToGb()}} | Export-Csv .\$folder\DBLogPaths.csv

Get-Mailbox | select DisplayName,LegacyExchangeDN | Export-Csv .\$folder\LegacyExchangeDNs.csv