############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################

## Variables
 #$SourceFilesDir = "\\services.hcmlp.com\deliverystore\WSOOnDemand"
 $SourceFilesDir = "$dirServicesDeliveryStoreFolder\WSOOnDemand"
 
 	$runDate 		= Get-Date
	$DataSetDate = (Get-Date -Year ($runDate.Year) -Month ($runDate.Month) -Day ($runDate.Day) 00:00)
	$yymmddDate 	= $runDate.ToString("yyyyMMdd")
    $strDateNow = get-date -format "yyyyMMddTHHmmss"

	$FullDayString  = $runDate.ToShortDateString()
    $DataSetDateString = $DataSetDate.ToShortDateString()
	##$FileName       = "StateStreetPositions"+$yymmddDate+".csv"
	#$logFile 		= $dirLogFolder+"\WSOondemandArchive"+$yymmddDate+".txt"
	
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$logFile 		= "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"
    ##$ArchiveDir     = "\\hcmlp.com\data\IT\DataFeeds\WSOOnDemandStressTesting"##\Archive"+$strDateNow
    ##$ArchiveDir     = "G:\IT\DataFeeds\WSOOnDemand\Archive\"+$strDateNow
    $ArchiveDir     = "$dirDataFeedsArchiveFolder\WSOOnDemand\Archive\WSOOnDemandArchive\"+$strDateNow
	
$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

########## Creating RefDataSet Record ################
$ServerName = "PHCMDB01"
### Create your insert statement
      $SQL  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= 0 ,
	@RefDataSetDate	    = '" +$FullDayString +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'ArchiveWSOOnDemandFolder'"  
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: $ServerName" |  Out-File $logFile -Append
	
[string]$SQL1  = $("SELECT TOP 1 RefDataSetID FROM  HCM.dbo.vRefDataSet WHERE 
RefDataSetDate = '" +$FullDayString +"' AND RefDataSetType = 'File' AND RefDataSource = 'Highland' AND Label = 'ArchiveWSOOnDemandFolder'
ORDER BY 1 DESC")

	### make database connection
      $ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=HCM;Database=HCM;Integrated Security=SSPI;"
      $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
      $dbconn.Open()
	  $dbconn1 = New-Object System.Data.SQLClient.SQLCommand
	  $dbconn1.Connection = $dbConn
	  $dbconn1.CommandText      = $SQL
      $dbCmd = $dbConn1.ExecuteReader()
	  $dbConn1.CommandTimeout = 0
	  
	  ### close the connection
      $dbCmd.Dispose()
	  $dbconn1.CommandText      = $SQL1 
	  $RefDataSetID = $dbConn1.ExecuteScalar()
	
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: RefDataSetID :: $RefDataSetID" |  Out-File $logFile -Append

       
    #Remove-Item $logFile
    
$LogTime = Get-Date

## Create Archive Directory If not exists    
if(!(Test-Path -Path $ArchiveDir ))
{
    New-Item -ItemType directory -Path $ArchiveDir | Out-File $logFile -Append
    $LogTime = Get-Date
    "> $LogTime :: Created $ArchiveDir " | Out-File $logFile -Append
} 

###Move imported file to Archive Directory
move-Item -Path $SourceFilesDir\*.csv -destination $ArchiveDir | Out-File $logFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Files Archived" |  Out-File $logFile -Append
##################### PASS DATASET ########################
[string]$SQL2  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= " +$RefDataSetID +" ,
	@RefDataSetDate	    = '" +$FullDayString +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'ArchiveWSOOnDemandFolder',
	@StatusCode         = 'P'"
	
##################### FAIL DATASET ########################
[string]$SQL3  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= " +$RefDataSetID +" ,
	@RefDataSetDate	    = '" +$FullDayString +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'ArchiveWSOOnDemandFolder',
	@StatusCode         = 'F'"

if(!(Test-Path -Path $SourceFilesDir\*.csv ))
{$dbconn1.CommandText      = $SQL2 
	$dbCmdnew1 = $dbConn1.ExecuteReader()
}
else
{$dbconn1.CommandText      = $SQL3 
	$dbCmdnew1 = $dbConn1.ExecuteReader()
}

$dbconn.Close()
$dbConn.Dispose()

	### cleanup
Remove-Variable dbCmd
Remove-Variable dbConn
	  
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File  $logFile -Append
