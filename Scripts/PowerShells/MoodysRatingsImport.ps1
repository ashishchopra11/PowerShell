############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
####################################################################################

#$XMLFolderPath="D:\Siepe\DataFeeds\Moodys"
$dirSourceFolder = "$dirServicesDeliveryStoreFolder\Moodys Ratings"

$ArchiveDir = "$dirArchiveHCM97DriveFolder\Moodys Ratings\Archive"
#$dirDestinationFolder  =  "$dirArchiveHCM97DriveFolder\Moodys\RDS"
$dirDestinationFolder  =  "$dirSourceFolder\RDSExtract"

if(-not(Test-Path -Path $dirDestinationFolder))
{
	New-Item -Path $dirDestinationFolder -ItemType "directory"
}

## Log File Creation
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\MoodysRatings.$logTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

  
$dtDate = Get-Date
$RefDataSetDateStr = Get-Date -Format "MM/dd/yyyy"
#$RefDataSetDateStr = "08/16/2016"

## Move Files to RDSExtract 
Write-Output "Moving files from $dirSourceFolder to $dirDestinationFolder****" | Out-File $logFile -Append
Move-Item "$dirSourceFolder\*current_rating_Utf8_Baseline_Daily*.Zip" -Destination $dirDestinationFolder -Force

$strDate = $logTime 
if (!(Test-Path -path $ArchiveDir\$strDate)) 
{ 
	New-Item -path $ArchiveDir\$strDate -ItemType directory 
} 
Write-Output "Extracting files from $dirDestinationFolder to $dirDestinationFolder****" | Out-File $logFile -Append
foreach ($file in Get-ChildItem	-Path $dirDestinationFolder | Where-Object {$_.Name -ilike "cfg_inst_current_rating_Utf8_Baseline_Daily_*.zip"}) 
{

	[String]$FileFullPath = $file.FullName
 	Expand-ZIPFile –File $FileFullPath –Destination $dirDestinationFolder
	Write-Output "File  $file extracted." | Out-File $logFile -Append
	
}   
#Import

	Write-Output "ImportCustodianMoodysIssuerRatings for RefDataSetDate : $RefDataSetDateStr started at: $($dtDate.ToString()) " | Out-File $logFile -Append
 	& $2016DTEXEC32 /f "$dirSSISExtractCustodian\ImportCustodianMoodysInstrumentRatings.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDateStr" /set "\package.variables[FolderName].Value;$dirDestinationFolder"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
	$dtDate = Get-Date
	Write-Output "ImportCustodianMoodysIssuerRatings for RefDataSetDate : $RefDataSetDateStr completed at: $($dtDate.ToString())" | Out-File $logFile -Append
	Write-Output "=============================================================================================================" | Out-File $logFile -Append
	
	Sleep -Seconds 30
	Remove-File -path "$dirDestinationFolder/cfg_inst_current_rating_Utf8_Baseline_Daily_*.XML"
	Move-Item -Path $dirDestinationFolder\cfg_inst_current_rating_Utf8_Baseline_Daily_*.ZIP -Destination $ArchiveDir\$strDate
	
Write-Output "Extracting files from $dirSourceFolder to $dirDestinationFolder****" | Out-File $logFile -Append
foreach ($file in Get-ChildItem	-Path $dirDestinationFolder | Where-Object {$_.Name -ilike "cfg_organization_current_rating_Utf8_Baseline_Daily_*.zip"}) 
{

	[String]$FileFullPath = $file.FullName
 	Expand-ZIPFile –File $FileFullPath –Destination $dirDestinationFolder
	Write-Output "File  $file extracted." | Out-File $logFile -Append
	
}

	Write-Output "ImportCustodianMoodysIssuerRatings for RefDataSetDate : $RefDataSetDateStr started at: $($dtDate.ToString()) " | Out-File $logFile -Append
 	& $2016DTEXEC32 /f "$dirSSISExtractCustodian\ImportCustodianMoodysIssuerRatings.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDateStr" /set "\package.variables[FolderName].Value;$dirDestinationFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
	$dtDate = Get-Date
	Write-Output "ImportCustodianMoodysIssuerRatings for RefDataSetDate : $RefDataSetDateStr completed at: $($dtDate.ToString())" | Out-File $logFile -Append
	
	Sleep -Seconds 30
	Remove-File -path "$dirDestinationFolder/cfg_organization_current_rating_Utf8_Baseline_Daily_*.XML"
	Move-Item -Path $dirDestinationFolder\cfg_organization_current_rating_Utf8_Baseline_Daily_*.ZIP -Destination $ArchiveDir\$strDate

## Normalize

	Write-Output "NormalizeVendorMoodys for RefDataSetDate : $RefDataSetDateStr started at: $($dtDate.ToString()) " | Out-File $logFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorMoodysRatings.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDateStr" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
	$dtDate = Get-Date
	Write-Output "NormalizeVendorMoodys for RefDataSetDate : $RefDataSetDateStr completed at: $($dtDate.ToString())" | Out-File $logFile -Append
	Write-Output "=============================================================================================================" | Out-File $logFile -Append
	
##Push

& $2016DTEXEC32 /F "$dirSSISPush\PushRatings.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDateStr"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"|  Out-File $logFile  -Append
		
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
  