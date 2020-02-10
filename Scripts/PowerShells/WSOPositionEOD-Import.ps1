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
#$LogFile = "$dirLogFolder\RunWSOAPIPositions-EOD."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

. "$dirScriptsFolder\PROD\fWSOConvertReportFormat-API_PositionsEOD.ps1"
. "$dirScriptsFolder\PROD\fWSOArchiveZipFilesAPI_PositionsEOD.ps1"
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

Clear-Host

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$WSO_Extracts_DIR 		= "D:\Siepe\DataFeeds\WSOReports"
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
$parameter_date = $parameter_date.ToShortDateString()
$strDateNow = get-date $process_date -format "yyyyMMdd"
$WSO_Extracts_DIR1 		= "$WSO_Extracts_DIR\$strDateNow\API\Converted"
$ArchiveFolder = "$WSO_Extracts_DIR1\Archive"
$FullDayString = ($process_date).ADDDAYS(0).ToString("MM/dd/yyyy")
$PriorstrDateNow = $strDateNow - 1

Write-Output " WSO_Extracts_DIR			= $WSO_Extracts_DIR" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR_SAT		= $WSO_Extracts_DIR_SAT" |  Out-File $LogFile -Append
Write-Output " WSO_Scripts				= $WSO_Scripts" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR_SUN		= $WSO_Extracts_DIR_SUN" |  Out-File $LogFile -Append
#Write-Output " curr_date				= $curr_date" |  Out-File $LogFile -Append
Write-Output " parameter_date			= $parameter_date" |  Out-File $LogFile -Append
Write-Output " Weekday (For Date which we passed)	= $Weekday" |  Out-File $LogFile -Append
Write-Output " process_date				= $process_date" |  Out-File $LogFile -Append
Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR1		= $WSO_Extracts_DIR1" |  Out-File $LogFile -Append
Write-Output " ArchiveFolder			= $ArchiveFolder" |  Out-File $LogFile -Append
Write-Output " PriorstrDateNow			= $PriorstrDateNow" |  Out-File $LogFile -Append



Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOConvertReportFormat-APIRegressionTest `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#Move/Convert API Files :-
	fWSOConvertReportFormat-APIPositionEOD -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

################ High Priority Files ################


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Calling function fWSOImportHighAPI `r`n Parameter passed here are : `r`n  WSO_Extracts_DIR = $WSO_Extracts_DIR `r`n  process_date = $process_date  `r`n " | Out-File $LogFile -Append
#Import Positions Files :-
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "EOD_ExtractPerformance_$strDateNow.CSV"
	$PerformanceLabel = "Performance EOD"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPerformance.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPerformance.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$PerformanceLabel"| Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Performance_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPerformance.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPerformance.dtsx Completed " | Out-File $LogFile -Append
	}
	
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "EOD_ExtractPosition_$strDateNow.CSV"
	$PositionLabel = "Position EOD"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPosition.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPosition.dtsx" 				/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$PositionLabel" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Position_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPosition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPosition.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "EOD_ExtractPositionMap_$strDateNow.CSV"
	$PositionMapLabel = "PositionMap EOD"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPositionMap.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPositionMap.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$PositionMapLabel" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""PositionMap_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPositionMap.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractPositionMap.dtsx Completed " | Out-File $LogFile -Append
	}
	
	

	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "EOD_ExtractRealUnReal_$strDateNow.CSV"
	$RealUnrealLabel = "RealUnrealGain EOD"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractRealUnreal.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$RealUnrealLabel" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""RealUnreal_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx Completed " | Out-File $LogFile -Append
	}

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "EOD_ExtractSettleUnsettleComplete_$strDateNow.CSV"
	$SettleUnsettleLabel = "SettleUnsettle EOD"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$SettleUnsettleLabel" | Out-File $LogFile -Append #/set "\package.variables[FileName].Value;ExtractSettleUnsettle.CSV" #/set "\package.variables[Label].Value;""SettleUnsettle_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx Completed " | Out-File $LogFile -Append
	}



################ Archiving and Zipping Files ################
$process_date = $parameter_date
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive and Zip WSO API Files" | Out-File $LogFile -Append
fWSOArchive-ZipFilesAPIPositionsEOD -WSO_Extracts_DIR $WSO_Extracts_DIR  -process_date $process_date -LogFile $LogFile

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
