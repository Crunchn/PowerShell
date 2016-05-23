$now = Get-Date
$present = (Get-Date).ToString("yyyyMMdd")
$reportemailsubject = "Mailbox Permissions"
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background-color: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
$smtpsettings = @{
	To =  "exchangemonitoring@server.net"
	From = "exreports@server.net"
	Subject = "$reportemailsubject - $now"
	SmtpServer = "smtp.server.net"
	}
    
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


Get-ChildItem -Recurse C:\Scripts\MailPermAuditLogs\DiffLogs | Get-Content | Out-String | Out-File C:\Scripts\MailPermAuditLogs\DiffMailEvent\$present.csv

$htmlreport = Import-Csv -Header Event,AccessRights C:\Scripts\MailPermAuditLogs\DiffMailEvent\$present.csv | ConvertTo-Html -Head $style

Send-MailMessage @smtpsettings -BodyAsHtml ($htmlreport | Out-String)

Move-Item C:\Scripts\MailPermAuditLogs\DiffLogs\*.csv C:\Scripts\MailPermAuditLogs\PostEventDiffLogs\