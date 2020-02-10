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
	. .\fLog.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 81
	
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

	$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\Goldman Sachs Cash Import"	
	$dirArchiveFolder = "$dirDataFeedsArchiveFolder\Goldman Sachs Cash Import\Archive"
	
	New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
	$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow
	Move-Item -Path "$dirDataFeedsFolder\*GS-SDI-Account_Balances*" -Destination "$dirArchiveFolder"
	
	foreach ($strFileName in Get-ChildItem -Path $dirArchiveFolder | Where-Object {$_.Name -ilike "GS-SDI-Account_Balances*.xls"}) 
	{
		$FileName = $strFileName.Tostring()
	
		$FileFullPath = $strFileName.FullName
		$RefDataSetDate1 = $null
		
		$wb = New-Object Aspose.Cells.Workbook($FileFullPath);
		$ws = $wb.Worksheets[0]	
		$ws.Cells.DeleteColumn(5,1)
		$ws.Cells.deleteRows(0,1)
		#$ws.Cells.DeleteBlankColumns();
		$NewFileName = "$dirDataFeedsFolder\" + "New_" + "$FileName"
		
		#$wb.Save($FileName,Aspose.Cells.FileFormatType.Excel2003)
		$wb.Save($NewFileName)
	}	
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "New_GS-SDI-Account_Balances*.xls"}) 
	{   
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
		$FileName = $strFileName.Tostring()
		
		$FileFullPath = $strFileName.FullName
		$RefDataSetDate1 = $null
    
		Write-Output $FileFullPath | Out-File $LogFile -Append
		
		$wb = New-Object Aspose.Cells.Workbook($FileFullPath)
		$ws = $wb.Worksheets[0]
				
		$RefDataSetDate_FileStr = ""
		[String]$RefDataSetDate_FileStr =$ws.Cells.GetCell(1,0).Value
		$RefDataSetDate_FileStr = $RefDataSetDate_FileStr.replace("All Accounts","").Trim()
		$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate_FileStr,'M/d/yyyy',$null)).toshortdatestring() 
		fLog -pMessage "RefDataSetDate :: $RefDataSetDate " -pLogFile $LogFile
	}
	
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $RefDataSetDate -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
