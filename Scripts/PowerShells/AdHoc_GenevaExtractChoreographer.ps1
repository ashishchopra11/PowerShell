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
#$logFile = "$dirLogFolder\ExtractGenevaPositionAdhoc.$logTime.txt" 
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

#$dirSSISExtractGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\ExtractGeneva\bin"
#$dirSSISNormalizeGeneva = "C:\_Apps\hcmlp\Data\SSIS.DataWarehouse\NormalizeGeneva\bin"

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

Write-Output " XMLFolderPath	= $XMLFolderPath" |  Out-File $LogFile -Append
Write-Output " logFile			= $logFile" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

if ($args[0] -ne $null)
{
    [String]$ArgValueStartDate = $args[0]
    
 	Try
	{
    	[Datetime]$ArgStartDate  = $ArgValueStartDate
	}
	catch
	{
        [string]$ArgDate_Invalid = $ArgValueStartDate
		Write-Output "Invalid RefDataSetDate passed for PowerShell argument. Value :: $ArgDate_Invalid "   | Out-File $LogFile -Append
		Exit
	}
}    
"Argument Passed :: Date :: $ArgStartDate" |   Out-File $LogFile -Append

if ($args[1] -ne $null)
{
    [String]$ArgValueEndDate = $args[1]
    
 	Try
	{
    	[Datetime]$ArgEndDate  = $ArgValueEndDate
	}
	catch
	{
        [string]$ArgDate_Invalid = $ArgValueEndDate
		Write-Output "Invalid RefDataSetDate passed for PowerShell argument. Value :: $ArgDate_Invalid "   | Out-File $LogFile -Append
		Exit
	}
} 
if($args[2] -ne $null) {
	[String]$ArgValueBatchId = $args[2]
	Try {
		$BatchID = $ArgValueBatchId
		}
	Catch {
		Write-Output "No Batch ID present" | Out-File $LogFile -Append
		Exit
	}
}

Write-Output "BatchID: $BatchID" | Out-File $logFile -Append
	
"Argument Passed :: Date :: $ArgValueEndDate" |   Out-File $LogFile -Append

	$formattedDate = $ArgStartDate.ToString("MM-dd-yyyy")

	$enc = [system.Text.Encoding]::UTF8
	$payload = $enc.GetBytes("$formattedDate")


#$start_day = Get-Date -Date "09/19/2017"
#$end_day = Get-Date -Date "09/19/2017"

$start_day = [DateTime]$ArgValueStartDate
$end_day = $ArgValueEndDate

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

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

while ($start_day -le $end_day) {
	#$curr_day = $start_day

	$date_string = Get-Date -Date $start_day -UFormat %x
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n  Label = $PositionLabel" | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append

$RtrString = & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" 
$RtrString | Out-File $LogFile -Append
## Check SSIS is success or not 
Write-Output "Last exit code: $lastexitcode" | Out-File $logFile -Append
	##If ($lastexitcode -ne 0 ) {
	if($RtrString -ilike "*DTSER_FAILURE*") {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-PubSub -Subject 'Process.Geneva.ImportNormalize.Positions.Failed' -Description $BatchID -Payload $payload  | Out-File $LogFile -Append
			Exit
		}

	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
$RtrStr = & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" 
$RtrStr | Out-File $LogFile -Append
## Check SSIS is success or not 
Write-Output "Last exit code: $lastexitcode" | Out-File $logFile -Append
	##If ($lastexitcode -ne 0 ) {
	if($RtrStr -ilike "*DTSER_FAILURE*") {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-PubSub -Subject 'Process.Geneva.ImportNormalize.Positions.Failed' -Description $BatchID -Payload $payload  | Out-File $LogFile -Append
			Exit
		}

	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
$RtrStr = & $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName" 
$RtrStr | Out-File $LogFile -Append
## Check SSIS is success or not 
Write-Output "Last exit code: $lastexitcode" | Out-File $logFile -Append
	##If ($lastexitcode -ne 0 ) {
	if($RtrStr -ilike "*DTSER_FAILURE*") {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-PubSub -Subject 'Process.Geneva.ImportNormalize.Positions.Failed' -Description $BatchID -Payload $payload | Out-File $LogFile -Append
			$start_day = $start_day.AddDays(1)
			Exit
		}

	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append
Write-Output "Start date = $start_day" | Out-File $logFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaYTDPnLDifference.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
$RtrStr = & $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaYTDPnLDifference.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[PowerShellLocation].Value;$ScriptName" 
$RtrStr | Out-File $LogFile -Append

$teststart_day = $start_day.AddDays(1)
$start_day = [DateTime]$start_day.AddDays(1)
Write-Output "New start date = $teststart_day , $start_day" | Out-File $logFile -Append
}
Write-PubSub -Subject "Process.Geneva.ImportNormalize.Positions.Completed" -Title "Completed Positions ImputNormalize for end date $end_day" -Description "$BatchID" -Payload $payload  | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append