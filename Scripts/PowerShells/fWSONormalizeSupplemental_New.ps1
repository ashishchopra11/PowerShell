FUNCTION fWSONormalizeSupplemental{
	Param
	{
		[datetime]$process_date
		,[string]$LogFile
	}
	
#	$ScriptName = $MyInvocation.MyCommand.Name
	IF ($ScriptName -eq $null)
	{
	$ScriptName = $MyInvocation.MyCommand.Name
	}
	ELSE 
	{$ScriptName = $ScriptName}
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
	
$FullDayString = $process_date.ToShortDateString()

Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSONormalizeSupplemental starts here " | Out-File $LogFile -Append

## -- Normalize Supplemental
	## -- Normalize into Reference
	
	## SSIS Status Variables

	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOBanks.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOBanks.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
		  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOBanks.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOBanks.dtsx Completed " | Out-File $LogFile -Append
	}
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractFacilities `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractFacilities.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractFacilities.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractFacilities.dtsx Completed " | Out-File $LogFile -Append
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractBankDeals.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractBankDeals.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractBankDeals.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractBankDeals.dtsx Completed " | Out-File $LogFile -Append
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractBond.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractBond.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractBond.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractBond.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractContracts.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractContracts.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractContracts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractContracts.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
	}
	
### BEGIN - ADDED BY MD - 2017-06-12
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx Completed " | Out-File $LogFile -Append
	}
### END - ADDED BY MD - 2017-06-12

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[DateTime]$FullDayString = '14-04-2017'
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
		  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractRating.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractRating.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractRating.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractRating.dtsx Completed " | Out-File $LogFile -Append
	}
	
	
	 if ($process_date.DayOfWeek -ne "Saturday" -and $process_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") The day of week is not equal to Saturday and Sunday :: $process_date ( $process_date.DayOfWeek ) " | Out-File $LogFile -Append
		
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractTraders.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractTraders.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractTraders.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractTraders.dtsx Completed " | Out-File $LogFile -Append
	}
	
	
	}

	## -- Re-normalize instrument info
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	   & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx Completed " | Out-File $LogFile -Append
	}
	
<# Moving to High Priority fWSONormalizeAPI_New.ps1 #>
#	## SSIS Status Variables
#	[Int]$lastexitcode = $null
#	[String]$SSISErrorMessage = $null
#	
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
#	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" |  Out-File $LogFile -Append
#			  ## Check SSIS is success or not 
#	If ($lastexitcode -ne 0 ) {
#			$SSISErrorMessage = fSSISExitCode $lastexitcode;
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx is not success" | Out-File $LogFile -Append
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
#		}
#		else{
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx Completed " | Out-File $LogFile -Append
#	}
	
	## Do not process ratings and industries for Saturday and Sunday ...
	 if ($process_date.DayOfWeek -ne "Saturday" -and $process_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") The day of week is not equal to Saturday and Sunday :: $process_date ( $process_date.DayOfWeek ) " | Out-File $LogFile -Append
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractSIC.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractSIC.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractSIC.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOExtractSIC.dtsx Completed " | Out-File $LogFile -Append
	}
	}


	## -- Push to HCM
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstFacilities.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushInstFacilities.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
		  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstFacilities.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstFacilities.dtsx Completed " | Out-File $LogFile -Append
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstIssue.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushInstIssue.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstIssue.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstIssue.dtsx Completed " | Out-File $LogFile -Append
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushBankDeals.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushBankDeals.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushBankDeals.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushBankDeals.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstRelation.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushInstRelation.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstRelation.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstRelation.dtsx Completed " | Out-File $LogFile -Append
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushLedgerAccounts.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 if ($process_date.DayOfWeek -ne "Saturday" -and $process_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {	
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstBond.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushInstBond.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstBond.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstBond.dtsx Completed " | Out-File $LogFile -Append
	}
	
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstCashFlow.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	  & $2016DTEXEC32 /f "$dirSSISPush\PushInstCashFlow.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstCashFlow.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstCashFlow.dtsx Completed " | Out-File $LogFile -Append
	}
	
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushIndustries.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushIndustries.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushIndustries.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushIndustries.dtsx Completed " | Out-File $LogFile -Append
	}
	
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushRatings.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushRatings.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushRatings.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushRatings.dtsx Completed " | Out-File $LogFile -Append
	}
	
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\NormalizeWSOExtractCapFloorRate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractCapFloorRate.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\NormalizeWSOExtractCapFloorRate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\NormalizeWSOExtractCapFloorRate.dtsx Completed " | Out-File $LogFile -Append
	}
	}

	## -- Re-push instrument info
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstruments.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushInstruments.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstruments.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstruments.dtsx Completed " | Out-File $LogFile -Append
	}

    ## --Repush Inst Identifiers into HCM
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstIdentifiers.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append  
     & $2016DTEXEC32 /f "$dirSSISPush\PushInstIdentifiers.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstIdentifiers.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISPush\PushInstIdentifiers.dtsx Completed " | Out-File $LogFile -Append
	}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}