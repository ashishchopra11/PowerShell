############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\fGenericNormalizationTrade.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 80													##### NEED TO UPDATE #####
	$GenericNormaliztaionJobID = 	48										##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\GoldmanSachsIntradayTrades"
	
	Write-Output "Test" | Out-File $LogFile -Append
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*GS-Intraday-Intraday_Trades*.csv"}) 
	{   
		$FileNamePath = $strFileName.FullName 	
		
		$CSV = Import-CSV $FileNamePath
		$RefDatasetDate = $CSV[0].("Activity Date")
	}
	
	$RefDataSetDate = [DateTime]::ParseExact($RefDataSetDate, "yyyyMMdd", $null) 
	
	#Write-Output "RefDataSetDate: $RefDatasetDate" | Out-File $LogFile -Append
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $RefDatasetDate -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalizationTrade -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
