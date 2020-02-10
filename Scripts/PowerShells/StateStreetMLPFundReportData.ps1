##Prod
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\fGenericImportJob.ps1
####################################################################################


## Apose.Cells
[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv8)

## Aspose License
$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}



$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ImportCustodianStateStreetMLPFundReports."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\StateStreet\MLPFundReports"
#$dirSourceFolder = "C:\HCM\DataFeeds\StateStreet"
#$dirArchiveFolder = "$dirSourceFolder\MLPFundReports\Archive"
$dirArchiveFolder = "$dirArchiveHCM97DriveFolder\StateStreetMLPFundReports\Archive"


[bool]$FileZipExists = $False
[bool]$FileExists = $False

#$dirArchiveFolder = "$dirDestinationFolder\Archive"

Write-Output " LogFile					= $LogFile" |  Out-File $LogFile -Append
Write-Output " dirSourceFolder			= $dirSourceFolder" |  Out-File $LogFile -Append
Write-Output " dirDestinationFolder		= $dirDestinationFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder			= $dirArchiveFolder" |  Out-File $LogFile -Append

###Create Archive folder
$strDateNow = get-date -format "yyyyMMddTHHmmss"
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory -force

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Creating Archive Folder ::  $dirArchiveFolder\$strDateNow " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  StateStreet MLP Fund reports " | Out-File $LogFile -Append

################# PY2E COST ###########################
## Check fo Source file existence
foreach ($FileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "PY2E_COST*.xlsx"}) 
{
	  $RefDataSetDate1 = $null
	    $RefDataSetDate = $null
 	$FileNamePath = $FileName.BaseName
	$RefDataSetDate1 = $FileNamePath.Split('_')[1]
	$RefDataSetDate = $RefDataSetDate1.Substring(5,($RefDataSetDate1.length)-5)
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate,”M.d.yy”,$null)).toshortdatestring()
	
	$xls = "$dirSourceFolder\$FileName"
	$strFileName = $FileName.BaseName+".csv"
	$LoadOptions = $null
	$FinalFile = "$dirSourceFolder\$strFileName"
	
	$LoadOptions = New-Object Aspose.Cells.LoadOptions;
	$LoadOptions.Password = "highland$"
	$wb = New-Object Aspose.Cells.Workbook($xls,$LoadOptions);

	$wb.Save($FinalFile);

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ImportCustodianStateStreetIntradayCost.dtsx `r`n Variable passed here are : `r`n  FolderPath = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianStateStreetIntradayCost.dtsx" /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Cost: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Cost: file imported" | Out-File $LogFile -Append
	
Remove-Item  $FinalFile
Move-Item -Path "$dirSourceFolder\$FileName" $dirArchiveFolder\$strDateNow  | Out-File $logFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $dirSourceFolder\$FileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
}


################# PY2E Report ###########################
## Check fo Source file existence
foreach ($FileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "MyStatestreet Report PY2E.xlsx"}) 
{

$xls = "$dirSourceFolder\$FileName"
	$strFileName = $FileName.BaseName+".csv"
	$LoadOptions = $null
	$FinalFile = "$dirSourceFolder\$strFileName"
	
	$LoadOptions = New-Object Aspose.Cells.LoadOptions;
	$LoadOptions.Password = "highland$"
	$wb = New-Object Aspose.Cells.Workbook($xls,$LoadOptions);

	$wb.Save($FinalFile);

   $RefDataSetDate = $null

	$RefDataSetDate = (Get-Date).toshortdatestring()

	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ImportCustodianStateStreetIntradayAccounting.dtsx `r`n Variable passed here are : `r`n  FolderPath = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianStateStreetIntradayAccounting.dtsx" /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Report: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Report: file imported" | Out-File $LogFile -Append
	
Remove-Item  $FinalFile
Move-Item -Path "$dirSourceFolder\$FileName" $dirArchiveFolder\$strDateNow  | Out-File $logFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $dirSourceFolder\$FileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
}

################# PY2E Trial ###########################
## Check fo Source file existence
foreach ($FileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "PY2E Trial*.xlsx"}) 
{


#### FUND , FUND DESC ,RefDataSetDate ######
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Fetch Fund , Fund Desc and RefDataSetDate from File content" | Out-File $LogFile -Append
	$FileNamePath = $FileName.FullName
	
	
	$xls = "$dirSourceFolder\$FileName"
	$strFileName = $FileName.BaseName+".csv"
	$LoadOptions = $null
	$FinalFile = "$dirSourceFolder\$strFileName"
	
	$LoadOptions = New-Object Aspose.Cells.LoadOptions;
	$LoadOptions.Password = "highland$"
	$wb = New-Object Aspose.Cells.Workbook($xls,$LoadOptions);

	$wb.Save($FinalFile);
	
	$ws = $wb.WorkSheets[0];
	
	$SheetName=$null
	$SheetName = $ws.get_Name() 
 	$SheetName = $SheetName.Replace("'","")
	 
	$Cell = $ws.Cells["A3"];
	$Fund = $Cell.get_DisplayStringValue()
	 
	 
	$Cell1 = $ws.Cells["C3"];
	$FundDesc = $Cell1.get_DisplayStringValue()
	
	
	$Cell2 = $ws.Cells["J4"];
	$RefDataSetDate1 = $Cell2.get_DisplayStringValue()
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,"dMMyy",$null)).toshortdatestring()
		
 
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ImportCustodianStateStreetIntradayTrial.dtsx `r`n Variable passed here are : `r`n  FolderPath = $dirSourceFolder `r`n  FileName = $FileName `r`n  RefDataSetDate = $RefDataSetDate `r`n  Fund = $Fund `r`n  FundDesc = $FundDesc `r`n  SheetName = $SheetName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianStateStreetIntradayTrial.dtsx" /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Fund].Value;$Fund" /set "\package.variables[FundDesc].Value;$FundDesc"  | Out-File $logFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Trial: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet MLP Fund PY2E_Trial: file imported" | Out-File $LogFile -Append
	
Remove-Item  $FinalFile
Move-Item -Path "$dirSourceFolder\$FileName" $dirArchiveFolder\$strDateNow  | Out-File $logFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $dirSourceFolder\$FileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
