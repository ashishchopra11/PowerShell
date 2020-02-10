
FUNCTION fWSOImportSupplemental-API{
	Param
	{
		[string]$WSO_Extracts_DIR
		,[datetime]$process_date
		,[string]$LogFile
	}
  Clear-Host
#	$ScriptName = $MyInvocation.MyCommand.Name
		IF ($ScriptName -eq $null)
	{
	$ScriptName = $MyInvocation.MyCommand.Name
	}
	ELSE 
	{$ScriptName = $ScriptName}
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
	
$strDateNow = get-date $process_date -format "yyyyMMdd"

#$strDate = get-date -format "yyyyMMddTHHmmss"

#$FullDayString = ($process_date).ADDDAYS(-1).ToString("MM/dd/yyyy")
$FullDayString = ($process_date).ADDDAYS(0).ToString("MM/dd/yyyy")
#$strDateNow = "20151102"
$PriorstrDateNow = $strDateNow - 1
$strDate = get-date -format "yyyyMMddTHHmmss"
#$strDate = "20151103T000000"
#$PriorstrDateNow = "20151103"
#$FullDayString = "11/03/2015"
$WSO_Extracts_DIR1 		= "$WSO_Extracts_DIR\$strDateNow\API\Converted"
$ArchiveFolder = "$WSO_Extracts_DIR1\Archive"

Write-Output " WSO_Extracts_DIR1		= $WSO_Extracts_DIR1" |  Out-File $LogFile -Append
Write-Output " ArchiveFolder			= $ArchiveFolder" |  Out-File $LogFile -Append
Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
Write-Output " PriorstrDateNow			= $PriorstrDateNow" |  Out-File $LogFile -Append

#$dirSSISExtractWSO      = "\\dhcmjob08\d$\HCM\SSIS2012.Datawarehouse\ExtractWSO\bin"

<#if (!(Test-Path -path $ArchiveFolder\$strDate)) 
    { 
	    New-Item -path $ArchiveFolder\$strDate -ItemType directory 
    }
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOImportSupplemental-API starts here " | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractBondPutCallSchedule_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractBondPutCallSchedule.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractBondPutCallSchedule.dtsx" 	/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""BondPutCallSchedule_API"""
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBondPutCallSchedule.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBondPutCallSchedule.dtsx Completed " | Out-File $LogFile -Append
	}

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractBonds_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractBonds.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractBonds.dtsx" 					/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Bonds_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBonds.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBonds.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractBondCouponRate_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractBondCouponRate.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractBondCouponRate.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""BondCouponRate_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBondCouponRate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBondCouponRate.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractContact_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractContact.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractContact.dtsx" 				/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Contact_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractContact.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractContact.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractCurrencyExchangeRates_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractCurrencyExchangeRates.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractCurrencyExchangeRates.dtsx" 	/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""CurrencyExchangeRates_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractCurrencyExchangeRates.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractCurrencyExchangeRates.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractEarnedIncomeDetail_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractEarnedIncomeDetail.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractEarnedIncomeDetail.dtsx" 	/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""EarnedIncomeDetail_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractEarnedIncomeDetail.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractEarnedIncomeDetail.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractEquities_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractEquities.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractEquities.dtsx" 				/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Equities_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractEquities.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractEquities.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractTransactions_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractTransactions.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractTransactions.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Transactions_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractTransactions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractTransactions.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractLedgerAccounts_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractLedgerAccounts.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""LedgerAccounts_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
	}

#	## SSIS Status Variables
#		[Int]$lastexitcode = $null
#		[String]$SSISErrorMessage = $null
#		[String]$SourceFileName = "Daily_ExtractLedgerTransactions_$strDateNow.CSV"
#		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractLedgerTransactions.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
#		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
#		& $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractLedgerTransactions.dtsx" 	/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""LedgerTransactions_API"""
#	  ## Check SSIS is success or not 
#		If ($lastexitcode -ne 0 ) {
#				$SSISErrorMessage = fSSISExitCode $lastexitcode;
#				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerTransactions.dtsx is not success" | Out-File $LogFile -Append
#				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
#			}
#			else{
#		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerTransactions.dtsx Completed " | Out-File $LogFile -Append
#		}
<# Running By 'D:\Siepe\Data\Scripts\WSO\ImportWSOLedgerAccountPortfolioMap.ps1'
### BEGIN - ADDED BY MD - 2017-06-12
	## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		[String]$SourceFileName = "Daily_ExtractLedgerAccountPortfolioMap_$strDateNow.CSV"
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractLedgerAccountPortfolioMap.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName `r`n  PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		& $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractLedgerAccountPortfolioMap.dtsx" 	/set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerAccountPortfolioMap.dtsx is not success" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			}
			else{
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractLedgerAccountPortfolioMap.dtsx Completed " | Out-File $LogFile -Append
		}
### END - ADDED BY MD - 2017-06-12
#>
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractActionCode_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractActionCode-API.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractActionCode-API.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""ActionCode_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractActionCode-API.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractActionCode-API.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractBankDeals_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractBankDeals-API.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractBankDeals-API.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""BankDeals_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBankDeals-API.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractBankDeals-API.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractContracts_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractContracts-API.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractContracts-API.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Contracts_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractContracts-API.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractContracts-API.dtsx Completed " | Out-File $LogFile -Append
	}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractFacilities_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractFacilities-API.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractFacilities-API.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Facilities_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractFacilities-API.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractFacilities-API.dtsx Completed " | Out-File $LogFile -Append
	}
	
    ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractRatings_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractRatings.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractRatings.dtsx" 				/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Ratings_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractRatings.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractRatings.dtsx Completed " | Out-File $LogFile -Append
	}
    
 ## Do not process ratings and industries for Saturday and Sunday ...
   if ($process_date.DayOfWeek -ne "Saturday" -and $process_date.DayOfWeek -ne "Sunday") {
  #if ($process_date.DayOfWeek -ne "Sunday") {
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") The day of week is not equal to Saturday and Sunday :: $process_date ( $process_date.DayOfWeek ) " | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractSIC_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractSIC.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractSIC.dtsx" 					/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""SIC_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractSIC.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractSIC.dtsx Completed " | Out-File $LogFile -Append
	}
		
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = "Daily_ExtractCapFloorRate_$strDateNow.CSV"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\Supplemental\ExtractCapFloorRate.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $SourceFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractCapFloorRate.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""CapFloorRate_API"""
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractCapFloorRate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSOImportSupplemental-API : $dirSSISExtractWSO\Supplemental\ExtractCapFloorRate.dtsx Completed " | Out-File $LogFile -Append
	}
}


<#	##Move file to Archive Directory
    Move-Item -Path "$WSO_Extracts_DIR1\Daily_Extract*_$strDateNow.csv" "$ArchiveFolder\$strDate" 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $WSO_Extracts_DIR1\Daily_Extract*_$strDate.csv ) to location ( $ArchiveFolder\$strDate ) " | Out-File $LogFile -Append
    
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
	#>
}
