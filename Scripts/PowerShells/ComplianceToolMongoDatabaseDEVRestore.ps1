CLS
############## Reference to configuration files ###################################
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation
Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fRefDataSetIU.ps1
####################################################################################

$date = get-date -format("MM-dd-yyyy")
$rootPath = "\\hcm22\dev-backup$\Mongobackups\"
$extractPath = "D:\Archive\"
#$rootPath = "C:\temp\test\"
#$extractPath = "C:\temp\test\"
$mongoLogDir = $dirLogFolder
$pathSuffix = "Backup-" + $date + ".zip"
$logFile = $mongoLogDir + "\MongoDevRestore_" + $date + ".log"

$cloDbPath = $rootPath + "cloCompliance" + $pathSuffix
$hfaDbpath = $rootPath + "hfaCompliance" + $pathSuffix

$ServerName = "PHCMDB01"
$DatabaseName = "DATAFeeds"
$dtDataSetDate = $date
$RefDataSetID = 0

## Create RefDataSet					
$RefDataSetID = fRefDataSetIU -rdsRefDataSetID 0 -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel "Mongo Dev Restore" -rdsStatusCode "I" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	
	
Try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    [System.IO.Compression.ZipFile]::ExtractToDirectory($cloDbPath,$extractPath + "cloCompliance")
    [System.IO.Compression.ZipFile]::ExtractToDirectory($hfaDbPath,$extractPath + "hfaCompliance")
    
    $mongoRestoreCommand = "C:\MongoTools\mongorestore.exe --host betaportal.highland.aws --port 27017 " + $extractPath
    Write-Output $mongoRestoreCommand | Out-File $logFile -Append
    
    $cloCommand = "&" + $mongoRestoreCommand + "cloCompliance"
    Write-Output $cloCommand | Out-File $logFile -Append
    
    Invoke-Expression $cloCommand | Out-File $logFile -Append
    
    $hfaCommand = "&" + $mongoRestoreCommand + "hfaCompliance"
    Write-Output $hfaCommand | Out-File $logFile -Append
    Invoke-Expression $hfaCommand | Out-File $logFile -Append
	
	#TODO: Pass
	fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel "Mongo Dev Restore" -rdsStatusCode "P" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
} Catch {
 ## Fail RefDataSet
 fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel "Mongo Dev Restore" -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
}
Remove-Item -path ($extractPath + "cloCompliance") -Recurse
Remove-Item -path ($extractPath + "hfaCompliance") -Recurse
