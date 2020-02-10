############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv4)


## Aspose License
$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file


$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ReturnDate = ""

#Create-File -path $($dirLogFolder+"\") -fileName $("ImportCustodianUSBankClientHoldings."+$strDateNow+".txt")
#$LogFile 				= "$dirLogFolder\ImportCustodianUSBankClientHoldings.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


## Variables
$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\USBank"
 
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\USBankClientHoldings\Archive"
$dirArchiveFolderPositionCashSummary = "$dirDataFeedsArchiveFolder\USBankPositionCashSummary\Archive"


#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append
Write-Output " ArchiveFolderPositionCashSummary	= $dirArchiveFolderPositionCashSummary" |  Out-File $LogFile -Append

$RefDataSetDate = ""

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  US Bank Position and Cash Account Summary starts here " | Out-File $LogFile -Append

##Create Archive folder
New-Item -path $dirArchiveFolderPositionCashSummary\$strDateNow -ItemType directory
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Created Archive timestamp directory :: $dirArchiveFolderPositionCashSummary\$strDateNow " | Out-File $LogFile -Append

## Import Position and Cash Account Summary
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {($_.Name -ilike "*CashFile*.xlsm") -or ($_.Name -ilike "*Daily*.xlsm")})
{
$ExcelFullPath = $strFileName.FullName
	$wb = New-Object Aspose.Cells.Workbook($ExcelFullPath);
	
Sleep -Seconds 10
	$ws = $wb.WorkSheets["Summary"]; #Summary tab
	$wt = $wb.WorkSheets["Client Holdings - Detailed"]; #ClientHoldings-Detailed tab
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  $wb , $ws , $wt " | Out-File $LogFile -Append
	
	
	

	##################### Code to get DealName ####################
	$Cell = $wt.Cells["A6"];
	$DealName = $Cell.get_DisplayStringValue()

	#################### Code to get Indexes of PositionSummary and CashAccountSummary #################
	$rowCount = $ws.Cells.GetLastDataRow(2)
	$PSI = $Null
	$CASI = $Null
	for($i=2;$i -lt $rowCount;$i++)
	{
	$Cell = $ws.Cells["B$i"];
	$Text = $Cell.get_DisplayStringValue()
	 if($Text -eq "Cash Account Summary")
	 { $PSI = $i-2  #### End Index of Position Summary
	 $CASI = $i+1   ### Start Index of CashAccountSummary
	}
	}
	################ Code to get RefDataSetDate and labels ###########
	   $splitString = $StrFileName.BaseName -split "_"
       $RefDataSetDate1 = $splitString[2]
	   $RefDataSetDate = ''
	
		If ($strFileName -ilike "*CashFile*") {
			$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring()
			Write-Output "FileName: CashFile" |  Out-File $LogFile -Append
		}
		Else {
			$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”MMddyyyy”,$null)).toshortdatestring()
			Write-Output "FileName: Daily" |  Out-File $LogFile -Append
		}
		
    	$label = $splitString[0]
		$LabelPS = $label + " Daily - Position Summary"
		$LabelCAS = $label + " Daily - Cash Account Summary"

#Writing variables to Log File.
Write-Output " LabelCAS			= $LabelCAS" |  Out-File $LogFile -Append
Write-Output "LabelPS 			= $LabelPS" |  Out-File $LogFile -Append
Write-Output "RefDataSetDate	= $RefDataSetDate" |  Out-File $LogFile -Append
Write-Output "PositionSummaryEndIndex	= $PSI" |  Out-File $LogFile -Append
Write-Output "CashSummaryStartIndex	= $CASI" |  Out-File $LogFile -Append
Write-Output "DealName	= $DealName" |  Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianUSBankPositionCashSummary.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate `r`n Label = $label" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianUSBankPositionCashSummary.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[LabelCAS].Value;$LabelCAS"  /set "\package.variables[LabelPS].Value;$LabelPS" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[CASIndex].Value;$CASI" /set "\package.variables[PSIndex].Value;$PSI" /set "\package.variables[DealName].Value;$DealName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Cash  position Summary: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Cash  position Summary: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	  ### Move imported file to Archive Directory
   Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolderPositionCashSummary\$strDateNow   
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $strFileName ) to location ( $dirArchiveFolderPositionCashSummary\$strDateNow ) " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUSBankPositionHolding.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

   	 & $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUSBankCashWorksheetAccount.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  US Bank Client Holdings: file ( $strFileName ) NormalizeCustodianUSBankCashWorksheetAccount.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCustodianUSBankCashWorksheetAccount.dtsx `r`n "| Out-File $LogFile -Append

		
}

