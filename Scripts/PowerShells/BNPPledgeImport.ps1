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
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\BNP Pledge"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.csv*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".csv.pgp", ""
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.csv*"})
	{	
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$HeaderLine =	'Financing Unit','Type','Issuer Name','Security Description','Cusip','ISIN','Ccy','Quantity','Price','Mkt Value','PV',
			'Concentration %','Eqty 90-day Volume','Days Volume','Bond Issue Size (K)','S&P Rating','Moody Rating','Equity Volatility',
			'CB Parity %','CB Premium %','CB Hedge Ratio','Core Rate','Conc Adj','Liq Adj','Volat Adj','Long Maturity Adj','HY Conc Adj',
			'Margin Rate','Margin Amount','Exception','Strategy','Acct Number','Country Of Risk','Sector','Group','FXRate'
		
		$import = Import-CSV $FileName -Header $HeaderLine | select -Skip 3			
		$import | Export-Csv $FileName -Force -NoTypeInformation
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.csv*"})
	{	
		$Fund = $strFileName.Name.Split("_")[1]
	
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewFileName = "$dirDataFeedsFolder\" + $Fund + "_" + "$strFileName"
		$Data = Import-CSV $FileName
		
		$ModifiedData = $Data | Select-Object @{n='FundID';e={$Fund}}, *
		
		$ModifiedData | Export-CSV $NewFileName -NoTypeInformation
	}
	
	
 
#****** Generic Import ******

	# 59100255
	$GenericImportJobID = 64					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# 59100259
	$GenericImportJobID = 65					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# 59100263
	$GenericImportJobID = 66					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# 59100265
	$GenericImportJobID = 67					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# 59100470
	$GenericImportJobID = 68					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	# 59103718
	$GenericImportJobID = 69					
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.csv*"})
	{
		Remove-Item "$dirDataFeedsFolder\$strFileName"
	}
	
#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianBNPPledgePositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	$GenericNormaliztaionJobID = 	58
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNPPledgePositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  | Out-File $logFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianBNPPledgePositions: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianBNPPledgePositions: file Normalized" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $PSScriptName END " | Out-File $LogFile -Append

	$GenericNormaliztaionJobID = 75
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
