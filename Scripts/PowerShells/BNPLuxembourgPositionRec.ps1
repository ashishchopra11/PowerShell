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
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 77													
	$GenericNormaliztaionJobID = 	12									

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	## Apose.Cells
	[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

	## Aspose License
	$license = New-Object Aspose.Cells.License
	$license.SetLicense($dirAsposeCellsLic);

	
	$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\BNP\BNPLuxembourg"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*Position_holding_BAYVK_R2_Lux*.xls"}) 
	{   
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::   BNP Lux Positions: file ( $strFileName ) processing " | Out-File $LogFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
	$FileName = $strFileName.Tostring()
	
	$FileFullPath = $strFileName.FullName
	$RefDataSetDate1 = $null
	
	$Path = $FileFullPath
	
	$wb = New-Object Aspose.Cells.Workbook($FileFullPath);
	$ws = $wb.Worksheets[0]
	
	$RefDataSetDate1 = $null
	[String]$RefDataSetDate1 =$ws.Cells.GetCell(1,7).Value
	$RefDataSetDate1 =  $RefDataSetDate1.Split(' ')[0]

	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,'M/dd/yyyy',$null)).toshortdatestring()
	}
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $RefDataSetDate -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