$RefDataSetDate = ""

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  US Bank Client Holdings starts here " | Out-File $LogFile -Append
$flag = 0
## ImportCitiPositions
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*_Client_Holdings_-_Detailed_CSV_*.csv"})
{

	# Creating new files to import to each table
	$FullPath = "$dirDataFeedsFolder\$strFileName"
	$FileName = "$strFileName"
	(Get-Content -Path $FullPath).Replace("Deal ID",'Deal Name') | Set-Content -Path $FullPath
	(Get-Content -Path $FullPath).Replace("Moody's Default Probability Rating,Moody's Derived Rating,Moody's Default Probability Rating","Moody's Default Probability Rating,Moody's Derived Rating,Moody's Default Probability Rating - WARF") | Set-Content -Path $FullPath
	(Get-Content -Path $FullPath).Replace("Moody's Derived Rating - MWARF","Moody's Derived Rating - WARF") | Set-Content -Path $FullPath
	
	$NewFileName1 = $FileName.Replace(".csv","_Amortization.csv")
	Copy-Item $FullPath -Destination "$dirDataFeedsFolder\$NewFileName1"
	$NewFileName2 = $FileName.Replace(".csv","_Holdings.csv")
	Copy-Item $FullPath -Destination "$dirDataFeedsFolder\$NewFileName2"
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  US Bank Client Holdings : file ( $strFileName ) processing " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Starting Generic Import" | Out-File $LogFile -Append
	# ATLS1501
	$GenericImportJobID = 122
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 126
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
	# HLMFELP
	$GenericImportJobID = 127
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 128
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
	# HLND1604
	$GenericImportJobID = 129
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 130
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
	# ACIS1707
	$GenericImportJobID = 131
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 132
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# Everything past this is old code
	
	   
   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
	   $splitString = $StrFileName.BaseName -split "_"
       $RefDataSetDate1 = $splitString[6]
       $RefDataSetDate1 = $RefDataSetDate1.Substring(0,8)
    $ArcDate = $RefDataSetDate1.Substring($RefDataSetDate1.Length -4,4) + $RefDataSetDate1.Substring(0,4)
    New-Item -path $dirArchiveFolder\$ArcDate -ItemType directory
  
	    $RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”MMddyyyy”,$null)).toshortdatestring()
    	$label2 = $splitString[0]
		$label = $label2 + " Client Holdings"
	$Date=(get-date).AddDays(-1).toshortdatestring()
 $Date2 = (get-date).AddDays(-3).toshortdatestring()
 (get-date).DayOFWeek 
    ##IF ($Date -eq $RefDataSetDate -or ((get-date).DayOFWeek  -eq "Monday" -and $Date2 -eq $RefDataSetDate ))
	  # {
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from $strFileName (File Name :: $RefDataSetDate " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianUSBankPositionHolding.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate `r`n Label = $label" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    #& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianUSBankPositionHolding.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$label"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Client Holdings: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Client Holdings: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
		    ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianAmortizationSchedule .dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
	$label1 = $label2 + " Client Holdings - Amortization Schedule"
   	#& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianAmortizationSchedule.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$label1 "  /set "\package.variables[PowerShellLocation].Value;$ScriptName"   | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Amortization Schedules: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Amortization Schedules: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	

#Import US Bank Institutional Position Holdings
	IF ($StrFileName.BaseName -ilike "H*" -or $StrFileName.BaseName -ilike "ATLS*" )
	{
			    ## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianUSBankInstitutionalPositionHoldings .dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		
		$label1 = $label2 + " Client Holdings - Institutional Position Holding"
	   	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianUSBankInstitutionalPositionHolding.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$label1 "  /set "\package.variables[PowerShellLocation].Value;$ScriptName"   | Out-File $logFile -Append
		
		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
				$SSISErrorMessage =  fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Institutional Position Holdings: file ( $strFileName ) not success" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") US Bank Institutional Position Holdings: file ( $strFileName ) imported" | Out-File $LogFile -Append
		$flag1=1
	}
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$ArcDate -Force
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
	$flag=1 
    #}

}

IF($flag -eq 1)
{

	IF($flag1 -eq 1)
	{
		## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUSBankInstitutionalPositionHoldings.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	   	 #& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUSBankInstitutionalPositionHolding.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
		$GenericNormalizationJobID = 27
		& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

			## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  US Bank Client Holdings: file ( $strFileName ) NormalizeCustodianUSBankInstitutionalPositionHoldings.dtsx is not success" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCustodianUSBankInstitutionalPositionHoldings.dtsx `r`n "| Out-File $LogFile -Append
	}

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUSBankPositionHolding.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

   	 #& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUSBankPositionHolding.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
	$GenericNormalizationJobID = 26
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  US Bank Client Holdings: file ( $strFileName ) NormalizeCustodianUSBankPositionHolding.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCustodianUSBankPositionHolding.dtsx `r`n "| Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUSBankAmortizationSchedule.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   & $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUSBankAmortizationSchedule.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  US Bank Client Holdings: file ( $strFileName ) NormalizeCustodianUSBankAmortizationSchedule.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCustodianUSBankAmortizationSchedule.dtsx `r`n "| Out-File $LogFile -Append
	




}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
