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


#****** REQUIRED VARIABLES - if no normalization is required, simply comment out the $GenericNormalizationJobID and fGenericNormalization lines below ******
	$GenericImportJobID = 73
#	$GenericNormaliztaionJobID = 											##### NEED TO UPDATE #####


#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""


#****** Use this section to add any custom logic for SourceFolder, RefDataSetDate, Label, FileName, or ArchiveFolder, then change the appropriate parameter below in the fGenericImportJob function below ******
	$SourceFolder = "\\services\DeliveryStore\Bloomberg Index Constituents"
	$WorkingFolder = "\\services\DeliveryStore\Bloomberg Index Constituents\Working"
	$ArchiveFolder = "\\hcm97\pmpdatafeeds\Bloomberg Index Constituents\$strDateNow"
	$FileExist = 0
#****** End section ******

#There may be multiple files that need to be processed at the same time - so we will need to create a loop to process each file individually
foreach ($FileName in Get-ChildItem	 -Path $SourceFolder | Where-Object {$_.Name -ilike "SECTOR_PERFORMANCE_-_*.xls"})
{ 
	$FileExist = 1
	#Move the target file out of the common folder with the other files and into the working destination - this will allow us to know exactly which file is being processed with each pass through the loop
	Move-Item -Path "$SourceFolder\$FileName" -Destination "$WorkingFolder\$FileName"
	
	#****** Generic Import ******
		#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
		fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $ArchiveFolder ([Ref]$ReturnDate)
		$RefDatasetDate = $ReturnDate

	##****** Generic Normalization ******
	#	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
}
If($FileExist -eq 1)
{
##****** NormalizeVendorBloombergIndexConstituentReturn ******
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergIndexConstituentReturn.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate `r`n " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergIndexConstituentReturn.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate" | Out-File $logFile  -Append
}