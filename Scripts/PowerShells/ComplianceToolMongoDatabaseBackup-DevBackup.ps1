param(
[string]$mongoToolsLocation="C:\Program Files\MongoDB 2.6 Standard\bin",
[string]$mongoHost="betaportal.hcmlp.com",
[string]$workPath=".",
[string]$backupFileArchive="\\hcm12.hcmlp.com\backups\mongoBackups"
)

############## Reference to configuration files ###################################
. ".\ComplianceToolMongoDatabaseBackup-IOFunctions.ps1"
. "D:\Siepe\Data\Scripts\Configurations\fRefDataSetIU.ps1"
. "D:\Siepe\Data\Scripts\Configurations\DirLocations.Config.ps1"
####################################################################################

[string]$strDateNow 	= get-date -format "yyyyMMddTHH"
#[string]$logFile 		= "$dirLogFolder\ComplianceMongoDevBackup_"+$strDateNow+".txt" ##Log file path

[string]$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
[string]$PSScriptName = $PSScriptName.Replace(".ps1","")
[string]$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

[string]$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

$ErrorActionPreference = "stop"

Try
{
	Write-EventLog -LogName Application -Source "Mongo DB Backup" -EntryType Information -Message "Starting Mongo DB Backup" -EventId 1
	
	
	$dbs = "cloCompliance", "hfaCompliance" , "navTieOut"

	$date = get-date -format ("MM-dd-yyyy")
	$dtDataSetDate = [datetime]::parseexact($date,"MM-dd-yyyy",$null)

	Write-Host "Mongo Tools Location: $mongoToolsLocation"
	Write-Host "Mongo Host: $mongoHost"
	Write-Host "Mongo Host: $mongoHost"
	Write-Host "Archive Path: $backupFileArchive"

	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Mongo Tools Location: $mongoToolsLocation" | Out-File $LogFile -Append
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Mongo Host: $mongoHost `r`n" | Out-File $LogFile -Append
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Mongo Host: $mongoHost" | Out-File $LogFile -Append
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Archive Path: $backupFileArchive `r`n" | Out-File $LogFile -Append
	
	### Server details
	$ServerName = "PHCMDB01"
	$DatabaseName = "DataFeeds"
	
	Write-Output " ServerName: $ServerName " | Out-File $LogFile -Append
	Write-Output " DatabaseName: $DatabaseName `r`n" | Out-File $LogFile -Append
	
	Foreach($db in $dbs) {
		
		## Create RefDataSet
		$rslabel = $db + " Mongo Backup"
		$RefDataSetID = fRefDataSetIU -rdsRefDataSetID 0 -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel $rslabel  -rdsStatusCode "I" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
		
		$mongoDumpPath = $mongoToolsLocation + "\mongodump.exe"
		$mongoDumpParameters = "-host " + $mongoHost + " -out " + $workPath + " -db " + $db
		$fullBackupCommand = '& ' + $mongoDumpPath + ' ' + $mongoDumpParameters

		Write-Host "Database to Backup: $db"
		Write-Host "Mongo DumpPath Location: $mongoDumpPath"
		Write-Host "Mongo DumpPath Parameters: $mongoDumpParameters"
		Write-Host "Full backup command: $fullBackupCommand"

		Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Database to Backup: $db " | Out-File $LogFile -Append
		Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Mongo DumpPath Location: $mongoDumpPath `r`n" | Out-File $LogFile -Append
		Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Mongo DumpPath Parameters: $mongoDumpParameters `r`n" | Out-File $LogFile -Append
		Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Full backup command: $fullBackupCommand `r`n" | Out-File $LogFile -Append
		
		Invoke-Expression $fullBackupCommand

		#zip up the outpath

		#get zipfilename
		$zipFileName = $db + "Backup-" + $date + ".zip"
		Write-Host $zipFileName
		$zipFilePath = $workPath + "\" +$zipFileName
		Write-Host $zipFilePath
		$zipFolderName = $workPath + "\" + $db
		Write-Host $zipFolderName

		#remove the zip file if already exists

		Remove-File $workPath $zipFileName
		ZipFiles $zipFilePath $zipFolderName

		#move the newly minted zip file into the archive folder
		Move-Item $zipFilePath $backupFileArchive -Force
		Write-EventLog -LogName Application -Source "Mongo DB Backup" -EntryType Information -Message "DB $db backed up successfully" -EventId 1
		Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Move file ($zipFilePath) to $backupFileArchive `r`n" | Out-File $LogFile -Append
		
		if(Test-Path -path $backupFileArchive\$zipFileName)	{
			## Create RefDataSet
			fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel $rslabel -rdsStatusCode "P" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
		}else{
			## Create RefDataSet
			fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel $rslabel -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
		}
	}

	Write-EventLog -LogName Application -Source "Mongo DB Backup" -EntryType Information -Message "Mongo DB Backup completed" -EventId 1
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName END `r`n" |   Out-File $LogFile -Append
}
Catch
{
	## Create RefDataSet
	fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Backup" -rdsRefDataSource "Compliance" -rdsLabel $rslabel -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
			
	$ErrorMessage = $_.Exception.Message
	Write-Host $ErrorMessage
	Write-EventLog -LogName Application -Source "Mongo DB Backup" -EntryType Error -Message "Mongo DB Backup error: $ErrorMessage" -EventId 1
	
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ErrorMessage `r`n" | Out-File $LogFile -Append
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName END `r`n" |   Out-File $LogFile -Append
}
