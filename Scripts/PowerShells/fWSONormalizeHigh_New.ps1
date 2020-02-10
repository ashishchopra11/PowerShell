FUNCTION fWSONormalizeHigh{
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
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSONormalizeHigh starts here " | Out-File $LogFile -Append
	
## -- Normalize High Priority
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPortfolios.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPortfolios.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPortfolios.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPortfolios.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOIssuers.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	#& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString"
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOIssuerAssets.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOAssetID.dtsx Completed " | Out-File $LogFile -Append
	}
	
	## -- Push to HCM
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\PushLegalEntities.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushLegalEntities.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushLegalEntities.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushLegalEntities.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\PushInstruments.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	  & $2016DTEXEC32 /f "$dirSSISPush\PushInstruments.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushInstruments.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushInstruments.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\PushPortfolios.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushPortfolios.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushPortfolios.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushPortfolios.dtsx Completed " | Out-File $LogFile -Append
	}
	 if ($process_date.DayOfWeek -ne "Saturday" -and $process_date.DayOfWeek -ne "Sunday") {
	#if ($process_date.DayOfWeek -ne "Sunday") {
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") The day of week is not equal to Saturday and Sunday :: $process_date ( $process_date.DayOfWeek ) " | Out-File $LogFile -Append
		## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractTrade.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
	  & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractTrade.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOExtractTrade.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOExtractTrade.dtsx Completed " | Out-File $LogFile -Append
	}}
	
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPositions.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPositions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPositions.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\PushInstIdentifiers.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISPush\PushInstIdentifiers.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushInstIdentifiers.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\PushInstIdentifiers.dtsx Completed " | Out-File $LogFile -Append
	}
	## -- Normalize into Reference
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName"	| Out-File $LogFile -Append
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx Completed " | Out-File $LogFile -Append
	}
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOYTDPnLDifference.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOYTDPnLDifference.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  |  Out-File $LogFile -Append
			  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOYTDPnLDifference.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeSupplemental : $dirSSISNormalizeWSO\NormalizeWSOYTDPnLDifference.dtsx Completed " | Out-File $LogFile -Append
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
