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
#	$GenericImportJobID = 													##### NEED TO UPDATE #####
#	$GenericNormaliztaionJobID = 											##### NEED TO UPDATE #####


#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""


#****** Use this section to add any custom logic for SourceFolder, RefDataSetDate, Label, FileName, or ArchiveFolder, then change the appropriate parameter below in the fGenericImportJob function below ******
	$dirRawFiles = "$dirServicesDeliveryStoreFolder\MSCI LRMP"
	$dirEmailRiskCommittee = "$dirRawFiles\Email Reports - Liquidity Risk Committee"
	$dirEmailFFA = "$dirRawFiles\Email Reports - FFA"
	
	Remove-Item "$dirEmailRiskCommittee\*.*"
	Remove-Item "$dirEmailFFA\*.*"
#****** End section ******


##****** Generic Import ******
#
#	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
#	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
#
#
##****** Generic Normalization ******
#	$RefDatasetDate = $ReturnDate
#	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
#