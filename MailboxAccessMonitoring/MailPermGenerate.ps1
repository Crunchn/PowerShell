$present = (Get-Date).ToString("yyyyMMddHH")
$past = (Get-Date).AddHours(-1).ToString("yyyyMMddHH")

if (!(Get-PSSnapin | where {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"}))
{
	try
	{
		Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction STOP
	}
	catch
	{
		#Snapin was not loaded
		Write-Warning $_.Exception.Message
		EXIT
	}
	. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
	Connect-ExchangeServer -auto -AllowClobber
}


Get-Mailbox -ResultSize unlimited | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | Export-Csv -NoTypeInformation C:\Scripts\MailPermAuditLogs\PermCSVLogs\$present.csv

Compare-Object -ReferenceObject (Get-Content C:\Scripts\MailPermAuditLogs\PermCSVLogs\$past.csv) -DifferenceObject (Get-Content C:\Scripts\MailPermAuditLogs\PermCSVLogs\$present.csv) | ConvertTo-Csv -NoTypeInformation | select -Skip 1 | Set-Content C:\Scripts\MailPermAuditLogs\DiffLogs\$present.csv