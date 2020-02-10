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
. "$dirScriptsFolder\PROD\fWSOConvertReportFormat-API_ReExtractTrades.ps1"
. "$dirScriptsFolder\PROD\fWSOImportHighAPI_ReExtractTrades.ps1"
. "$dirScriptsFolder\PROD\fWSONormalizeHigh_ReExtractTrades.ps1"
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
	if($ArgDate.DayOfWeek -eq "Sunday"){
	    [datetime]$parameter_date = $ArgDate.AddDays(-2)
		[datetime]$process_date  = $ArgDate.AddDays(-2)
	}
	elseif($ArgDate.DayOfWeek -eq "Monday") {
	    [datetime]$parameter_date = $ArgDate.AddDays(-3)
		[datetime]$process_date  = $ArgDate.AddDays(-3)
	}
	else {
	    [datetime]$parameter_date = $ArgDate.AddDays(-1)
		[datetime]$process_date  = $ArgDate.AddDays(-1)
	}
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

$ArgDateString = $ArgDate.ToString("yyyyMMdd")
$ProcessDateString = $process_date.ToString("yyyyMMdd")

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Rename files from datestamp $ArgDateString to $ProcessDateString  `r`n " | Out-File $LogFile -Append
Rename-Item -Path "\\services\deliverystore\WSOOnDemand\ReExtractTrades_ExtractTradesi2d_$ArgDateString.csv" -NewName "ReExtractTrades_ExtractTradesi2d_$ProcessDateString.csv"
Rename-Item -Path "\\services\deliverystore\WSOOnDemand\ReExtractTrades_ExtractPositionMap_$ArgDateString.csv" -NewName "ReExtractTrades_ExtractPositionMap_$ProcessDateString.csv"

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

	Write-Output "Payload: $payload" | Out-File $LogFile -Append
	Write-PubSub "WsoAdapter.Report.Group.Choreographer.ReExtract.Completed" -Description $BatchID -Payload $payload | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

Write-PubSub -Subject "WSO.Trades.Reload.Complete" -Title "WSO Trades have been reloaded"
