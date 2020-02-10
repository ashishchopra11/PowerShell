############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\fSSISExitCode.ps1
#################################################################################### 


#****** REQUIRED VARIABLES - if no normalization is required, simply comment out the $GenericNormalizationJobID and fGenericNormalization lines below ******
	$GenericImportJobID = 86

#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""


#****** Use this section to add any custom logic for SourceFolder, RefDataSetDate, Label, FileName, or ArchiveFolder, then change the appropriate parameter below in the fGenericImportJob function below ******
	$SourceFolder = "\\services\DeliveryStore\Bloomberg Style Factors"
	$WorkingFolder = "\\services\DeliveryStore\Bloomberg Style Factors\Working"
	$ArchiveFolder = "\\hcm97\pmpdatafeeds\Bloomberg Style Factors\$strDateNow"
#****** End section ******

#There may be multiple files that need to be processed at the same time - so we will need to create a loop to process each file individually
foreach ($FileName in Get-ChildItem	 -Path $SourceFolder | Where-Object {$_.Name -ilike "*_Style_Factors.xls"})
{ 
	#Move the target file out of the common folder with the other files and into the working destination - this will allow us to know exactly which file is being processed with each pass through the loop
	Move-Item -Path "$SourceFolder\$FileName" -Destination "$WorkingFolder\$FileName"
	
	#****** Generic Import ******
		#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
		fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveFolder ([Ref]$ReturnDate)
		$RefDatasetDate = get-date -Date $ReturnDate

	#Normalize
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeVendorBloombergStyleFactors.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		
		& $2016DTEXEC32 /F "$dirSSISNormalizeVendor\NormalizeVendorBloombergStyleFactors.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append

		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: NormalizeVendorBloombergStyleFactors.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeVendorBloombergFactor.dtsx `r`n "| Out-File $LogFile -Append

	#Push
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling PushBloombergStyleFactors.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		
		& $2016DTEXEC32 /F "$dirSSISPush\PushBloombergStyleFactors.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append

		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: PushBloombergStyleFactors.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed PushBloombergStyleFactors.dtsx `r`n "| Out-File $LogFile -Append
}
