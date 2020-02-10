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

$strDateNow = get-date -format "yyyyMMddTHHmmss"
$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
$PSScriptName 	= $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
$ReturnDate = ""

$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\MSCI Index Data"
$TempFolder = "D:\Siepe\DataFeeds\MSCI Index Data"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\MSCI Index Data\Archive\$strDateNow"
if(!(Test-Path -Path $dirArchiveFolder )){
    New-Item -ItemType directory -Path $dirArchiveFolder
}

## Disable/Enable loading datafeeds tables
[BOOLEAN]$Loaddata_tMSCIIndexData_IndexSameDay					= $true
[BOOLEAN]$Loaddata_tMSCIIndexData_SecuritySameDay				= $true
[BOOLEAN]$Loaddata_tMSCIIndexData_SecurityConstituentsSameDay	= $true
[BOOLEAN]$Loaddata_tMSCIIndexData_SecurityCodeMap				= $true
[BOOLEAN]$Loaddata_tMSCIIndexData_DividendSameDay				= $true
[BOOLEAN]$Loaddata_tMSCIIndexData_SecurityFuture				= $false
[BOOLEAN]$Loaddata_tMSCIIndexData_SecurityConstituentsFuture	= $false
[BOOLEAN]$Loaddata_tMSCIIndexData_IndexFuture					= $false
[BOOLEAN]$Loaddata_tMSCIIndexData_DividendsFuture				= $false

foreach ($ZipFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.zip"})
{
  	$FileZipExists = $True
	##Remove existing files
	$RawZIPFilePath = $ZipFileName.FullName
	
	$RefDataSetDate1 = $ZipFileName.BaseName.Substring(0,8)
	$RefDataSetDate = ([datetime]::ParseExact("$RefDataSetDate1","yyyyMMdd",$null)).toshortdatestring()
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  MSCI Index Data : RefDataSetDate is  $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  MSCI Index Data : Unzip File $RawZIPFilePath " | Out-File $LogFile -Append
	
	# UnRAR the file. -y responds Yes to any queries UnRAR may have.
	&  "C:\Program Files\WinRAR\Winrar.exe" x -y -o+  $RawZIPFilePath $TempFolder | Wait-Process 
	
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  MSCI Index Data : Unzip Done " | Out-File $LogFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  MSCI Index Data : file ( $strFileName ) processing " | Out-File $LogFile -Append
}

foreach ($FileName in Get-ChildItem -Path $TempFolder  | Where-Object {$_.Name -ilike "*_D_ICFESG_D_ACWI.RIF*"}) 
{
	$InputFile = $FileName.FullName
	$SplitFileName = $FileName.Name.Split("_")
	$FileDate = $SplitFileName[0]
	$Reader = New-Object System.IO.StreamReader($InputFile)
	$a = 1
	While (($Line = $Reader.ReadLine()) -ne $null) {
	    #If ($Line -ilike "*DRESDW.*" -and ($Line -like "*INDEX SAME DAY*" -or $Line -like "*SECURITY SAME DAY*" -or $Line -like "*SECURITY CODE MAP*" -or $Line -like "*INDEX SAME DAY*" -or $Line -like "*DIVIDENDS SAME DAY*")) {
		If ($Line -ilike "*DRESDW.*") {
				[String]$SplitLine  = $Line.ToString()
				$FilNameStartIndex 	= $SplitLine.IndexOf(" ",2)
				$FilNameEndIndex 	= $SplitLine.IndexOf("DRESDW.",1)
				$FileName = $SplitLine.substring($FilNameStartIndex,$FilNameEndIndex - $FilNameStartIndex).Trim()
				$FileName = "D_ICFESG_D_ACWI - "+$FileName +"."+$FileDate+".txt"
				$FileName	
	        	$OutputFile = $FileName
	        	$a++
	    }    
		if ($Line -notlike "#*" -and $Line -notlike "[*]" -and $Line -notlike "#EOD" -and $Line -notlike "SSL>>>>>>>SSL*")
		{
			Add-Content "$TempFolder\$OutputFile" $Line
		}
	}
	$Reader.Close()
}

 ## Move from temp folder to shared path
 Move-Item -Path "$TempFolder\*.txt" -Destination $dirDataFeedsFolder -Force 
 
if($Loaddata_tMSCIIndexData_IndexSameDay){
	#****** Initialize variables ******
		$GenericImportJobID = 138													##### NEED TO UPDATE #####
		
	#****** IndexSameDay ******
		#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
		fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** SecuritySameDay ******
if($Loaddata_tMSCIIndexData_SecuritySameDay){
	$GenericImportJobID = 139
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** SecurityConstituentsSameDay ******
if($Loaddata_tMSCIIndexData_SecurityConstituentsSameDay){
	$GenericImportJobID = 140
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** SecurityCodeMap ******
if($Loaddata_tMSCIIndexData_SecurityCodeMap){
	$GenericImportJobID = 141
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** DividendSameDay ******
if($Loaddata_tMSCIIndexData_DividendSameDay){
	$GenericImportJobID = 142
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** SecurityFuture ******
if($Loaddata_tMSCIIndexData_SecurityFuture){
	$GenericImportJobID = 143
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** SecurityConstituentsFuture ******
if($Loaddata_tMSCIIndexData_SecurityConstituentsFuture){
	$GenericImportJobID = 144
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
#****** IndexFuture ******
if($Loaddata_tMSCIIndexData_IndexFuture){
	$GenericImportJobID = 145
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}

#****** DividendsFuture ******
if($Loaddata_tMSCIIndexData_DividendsFuture){
	$GenericImportJobID = 146
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $dirArchiveFolder ([Ref]$ReturnDate)
}
	Remove-Item -Path "$dirDataFeedsFolder\*.txt"
	Remove-Item -Path "$dirArchiveFolder\*.txt"
	Move-Item -Path $RawZIPFilePath $dirArchiveFolder
	Remove-Item -Path $InputFile
	Remove-Item -Path "$TempFolder\*.RIF"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved rest of uprocessed files ( $dirDataFeedsFolder\*.txt ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

$GenericNormaliztaionJobID = 62
fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null