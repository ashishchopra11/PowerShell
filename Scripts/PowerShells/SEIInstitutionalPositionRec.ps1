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
	$GenericImportJobID = 53													##### NEED TO UPDATE #####
	$GenericNormaliztaionJobID = 	44										##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	$pRefDataSetDate = $null
	
## As We are receiving Sunday date for Friday file, So added code to get Friday RefdataSetDate. 
## Other than Monday it will automatically use File date which is T-1.
## This if block runs only on Mondays !!!!!!!
[DateTime]$CurrentDate = Get-Date
if ($CurrentDate.DayOfWeek -eq "Monday")
{
	$DirSource = "$dirServicesDeliveryStoreFolder\SEIInstitutionalPositionRec"
	foreach ($strFileName in Get-ChildItem	 -Path $DirSource | Where-Object {$_.Name -ilike "*Highland Capital Daily Position File*"})
	{
	   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Extract RefDataSetDate " | Out-File $LogFile -Append
	   $FileName = $strFileName.Name
	   $DatePart = $FileName.Substring(0,8)
	   [DateTime]$dtFileDate = ([datetime]::ParseExact($DatePart,"MM.dd.yy",$null))
	   if($dtFileDate.DayOfWeek -eq "Sunday")
	   {
	   		$pRefDataSetDate = $dtFileDate.AddDays(-2)
	   }
	}	
}
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $pRefDataSetDate -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
