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
#$logFile = "$dirLogFolder\ExtractGenevaPositionsEOD.$logTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

Write-Output " XMLFolderPath	= $XMLFolderPath" |  Out-File $LogFile -Append
Write-Output " logFile			= $logFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Extract Geneva starts here " | Out-File $LogFile -Append

#$start_day = Get-Date -Date "1/05/2009"
#$end_day = Get-Date -Date "1/19/2009"
#
#while ($start_day -le $end_day) {
#$curr_day = Get-Date -Date $start_day
$curr_day = Get-Date
##$curr_day = Get-Date -Date "9/18/2015"



if ($curr_day.DayOfWeek -eq "Sunday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Sunday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
elseif ($curr_day.DayOfWeek -eq "Monday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Monday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
elseif ($curr_day.DayOfWeek -eq "Tuesday") {
$rpt_date_list = $curr_day.AddDays(-3), $curr_day.AddDays(-2), $curr_day.AddDays(-1)
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Tuesday so Process will run for past 3 days `r`n $rpt_date_list " | Out-File $LogFile -Append
}
else {
$rpt_date_list = $curr_day.AddDays(-1)
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  The Process will run for one day :: $rpt_date_list " | Out-File $LogFile -Append
}
 




$rpt_date_list | Sort-Object | ForEach-Object -Process {
$rpt_date = [datetime]$_ 
$date_string = Get-Date -Date $rpt_date -UFormat %x
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	$Label = $null
	$Addendum_ErrorsLabel = $null
	
	$Label = "Position EOD"
	$Addendum_ErrorsLabel = "Addendum Errors – Position Load EOD"
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Assigning Label : $Label and $Addendum_ErrorsLabel " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label"  /set "\package.variables[Addendum_ErrorsLabel].Value;$Addendum_ErrorsLabel" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success " | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append


	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	$Label = $null
	$Label = "PositionStratPLITD EOD" 
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Assigning Label : $Label and $Addendum_ErrorsLabel " | Out-File $LogFile -Append
		
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" /set "\package.variables[Label].Value;$Label" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append
	}
	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append