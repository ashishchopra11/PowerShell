CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = ("$dirLogFolder\BloombergBackOfice.BloombergBackOffice."+$strDateNow+".txt").ToString()
$ScriptName = $MyInvocation.MyCommand.Definition

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = ("$dirLogFolder\$PSScriptName."+$strDateNow+".txt").ToString()

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$RefDataSetDate1 =$Null

##Pass RefDataSet Here in format "yyyyMMdd"
$RefDataSetDate1 =  "20180107"
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring()


# Calling for ExtractVendorBloombergBackOffice.dtsx 
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-Import.ps1 –RefDataSetDate $RefDataSetDate -LogFile $LogFile"
 Invoke-Expression $command
 
 # Calling for ExtractVendorBloombergCorpActions.dtsx
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-ExtractCorpActions.ps1 –RefDataSetDate $RefDataSetDate  -LogFile $LogFile"
Invoke-Expression $command

# Calling for NormalizeVendorBloombergEquityPricing.dtsx
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-NormalizeEquityPricing.ps1 –RefDataSetDate $RefDataSetDate  -LogFile $LogFile"
 Invoke-Expression $command

# Calling for Geneva.fPriceXML(Curr_Date/RefDataSetDate) - this powerShell is pointing to Production PHCMDB01
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-PushPricesToGeneva.ps1 –RefDataSetDate $RefDataSetDate  -LogFile $logFile"
Invoke-Expression $command

# Calling for ExtractVendorBloombergLookups.dtsx 
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-ExtractLookups.ps1 –RefDataSetDate $RefDataSetDate  -LogFile $LogFile "
Invoke-Expression $command


# Calling for NormalizeVendorBloombergEquityCorpActions.dtsx
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-NormalizeCorpActions.ps1  –RefDataSetDate $RefDataSetDate  -LogFile $LogFile"
Invoke-Expression $command


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
