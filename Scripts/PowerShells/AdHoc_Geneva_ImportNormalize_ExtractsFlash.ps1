############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################

#$start_day = Get-Date -Date "1/05/2009"
#$end_day = Get-Date -Date "1/19/2009"
#
#while ($start_day -le $end_day) {
#$curr_day = Get-Date -Date $start_day

#$curr_day = Get-Date -Date "08/14/2015"

$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\ExtractGenevaFlashAdhoc.$logTime.txt" 
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
$curr_day = Get-Date "08/12/2017"
s
#if ($curr_day.DayOfWeek -eq "Sunday") {
#break ;
#}
#elseif ($curr_day.DayOfWeek -eq "Monday") {
#break ;
#}
#elseif ($curr_day.DayOfWeek -eq "Tuesday") {
#$rpt_date_list = $curr_day.AddDays(-3), $curr_day.AddDays(-2), $curr_day.AddDays(-1)
#}
#else {
$rpt_date_list = $curr_day.AddDays(-1)
#}

$rpt_date_list | Sort-Object | ForEach-Object -Process {

$rpt_date = [datetime]$_ 

$date_string = Get-Date -Date $rpt_date -UFormat %x

## Extract Positions Flash
$PositionLabel		= "Position Flash"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  Label = $PositionPLLabel  `r`n  XMLFolderPath = $XMLFolderPath "  | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
 & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"  /set "\package.variables[Label].Value;$PositionLabel" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed ExtractGenevaPosition.dtsx `r`n "| Out-File $LogFile -Append

## Extract PositionPL Flash wiht StartDate
$StartDate	 		= Get-Date $rpt_date -Format "MM/dd/yyyy" -Day 1 
$PositionPLLabel	= "PositionStratPLITD Flash"

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  StartDate = $StartDate `r`n  Label = $PositionPLLabel  `r`n  XMLFolderPath = $XMLFolderPath "  | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[StartDate].Value;$StartDate" /set "\package.variables[Label].Value;$PositionPLLabel" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName"   | Out-File $LogFile  -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed ExtractGenevaPositionPL.dtsx `r`n "| Out-File $LogFile -Append

## Normalize Position Flash
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = $Flash " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder" /set "\package.variables[FlashFlag].Value;Flash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append