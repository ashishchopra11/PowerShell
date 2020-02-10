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
	$GenericImportJobID1 = 124
	$GenericImportJobID2 = 125
	$GenericNormaliztaionJobID = 55


#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""


#****** Use this section to add any custom logic for SourceFolder, RefDataSetDate, Label, FileName, or ArchiveFolder, then change the appropriate parameter below in the fGenericImportJob function below ******
	###Later we will need to run the generic normalization for the RefDataSetDate loaded, as well as for every date afterward, up to yesterday's date
	$CurrDate = Get-Date
#****** End section ******


#****** Generic Import ******

	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID1 -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate

	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID2 -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	##$RefDatasetDate = $ReturnDate ## We do not want this date for the normalization - just the date from the first file


#****** Generic Normalization ******
	###We need to run the generic normalization for the RefDataSetDate loaded, as well as for every date afterward, up to yesterday's date
	while($RefDatasetDate -lt $CurrDate){
		fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
		
		$RefDatasetDate = $RefDatasetDate.AddDays(1)
	}
