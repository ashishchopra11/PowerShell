$logFilePath = "D:\Siepe\Data\Logs"
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$LogFile = "$logFilePath\Delete180daysoldLogs"+$strDateNow+".txt"
$Now = Get-Date
$Days = "45" #----- define amount of days ----#
$Extension = "*txt" #----- define extension ----#
$Lastwrite = $Now.AddDays(-$Days)
$ServerName = "PHCMDB01"
$RefDataSetdate = (Get-Date).ToShortDateString();

### Create your insert statement
      $SQL  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= 0 ,
	@RefDataSetDate	    = '" +$RefDataSetdate +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'Delete old log files'"  
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: $ServerName" | Out-File $LogFile -Append
	
[string]$SQL1  = $("SELECT TOP 1 RefDataSetID FROM  HCM.dbo.vRefDataSet WHERE 
RefDataSetDate = '" +$RefDataSetdate +"' AND RefDataSetType = 'File' AND RefDataSource = 'Highland' AND Label = 'Delete old log files'
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
	
	
Write-output "Value is " $RefDataSetID
#----- get files based on lastwrite filter and specified folder ---#
foreach ($LogFile in Get-ChildItem -Path $logFilePath |Where-Object {$_.Name -ilike "*.txt"} | where {$_.LastwriteTime -le $Lastwrite})
{
	$LogFile
    write-host "Deleting File $LogFiles" 
    Remove-item $LogFile.Fullname 
}

[string]$SQL2  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= " +$RefDataSetID +" ,
	@RefDataSetDate	    = '" +$RefDataSetdate +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'Delete old log files',
	@StatusCode         = 'P'"

[string]$SQL3  = "EXEC HCM.dbo.pRefDataSetIU
	@RefDataSetID		= " +$RefDataSetID +" ,
	@RefDataSetDate	    = '" +$RefDataSetdate +"' ,
	@RefDataSetType		= 'File' ,
	@RefDataSource		= 'Highland' ,
	@Label				= 'Delete old log files',
	@StatusCode         = 'F'"

########## update RefDataSet on the basis of presence of log file ###########
foreach ($LogFile in Get-ChildItem -Path $logFilePath |Where-Object {$_.Name -ilike "*.txt"})
{ 

########### If still log file exists , then FAIL ############
 if($LogFile.LastWriteTime -le $Lastwrite)
 { $dbconn1.CommandText      = $SQL3 
	$dbCmdnew1 = $dbConn1.ExecuteReader()
	
	 $dbconn.Close()
      $dbConn.Dispose()

	### cleanup
      Remove-Variable dbCmd
      Remove-Variable dbConn
 Exit
 }
 }
 
########### If  log file doesnot exists , then PASS ############
$dbconn1.CommandText      = $SQL2 
$dbCmdnew1 = $dbConn1.ExecuteReader()


	 $dbconn.Close()
      $dbConn.Dispose()

	### cleanup
      Remove-Variable dbCmd
      Remove-Variable dbConn
	  
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
