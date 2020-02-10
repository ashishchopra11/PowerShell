############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
#################################################################################### 


#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""


#****** Use this section to add any custom logic for SourceFolder, RefDataSetDate, Label, FileName, or ArchiveFolder, then change the appropriate parameter below in the fGenericImportJob function below ******
	$ScriptName = $MyInvocation.MyCommand.Definition
	$ArchiveLocation = "\\hcm97\pmpdatafeeds\SEI Administrator Retail Data\$strDateNow"
#****** End section ******


#****** Generic Import - Positions & Prices ******
	$GenericImportJobID = 2
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate

	if ($ReturnDate -ne "") {
	#****** Generic Normalization - Positions ******
		$GenericNormaliztaionJobID = 32
		fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

	#****** Generic Normalization - Prices ******
		$GenericNormaliztaionJobID = 33
		fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	} 
	
	
#****** Generic Import - P&L YTD ******
	$GenericImportJobID = 4
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate


#****** Generic Import - NAV ******
	$ReturnDate = ""	
	$GenericImportJobID = 5
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate

	if ($ReturnDate -ne "") {
	#****** Custom Normalization - SEI Retail NAV ******
		# SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianSEIAdministratorRetailData_NAV.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIAdministratorRetailData_NAV.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
		
		# Check for SSIS failure
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") SEI NAV: file ( $strFileName ) NormalizeCustodianSEIAdministratorRetailData_NAV.dtsx failed" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}


	#****** Custom Push - SEI Retail NAV ******
		# SSIS DataSet Variables
		$DataSource = "SEI Retail NAV"
		$Label		= "NAV"
		$Label_HCM	= "SEI Retail tFundTickerNav"
		
		# SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushNav.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		& $2016DTEXEC32 /f  "$dirSSISPush\PushNav.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[DataSource].Value;$DataSource" /set "\package.variables[Label].Value;$Label" /set "\package.variables[Label_HCM].Value;$Label_HCM" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append	
		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") SEI NAV: file ( $strFileName ) PushNav.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
	}


#****** Generic Import - Trial Balance R122 ******
	$GenericImportJobID = 34
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	
#****** Generic Import - P&L ******
	$ReturnDate = ""
	$GenericImportJobID = 3
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	
#****** Generic Import - Trial Balance R092 ******
	$GenericImportJobID = 33
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveLocation ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate


	if ($ReturnDate -ne "") {
	#****** Custom Normalization - SEI Fund Values ******
		# SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianSEIAdministratorRetailData_PLReconFundValues.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIAdministratorRetailData_PLReconFundValues.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
		
		# Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") SEI NAV and PL: file ( $strFileName ) NormalizeCustodianSEIAdministratorRetailData_PLReconFundValues.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
