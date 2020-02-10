############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\ConnectionStrings.config.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

## Apose.Cells
[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

## Aspose License
$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);
	
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
#$logFile 				= "$dirLogFolder\ImportCustodianBNYPrimePledgePositions.$strDateNow.txt"

$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


## Variables
$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\BNY Prime Broker Pledged Positions"
 #$dirDataFeedsFolder = "C:\HCM\DataFeeds\BnyMellon\Pledge"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\BNY Prime Broker Pledged Positions\Archive"
#$dirArchiveFolder = "C:\HCM\DataFeeds\BnyMellon\Pledge\Prime\Archive"
$strDateNow = get-date -format "yyyyMMddTHHmmss"


###Create Archive folder

Write-Output " dirSourceFolder			= $dirSourceFolder" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder				= $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile				= $LogFile `r`n" | Out-File $LogFile -Append

New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here " | Out-File $LogFile -Append


######### REFDATASETDATE LOGIC #######################
$dtDataSetDate = Get-Date  


if(($dtDataSetDate).DayOfWeek -eq "Monday")
{ $RefDataSetDate = $dtDataSetDate.AddDays(-3).ToString("yyyy/MM/dd")
}
elseif(($dtDataSetDate).DayOfWeek -eq "Sunday")
{
 $RefDataSetDate = $dtDataSetDate.AddDays(-2).ToString("yyyy/MM/dd")
}
else
{
 $RefDataSetDate = $dtDataSetDate.AddDays(-1).ToString("yyyy/MM/dd")
}

$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate,”yyyy/MM/dd”,$null)).toshortdatestring()
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RefDataSetDate = $RefDataSetDate  " | Out-File $LogFile -Append

$Count = 0
################################## Processing source files #######################
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.xls*"})
{
   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Bny Mellon Prime Pledge Positions : file ( $strFileName1 and $strFileName2 ) processing " | Out-File $LogFile -Append

	$xls = "$dirDataFeedsFolder\$strFileName" 
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Bny Mellon Prime Pledge Positions : file ( $xls ) processing " | Out-File $LogFile -Append
	
	#$csvFile = $xls -replace $strFileNameExtension,".csv"
	$csvFile = "$dirDataFeedsFolder\"+$strFileName.BaseName+".csv"
	$csvTarget = "$dirDataFeedsFolder\BnyMellonPrimePledge.csv"
	$strFileNameFinal = "BnyMellonPrimePledge.csv"
	$strFileNameExtension = [IO.Path]::GetExtension($strFileName)
	$Password = "Highland2019"
	
	$LoadOptions = $null
	$LoadOptions = New-Object Aspose.Cells.LoadOptions;
	$LoadOptions.Password = "Highland2019"
	$wb = New-Object Aspose.Cells.Workbook($xls,$LoadOptions);

	$wb.Save($csvFile);

if($Count -gt 0)
{
#Get-Content $csvFile |Out-File  $csvTarget -Append
Get-Content $csvFile|Select-Object -Skip 1|Out-File $csvTarget -Append
}
else
{
Get-Content $csvFile |Out-File  $csvTarget -Append
}
Remove-Item $csvFile 
 $Count = $Count+1

}

$FormattedRefDataSetDate = ([datetime]::Parse($RefDataSetDate)).tostring("yyyyMMdd")
$NewName = "BnyMellonPrimePledge_"+$FormattedRefDataSetDate+".csv"

Write-Output $NewName | Out-File $LogFile -Append

Rename-Item -Path "$dirDataFeedsFolder\BnyMellonPrimePledge.csv" -NewName $NewName


#****** Initialize variables ******
	$GenericImportJobID = 54													##### NEED TO UPDATE #####
	$GenericNormaliztaionJobID = 	45										##### NEED TO UPDATE #####
	$ReturnDate = ""

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDataSetDate = $ReturnDate

	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNYPrimeBrokerPledgedPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"/set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append


#****** Generic Normalization ******
	$NewRefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $NewRefDatasetDate -pLogFile $LogFile -pScriptName $null
	
  foreach ($strFileName1 in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.xls*"})
{
	Remove-Item "$dirDataFeedsFolder\$strFileName1"
}