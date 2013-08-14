$ErrorActionPreference = "SilentlyContinue"

function RunSendEmail
{
	$FromAddress = "no-reply-BarracudaIssues@domain.com"
	#$ToAddress = "alerts@domain.com,craig.irvin@domain.com"
	$ToAddress = "email@domain.com"
	$MessageSubject = "Barracuda Spamfilter Issues Found"
	$MessageBody = get-content body.txt
	$SendingServer = "<IP or DNS name of SMTP server>"

	###Create the mail message and add the statistics text file as an attachment
	$SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress,$ToAddress,$MessageSubject,$MessageBody
	$SMTPMessage.IsBodyHtml = $false
	###Send the message
	$SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
	$SMTPClient.Send($SMTPMessage)
}

function ConnectToDevice
{
	param($DeviceURL,$DeviceShortName)
	$XMLObject = New-Object XML
	Write-Host "Loading up XML output for device $DeviceURL"
	$XMLObject.Load($DeviceURL)
	
	If ( $XMLObject.stats -ne $NULL)
	{
		[int]$OutboundQSize = $XMLObject.stats.performance.outbound_queue_size
		[int]$InboundQSize = $XMLObject.stats.performance.inbound_queue_size
		[int]$LatencySeconds = $XMLObject.stats.performance.latency_seconds
		[int]$SysTempCelsius = $XMLObject.stats.performance.sys_temp_celsius
		[int]$CpuTempCelsius = $XMLObject.stats.performance.cpu_temp_celsius	
	
		If ($InboundQSize -ge $global:InboundQueueSize)
		{
			Add-Content body.txt "$DeviceShortName Inbound queue size is currently $InboundQSize which is abnormal.`f"
			Write-Host "$DeviceShortName Inbound queue: $InboundQSize ==> Metric: $global:InboundQueueSize"
			$global:ErrorCount ++
		}
		
		If ($OutboundQSize -ge $global:OutboundQueueSize)
		{
			Add-Content body.txt "$DeviceShortName Outbound queue size is currently $OutboundQSize which is abnormal.`f"
			Write-Host "$DeviceShortName Outbound queue: $OutboundQSize ==> Metric: $global:OutboundQueueSize"
			$global:ErrorCount ++
		}

		If ($LatencySeconds -ge $global:LatencySeconds)
		{
			Add-Content body.txt "$DeviceShortName is experiencing a high latency of over $global:LatencySeconds seconds.`f"
			Write-Host "$DeviceShortName Latency: $LatencySeconds ==> Metric: $global:LatencySeconds"
			$global:ErrorCount ++
		}
		
		If ($SysTempCelsius -ge $global:SysTempCelsius -OR $CpuTempCelsius -ge $global:CpuTempCelsius)
		{
			Add-Content body.txt "$DeviceShortName is running hot! System Temp: $SysTempCelsius Celsius and CPU Temp: $CpuTempCelsius Celsius.`f"
			Write-Host "$DeviceShortName System Temp: $SysTempCelsius ==> Metric: $global:SysTempCelsius"
			Write-Host "   CPU Temp: $CpuTempCelsius ==> Metric: $global:CpuTempCelsius"
			$global:ErrorCount ++
		}
	}
	else
	{
		Write-Host "Could not connect to $DeviceShortName"
	}
}


$Devices = Import-CSV Devices.csv
$global:ErrorCount = 0
if ((test-path body.txt) -eq $true)
{
	remove-item body.txt
}
get-content MonitorSettings.ini | foreach-object {$iniData = @{}}{$iniData[$_.split('=')[0]] = $_.split('=')[1]}
[int]$global:OutboundQueueSize = $iniData.OutboundQueueSize
[int]$global:InboundQueueSize = $iniData.InboundQueueSize
[int]$global:LatencySeconds = $iniData.LatencySeconds
[int]$global:SysTempCelsius = $iniData.SysTempCelsius
[int]$global:CpuTempCelsius = $iniData.CpuTempCelsius

foreach ($Device in $Devices)
{
	$DeviceURL = $Device.URL
	$DeviceShortName = $Device.ShortName
	ConnectToDevice $DeviceURL $DeviceShortName
}

if ($global:ErrorCount -gt 0)
{
	RunSendEmail
}
