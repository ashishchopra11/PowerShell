############## Reference to configuration files ####################################
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

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("ImportCustodianGSSwapPosition."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ImportCustodianGSSwapPosition.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\GoldmanSachs"
 #$dirSourceFolder = "C:\Siepe\DataFeeds\GS"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\GoldmanSachsSwapPositions\Archive"
#$dirArchiveFolder = "C:\Siepe\DataFeeds\GS\Archive"
 
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

foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*Highland Capital Mgmt Fund Advisors LP (EQ)*.xls"})
 {   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  GS Swap Position  : file ( $strFileName ) processing " | Out-File $LogFile -Append
<#
	$strFile = $strFileName.BaseName
 	$xls = "$dirSourceFolder\$strFileName"
	$csv = "$dirSourceFolder\$strFile.csv"
	
	$wb = New-Object Aspose.Cells.Workbook($xls);
	$ws = $wb.WorkSheets[0];
	$wb.Save($csv);
	
	$RefDataSetDate = $null
  	$ExcelData = New-Object System.Data.DataTable
	$ExcelData = $wb.WorkSheets[0].Cells.ExportDataTable(0,0,$wb.Worksheets[0].Cells.MaxDataRow+1,$wb.Worksheets[0].Cells.MaxDataColumn+1);
	$Path = "$dirSourceFolder\$strFileName"
	$dtDataSetDate1 = $ExcelData.Rows[2].Column2
 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Excel Data   : $ExcelData " | Out-File $LogFile -Append
	
	############RefDataSetDate ############
	$RefDataSetDate = ([datetime]::ParseExact($dtDataSetDate1,”MMM d, yyyy”,$null)).toshortdatestring()
	$Label = "Swap Position - HCMF"

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianGSSwapPosition.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianGSSwapPosition.dtsx" /set "\package.variables[FileName].Value;$strFile.csv"  /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label"| Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") GS Swap Position : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	
	##Remove Temp File :-
	Remove-Item $csv
	#>
	
	$strFile1 = "EquitySwapsTerm.csv"
	$strFile2 = "EquitySwaps.csv"
 	$xls = "$dirSourceFolder\$strFileName"
	$csv1 = "$dirSourceFolder\$strFile1"
	$csv2 = "$dirSourceFolder\$strFile2"
		
	if(Test-Path -Path $csv1)
	{
		Remove-Item $csv1
	}
	if(Test-Path -Path $csv2)
	{
		Remove-Item $csv2
	}
	
	$wb = New-Object Aspose.Cells.Workbook($xls);
	$wb.Worksheets.ActiveSheetIndex = 1
	$wb.Save($csv1);
	
	$wb.Worksheets.ActiveSheetIndex = 2
	$ws = $wb.WorkSheets[2];
	$wb.Save($csv2);
	$wb.Worksheets.ActiveSheetIndex = 0
	
	

	$RefDataSetDate = $null
  	  
	$csvData = Import-Csv $csv2 
	$dtDataSet =   $($csvData[0])."Equity Swaps"
	$dtDataSetDate1 = $($dtDataSet.Split(":")[1]).TRIM()
	 
 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  RefDatasetDate : $dtDataSetDate1     " | Out-File $LogFile -Append
 
	
 	############RefDataSetDate ############
	#$dtDataSetDate1 = $sh.Range("B3").Text.ToString()
	$RefDataSetDate = ([datetime]::ParseExact($dtDataSetDate1,”MMM d, yyyy”,$null)).toshortdatestring()

	$Label = "Swap Position - HCMF"
	$HeaderExclude = 2
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianGSSwapPosition.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianGSSwapPosition.dtsx" /set "\package.variables[FileName].Value;$strFile2" /set "\package.variables[FileName1].Value;$strFile1" /set "\package.variables[HeaderExclude].Value;$HeaderExclude" /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label"| Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") GS Swap Position : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
	##Remove Temp File :-
	Remove-Item $csv1
	Remove-Item $csv2
	###Move file to Archive Directory
    Move-Item -Path "$dirSourceFolder\$strFileName" "$dirArchiveFolder"| Out-File $logFile -Append
	Move-Item -Path $xls1 "$dirArchiveFolder"| Out-File $logFile -Append

    Write-Output "Source file $strFileName and $xls1 moved to folder $dirArchiveFolder" | Out-File $logFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")GS Swap Position  : file ( $strFileName ) imported" | Out-File $LogFile -Append


}

 foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "GS_HIGHLAND FUNDS I - HIGHLAND MERGER ARBITRAGE FUND*.xls"})
 {   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  GS Swap Position  : file ( $strFileName ) processing " | Out-File $LogFile -Append

	
	$strFile1 = "EquitySwapsTerm.csv"
	$strFile2 = "EquitySwaps.csv"
 	$xls = "$dirSourceFolder\$strFileName"
	$csv1 = "$dirSourceFolder\$strFile1"
	$csv2 = "$dirSourceFolder\$strFile2"
		
	if(Test-Path -Path $csv1)
	{
		Remove-Item $csv1
	}
	if(Test-Path -Path $csv2)
	{
		Remove-Item $csv2
	}
	
	$wb = New-Object Aspose.Cells.Workbook($xls);
	$wb.Worksheets.ActiveSheetIndex = 1
	$wb.Save($csv1);
	
	$wb.Worksheets.ActiveSheetIndex = 2
	$ws = $wb.WorkSheets[2];
	$wb.Save($csv2);
	$wb.Worksheets.ActiveSheetIndex = 0
	
	

	$RefDataSetDate = $null
  	  
	$csvData = Import-Csv $csv2 
	$dtDataSet =   $($csvData[0])."Equity Swaps"
	$dtDataSetDate1 = $($dtDataSet.Split(":")[1]).TRIM()
	 
 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  RefDatasetDate : $dtDataSetDate1     " | Out-File $LogFile -Append
 
	
 	############RefDataSetDate ############
	#$dtDataSetDate1 = $sh.Range("B3").Text.ToString()
	$RefDataSetDate = ([datetime]::ParseExact($dtDataSetDate1,”MMM d, yyyy”,$null)).toshortdatestring()

	$Label = "Swap Position - HMAF"
	$HeaderExclude = 2
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianGSSwapPosition.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianGSSwapPosition_20181227.dtsx" /set "\package.variables[FileName].Value;$strFile2" /set "\package.variables[FileName1].Value;$strFile1" /set "\package.variables[HeaderExclude].Value;$HeaderExclude" /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label"| Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") GS Swap Position : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
	##Remove Temp File :-
	Remove-Item $csv1
	Remove-Item $csv2
		
	###Move file to Archive Directory
    Move-Item -Path "$dirSourceFolder\$strFileName" "$dirArchiveFolder"| Out-File $logFile -Append
	#Move-Item -Path $xls1 "$dirArchiveFolder"| Out-File $logFile -Append

    Write-Output "Source file $strFileName and $xls1  moved to folder $dirArchiveFolder" | Out-File $logFile -Append
	
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")GS Swap Position : file ( $strFileName ) imported" | Out-File $LogFile -Append


}   
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianGSSwapPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n PowerShellLocation = $ScriptName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	# Normalize  BNPPositions 
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianGSSwapPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"/set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
    #$GenericNormalizationJobID = 29
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") GS Positions : NormalizeCustodianGSSwapPosition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")GS Positions  : Normalization Complete" | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
