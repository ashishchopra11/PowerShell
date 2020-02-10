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
	
	Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 133
	$GenericNormaliztaionJobID = 	25

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$PostionFilesDir = "$dirServicesDeliveryStoreFolder\State Street Administrator Position Rec"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: PostionFilesDir		=	$PostionFilesDir" |  Out-File $LogFile -Append
	
	# UnRAR the files.
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Removed .CSV files from zip" | Out-File $LogFile -Append	
	Remove-Item -Path "$PostionFilesDir\*.csv" -Force
	Expand-ZIPFile  -File "$PostionFilesDir\attachment.zip" -Destination $PostionFilesDir  | Wait-Process 

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
	Remove-Item -force "$PostionFilesDir\attachment.zip"

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianStateStreetAdministratorPositionRec.dtsx `r`n "| Out-File $LogFile -Append
