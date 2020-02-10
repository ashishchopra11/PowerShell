############## Reference to configuration files ###################################
CLS
Clear-Host
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################

### A list of days to process  ...
New-Variable process_days_list

### Today's date ...
New-Variable curr_date

$curr_date = Get-Date
$ErrorFileLocation = "$dirArchiveHCM46DriveFolder\WSOTransactions\Archive\"

$strDateNow = get-date -format "yyyyMMddTHHmmss"

#$logFile = "$dirLogFolder\WSOTransactions"+$strDateNow+".txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

### Do not load on Sunday or Monday
if ($curr_date.DayOfWeek -eq "Sunday") {
  break ;
} elseif ($curr_date.DayOfWeek -eq "Monday") {
  break ;
} elseif ($curr_date.DayOfWeek -eq "Tuesday") {
  ### Load Saturday, Sunday, and Monday on Tuesday morning ...
  $process_days_list = (Get-Date).AddDays(-3),(Get-Date).AddDays(-2),(Get-Date).AddDays(-1)
} else {
  $process_days_list = (Get-Date).AddDays(-1)
}

### Process each load day ...
$process_days_list | Sort-Object -Descending | ForEach-Object -Process {

  $process_date = $_

	$FullDayString = $process_date.ToString("MM/dd/yyyy")
#$FullDayString = '2017/03/17'
  ### -- Normalize into Reference
   & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractActionCode.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

   & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractTransaction.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[ErrorFileLocation].Value;$ErrorFileLocation" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

  
#  if ($process_date.DayOfWeek -eq "Saturday" -OR $process_date.DayOfWeek -eq "Sunday") {
#    & dtexec /f "$SSIS_Normalize_Dir\NormalizeWSOExtractTrade.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString"
#	}
}