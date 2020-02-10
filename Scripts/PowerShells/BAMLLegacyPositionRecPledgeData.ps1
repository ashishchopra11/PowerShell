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
	$GenericImportJobID = 100

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\BAML Legacy Position Rec & Pledge Data"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*XHIHFTPAC1*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$FileName = $FileName.SubString(0,110)
		$NewName = $FileName -Replace ".txt.asc", ".csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*XHIHFTPAC1*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace('|',',') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*XHIHFTPAC1*"})
	{	
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$HeaderLine =	'RunDate','BusinessDate','ClientID','ClientSName','ClientBusGroupID','ClientBusGroupSName','FundID','FundSName',
		'InboundReportedAccountNumber','GPBAccountNumber','AccountSName','TradingGroupID','TradingGroupSName','TradingSubgroupID','TradingSubgroupSName',
		'CustodianCode','CustodianSName','CoreAccountID','GPBProductID','ProductSDesc','OldProductSDesc','ISIN','CUSIP','TickerSymbol','QuickCode',
		'SEDOL','OPRACode','StandardCompositeID','USCompositeID','AssetClass','IssueCurrency','TradingCurrency','ProductType','PriceFactor',
		'TradeFactor','BaseCCY','LocaltoBaseFX','PositionType','PositionDate','KnowledgeDate','TDQuantity','SDQuantity','BaseMarket Price',
		'BaseTDMarketValue','BaseSDMarketValue','BaseAccruedDividends','BaseAccruedInterest','LocalMarketPrice','OverriddenLocalPrice',
		'LocalTDMarketValue','LocalSDMarketValue','LocalAccruedDividends','LocalAccruedInterest','BaseCost','BaseGL','BaseLTGL','BaseSTGL',
		'BaseCapGL','BaseLTCapGL','BaseSTCapGL','BaseFXGL','LocalCost','LocalGL','LocalLTGL','LocalSTGL','Product','Option Type','Expiration Date',
		'Strike Price','Underlying Ticker','Underlying CUSIP','Underlying ISIN','Underlying Sedol','Primary RIC','Financing Type'
    
		
		$import = Import-CSV $FileName -Header $HeaderLine | Select -Skip 1
		$import | Export-Csv $FileName -Force -NoTypeInformation
	}

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate

	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBAMLPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"| Out-File $logFile  -Append

	
	$GenericNormaliztaionJobID = 	11
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	$GenericNormaliztaionJobID = 	30
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
