Set-Location "C:\Siepe\Data\Scripts\Configurations"
. .\DirLocations.Config.ps1
CLS


########### Run as administrator ###########

if(!(Test-Path -Path $dirPowerShellFolder )){
    New-Item -ItemType directory -Path $dirPowerShellFolder
}

$logFile = "$dirPowerShellFolder\createEnvironmentVariables.txt"
$logTime = Get-Date
"Started creating Environment variables at $logTime"

## To Create EnvironmentVariables to keep SSIS XML Configuration files path.

$SSISConfigurationPath = "D:\Siepe\Data\SSIS\Configuration"

######## SSIS XML Configuration Locations ########
[Environment]::SetEnvironmentVariable("SSIS_DTSX_ARCHIVEDATAFEEDS", "$SSISConfigurationPath\DTSX_ArchiveDatafeeds.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_ARCHIVEDATAFEEDS", "$SSISConfigurationPath\ArchiveDatafeeds.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_Capstone", "$SSISConfigurationPath\Capstone.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_DF", "$SSISConfigurationPath\DATAFeeds.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_EXTWEB", "$SSISConfigurationPath\ExternalWebsite.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_FISD", "$SSISConfigurationPath\FISD.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[[Environment]::SetEnvironmentVariable("SSIS_DW_HCM", "C:\HCM TFS\SSIS.Datawarehouse\Configuration\HCM.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_REF", "$SSISConfigurationPath\Reference.dtsConfig","Machine") | Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_WSOData", "$SSISConfigurationPath\WSOData.dtsConfig","Machine") | Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_DW_XF", "$SSISConfigurationPath\Xpressfeeds.dtsConfig","Machine") | Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_GV_SVR", "$SSISConfigurationPath\GenevaServer.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_SMTP_HCM", "$SSISConfigurationPath\SMTP_HCM.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_VAR_DFDIR", "$SSISConfigurationPath\DataFeedsDir.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile
[Environment]::SetEnvironmentVariable("SSIS_VAR_INTRANET", "$SSISConfigurationPath\IntranetURL.dtsConfig","Machine")	| Out-File -encoding ASCII -append -filePath $logFile

######## PowerShell Configuration Folder location ########
[Environment]::SetEnvironmentVariable("Powershell_ConfigRootLocation", "D:\Siepe\Data\Scripts\Configurations","Machine")	| Out-File -encoding ASCII -append -filePath $logFile

$logTime = Get-Date
"Finished creating Environment variables at $logTime"


