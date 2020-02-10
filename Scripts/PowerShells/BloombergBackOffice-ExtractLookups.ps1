#############################
#### Extract Lookup Values
############################# 
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

#Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

param([String]$LogFile = $Null,[datetime]$RefDataSetDate = $NULL)

IF ($LogFile -eq $null)
{
##LogFile
$logTime	 = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\BloombergBackOfice.ExtractVendorBloombergLookups."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

#### Willy local
#$Extract_Dir 	= "C:\VSS\Data\SSIS.Datawarehouse\ExtractVendor\bin"
#### HCM36 
#$BackOffice_data = "$dirArchiveHCM46DriveFolder\Bloomberg Back Office" 
$BackOffice_data = "$dirServicesDeliveryStoreFolder\Bloomberg\Bloomberg Back Office"
#$DataFeedsDir = $dirArchiveHCM46DriveFolder
 

Write-Output " BackOffice_data`t`t`t= $BackOffice_data" |  Out-File $LogFile -Append
Write-Output " logFile`t`t`t= $logFile" |  Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Extract Vendor Bloomberg Lookups starts here " | Out-File $LogFile -Append
$Source = "$BackOffice_data\Securities & Pricing"
$SourceFile1 = $Source + "\lu_temp.txt"
$SourceFile2 = $Source + "\lookup.out"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Bloomberg backoffice : Running import for files ( $SourceFile1 ) and ( $SourceFile2 ). " | Out-File $LogFile -Append

$SourceFile2
IF((Test-Path -Path $SourceFile1) -or (Test-Path -Path $SourceFile2))
{

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractVendorBloombergLookups.dtsx `r`n Variable passed here are : `r`n  DataFeedsDir = $BackOffice_data " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append

IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISExtractVendor\ExtractVendorBloombergLookups.dtsx" /set "\package.variables[DataFeedsDir].Value;$BackOffice_data" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISExtractVendor\ExtractVendorBloombergLookups.dtsx" /set "\package.variables[DataFeedsDir].Value;$BackOffice_data"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
}

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Vendor Bloomberg Lookups not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Vendor Bloomberg Lookups imported" | Out-File $LogFile -Append
}
ELSE
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Bloomberg backoffice : Files are not present. " | Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

# Write-PubSub -Subject "Process.Bloomberg.Daily.ImportNormalize.BackofficeStepFive" -Title "Complete - next Extract CAX" -Description "Complete - next Extract CAX"
