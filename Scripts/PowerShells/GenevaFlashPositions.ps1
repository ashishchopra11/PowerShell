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

## Log File Creation
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\ExtractGenevaFlash.$logTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
#$start_day = Get-Date -Date "1/05/2009"
#$end_day = Get-Date -Date "1/19/2009"
#
#while ($start_day -le $end_day) {
#$curr_day = Get-Date -Date $start_day

$curr_day = Get-Date -Date "07/14/2017"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

Write-Output " XMLFolderPath	= $XMLFolderPath" |  Out-File $LogFile -Append
Write-Output " logFile			= $logFile" |  Out-File $LogFile -Append

$curr_day = Get-Date 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Extract Geneva Flash starts here " | Out-File $LogFile -Append

if ($curr_day.DayOfWeek -eq "Sunday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Sunday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
elseif ($curr_day.DayOfWeek -eq "Monday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Monday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
else {
$rpt_date_list = $curr_day.AddDays(-1)
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  The Process will run for one day :: $rpt_date_list " | Out-File $LogFile -Append
}

$rpt_date_list | Sort-Object | ForEach-Object -Process {

$rpt_date = [datetime]$_ 

$date_string = Get-Date -Date $rpt_date -UFormat %x


## Extract Positions Flash
$PositionLabel		= "Position Flash"
 ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n  Label = $PositionLabel" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"  /set "\package.variables[Label].Value;$PositionLabel" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |   Out-File $LogFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Flash: Not success " | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Flash: Imported" | Out-File $LogFile -Append
## Extract PositionPL Flash wiht StartDate
$StartDate	 		= Get-Date $rpt_date -Format "MM/dd/yyyy" -Day 1 
$PositionPLLabel	= "PositionStratPLITD Flash"

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n  Label = $PositionPLLabel `r`n  StartDate = $StartDate"| Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[StartDate].Value;$StartDate" /set "\package.variables[Label].Value;$PositionPLLabel" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |   Out-File $LogFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Flash: Not success " | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Flash: Imported" | Out-File $LogFile -Append
	
## Normalize Position Flash
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"  /set "\package.variables[FlashFlag].Value;Flash" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |   Out-File $LogFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Flash: NormalizeGenevaPositions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append