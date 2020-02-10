s############## Reference to configuration files ###################################
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

$logTime = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\RunWSOAPI-PriceRefresh."+$strDateNow+".txt"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

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
"Argument Passed :: Date :: $ArgDate" |   Out-File $LogFile -Append
##############################################################################
. "$dirScriptsFolder\PROD\fWSOConvertReportFormat-API_PriceRefresh.ps1"
. "$dirScriptsFolder\PROD\fWSOImportHighAPI_PriceRefresh.ps1"
. "$dirScriptsFolder\PROD\fWSONormalizeHigh_PriceRefresh.ps1"
. "$dirScriptsFolder\PROD\fCleanWSOPriceSourceFile_PriceRefresh.ps1"
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
	$process_date = ($curr_date)
	[datetime]$parameter_date = ($curr_date)
}

$Weekday = $parameter_date.DayOfWeek

Write-Output " WSO_Extracts_DIR			= $WSO_Extracts_DIR" |  Out-File $LogFile -Append
Write-Output " WSO_Scripts				= $WSO_Scripts" |  Out-File $LogFile -Append
Write-Output " parameter_date			= $parameter_date" |  Out-File $LogFile -Append
Write-Output " Weekday (For Date which we passed)	= $Weekday" |  Out-File $LogFile -Append
Write-Output " process_date				= $process_date" |  Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOConvertReportFormat-API `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#WSO Move/Convert API Files :-
	fWSOConvertReportFormat-API -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

$Arg_Date = $process_date
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fCleanWSOPriceSourceFile `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
## Clean Up WSO Price Source file before importing to DataFeeds 
    fCleanWSOPriceSourceFile -ArgDate $process_date -LogFile $LogFile
 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOImportHighAPI `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#WSOImport Files :-
	 fWSOImportHighAPI -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

#WSO Normalize
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSONormalizeHigh `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
	 fWSONormalizeHigh -process_date $process_date -LogFile $LogFile
	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
