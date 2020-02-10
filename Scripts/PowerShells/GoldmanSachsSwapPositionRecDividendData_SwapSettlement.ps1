############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

## Apose.Cells
[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv4)

<#
	## Aspose License
	$license = New-Object Aspose.Cells.License
	$license.SetLicense($dirAsposeCellsLic);
#>
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder +"\") -fileName $("ExtractCustodianGSSwapSettlement."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ExtractCustodianGSSwapSettlement.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirDataFeedsFolder  = "$dirServicesDeliveryStoreFolder\Goldman Sachs Swap Position and Dividend Data - Swap Settlement"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\Goldman Sachs Swap Position and Dividend Data - Swap Settlement\Archive"

Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder				= $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile				= $LogFile `r`n" | Out-File $LogFile -Append


##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder creates here " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Set Current Location :: $dirDataFeedsFolder " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  GS Swap Settlement starts here " | Out-File $LogFile -Append


foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SettlementReport*.xls"})
{   
	$strFile = $strFileName.BaseName
	$CounterParty1 = $strFile -split("_")
	$CounterParty = $CounterParty1[2]

	$xls = "$dirDataFeedsFolder\$strFileName"
	$csvName = "$dirDataFeedsFolder\$strFile.csv"
	$PDF = "$dirDataFeedsFolder\$strFile"+".pdf" 
	$CSVFileName = "$strFile.csv"

	#Copy-Item "$dirDataFeedsFolder\$strFileName" $Copyxls 

	$ExcelFullPath = $strFileName.FullName
	
	$wb = New-Object Aspose.Cells.Workbook($ExcelFullPath);
		
	$wb.Save($csvName);
 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  GS Swap Settlement : Fetching field values " | Out-File $LogFile -Append
  
 	$Data = Get-Content $csvName 
	
	<#
	$RefDataSetDate1 = $Data[3].Split(",")[1].Trim()
	$RefDataSetDate1 = $RefDataSetDate1.replace(" " , "-")
 	$RefDataSetDate1 = $RefDataSetDate1 +"-"+ $Data[3].Split(",")[2].Trim()
	$RefDataSetDate1 = $RefDataSetDate1.Replace('"',"") ;
 	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”MMMM-d-yyyy”,$null)).toshortdatestring();#>
	
	
	$ReportDate1 = $Data[3].Split(",")[1].Trim()
	$ReportDate1 = $ReportDate1.replace(" " , "-")
 	$ReportDate1 = $ReportDate1 +"-"+ $Data[3].Split(",")[2].Trim()
	$ReportDate1 = $ReportDate1.Replace('"',"") ;
 	$ReportDate = ([datetime]::ParseExact($ReportDate1,”MMMM-d-yyyy”,$null))
	
	IF($ReportDate.DayOfWeek -eq "Monday" -or $ReportDate.DayOfWeek -eq "Tuesday")
	{
	$RefDataSetDate = $ReportDate.AddDays(-4).ToShortDateString();

	}
	ELSEIF($ReportDate.DayOfWeek -eq "Sunday")
	{
	$RefDataSetDate = $ReportDate.AddDays(-3).ToShortDateString();
	
	}
	ELSE
	{
    $RefDataSetDate = $ReportDate.AddDays(-2).ToShortDateString();

	}
	
 	Sleep -Seconds 2
	
	$ReportDate = $ReportDate.ToShortDateString();
	

	
 	$CounterPartyName = $Data[5].Split(",")[1].Trim()
	$CounterPartyName | Out-File $LogFile -Append
  	Sleep -Seconds 1
 	$CounterPartyNumber = $Data[6].Split(",")[1].Trim()
	$CounterPartyNumber | Out-File $LogFile -Append
  	Sleep -Seconds 1
 	$AssetType = $Data[11].Split(",")[0].Trim()
	$AssetType = $AssetType.Replace('"',"");
	$AssetType | Out-File $LogFile -Append
  	Sleep -Seconds 1

	Write-Output " Variable values are :-" | Out-File $LogFile -Append

	Write-Output " ReportDate				    = $ReportDate" | Out-File $LogFile -Append
	Write-Output " RefDataSetDate				= $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output " CounterPartyName				= $CounterPartyName `r`n" | Out-File $LogFile -Append
	Write-Output " CounterPartyNumber			= $CounterPartyNumber" | Out-File $LogFile -Append
	Write-Output " AssetType					= $AssetType `r`n" | Out-File $LogFile -Append
	Write-Output " CounterParty1				= $CounterParty1 `r`n" | Out-File $LogFile -Append
	
  ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianGSSwapSettlement.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FileDirectory = $dirDataFeedsFolder `r`n  FileName = $csvName `r`n  PowerShellLocation = $ScriptName   `r`n  PowerShellLocation = $ScriptName  `r`n  AssetType = $AssetType  `r`n  CounterPartyNumber = $CounterPartyNumber  `r`n  CounterPartyName = $CounterPartyName  `r`n  CounterParty = $CounterParty " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianGSSwapSettlement.dtsx" /set "\package.variables[FileName].Value;$CSVFileName"  /set "\package.variables[FilePath].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" /set "\package.variables[AssetType].Value;$AssetType" /set "\package.variables[CounterPartyName].Value;$CounterPartyName" /set "\package.variables[CounterPartyNumber].Value;$CounterPartyNumber" /set "\package.variables[CounterParty].Value;$CounterParty" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  GS Swap Settlement : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  GS Swap Settlement : file ( $strFileName ) imported" | Out-File $LogFile -Append

#####Archiving Source File ##########
	Move-Item -Path "$dirDataFeedsFolder\$strFileName" $dirArchiveFolder
	Move-Item -Path "$dirDataFeedsFolder\$csvName" $dirArchiveFolder
	Move-Item -Path $PDF $dirArchiveFolder
   
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Moved all GS Swap Settlement files to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append


}

   