############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################
$TimeOfDay 				= ""
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$runDate 				= Get-Date
$yymmddDate 			= $runDate.ToString("yyyyMMdd")
$WSO_Extracts_DIR 		= "C:\Temp\WSOReports"
$Download_FileName 		= "HighlandCashDiscrepancyReportBandera.CSV"
$Download_FileName1 		= "HighlandCashDiscrepancyReportBandera"
$Download_Location 		= "$dirServicesDeliveryStoreFolder\ComplianceBanderaCashDiscrepancies\$Download_FileName"
$Source_Location 		= "D:\Siepe\DataFeeds\WSOReports\Cash"
#$LogDir				= "C:\FTPFolder\Logs"
#$logFile 				= $dirLogFolder+"\HighlandCashDiscrepancyReportBandera"+"_"+$yymmddDate+".txt"
$PSScriptName 			= $MyInvocation.MyCommand.Name.ToString()
$PSScriptName 			= $PSScriptName.Replace(".ps1","")
$logFile 				= "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"
$Label                  = "Bandera"
#$ArchiveFile            = "HighlandCashDiscrepancyReportBandera"+"_"+$strDateNow+".CSV"
$DataDir = $Source_Location+"\"
$ArchiveDir = "$dirDataFeedsArchiveFolder\WSOReports\Cash\"

## Delivery Tool
#$DeliveryService = "C:\HCMLP\Applications\Services\Production\Delivery\Hcmlp.Shared.Service.Delivery.DeliveryTool.exe"
#$DeliveryService = "D:\Siepe\Applications\Services\Production\Delivery\Hcmlp.Shared.Service.Delivery.DeliveryTool.exe"
#
#cmd /c $DeliveryService -production -receive -name WSOsftpall -file $Download_FileName
$ScriptName = $MyInvocation.MyCommand.Definition

## Moving file from FTP download location to shared location for the package
if(Test-Path -Path $Download_Location )
{
    Move-Item $Download_Location $Source_Location
    $LogTime = Get-Date
    "> $LogTime :: FIle moved to $Source_Location " | Out-File -encoding ASCII  -FilePath $logFile
}
$RefDataSetDate = $null
$RefDataSetDate1 = Get-Date 
$RefDataSetDate = $RefDataSetDate1.toshortdatestring()


## Load data to table [DataFeeds].[Custodian].[tBAMLPBShortLocateReceive]
"> $LogTime :: Executing ExtractCashRecon" | Out-File -encoding ASCII -append -FilePath $logFile
 & $2016DTEXEC32 /F "$dirSSISExtractWSO\ExtractCashRecon.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataDir].Value;$DataDir" /set "\package.variables[ArchiveDir].Value;$ArchiveDir" /set "\package.variables[FileName1].Value;$Download_FileName1"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File -encoding ASCII -append -FilePath $logFile
#& $2016DTEXEC32 /F "$dirSSISExtractWSO\ExtractCashRecon.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataDir].Value;$DataDir" /set "\package.variables[FileName1].Value;$Download_FileName1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File -encoding ASCII -append -FilePath $logFile
"> $LogTime :: Executed ExtractCashRecon" | Out-File -encoding ASCII -append -FilePath $logFile

