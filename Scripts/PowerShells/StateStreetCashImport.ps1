############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $("ExtractCustodianSocGenPositions."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ExtractCustodianStateStreetCashRecon.$strDateNow.txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append


[bool]$FileExists = $False
[bool]$FileZipExists = $False

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\StateStreet\CashRecon" 
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\StateStreetCashRecon\Archive" 

Write-Output " dirSourceFolder		        = $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	        = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here if not exists " | Out-File $LogFile -Append
[bool]$FileExists = $False


#Remove-Item -Path "$dirSourceFolder\*.xls" -Force
	#Expand-ZIPFile  –File "$dirSourceFolder\Cash_Reconciliation_Longhorn Credit Funding, LLC*.zip" -Destination $dirSourceFolder  | Out-File $logFile -Append

foreach ($ZipFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Cash_Reconciliation_Longhorn Credit Funding, LLC*.zip"}) 
{	
	$FileZipExists = $True
	##Remove existing files
	$RawZIPFilePath = $ZipFileName.FullName

    #$zipFilePassword = "High1845"
	
	# UnRAR the file. -y responds Yes to any queries UnRAR may have.
	&  "C:\Program Files\WinRAR\Winrar.exe" x -y   -o+  $RawZIPFilePath $dirSourceFolder  "-pHigh1845" | Wait-Process 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Files Extracted in $dirSourceFolder " | Out-File $LogFile -Append


## ExtractCustodianMSEquitySwapPositions :-
foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Cash_Reconciliation_Longhorn Credit Funding, LLC*.xls"}) 
{    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: StateStreet CashRecon   : file ( $strFileName ) processing " | Out-File $LogFile -Append
     Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append


	$ExcelFullPath = $strFileName.FullName
	$wb = New-Object Aspose.Cells.Workbook($ExcelFullPath);
	
	$CSVFullPath = $ExcelFullPath -replace ".xls" , ".csv"
    $CSVFullPathNew = $CSVFullPath -replace ".csv" , "_New.csv"
	$FileExists = $True
    
	$wb.Save($CSVFullPath);
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Converted XLS to CSV" | Out-File $LogFile -Append
	
	$Data = Import-Csv $CSVFullPath | select -First 10 |Export-Csv $CSVFullPathNew

	### Get RefDataSet Date from File Content
	$SourceCsv = Import-Csv -Path $CSVFullPathNew -Header ("A","B","C","D","RefDataSetDate") -Delimiter ","
	$SourceCsvRDDate  = $SourceCsv[0]
	$RefDataSetDate1 = $SourceCsvRDDate.RefDataSetDate;
 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::RefDataSetDate from file = $RefDataSetDate1 " | Out-File $LogFile -Append
	$RefDataSetDate1 = $RefDataSetDate1.Trim();
	$dtDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,"M/d/yyyy",$null)).toshortdatestring()

	$CsvFileName = $strFileName -replace ".xls" , "_New.csv"
	
	# GENERATING LABEL :-
	IF($CsvFileName.Contains("Strategy B") -eq "$true")
	{
	$Label = "StateStreetCashReconLonghornB"
	}
	else
	{ $Label = "StateStreetCashReconLonghornA"
	}

    ##SSIS Status Variables
    [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianStateStreetCashRecon.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $CsvFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	### Extract ExtractCustodianStateStreetCashRecon 
	& $2016DTEXEC64 /F "$dirSSISExtractCustodian\ExtractCustodianStateStreetCashRecon.dtsx" /set "\package.variables[FileName].Value;$CsvFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate"  /set "\package.variables[Label].Value;$Label" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") StateStreetCashRecon : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") StateStreetCashRecon : file ( $strFileName ) imported" | Out-File $LogFile -Append
	
    ### Move imported file to Archive Directory
	Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

Remove-Item $CSVFullPath
Remove-Item $CSVFullPathNew

}
}

 ##SSIS Status Variables
    [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianStateStreetCashImport_CashWorksheet.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	### Normalize SS Cash Recon
& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianStateStreetCashImport_CashWorksheet.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") StateStreetCashRecon : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") StateStreetCashRecon : file ( $strFileName ) Normalized" | Out-File $LogFile -Append

If ($FileZipExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( attachment*.zip ) not exist at ::  $dirSourceFolder " | Out-File $LogFile -Append    
}	

If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( Cash_Reconciliation_Longhorn Credit Funding, LLC*.xls) not exist at :: $dirSourceFolder " | Out-File $LogFile -Append    
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
