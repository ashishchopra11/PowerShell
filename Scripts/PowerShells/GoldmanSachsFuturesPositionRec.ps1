############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\fGetDataFromFile.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 78
	$GenericNormaliztaionJobID = 	18
	
	## Apose.Cells
	[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

	## Aspose License
	$license = New-Object Aspose.Cells.License
	$license.SetLicense($dirAsposeCellsLic);
	
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\Goldman Sachs Futures"	
	$dirArchiveFolder = "$dirDataFeedsArchiveFolder\GoldmanSachsFuturesPositionRec\Archive"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "GS-SDI-Open_Positions-*.xls"}) 
	{   
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
		$FileName = $strFileName.Tostring()
		
		$FileFullPath = $strFileName.FullName
		
		fLog -pMessage "Parse RefDataSetDate from File Contents :: $FileFullPath " -pLogFile $LogFile
		
		$RefDataSetDate_FileStr = ""
		fGetDataFromFile -pLocationInFile '3,1' -pPathToFile $FileFullPath -pWorksheetNumber 1 -ReturnValue ([Ref]$RefDataSetDate_FileStr)
		fLog -pMessage "RefDataSetDate_FileStr :: $RefDataSetDate_FileStr " -pLogFile $LogFile
		$RefDataSetDate_FileStr = $RefDataSetDate_FileStr.replace("All Accounts","").Trim()
		$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate_FileStr,'M/d/yyyy',$null)).toshortdatestring() 
		fLog -pMessage "RefDataSetDate :: $RefDataSetDate " -pLogFile $LogFile
 	
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $RefDataSetDate -pLabel $null -pLogFile $LogFile -pFileName $FileName -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	#$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDataSetDate -pLogFile $LogFile -pScriptName $null
}