FUNCTION fGenevaImportNormalize{
	Param
	{
		[datetime]$process_date
		,[string]$LogFile
	}
	
	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\DTExec.Config.ps1
	. .\DirLocations.Config.ps1

	$ScriptName = $MyInvocation.MyCommand.Name
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
	$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
	$date_string = Get-Date -Date $process_date -UFormat %x
	$FullDayString = $process_date.ToShortDateString()
	Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
	Write-Output " date_string				= $date_string" |  Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fGenevaImportNormalize starts here " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractGeneva\ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISExtractGeneva\ExtractGenevaPosition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISExtractGeneva\ExtractGenevaPosition.dtsx Completed " | Out-File $LogFile -Append
	}

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx Completed " | Out-File $LogFile -Append
	}

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
	
	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") fGenevaImportNormalize : $dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx Completed " | Out-File $LogFile -Append
	}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
