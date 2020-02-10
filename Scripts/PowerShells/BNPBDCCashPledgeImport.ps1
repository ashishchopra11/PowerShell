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
	$GenericImportJobID = 157													##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv4)
	$license = New-Object Aspose.Cells.License
	$license.SetLicense($dirAsposeCellsLic);
	
	$sourcePath = "\\services\DeliveryStore\BNP BDC Pledge";

	
    foreach($strFileName in Get-ChildItem -path $sourcePath | Where-Object {$_.Name -ilike 'NEXP DVX_RVM*.XLS'})
    { 
	    $excelPath = $strFileName.FullName
	    
	    $Workbook = New-Object Aspose.Cells.Workbook($excelPath)
	    $Worksheet = $Workbook.Worksheets[0]
	    
	    $Worksheet.Cells.DeleteRow(35)
	    
	    $Workbook.Save($excelPath)
    }
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	