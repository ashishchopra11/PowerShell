############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1

####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Archive folder
$strDateNow = Get-Date -format "yyyyMMddTHHmmss"
#$LogFile    = "$dirLogFolder\ExtractWSO_YTD"+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$NotificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

	
	Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

	$enc = [system.Text.Encoding]::UTF8

	$today_date = get-date
	$current_date = ($today_date).AddDays(-1)
	$current_string = $current_date.ToString("yyyy-MM-ddT00:00:00Z")
	$current_payload = "<ReportParameters><ReportId>12</ReportId><RunDate>$current_string</RunDate></ReportParameters>"
	$current_payload_encoded = $enc.GetBytes($current_payload) 

	######Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

	Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $current_payload_encoded
	
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName END `r`n" |   Out-File $LogFile -Append
