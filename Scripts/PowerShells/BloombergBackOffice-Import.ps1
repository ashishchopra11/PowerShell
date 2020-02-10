##################################################################
##	
##	BloombergBackOffice.ps1
##	FTP, Decrypt and Decompress the Bloomberg Back Office files
##	
##################################################################
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################
$dirSSISExtractVendor

param(
[String]$LogFile = $NULL,
[datetime]$RefDataSetDate = $NULL 
)

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

##LogFile

$LogFile

If ($LogFile -eq $NULL)
{
$logTime = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\BloombergBackOfice.BloombergBackOffice."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$RefDataSetDate

#$BackOffice_data = "$dirArchiveHCM46DriveFolder\Bloomberg Back Office" 
#$BackOffice_data = "C:\HCM\DataFeeds\Bloomberg\Bloomberg Back Office"
$DeliveryStore = "$dirServicesDeliveryStoreFolder\Bloomberg"
$BackOffice_data = "$DeliveryStore\Bloomberg Back Office"


#$DeliveryStore = "C:\DeliveryStore\20161018"

#$DataFeedsDir = $dirArchiveHCM46DriveFolder
$DataFeedsDir = $DeliveryStore
#$DataFeedsDir = "C:\HCM\DataFeeds\Bloomberg"

Write-Output " BackOffice_data`t`t`t= $BackOffice_data" |  Out-File $LogFile -Append
Write-Output " DeliveryStore`t`t`t= $DeliveryStore" |  Out-File $LogFile -Append
Write-Output " DataFeedsDir`t`t`t= $DataFeedsDir" |  Out-File $LogFile -Append
Write-Output " LogFile`t`t`t= $logFile" |  Out-File $LogFile .-Append


Set-Location $DeliveryStore
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $DeliveryStore " | Out-File $LogFile -Append

Move-Item *.enc $BackOffice_data -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.enc ) to location ( $BackOffice_data ) " | Out-File $LogFile -Append

$Source = "$BackOffice_data\Securities & Pricing"
#Set-Location $BackOffice_data
Set-Location $Source
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $BackOffice_data " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::   Bloomberg backoffice data starts here " | Out-File $LogFile -Append

#$RefDataSetDate1 =  "19000101"
#$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring()

## FTP
#& C:\WINDOWS\system32\ftp.exe `-s:"$BackOffice_data\Configuration\BackOffice_FTP.txt"

##Decrypt
foreach ($file in Get-ChildItem) 
	{if($file.extension -eq ".enc" )
		{	
		$inFile = $file.fullname 
		$outFile = $inFile -replace ".enc", ""
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::   Bloomberg backoffice :: Decrypting ( $inFile ) to ( $outFile ) using ( $BackOffice_data\Configuration\des.exe )" | Out-File $LogFile -Append	
		& "$BackOffice_data\Configuration\des.exe" -D -k "7RV.K(,1" $inFile $outFile		
		}
	}

##Decompress
foreach ($file in Get-ChildItem) 
	{if($file.extension -eq ".gz" )
		{
		$inFile = $file.fullname 
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::   Bloomberg backoffice :: Decompressing ( $inFile ) using ( $BackOffice_data\Configuration\gzip.exe )" | Out-File $LogFile -Append	
		& "$BackOffice_data\Configuration\gzip.exe" -d -f -N -S ".gz" $inFile	
		}
	}

$FileLocation = $DataFeedsDir + "\Bloomberg Back Office"
$SourceFile1 = $DataFeedsDir + "\Bloomberg Back Office\Securities & Pricing\equity_namr.dif"
$SourceFile2 = $DataFeedsDir + "\Bloomberg Back Office\Securities & Pricing\equity_namr.px"

if([Int] (Get-Date).DayOfWeek -eq 2)
{
	$SecurityFileName="equity_namr.out"
}
else
{
	$SecurityFileName="equity_namr.dif"
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Bloomberg backoffice : Running import for files ( $SourceFile1 ) and ( $SourceFile2 ). " | Out-File $LogFile -Append

IF((Test-Path -Path $SourceFile1) -or (Test-Path -Path $SourceFile2))
{
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractVendorBloombergBackOffice.dtsx `r`n Variable passed here are : `r`n  DataFeedsDir = $DataFeedsDir " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
#Load Equity and Price files into Datafeeds
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISExtractVendor\ExtractVendorBloombergBackOffice.dtsx" /set "\package.variables[DataFeedsDir].Value;$DataFeedsDir"   /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[SecuritiesFileName].Value;$SecurityFileName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISExtractVendor\ExtractVendorBloombergBackOffice.dtsx" /set "\package.variables[DataFeedsDir].Value;$DataFeedsDir"   /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" /set "\package.variables[SecuritiesFileName].Value;$SecurityFileName" | Out-File $logFile -Append
}

## Check SSIS is success or not     /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg backoffice not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg backoffice imported" | Out-File $LogFile -Append
}
ELSE
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Bloomberg backoffice : Files are not present. " | Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

# not required pub Sub message 
## Write-PubSub -Subject "Process.Bloomberg.Daily.ImportNormalize.BackofficeStepTwo" -Title "Complete - next Bloomberg Reference Load" -Description "Complete - next Bloomberg Reference Load"