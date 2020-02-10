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

#****** Initialize variables ******
	$GenericImportJobID = 12
	$GenericNormaliztaionJobID = 1031			##### ****** NEED TO UPDATE ****** #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	
	$SourceDirectory = "\\services\deliverystore\State Street Hurley Cash"
	$ArchiveDirectory = "\\hcm97\pmpdatafeeds\State Street Hurley Cash"
	$ReturnDate = ""
 
 
#****** Unzip File ******
	foreach ($ZipFileName in Get-ChildItem -Path $SourceDirectory | Where-Object {$_.Name -ilike "*attachment.zip"})
	{ 
		Expand-ZIPFile –File "$SourceDirectory\$ZipFileName" –Destination $SourceDirectory   | Wait-Process 
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::   Completed Extraction :: $ZipFileName " | Out-File $LogFile -Append
	}

#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder "$ArchiveDirectory\$strDateNow" ([Ref]$ReturnDate)

#****** Generic Normalization ******
	#####$RefDatasetDate = $ReturnDate
	#####
	#######Think through how to pass log file into fGenericNormalization
	#####fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
