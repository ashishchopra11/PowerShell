############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\ConnectionStrings.config.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
#$logFile 				= "$dirLogFolder\ImportCustodianBNYPrimePledgePositions.$strDateNow.txt"

$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
Write-Output "Test" | Out-File $LogFile -Append
$WSO_Extracts_DIR1 = "\\services.hcmlp.com\DeliveryStore\WSOOnDemand"
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$FullDayString = "2019/02/20"
	[String]$SourceFileName = "Daily_ExtractFacilities_20190220.csv"
	 & $2016DTEXEC32 /f "$dirSSISExtractWSO\Supplemental\ExtractFacilities-API.dtsx" 		/set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$SourceFileName" 
	 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractFacilities.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" 
