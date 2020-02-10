FUNCTION fWSONormalizeHigh{
	Param
	{
		[datetime]$process_date
		,[string]$LogFile
	}
	
	$currDate = Get-Date 
	
	If ($currDate -ge $process_date) {
		$process_date = $currDate.AddDays(-1)
	}
	
	$ScriptName = $MyInvocation.MyCommand.Name
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
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fWSONormalizeHigh : $dirSSISNormalizeWSO\NormalizeWSOPrices.dtsx Completed " | Out-File $LogFile -Append
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
