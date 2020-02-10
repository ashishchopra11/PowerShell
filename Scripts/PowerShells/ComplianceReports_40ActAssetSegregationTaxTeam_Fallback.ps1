############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1

####################################################################################
$dirScriptsPath = "$dirScriptsFolder\PROD"
Set-Location $dirScriptsPath
. .\FortyActHelperFunctions.ps1

####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}
$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\FortyActMonitoringFinal."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$smtpServer="mail.hcmlp.com"
$fromAddress = "intranet@hcmlp.com"

Write-Output " SmtpServer		= $smtpServer" 			|  Out-File $LogFile -Append
Write-Output " FromAddress		= $fromAddress" 		|  Out-File $LogFile -Append
Write-Output " LogFile			= $LogFile" 			|  Out-File $LogFile -Append


Try
{

    	$toList = $highlandToList
		$ccList = $highlandCCList
		$fundName="All"
		$date = get-date -format ("MM/dd/yyyy")
		$subject= "Daily 1940 Act Monitoring for " + $date
		Invoke-FortyAct -preliminary "false" -fallback "true" -env "production" -schedule "Early"

}
Catch [system.exception]
{
	Write-Output "`n`n################ failed preliminary 1940 Act monitoring `r`n" |  Out-File $LogFile -Append
	
	$ErrorMessage = $_.Exception.Message
	Write-Output "`n`n################ $ErrorMessage `r`n" |  Out-File $LogFile -Append
    
    Send-MailMessage -SmtpServer $smtpServer -From $fromAddress -To "etsimberg@hcmlp.com" -Subject "1940 Act Warning Failed" -Body $ErrorMessage
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append