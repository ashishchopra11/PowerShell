############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
##$XMLFolderPath="\\hcm97\PMPDataFeeds\Geneva"
####################################################################################
$ScriptName = $MyInvocation.MyCommand.Definition

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

## Log File Creation
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\ExtractGenevaPosition.$logTime.txt" 
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

#$dirSSISExtractGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\ExtractGeneva\bin"
#$dirSSISNormalizeGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\NormalizeGeneva\bin"

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

Write-Output " XMLFolderPath	= $XMLFolderPath" |  Out-File $LogFile -Append
Write-Output " logFile			= $logFile" |  Out-File $LogFile -Append


$start_day = Get-Date -Date "12/31/2018"
$end_day = Get-Date -Date "03/16/2018"

$today_day = Get-Date
if ($today_day.DayOfWeek -eq "Sunday") {
	$max_day = $today_day.AddDays(-2)
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today ($today_day) is a Sunday so max_day will be set to C-2 ($max_day) " | Out-File $LogFile -Append
}
elseif ($today_day.DayOfWeek -eq "Monday") {
	$max_day = $today_day.AddDays(-3)
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today ($today_day) is a Monday so max_day will be set to C-3 ($max_day) " | Out-File $LogFile -Append
}
else {
	$max_day = $today_day.AddDays(-1)
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today ($today_day) is not a Sunday or Monday so max_day will be set to C-1 ($max_day) " | Out-File $LogFile -Append
}

if ($max_day -lt $end_day) {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  max_day ($max_day) is less than entered end_day ($end_day), which is not allowed. end_day will be set to $max_day instead " | Out-File $LogFile -Append
	$end_day = $max_day
}
else {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  end_day ($end_day) is less than entered max_day ($max_day) - no issue " | Out-File $LogFile -Append
}

Write-Output " start_day		= $start_day" |  Out-File $LogFile -Append
Write-Output " end_day			= $end_day" |  Out-File $LogFile -Append

while ($start_day -le $end_day) {
	$curr_day = $start_day

	$date_string = Get-Date -Date $start_day -UFormat %x
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n  Label = $PositionLabel" | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append

#NormalizeGenevaYTDPnLDifference
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaYTDPnLDifference.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append
	
	
$start_day = $start_day.AddDays(1)
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append