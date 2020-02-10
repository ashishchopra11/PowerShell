############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
. .\ConnectionStrings.config.ps1
. .\IOFunctions.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$strDateNow = get-date -format "yyyyMMddTHHmmss"

#$LogFile = "$dirLogFolder\ImportJefferiesMarginDetails."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
$ReturnDate = ""

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

#$jefferies_dir = "$dirServicesDeliveryStoreFolder\Jefferies"
$jefferies_dir = "$dirServicesDeliveryStoreFolder\Jefferies Pledge Import"
$jefferies_dir_Archive = "$dirDataFeedsArchiveFolder\Jefferies Pledge Import\Archive"

New-Item -path $jefferies_dir_Archive\$strDateNow -ItemType directory
$jefferies_dir_Archive = $jefferies_dir_Archive+"\"+$strDateNow
$ErrorFileName = "ErrorLogs.txt"

Write-Output " jefferies_dir`t`t`t= $jefferies_dir" |  Out-File $LogFile -Append
Write-Output " jefferies_dir_Archive`t`t`t= $jefferies_dir_Archive" |  Out-File $LogFile -Append
Write-Output " LogFile`t`t`t= $LogFile" |  Out-File $LogFile -Append

$Dates = New-Object System.Collections.ArrayList
[bool]$FileExists = $False

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Extract all the dates from  *_Margin-Detail.xls" | Out-File $LogFile -Append
foreach ($strFileName in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*_Margin-Detail.xls"})
{
	$FilePath =  $strFileName.FullName
	$FileExists = $True
	#$FilePath = "D:\Working\HCM\Package\43100448_20160322_Margin-Detail.xls"
	#$FileName =  "43100448_20160322_Margin-Detail.xls"
	
    [DateTime]$date 
	$date = $null
	$dateStr = $null
	$date = Get-Date -Year $strFileName.Name.substring(9,4) -Month $strFileName.Name.substring(13,2) -Day $strFileName.Name.substring(15,2)
	
	$dateStr = $date.ToString("yyyyMMdd")
		
	if (-not($dates.Contains($dateStr)) -and $dateStr -ne $null )
	{
		$Dates.Add($dateStr)
		 
	}
	
}
If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( *_Margin-Detail.xls ) not exist at :: $jefferies_dir " | Out-File $LogFile -Append    
}
foreach($DateString in $Dates)
{
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Jefferies Margin Detail starts for RefDatasetDate : $DateString" | Out-File $LogFile -Append
foreach ($strFileName in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*_"+$DateString+"_Margin-Detail.xls"})
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Jefferies Margin Detail starts for :$strFileName " | Out-File $LogFile -Append

	if (Test-Path "$jefferies_dir\$ErrorFileName")
	{
		Remove-Item $jefferies_dir\$ErrorFileName -Force 
	}
	New-Item -path $jefferies_dir\$ErrorFileName -ItemType file
	
	$FilePath =  $strFileName.FullName
	 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing RefDataSetDate from source : " | Out-File $LogFile -Append
	[DateTime]$date 
	$date = $null
	$dateStr = $null
	$date = Get-Date -Year $strFileName.Name.substring(9,4) -Month $strFileName.Name.substring(13,2) -Day $strFileName.Name.substring(15,2)
	
	$dateStr = $date.ToString("yyyyMMdd")
 	$date1 = ([datetime]::ParseExact($dateStr,"yyyyMMdd",$null)).toshortdatestring()


#$date1 =  Get-Date -Year $file1.Name.substring(9,4) -Month $file1.Name.substring(13,2) -Day $file1.Name.substring(15,2) -Format d
$FileName= $strFileName.Name
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from source File Name :: $date1 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianJefferiesPledge.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date1 `r`n  FileDirectory = $jefferies_dir `r`n FileName = $FileName `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesPledge.dtsx" /set "\package.variables[RefDataSetDate].Value;$date1" /set "\package.variables[FileDate].Value;$dateStr"  /set "\package.variables[FileDirectory].Value;$jefferies_dir" /set "\package.variables[FileName].Value;$FileName" /set "\package.variables[ErrorFileName].Value;$ErrorFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
## Check SSIS is success or not 
##Handling the error in SSIS and extracting the file name in error log file
	$src = get-content $jefferies_dir\$ErrorFileName 
	If ($lastexitcode -ne 0 -and ($src -eq $null -or $scr -eq "" )) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Importing Jefferies Margin Detail : file ( $FileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Jefferies Margin Detail: file ( $FileName ) imported" | Out-File $LogFile -Append
	
	
	if ($src -ne $null -and $scr -ne "")
	{
	$srcARR = ($src -split '~')  
	$srcARR
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Below are the files for which the import process got failed" | Out-File $LogFile -Append
	foreach ($strng in $srcARR)
	{
	Write-Output "`r`n$string" | Out-File $LogFile -Append
	}
	Write-Output "`r`n################################################" | Out-File $LogFile -Append
	}
	if (Test-Path "$jefferies_dir\$ErrorFileName")
	{
		Remove-Item $jefferies_dir\$ErrorFileName -Force 
	}
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianJefferiesPledge.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date1 `r`n PowerShellLocation = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
	# Generic Normalization
	$GenericNormaliztaionJobID = 	57
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $date1 -pLogFile $LogFile -pScriptName $null
	
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesPledge.dtsx" /set "\package.variables[RefDataSetDate].Value;$date1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Normalize Jefferies Margin Detail : file ( $FileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Jefferies Margin Detail: normalized" | Out-File $LogFile -Append
	
	$GenericNormaliztaionJobID = 74
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $date1 -pLogFile $LogFile -pScriptName $null

	##All files are procesing in SSIS loop itself.
	break;
	
}
foreach ($strFileName in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*_"+$DateString+"_Margin-Detail.xls"})
{
	$FilePath =  $strFileName.FullName
    Move-Item -Path	$FilePath -Destination $jefferies_dir_Archive -force  | Out-File $LogFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $FilePath ) to location ( $jefferies_dir_Archive ) " | Out-File $LogFile -Append
}

}

Write-PubSub -Subject "PledgeTool.ReferenceData.JEFF" -Title "Normalize State Street Pledge Data" -Description "Normalize State Street Pledge Data"

########## ##### This script source file is from JefferiesLoadHairCuts_SSIS.ps1 - Now we are using for Pledge Jefferies Margin Details  ########## ##### 
########## ##### So far we have only import so commenting Portfolio-Margin Import and both Normalize Part ########## ##### 


<#
foreach ($file in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*Portfolio-Margin-Detail.xls"}) {

$date =  Get-Date -Year $file.Name.substring(9,4) -Month $file.Name.substring(13,2) -Day $file.Name.substring(15,2) -Format d
$fund =  $file.Name.substring(0,8)

& $2012DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesPortfolioMarginDetail.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[FundId].Value;$fund" /set "\package.variables[Directory].Value;$jefferies_dir" /set "\package.variables[FileName].Value;$file"

Move-Item -Path $file.FullName -Destination $jefferies_dir_Archive
}

& $2012DTEXEC64 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesPortfolioMargin.dtsx" /set "\package.variables[RefDataSetDate].Value;$date"
& $2012DTEXEC64 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesMargin.dtsx" /set "\package.variables[RefDataSetDate].Value;$date1"
Write-PubSub -Subject "DataWarehouse.Datafeeds.Incoming" -Title "Jefferies Haircuts Loaded for pkg 1 - $date and pkg 2 - $date1" -Description "Jefferies has 2 seperate packages for 2 separate files that run Haircuts"
#>
