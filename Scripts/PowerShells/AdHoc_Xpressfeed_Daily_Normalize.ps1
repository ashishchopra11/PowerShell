############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################
################## Xpressfeeds Normalize Daily



###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Log file
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logTime = get-date -format "yyyyMMddTHHmmss"
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+$logTime+".txt"
#$logFile = "$dirLogFolder\NormalizeVendorXpressfeed.$strDateNow.txt"

$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$runDate 			= Get-Date "2018/01/07"

#$FullDayString		= $runDate.date.ToString("MM/dd/yyyy")
$FullDayString		= $runDate.AddDays(-1).date.ToString("MM/dd/yyyy")
$FromFullDayString  = $runDate.AddDays(-16).date.ToString("MM/dd/yyyy")

Write-Output " runDate		        = $runDate `r`n" | Out-File $LogFile -Append
Write-Output " FullDayString	        = $FullDayString `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append
Write-Output " FromFullDayString		        = $FromFullDayString  `r`n" | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
#	$FullDayString = "2017/07/02"
	
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeVendorSPXpressfeed.dtsx `r`n Variable passed here are : `r`n  FromRefDataSetDate = $FromFullDayString `r`n RefDataSetDate = $FullDayString  `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


##################################################### NormalizeVendorRatingExpress.dtsx
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorSPXpressfeed.dtsx" /set "\package.variables[FromRefDataSetDate].Value;$FromFullDayString" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExpressFeed : NormalizeVendorSPXpressfeed.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BNP Positions  : Normalization Complete" | Out-File $LogFile -Append

<#
$FromFullDayString = "04/16/2016"
$FullDayString = "05/05/2016"
##################################################### NormalizeVendorRatingExpress.dtsx
& $2012DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorSPXpressfeed.dtsx" /set "\package.variables[FromRefDataSetDate].Value;$FromFullDayString" /set "\package.variables[RefDataSetDate].Value;$FullDayString" | Out-File -encoding ASCII -append -filePath $logFile
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append