############## Reference to configuration files ###################################
CLS
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
$logTime = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\RunWSOAPI-ReExtract."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
############################# Validate Argument ############################# 
## Default to 01/01/1900
[Datetime]$ArgDate = "01/01/1900"

if ($args[0] -ne $null)
{
    [String]$ArgValue = $args[0]
    
 	Try
	{
    	[Datetime]$ArgDate  = $ArgValue
	}
	catch
	{
        [string]$ArgDate_Invalid = $ArgValue
		Write-Output "Invalid RefDataSetDate passed for PowerShell argument. Value :: $ArgDate_Invalid "   | Out-File $LogFile -Append
		Exit
	}
}

if($args[1] -ne $null) 
{
	[String]$ArgValueBatchId = $args[1]
	Try {
		$BatchID = $ArgValueBatchId
		Write-Output "Received batchID $BatchID" | Out-File $LogFile -Append
	}
	Catch {
		Write-Output "No Batch ID Present" | Out-File $LogFile -Append
	}
}
"Argument Passed :: Date :: $ArgDate" |   Out-File $LogFile -Append
"Argument Passed :: Guid :: $BatchID" | Out-File $LogFile -Append
##############################################################################
. "$dirScriptsFolder\PROD\fWSOConvertReportFormat-API_ReExtract.ps1"
. "$dirScriptsFolder\PROD\fWSOImportHighAPI_ReExtract.ps1"
. "$dirScriptsFolder\PROD\fWSONormalizeHigh_ReExtract.ps1"
. "$dirScriptsFolder\PROD\fGenevaImportNormalize_ReExtract.ps1"
Clear-Host

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$WSO_Extracts_DIR 		= "D:\Siepe\DataFeeds\WSOReports"
$WSO_Scripts			= "$dirScriptsFolder\WSO"

## A list of days to process  ...
New-Variable process_days_list

## Today's date ...
New-Variable curr_date

##[datetime]$curr_day = Get-Date

<################### 
$parameter_date = To hold default process date, it will not change in whole process
				If pass as argument then $ArgDate
				Else $current_date - 1 
###################>

if($ArgDate -ne "1900/01/01" -and $ArgDate -ne $null)
{
    [datetime]$parameter_date = $ArgDate
	[datetime]$process_date  = $ArgDate
}
else
{
	$curr_date = Get-Date
	$process_date = ($curr_date).AddDays(-1)
	[datetime]$parameter_date = ($curr_date).AddDays(-1)
}

$Weekday = $parameter_date.DayOfWeek

Write-Output " WSO_Extracts_DIR			= $WSO_Extracts_DIR" |  Out-File $LogFile -Append
Write-Output " WSO_Scripts				= $WSO_Scripts" |  Out-File $LogFile -Append
Write-Output " parameter_date			= $parameter_date" |  Out-File $LogFile -Append
Write-Output " Weekday (For Date which we passed)	= $Weekday" |  Out-File $LogFile -Append
Write-Output " process_date				= $process_date" |  Out-File $LogFile -Append

	$formattedDate = $ArgDate.ToString("MM-dd-yyyy")

	$enc = [system.Text.Encoding]::UTF8
	$payload = $enc.GetBytes("ScriptPayload: $formattedDate")

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOConvertReportFormat-API `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#WSO Move/Convert API Files :-
	fWSOConvertReportFormat-API -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile
	

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOImportHighAPI `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#WSOImport Files :-
	$result = fWSOImportHighAPI -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile
	Write-Output "result = $result" | Out-File $LogFile -Append
	if($result -contains "Fail") {
		Write-Output "Failed ImportHighApi, sending Pub/Sub" | Out-File $LogFile -Append
		Write-PubSub 'WsoAdapter.Report.Group.ReExtract.Failed' -Description $BatchID -Payload $payload
		Exit
	}
	

#WSO Normalize
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSONormalizeHigh `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
	$result = fWSONormalizeHigh -process_date $process_date -LogFile $LogFile
	Write-Output "result = $result" | Out-File $LogFile -Append
	if($result -contains "Fail") {
		Write-Output "Failed NormalizeHigh, sending Pub/Sub" | Out-File $LogFile -Append

		Write-PubSub 'WsoAdapter.Report.Group.ReExtract.Failed' -Description $BatchID -Payload $payload
		Exit
	}

##Geneva Import/Normalize
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fGenevaImportNormalize `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#	fGenevaImportNormalize -process_date $process_date -LogFile $LogFile
#	$FullDayString = $process_date.ToShortDateString()
#
#	Write-PubSub -Subject "DataWarehouse.WSOData.Loaded" -Title "Data Warehouse WSOData Load Completed for $FullDayString" -Description "$FullDayString"
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.WSOData.Loaded`" -Title `"Data Warehouse WSOData Load Completed for $FullDayString`" -Description `"$FullDayString`" " | Out-File $LogFile -Append
	Write-Output "Payload: $payload" | Out-File $LogFile -Append
	Write-PubSub "WsoAdapter.Report.Group.Choreographer.ReExtract.Completed" -Description $BatchID -Payload $payload | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
