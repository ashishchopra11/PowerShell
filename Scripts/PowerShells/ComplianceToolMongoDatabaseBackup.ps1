CLS
#$cmd = ".\DevBackup.ps1 -mongoToolsLocation c:\MongoTools -workPath c:\MongoBackup -backupFileArchive \\hcm12.hcmlp.com\backup\Mongobackups"
$cmd = 'D:\Siepe\Data\Scripts\PROD\ComplianceToolMongoDatabaseBackup-DevBackup.ps1 -mongoHost "hcmv02.hcmlp.com" -mongoToolsLocation "c:\MongoTools" -workPath "D:\Siepe\Data\Scripts\CLOComplianceBackup\workpath" -backupFileArchive \\hcm22\dev-backup$\Mongobackups'
Set-Location D:\Siepe\Data\Scripts\PROD
Invoke-Expression $cmd
