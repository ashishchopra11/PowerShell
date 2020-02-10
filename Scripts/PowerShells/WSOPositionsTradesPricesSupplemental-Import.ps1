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
$LogFile = "$dirLogFolder\RunWSOAPI."+$strDateNow+".txt"

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
. "$dirScriptsFolder\PROD\fWSOConvertReportFormat-API_New.ps1"
. "$dirScriptsFolder\PROD\fWSOImportSupplemental-API_New.ps1"
. "$dirScriptsFolder\PROD\fWSOImportHighAPI_New.ps1"
. "$dirScriptsFolder\PROD\fWSONormalizeHigh_New.ps1"
. "$dirScriptsFolder\PROD\fWSONormalizeSupplemental_New.ps1"
. "$dirScriptsFolder\PROD\fWSOPricesToGeneva_New.ps1"
. "$dirScriptsFolder\PROD\fWSOArchiveZipFilesAPI_New"

Clear-Host

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$WSO_Extracts_DIR 		= "D:\Siepe\DataFeeds\WSOReports"
$WSO_Archive_DIR 		= "$dirDataFeedsArchiveFolder\WSOReports"
$WSO_Extracts_DIR_SAT	= "$WSO_Extracts_DIR\SAT"
$WSO_Scripts			= "$dirScriptsFolder\WSO"
$WSO_Extracts_DIR_SUN	= "$WSO_Extracts_DIR\SUN"

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
	#[DateTime]$curr_date = "2017-07-13"
	
	$process_date = ($curr_date).AddDays(-1)
	[datetime]$parameter_date = ($curr_date).AddDays(-1)
}

$Weekday = $parameter_date.DayOfWeek

Write-Output " WSO_Extracts_DIR			= $WSO_Extracts_DIR" |  Out-File $LogFile -Append
Write-Output " WSO_Archive_DIR			= $WSO_Archive_DIR" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR_SAT		= $WSO_Extracts_DIR_SAT" |  Out-File $LogFile -Append
Write-Output " WSO_Scripts				= $WSO_Scripts" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR_SUN		= $WSO_Extracts_DIR_SUN" |  Out-File $LogFile -Append
#Write-Output " curr_date				= $curr_date" |  Out-File $LogFile -Append
Write-Output " parameter_date			= $parameter_date" |  Out-File $LogFile -Append
Write-Output " Weekday (For Date which we passed)	= $Weekday" |  Out-File $LogFile -Append
Write-Output " process_date				= $process_date" |  Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOConvertReportFormat-API `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#Move/Convert API Files :-
	fWSOConvertReportFormat-API -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

################ High Priority Files ################

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOImportHighAPI `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#Import High Priority Files :-
	 fWSOImportHighAPI -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

#Create Process Date List
	if ($process_date.DayOfWeek -eq "Monday") {
	  ## Load Saturday, Sunday, and Monday on Tuesday morning ...
	  $process_days_list = ($process_date).AddDays(-2),($process_date).AddDays(-1),$process_date
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Process day is Monday so our process day list : `r`n $process_days_list" | Out-File $LogFile -Append
	} else {
	  $process_days_list = $process_date
	  # Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Process day is not Monday so our process day list : `r`n $process_days_list" | Out-File $LogFile -Append
	}

#Normalize High Priority
	  if ($parameter_date.DayOfWeek -ne "Saturday" -and $parameter_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Starting Normalize High Priority" | Out-File $LogFile -Append
		$process_days_list | Sort-Object -Descending | ForEach-Object -Process {
			$process_date = $_
			#Normalize All WSO :-
			
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSONormalizeHigh `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
			 fWSONormalizeHigh -process_date $process_date -LogFile $LogFile
			$FullDayString = $process_date.ToShortDateString()

			 Write-PubSub -Subject "DataWarehouse.WSOData.Loaded" -Title "Data Warehouse WSOData Load Completed for $FullDayString" -Description "$FullDayString"
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.WSOData.Loaded`" -Title `"Data Warehouse WSOData Load Completed for $FullDayString`" -Description `"$FullDayString`" " | Out-File $LogFile -Append
		}
	}

#Push Prices to Geneva
 	if ($parameter_date.DayOfWeek -ne "Saturday" -and $parameter_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Starting Push Prices to Geneva" | Out-File $LogFile -Append
	$process_days_list | Sort-Object | ForEach-Object -Process {
		$process_date = $_
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOPricesToGeneva `r`n Parameter passed here are : `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
			#Geneva Price Push :-
			 fWSOPricesToGeneva -process_date $process_date -LogFile $LogFile
			$FullDayString = $process_date.ToShortDateString()
		}
	}

#Send Geneva.Prices.Upload.Complete PubSub
	 if ($parameter_date.DayOfWeek -ne "Saturday" -and $parameter_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
		 Write-PubSub -Subject "ReportSubscription.PubSubOnly.GenevaPositionsTradesPrices.DailyExtracts" -Title "Data Warehouse Price Load Completed for $FullDayString" -Description "$FullDayString"
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Published PubSub :: Write-PubSub -Subject `"ReportSubscription.PubSubOnly.GenevaPositionsTradesPrices.DailyExtracts`" -Title `"Data Warehouse Price Load Completed for $FullDayString`" -Description `"$FullDayString`" " | Out-File $LogFile -Append
	}
	
################ Supplemental Files Process ################

#Import Supplemental Files (and archive files) :-
	$process_date = $parameter_date
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOImportSupplemental-API `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR  `r`n  process_date = $process_date `r`n " | Out-File $LogFile -Append
	 fWSOImportSupplemental-API -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

#Normalize Supplemental
	 if ($parameter_date.DayOfWeek -ne "Saturday" -and $parameter_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Starting Normalize Supplemental" | Out-File $LogFile -Append
	$process_days_list | Sort-Object -Descending | ForEach-Object -Process {
		$process_date = $_
			#Normalize All WSO :-
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSONormalizeSupplemental `r`n Parameter passed here are : `r`n  process_date = $process_date `r`n " | Out-File $LogFile -Append
			 fWSONormalizeSupplemental -process_date $process_date -LogFile $LogFile
		}
	}
	
################ Archiving and Zipping Files ################
$process_date = $parameter_date
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive and Zip WSO API Files" | Out-File $LogFile -Append
fWSOArchive-ZipFilesAPI -WSO_Extracts_DIR $WSO_Extracts_DIR -WSO_Archive_DIR $WSO_Archive_DIR -process_date $process_date -LogFile $LogFile


Write-PubSub -Subject "Reporting.WSO.UnmappedPortfolio" 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Published PubSub :: Write-PubSub -Subject `"Reporting.WSO.UnmappedPortfolio`"  " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
