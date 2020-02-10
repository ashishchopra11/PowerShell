FUNCTION fWSOImportHighAPI{
	Param
	{
		[string]$WSO_Extracts_DIR
		,[datetime]$process_date
		,[string]$LogFile
	}
	
$ScriptName = $MyInvocation.MyCommand.Name
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$strDateNow = get-date $process_date -format "yyyyMMdd"
#$strDate = get-date -format "yyyyMMddTHHmmss"

$currDate = Get-Date  
	
If ($currDate -ge $process_date) {
	$FullDayString = ($currDate).ADDDAYS(-1).ToString("MM/dd/yyyy")
}
Else {
	$FullDayString = ($process_date).ADDDAYS(0).ToString("MM/dd/yyyy")
}
#$strDateNow = "20151102"
$PriorstrDateNow = $strDateNow - 1
$strDate = get-date -format "yyyyMMddTHHmmss"
  ## -- Run Imports
  ## -- Import into DataFeeds 
$WSO_Extracts_DIR1 		= "$WSO_Extracts_DIR\$strDateNow\API\Converted"
$ArchiveFolder = "$WSO_Extracts_DIR1\Archive"

Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
Write-Output " PriorstrDateNow			= $PriorstrDateNow" |  Out-File $LogFile -Append
Write-Output " WSO_Extracts_DIR1		= $WSO_Extracts_DIR1" |  Out-File $LogFile -Append
Write-Output " ArchiveFolder			= $ArchiveFolder" |  Out-File $LogFile -Append

if (!(Test-Path -path $ArchiveFolder\$strDate)) 
    { 	
	    New-Item -path $ArchiveFolder\$strDate -ItemType directory 
    }

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOImportHighAPI starts here " | Out-File $LogFile -Append
				
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "PriceRefresh_ExtractMarks_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractMarks.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractMarks.dtsx" 					/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Marks_API"""
	## Check SSIS is success or not 
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractMarks.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportHighAPI : $dirSSISExtractWSO\High\ExtractMarks.dtsx Completed " | Out-File $LogFile -Append
	}
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
