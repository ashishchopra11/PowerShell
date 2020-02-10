############## Reference to configuration files ###################################
CLS
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
#$XMLFolderPath="\\hcm97\PMPDataFeeds\Geneva"
####################################################################################

#$dirSSISExtractGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\ExtractGeneva\bin"
#$dirSSISNormalizeGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\NormalizeGeneva\bin"



## Log File Creation
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\ExtractGenevaDailyPriorWeekHistory.$logTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition


$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
$curr_date = Get-Date

if ($curr_date.DayOfWeek -eq "Sunday") {
	$end_day = ($curr_date).AddDays(-3)
} elseif ($curr_date.DayOfWeek -eq "Monday") {
	$end_day = ($curr_date).AddDays(-4)
} elseif ($curr_date.DayOfWeek -eq "Tuesday") {
	$end_day = ($curr_date).AddDays(-4)
} else {
	$end_day = ($curr_date).AddDays(-2)
}

$start_day = ($end_day).AddDays(-6)

while ($start_day -le $end_day) {
	$date_string = Get-Date -Date $start_day -UFormat %x

    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed ExtractGenevaPosition.dtsx `r`n "| Out-File $LogFile -Append

    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed ExtractGenevaPositionPL.dtsx `r`n "| Out-File $LogFile -Append
  
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaYTDPnLDifference.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaYTDPnLDifference.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaYTDPnLDifference.dtsx `r`n "| Out-File $LogFile -Append
	
	$start_day = $start_day.AddDays(1)
}
