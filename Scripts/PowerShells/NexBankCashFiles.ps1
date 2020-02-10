############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\DTExec.Config.ps1
	. .\fSSISExitCode.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 155
	$GenericNormaliztaionJobID = 78
	$DataSource = "NexBank"

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

#****** Push To HCM ******
	$date_string = $RefDatasetDate.ToShortDateString()
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushCashWorksheetData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate "| Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISPush\PushCashWorksheetData.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate"/set "\package.variables[Ref_RefDataSource].Value;$DataSource"  | Out-File $LogFile  -Append
	## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") PushCashWorksheetData: Not success " | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") PushCashWorksheetData: Success" | Out-File $LogFile -Append
