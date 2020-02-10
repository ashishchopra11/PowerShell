#############################
#### Bloomberg Reference Load
#############################
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

# Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

param([String]$LogFile = $Null , [datetime]$RefDataSetDate = $NULL)

If ($LogFile -eq $null)
{
##LogFile
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$logTime = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\BloombergBackOfice.NormalizeVendorBloombergEquityPricing."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Normalize Vendor Bloomberg Equity Pricing starts here " | Out-File $LogFile -Append
#### Willy local
#$Extract_Dir 	= "C:\VSS\Data\SSIS.Datawarehouse\NormalizeVendor\bin"
#### HCM36 

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergEquityPricing.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append

## SSIS Normalization Package
<#
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergEquityPricing.dtsx" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
}
ELSE{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergEquityPricing.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
}
#>

## Generic Normalization
If ($RefDataSetDate -eq $null) {
	$RefDataSetDate = Get-Date -Format "MM/dd/yyyy"
}

$GenericNormaliztaionJobID = 	81
fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Normalize Vendor Bloomberg Equity Pricing : NormalizeVendorBloombergEquityPricing.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergEquityPricing.dtsx `r`n "| Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

# Write-PubSub -Subject "Process.Bloomberg.Daily.ImportNormalize.BackofficeStepThree" -Title "Complete - next Bloomberg Push Prices to Geneva" -Description "Complete - next Bloomberg Push Prices to Geneva"
