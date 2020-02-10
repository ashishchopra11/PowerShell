############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
. .\fRefDataSetIU.ps1
. .\fGet-ExcelData.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

CLS
## Find RefDataSet Label
$LabelDate = Get-Date
if($LabelDate.Hour -ge 00 -and $LabelDate.Hour -le 03){
	$RefDataSetLabel = "Job Services 12 AM"
	$ExcelRefDataSetLabel = "RegressionTest Excel 12 AM"
}elseif($LabelDate.Hour -ge 04 -and $LabelDate.Hour -le 08){
	$RefDataSetLabel = "Job Services 04 AM"
	$ExcelRefDataSetLabel = "RegressionTest Excel 04 AM"
}elseif($LabelDate.Hour -ge 09 -and $LabelDate.Hour -le 13){
	$RefDataSetLabel = "Job Services 09 AM"
	$ExcelRefDataSetLabel = "RegressionTest Excel 09 AM"
}elseif($LabelDate.Hour -ge 14 -and $LabelDate.Hour -le 19){
	$RefDataSetLabel = "Job Services 02 PM"
	$ExcelRefDataSetLabel = "RegressionTest Excel 02 PM"
}elseif($LabelDate.Hour -ge 20 -and $LabelDate.Hour -le 23){
	$RefDataSetLabel = "Job Services 08 PM"
	$ExcelRefDataSetLabel = "RegressionTest Excel 08 PM"
}
function CheckServices($ServiceName) 
{
	#$username = "HCMLP\Virtual.DBA"
	#$password = ConvertTo-SecureString -AsPlainText "nD7KBe01" -Force
	
	#$Cred = new-object -typename System.Management.Automation.PSCredential `
	 #        -argumentlist $username, $password
			 
$Server = "HCMV14"
$ServiceStatus = (Get-Service -Name $ServiceName -ComputerName $Server|Select Status)
#$Scriptblock = $ExecutionContext.InvokeCommand.NewScriptBlock("Get-Service -Name '$ServiceName'  -ComputerName '$Server'|Select Status")
#$ServiceStatus = Invoke-Command -Computername $Server -ScriptBlock #$scriptblock -Credential $Cred
$ServiceStatus.Status
Return, $ServiceStatus.Status
}
function CheckForError($RSJObName, $RunTime, $UserName)
{

	 $DataSource = "PHCMDB01"
	#$DataSource = "DHCMDB01"
	$DatabaseName = "DataFeeds"
	$ConnectionString = "Data Source=" +$DataSource +";Initial Catalog="+ $DatabaseName +";Database="+ $DatabaseName +";Integrated Security=SSPI;"
	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
	$dbCmd = $dbConn.CreateCommand()
	$dbCmd.CommandTimeout = 0
	
	IF($UserName -ne $null -and $UserName -ne "")
	{
	$dbCmd.CommandText = "DECLARE @ExceptionMsg varchar(max) = ''
	
	SELECT @ExceptionMsg = ISNULL(@ExceptionMsg,'')+ExceptionMessage +'<br>'
	FROM Enterprise.dbo.tLogbookEntry  WHERE ThreadID IN (
	SELECT  ThreadID 
		FROM Enterprise.dbo.tLogbookEntry 
		WHERE
		EntryDateTime >'$RunTime'  AND UserName = '$UserName' AND ExceptionMessage like '%$RSJObName%'
		) AND TraceEventType = 'Error'  AND EntryDateTime >'$RunTime'
	ORDER BY EntryDateTime


	SELECT @ExceptionMsg AS ExpMsg"
	}
	ELSE 
	{
		$dbCmd.CommandText = "DECLARE @ExceptionMsg varchar(max) = ''
	SELECT @ExceptionMsg = ISNULL(@ExceptionMsg,'')+ExceptionMessage +'<br>' 
	FROM
	(
		SELECT EntryDateTime,ExceptionMessage
		FROM Enterprise.dbo.tLogbookEntry 
		WHERE TraceEventType = 'Error'AND 
		EntryDateTime >'$RunTime'
		)Q
	WHERE ExceptionMessage like '%$RSJObName%'
	ORDER BY EntryDateTime

	SELECT @ExceptionMsg AS ExpMsg"
	}
	$dbConn.Open()
	$ErrorStr = $dbCmd.ExecuteScalar().ToString()
	$dbConn.Close()
	return ,$ErrorStr
}
## Check WSO Log if regression extract not success
function CheckWSOLog
{
	[int]$WSOStatusFromLog =  -1
	$DataSource = "PHCMDB01"
	$DatabaseName = "DataFeeds"
	$ConnectionString = "Data Source=" +$DataSource +";Initial Catalog="+ $DatabaseName +";Database="+ $DatabaseName +";Integrated Security=SSPI;"
	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
	$dbCmd = $dbConn.CreateCommand()
	$dbCmd.CommandTimeout = 0
	
	$dbCmd.CommandText = "DECLARE @EarliestTime DATETIME, @ErrorCount INT, @EntryCount INT
					SET @EarliestTime = DATEADD(mi, -10, getdate())

					SELECT  @EntryCount= COUNT(AppDomainName)
					FROM Enterprise..vLogbookEntry 
					WHERE AppDomainName LIKE '%WSO%' AND EntryDateTime > @EarliestTime GROUP BY AppDomainName

					SELECT  @ErrorCount = COUNT(AppDomainName)
					FROM Enterprise..vLogbookEntry
					WHERE AppDomainName LIKE '%WSO%' AND EntryDateTime > @EarliestTime AND TraceEventType = 'Error' GROUP BY AppDomainName

					IF @EntryCount <> 0 AND @EntryCount IS NOT NULL AND (@ErrorCount = 0 OR @ErrorCount IS NULL)
						SELECT 1 AS WSOResult
					ELSE 
			SELECT 0 AS WSOResult"
	
	$dbConn.Open()
	$WSOStatusFromLog = $dbCmd.ExecuteScalar().ToString()
	$dbConn.Close()
	return ,$WSOStatusFromLog
}
## Check ReceiveService Log if regression test Recevie job not success for some other reason.
function CheckReceiveServiceLog
{
	[int]$ReceiveServiceStatusFromLog =  -1
	$DataSource = "PHCMDB01"
	$DatabaseName = "DataFeeds"
	$ConnectionString = "Data Source=" +$DataSource +";Initial Catalog="+ $DatabaseName +";Database="+ $DatabaseName +";Integrated Security=SSPI;"
	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
	$dbCmd = $dbConn.CreateCommand()
	$dbCmd.CommandTimeout = 0
	
	$dbCmd.CommandText = "DECLARE @EarliestTime DATETIME, @ErrorCount INT, @EntryCount INT
					SET @EarliestTime = DATEADD(mi, -10, getdate())

					SELECT  @EntryCount= COUNT(ExceptionMessage)
					FROM Enterprise..vLogbookEntry 
					WHERE UserName = 'HCMLP\Prod.Report.Admin' AND EntryDateTime > @EarliestTime AND ExceptionMessage LIKE '%Successful in writing to local path:%' 
					GROUP BY UserName

					SELECT  @ErrorCount = COUNT(ExceptionMessage)
					FROM Enterprise..vLogbookEntry
					WHERE UserName = 'HCMLP\Prod.Report.Admin' AND EntryDateTime > @EarliestTime AND (ExceptionMessage LIKE '%ERROR for Subscription ID:%' OR ExceptionMessage LIKE '%Error downloading file:%')
					GROUP BY UserName 

					IF @EntryCount <> 0 AND @EntryCount IS NOT NULL AND (@ErrorCount = 0 OR @ErrorCount IS NULL)
						SELECT 1 AS ReceiveServiceResult
					ELSE 
						SELECT 0 AS ReceiveServiceResult"
	
	$dbConn.Open()
	$ReceiveServiceStatusFromLog = $dbCmd.ExecuteScalar().ToString()
	$dbConn.Close()
	return ,$ReceiveServiceStatusFromLog
}
[string]$strDateNow 	= get-date -format "yyyyMMddTHH"
[string]$logFile 		= "$dirLogFolder\RegressionTest_DeliveryService_CheckSFTP_"+$strDateNow+".txt" ##Log file path

### make the connection
$ServerName = "PHCMDB01"
$DatabaseName = "DataFeeds"

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"  
	 
# Setup session options
$sessionOptionsSFTPFileCheck = New-Object WinSCP.SessionOptions -Property @{
		    Protocol = [WinSCP.Protocol]::Sftp
		    HostName = 'sftp.siepe.io'
		    UserName = '005tools'
		    Password = 'n2tyF8dZuc'
		    SshHostKeyFingerprint = 'ecdsa-sha2-nistp256 256 04:c2:28:04:8a:a7:0a:9e:36:7d:10:c9:41:d4:49:f3'
		}
<#
## RefDataSetDate and Delivery or Receive File name Setup 
if((get-date).Dayofweek -eq "Monday")
{
	$FileDate =(get-date).AddDays(-3).ToString("yyyyMMddTHH")
}
else
{
	$FileDate =(get-date).AddDays(-1).ToString("yyyyMMddTHH")
}
#>
$FileDate =(get-date).ToString("yyyyMMddTHH")
$ExtractFile = "RegressionTest_" + $FileDate + ".CSV"
$RemotePathExtractFile = "/RegressionTest/" + $ExtractFile

$dtDataSetDate = [datetime]::parseexact($FileDate,"yyyyMMddTHH",$null).ToShortDateString()
$dtMailTime = [datetime]::parseexact($FileDate,"yyyyMMddTHH",$null)

## Create RefDataSet					
 $RefDataSetID = fRefDataSetIU -rdsRefDataSetID 0 -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel $RefDataSetLabel -rdsStatusCode "I" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	            
[string]$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Regression Test - Notification Service, Receive Service, Delivery Service, Script Adapter Service, WSO Adapter Service and EMail Adapater Services `r`n" |   Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Job Services RefDataSetID = $RefDataSetID `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

[string]$dirSourceFolder = "$dirServicesDeliveryStoreFolder\RegressionTest" ## Source File location
[string]$dirArchiveFolder = "$dirArchiveHCM46DriveFolder\RegressionTest\Archive" ## Archive File location
[string]$dirSourceFolderWSOonDemand = "$dirServicesDeliveryStoreFolder\WSOOnDemand" ## Archive File location

Write-Output " dirSourceFolder			= $dirSourceFolder" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder Margin	= $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow				= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile					= $LogFile `r`n" | Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
<#
######################################## Verify and Create If Regression Jobs are not present ############################################
[String]$CreateJobsSQL = "
IF NOT EXISTS (SELECT 1 FROM HCM.Report.tSubscriptionXML WHERE Name = 'RegressionTest_Mail_Notification')
BEGIN
BEGIN TRAN
EXEC [Report].[pSubscriptionIXml] @SubscriptionItemXML='<SubscriptionItem><Subscriber><ID>555</ID><Name>rrutledge@hcmlp.com</Name></Subscriber><DeliveryContent><ArrayOfTitles /><SubscriptionDetails><PrimaryOwner /><SecondaryOwner /><SubscriptionID>1802</SubscriptionID><Documentation /></SubscriptionDetails><ContentOptions xmlns:p3=""http://www.w3.org/2001/XMLSchema-instance"" p3:type=""ContentOptionsCustomGenericGridSql""/><ID>1</ID><Name>Hcmlp.OMS.Notifications.CustomGenericGridSql</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><ConnectionString>HCM</ConnectionString><ConnectionTimeout>0</ConnectionTimeout><Parameters><Parameter><Name /><Value>SELECT TOP 10 * FROM vIssuer</Value></Parameter></Parameters></DeliveryContent><DeliveryMechanism><DeliveryOptions xmlns:p3=""http://www.w3.org/2001/XMLSchema-instance"" p3:type=""DeliveryOptionsEmail""><MailPriority>Normal</MailPriority></DeliveryOptions><ID>1</ID><Name>Email</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><Address>rkari@siepe.com,hgupta@siepe.com</Address></DeliveryMechanism><DeliveryFrequency xmlns:p2=""http://www.w3.org/2001/XMLSchema-instance"" p2:type=""DeliveryFrequencyOnEvent"" OnEventName=""Dallas.HoldCo.RegressionTest.Mail.Notification""><ActiveDaysOfWeek /><EffFromTimeShortTimeString>3:33 AM</EffFromTimeShortTimeString><EffThruTimeShortTimeString>12:00 AM</EffThruTimeShortTimeString><ID>6</ID><Name>OnEvent</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><EffFromDate>2017-05-07T00:00:00</EffFromDate><EffThruDate>9999-01-01T00:00:00</EffThruDate><EffFromTime>2017-05-07T03:33:00</EffFromTime><EffThruTime>9999-01-01T00:00:00</EffThruTime><EveryNPeriod>1</EveryNPeriod></DeliveryFrequency><RetryInterval>0</RetryInterval><NumberRetrys>0</NumberRetrys><ID>2395</ID><Name>RegressionTest_Mail_Notification</Name><Description>Highland - Regression Test - Report Subscription - EMail Notification Service</Description><DomainName>Production</DomainName><ReportID>0</ReportID></SubscriptionItem>'
COMMIT TRAN
END

IF NOT EXISTS (SELECT 1 FROM HCM.Report.tSubscriptionXML WHERE Name = 'RegressionTest_Delivery_Service')
BEGIN
BEGIN TRAN
EXEC [Report].[pSubscriptionIXml] @SubscriptionItemXML='<SubscriptionItem><Subscriber><ID>555</ID><Name>rrutledge@hcmlp.com</Name></Subscriber><DeliveryContent><ArrayOfTitles /><SubscriptionDetails><PrimaryOwner /><SecondaryOwner /><SubscriptionID>1802</SubscriptionID><Documentation /></SubscriptionDetails><ContentOptions xmlns:p3=""http://www.w3.org/2001/XMLSchema-instance"" p3:type=""ContentOptionsCustomCsvSql"" FieldDelimiter=""0"" TextQualifier=""0"" /><ID>2</ID><Name>Hcmlp.OMS.Notifications.CustomCsvSql</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><ConnectionString>HCM</ConnectionString><ConnectionTimeout>0</ConnectionTimeout><Parameters><Parameter><Name /><Value>SELECT TOP 10 * FROM vIssuer</Value></Parameter></Parameters></DeliveryContent><DeliveryMechanism><DeliveryOptions xmlns:p3=""http://www.w3.org/2001/XMLSchema-instance"" p3:type=""DeliveryOptionsDeliveryService"" PayloadName=""RegressionTest_"" PayloadNameDate=""T-1"" PayloadNameDateSuffix=""yyyyMMdd.CSV"" /><ID>2</ID><Name>DeliveryService</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><Address>SiepeSFTPRegressionTest</Address></DeliveryMechanism><DeliveryFrequency xmlns:p2=""http://www.w3.org/2001/XMLSchema-instance"" p2:type=""DeliveryFrequencyOnEvent"" OnEventName=""Dallas.HoldCo.RegressionTest.Delivery""><ActiveDaysOfWeek /><EffFromTimeShortTimeString>3:33 AM</EffFromTimeShortTimeString><EffThruTimeShortTimeString>12:00 AM</EffThruTimeShortTimeString><ID>6</ID><Name>OnEvent</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><EffFromDate>2017-05-07T00:00:00</EffFromDate><EffThruDate>2017-07-28T00:00:00</EffThruDate><EffFromTime>2017-05-07T03:33:00</EffFromTime><EffThruTime>2017-07-28T00:00:00</EffThruTime><EveryNPeriod>1</EveryNPeriod></DeliveryFrequency><ID>2396</ID><Name>RegressionTest_Delivery_Service</Name><Description>Highland - Regression Test - Report Subscription - Delivery Service</Description><DomainName>Production</DomainName><ReportID>939</ReportID></SubscriptionItem>'
COMMIT TRAN
END

IF NOT EXISTS (SELECT 1 FROM HCM.Report.tSubscriptionXML WHERE Name = 'RegressionTest_Receive_Service')
BEGIN
BEGIN TRAN
EXEC [Report].[pSubscriptionIXml] @SubscriptionItemXML='<SubscriptionItem><Subscriber><ID>555</ID><Name>rrutledge@hcmlp.com</Name></Subscriber><DeliveryContent><ArrayOfTitles /><ID>13</ID><Name>Hcmlp.OMS.Notifications.CustomFileAttachmentPayload</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><ConnectionString>HCM</ConnectionString><ConnectionTimeout>0</ConnectionTimeout><Parameters><Parameter><Name /><Value>default</Value></Parameter></Parameters></DeliveryContent><DeliveryMechanism><DeliveryOptions xmlns:p3=""http://www.w3.org/2001/XMLSchema-instance"" p3:type=""DeliveryOptionsReceiveService"" PayloadName=""Regression*"" PayloadNameDate=""T-1"" PayloadNameDateSuffix=""yyyyMMdd*"" RecipientList=""tnguyen@hcmlp.com"" /><ID>3</ID><Name>ReceiveService</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><Address>SiepeSFTPRegressionTest</Address></DeliveryMechanism><DeliveryFrequency xmlns:p2=""http://www.w3.org/2001/XMLSchema-instance"" p2:type=""DeliveryFrequencyOnEvent"" OnEventName=""Dallas.HoldCo.RegressionTest.Receive""><ActiveDaysOfWeek /><EffFromTimeShortTimeString>6:00 AM</EffFromTimeShortTimeString><EffThruTimeShortTimeString>12:00 AM</EffThruTimeShortTimeString><ID>6</ID><Name>OnEvent</Name><CreatedDate>0001-01-01T00:00:00</CreatedDate><EffFromDate>2011-09-16T06:00:00</EffFromDate><EffThruDate>9999-01-01T00:00:00</EffThruDate><EffFromTime>2011-09-16T06:00:00</EffFromTime><EffThruTime>9999-01-01T00:00:00</EffThruTime><EveryNPeriod>1</EveryNPeriod></DeliveryFrequency><CompletionPubSub /><ID>2398</ID><Name>RegressionTest_Receive_Service</Name><Description>Highland - Regression Test - Report Subscription - Receive Service</Description><DomainName>Production</DomainName><ReportID>477</ReportID></SubscriptionItem>'
COMMIT TRAN
END
"

$dbCmd.CommandText = $CreateJobsSQL
$dbConn.Open()
$NsError = $dbCmd.ExecuteScalar().ToString()
$dbConn.Close()
#>


######################################## Notification Service ############################################
Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# " |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING Notification Service " |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# " |   Out-File $LogFile -Append

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
$NotificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Sending Pubsub :RegressionTest.Mail.Notification `r`n" |   Out-File $LogFile -Append
Write-PubSub -Subject "RegressionTest.Mail.Notification" -Title "Regression Test" -Description "Regression Test"
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Starting Sleep : 10Sec  `r`n" |   Out-File $LogFile -Append
Sleep -Seconds 10
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Resumed from Sleep `r`n" |   Out-File $LogFile -Append
$NsError = CheckForError -RSJObName RegressionTest_Mail_Notification -RunTime $NotificationTime
$NsResult = "Failure"
if($NsError.Length -eq 0)
{
    $NsResult = "Success"
}
$Ns_ServiceStatus = CheckServices -ServiceName "Siepe Notification Service"
$Ns_ServiceStatus 

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Notofication Service Test Completed : NsResult = $NsResult `r`n NsError =  $NsError `r`n " |   Out-File $LogFile -Append


######################################## Delivery Service ############################################

Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING Delivery Service 		" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
$NotificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  PubSub Published : RegressionTest.Delivery `r`n " | Out-File $LogFile -Append
Write-PubSub -Subject "RegressionTest.Delivery" -Title "RegressionTest"
Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Start Sleep Delivery services 250 sec `r`n " | Out-File $LogFile -Append
Sleep -Seconds 250

Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Resume Delivery services `r`n" | Out-File $LogFile -Append
$DS_Error_Message = CheckForError -RSJObName "RegressionTest_Delivery_Service" -RunTime $NotificationTime
Write-Output " `r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Error Message  `r`n: $DS_Error_Message  `r`n " | Out-File $LogFile -Append
######### Verify through PowerShell if file delivered to SFTP or not
$SFTPCheckCounter = 0 
$FileInSFTP = 0
$LoopExit = 0
$ErrorCount = 0
while ($LoopExit -lt 2 )
{
    $LoopExit = $LoopExit + 1
	try
	{
	    $sessionSFTPFileCheck = New-Object WinSCP.Session 
		try
	    {
	        # Connect
	        $sessionSFTPFileCheck.Open($sessionOptionsSFTPFileCheck)
	         $directory = $sessionSFTPFileCheck.ListDirectory("/RegressionTest")
			 Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  directory FTP:  `r`n $directory `r`n `r`n`r`n" | Out-File $LogFile -Append
	        ##Testing file present on SFTP or not 
	        $ListFilesInSFTP = $sessionSFTPFileCheck.EnumerateRemoteFiles("/RegressionTest/", $ExtractFile, [WinSCP.EnumerationOptions]::None)
			Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Files Present on FTP:  `r`n $ListFilesInSFTP `r`n `r`n`r`n" | Out-File $LogFile -Append
			Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Check Required File on SFTP :: $RemotePathExtractFile `r`n" | Out-File $LogFile -Append
	        if ($ListFilesInSFTP.Count -gt 0 -and $sessionSFTPFileCheck.FileExists($RemotePathExtractFile))
	        {
	            Write-Output("File {0} exists" -f $RemotePathExtractFile)  |  Out-File $LogFile -Append
		        #Fire PubSub to download the file 
		        Write-Output "Delivery Serivce :"+ $ExtractFile + " Delivered file ($ExtractFile) to Siepe SFTP under \RegressionTest\ folder. `r`n" |  Out-File $LogFile -Append
				$DS_Message = " Delivered file ("+$ExtractFile+") to Siepe SFTP under \RegressionTest\ folder."
				$FileInSFTP = 1 
	        }
	        else
	        {
			Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File not present on SFTP :: $RemotePathExtractFile`r`n " | Out-File $LogFile -Append
	            if( $SFTPCheckCounter -lt 2)
	            {
	                Write-Host ("File {0} does not exist" -f $RemotePath)  | Out-File $LogFile -Append
	                Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: FILE NOT FOUND  $counter : $RemotePathExtractFile `r`n" |  Out-File $LogFile -Append
                    $SFTPCheckCounter = $SFTPCheckCounter + 1
	               Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Start Sleep Delivery services 20sec `r`n " | Out-File $LogFile -Append
					Sleep -Seconds 50
					Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Resume Delivery services `r`n" | Out-File $LogFile -Append
	            }
	            else 
	            {
	                Write-Output "Delivery Serivce :"+ $ExtractFile + " not delivered to Siepe SFTP, Please have a look !! `r`n" |  Out-File $LogFile -Append
					$DS_Message = "File ("+$ExtractFile + ") not delivered to Siepe SFTP, Please have a look !!"
					Write-Output $DS_Error_Message | Out-File $logFile -Append		     
	            }
	        }
	    }
       Catch
        {
            $ErrorCount = $ErrorCount + 1
            $sessionSFTPFileCheck.Dispose()
            $message = $_.Exception.Message.ToString()
            if($ErrorCount -eq 2)
            {
                throw $message
            }
           
        }
        
	
	}
	catch [Exception]
	{
        #$_.Exception.Message
	    $DS_Error_Message = ("Error: {0}" -f $_.Exception.Message).ToString()
	    Write-Output ("Error: {0}" -f $_.Exception.Message) | Out-File $logFile -Append	
	}
}
$DS_ServiceStatus = CheckServices -ServiceName "Siepe Notification Service" | Select -Unique
$DS_ServiceStatus
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Completed Delivery Service Testing" | Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Delivery Service Test Completed : `r`n FileInSFTP =  $FileInSFTP `r`n DS_Message = $DS_Message `r`n DS_Error_Message = $DS_Error_Message`r`n " |   Out-File $LogFile -Append

 $Ns_ServiceStatus
  $RS_ServiceStatus
  $DS_ServiceStatus
  $SA_ServiceStatus

######################################## Receive Service ############################################
Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING Receive Service 		" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append

$FileInDeliveryStore = 0
$Rs_Error_Message = ""
$RS_Message = ""
if($FileInSFTP -eq 1)
{
    $NotificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  PubSub Published : RegressionTest.Receive ::  NotificationTime : $NotificationTime `r`n " | Out-File $LogFile -Append
	Write-PubSub -Subject "RegressionTest.Receive" -Title "RegressionTest"
    Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Start Sleep Recieve service 50sec `r`n " | Out-File $LogFile -Append
    Sleep -Seconds 50
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Resume Recieve service `r`n " | Out-File $LogFile -Append
    $Rs_Error_Message = CheckForError -RSJObName "RegressionTest_Receive_Service" -RunTime $NotificationTime
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  ERROR:`r`n $Rs_Error_Message `r`n " | Out-File $LogFile -Append
    ######### Verify through PowerShell if file downloaded to Delivery Store or not
    $LocalExtractFile = $dirSourceFolder + "\" + $ExtractFile + "*" 
    Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  TESTING Path : $LocalExtractFile  `r`n " | Out-File $LogFile -Append
	
	if (!(Test-path -Path  $LocalExtractFile))
    {
	     Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Start Sleep Recieve service for another 50sec `r`n " | Out-File $LogFile -Append
		Sleep -Seconds 50
    }
	
	if (Test-path -Path  $LocalExtractFile) 
    {
	    $RS_Message = $RS_Message + "`r`n File ("+$ExtractFile+") downloaded to \\services.hcmlp.com\DeliveryStore\RegressionTest."
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File ("+$ExtractFile+") downloaded to \\services.hcmlp.com\DeliveryStore\RegressionTest." | Out-File $LogFile -Append
	    $FileInDeliveryStore = 1
    }
	elseif ($FileInDeliveryStore -eq 0)
    {
	    Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File ("+$ExtractFile+") Not Present checking LogBookEnty if any other Receive Service Jobs in Queue `r`n " | Out-File $LogFile -Append
		[int]$ReceiveServiceStatusFromLog = -1
		$ReceiveServiceStatusFromLog = CheckReceiveServiceLog
		If($ReceiveServiceStatusFromLog -eq 1){
			$RS_Message =  $RS_Message + "`r`n File ("+$ExtractFile+") <b>not downloaded</b> to \\services.hcmlp.com\DeliveryStore\RegressionTest , <b> as we have other Receive Service Jobs in queue</b>."
			$FileInDeliveryStore = 1
		}
		else{
			$RS_Message = $RS_Message + "`r`n File ("+$ExtractFile+") not Downloaded to  \\services.hcmlp.com\DeliveryStore\RegressionTest and we dont have any other Receive Service Jobs in queue."
		}
    }
    else
    {
	    $RS_Message = $RS_Message + "`r`n File ("+$ExtractFile+") not downloaded to \\services.hcmlp.com\DeliveryStore\RegressionTest."
	    Write-Output "'r'n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") File ("+$ExtractFile+") not available in \\services.hcmlp.com\DeliveryStore\RegressionTest." | Out-File $LogFile -Append
    }
}
else
{
	$RS_Message = "File ("+$ExtractFile+") not available in SFTP so <b>not Kicking off Receive Service Job</b> <br/>"
	Write-Output "'r'n Receive Service: File (" +$ExtractFile +") not available in SFTP so not Kicking off Receive Service" | Out-File $LogFile -Append
}
$RS_ServiceStatus = CheckServices -ServiceName "Siepe Notification Service" | Select -Unique
$RS_ServiceStatus
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Receive Service Test Completed : `r`n FileInDeliveryStore =  $FileInDeliveryStore `r`n RS_Message = $RS_Message `r`n  Rs_Error_Message = $Rs_Error_Message`r`n " |   Out-File $LogFile -Append
 
 	$Ns_ServiceStatus
  $RS_ServiceStatus
  $DS_ServiceStatus
  $SA_ServiceStatus

$WSOAdapter_Error_Message = ""
$WSOAdapter_Message = ""
######################################## WSO Adapter Service ############################################
Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING WSO Adapter Service 		" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append

	$WSOFilePattern = "RegressionTestWSO*.csv"
	$FileLocateWSOTEST = "$dirSourceFolderWSOonDemand\$WSOFilePattern"
	$FileLocateWSOTEST |  Out-File $LogFile -Append
	
	Write-Output "`r`n################$dirSourceFolderWSOonDemand\$WSOFilePattern  `r`n" |  Out-File $LogFile -Append
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  PubSub Published : RegressionTest.DownloadFileEvent.WSOAdapter `r`n " | Out-File $LogFile -Append
	 Write-PubSub -Subject "RegressionTest.DownloadFileEvent.WSOAdapter" -Title "RegressionTest WSO Adapter"
     Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Start Sleep WSO Adapter 400sec `r`n " | Out-File $LogFile -Append
   Sleep -Seconds 400
  
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Resume WSO Adapter `r`n " | Out-File $LogFile -Append
 #   $WSOAdapter_Error_Message = CheckForError -RSJObName "Regression.Test" -RunTime $NotificationTime -userName "HCMLP\Prod.Wso.Adapter"
    ######### Verify through PowerShell if file Archived or not

    $FileInWSOOnDemand = 0
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  TEST file present or not : $dirSourceFolderWSOonDemand\$WSOFilePattern `r`n " | Out-File $LogFile -Append
    if ((Test-Path -path "$dirSourceFolderWSOonDemand\$WSOFilePattern"))
    {
	    $WSOAdapter_Message =  $WSOAdapter_Message + "`r`n File ("+$WSOFilePattern+") Downloaded to $dirSourceFolderWSOonDemand"
		Remove-Item -Path $FileLocateWSOTEST #$dirSourceFolder
		$FileInWSOOnDemand = 1
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File Exist `r`n " | Out-File $LogFile -Append
    }
	elseif ($FileInWSOOnDemand -eq 0)
    {
	    Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File ("+$WSOFilePattern+") Not Present checking LogBookEnty if any other WSO Extracts in Queue `r`n " | Out-File $LogFile -Append
		[int]$WSOLogStatus = -1
		$WSOLogStatus = CheckWSOLog
		If($WSOLogStatus -eq 1){
			$WSOAdapter_Message =  $WSOAdapter_Message + "`r`n File ("+$WSOFilePattern+") <b>not downloaded</b> to $dirSourceFolderWSOonDemand, as <b> we have other WSO extracts in queue</b>."
			$FileInWSOOnDemand = 1
		}
		else{
			$WSOAdapter_Message = $WSOAdapter_Message + "`r`n File ("+$WSOFilePattern+") not Downloaded to $dirSourceFolderWSOonDemand and we dont have any other extracts in queue."
		}
    }
    else
    {
	    Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File Not Present `r`n " | Out-File $LogFile -Append
		$WSOAdapter_Error_Message = CheckForError -RSJObName "Regression.Test" -RunTime $NotificationTime -userName "HCMLP\Prod.Wso.Adapter"
		$WSOAdapter_Message = $WSOAdapter_Message + "`r`n File ("+$WSOFilePattern+") not Downloaded to $dirSourceFolderWSOonDemand"
    }
$WSO_ServiceStatus = CheckServices -ServiceName "Siepe WsoAdapter Service" | Select -Unique
#$WSO_ServiceStatus =  Get-Service -Name "Siepe WsoAdapter Service" -ComputerName "HCMV14"|Select Status | Select -Unique
$WSO_ServiceStatus
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: WSO Adapter Service Test Completed : `r`n FileInWSOOnDemand =  $FileInWSOOnDemand `r`n  WSOAdapter_Message = $WSOAdapter_Message `r`n WSOAdapter_Error_Message = $WSOAdapter_Error_Message `r`n " |   Out-File $LogFile -Append


$EMailAdapter_Error_Message = ""
$EMailAdapter_Message = ""
######################################## EMail Adapter Service ############################################
Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING EMail Adapter Service 		" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append

	$EMailFilePattern = "RegressionTestEmailAdapter.xlsm"
		
	Write-Output "`r`n################$dirSourceFolderWSOonDemand\$WSOFilePattern  `r`n" |  Out-File $LogFile -Append
    $EMailAdapter_Error_Message = CheckForError -RSJObName "RegressionTestEmailAdapter.xlsm" -RunTime $NotificationTime -UserName "HCMLP\prod.emailadapter"
    ######### Verify through PowerShell if file Archived or not
    $FileDownloadEmailAdapter = 0
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  TEST file present or not : $dirSourceFolder\$EMailFilePattern `r`n " | Out-File $LogFile -Append
    if ((Test-Path -path "$dirSourceFolder\$EMailFilePattern"))
    {
	    $EMailAdapter_Message =  $EMailAdapter_Message + "`r`n File ("+$EMailFilePattern+") Downloaded to $dirSourceFolder"
		$FileDownloadEmailAdapter = 1
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File Exist `r`n " | Out-File $LogFile -Append
		 $EMailAdapter_ServiceStatus = "Running"
    }
    else
    {
	    $EMailAdapter_Message = $EMailAdapter_Message + "`r`n File ("+$EMailFilePattern+") not Downloaded to $dirSourceFolder"
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File Not Present `r`n " | Out-File $LogFile -Append
		$EMailAdapter_ServiceStatus = "Not Running"
    }
	$EMailAdapter_Message | Out-File $LogFile -Append
$EMailAdapter_ServiceStatus
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: EMail Adapter Service Test Completed : `r`n FileDownloadEmailAdapter =  $FileDownloadEmailAdapter `r`n  EMailAdapter_Message = $EMailAdapter_Message `r`n EMailAdapter_Error_Message = $EMailAdapter_Error_Message `r`n " |   Out-File $LogFile -Append

Sleep -Seconds 120

$sc_Error_Message = ""
$SA_Message = ""
######################################## Script Adapter Service ############################################
Write-Output "`r`n`r`n ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: STARTING Script Adapter Service 		" |   Out-File $LogFile -Append
Write-Output "`r`r ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ############################# 	" |   Out-File $LogFile -Append

if($FileInDeliveryStore -eq 1)
{
    $NotificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Publishing PubSub Message : RegressionTest.ScriptAdapter `r`n " | Out-File $LogFile -Append
	Write-PubSub -Subject "RegressionTest.ScriptAdapter" -Title "RegressionTest Script Adapter"
     Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Start Sleep Script Adapter 30sec `r`n " | Out-File $LogFile -Append
     Sleep -Seconds 50
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Resume Script Adapter `r`n " | Out-File $LogFile -Append
    $sc_Error_Message = CheckForError -RSJObName "RegressionTest_ScriptAdapter" -RunTime $NotificationTime
    ######### Verify through PowerShell if file Archived or not
    $FileInArchive = 0
	Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  TEST file present or not : $dirArchiveFolder\$strDateNow\$ExtractFile `r`n " | Out-File $LogFile -Append
    $flag  = 1 
	do {
	if ((Test-Path -path "$dirArchiveFolder\$strDateNow\$ExtractFile"))
    {
	    $FileInArchive =1
	    $SA_Message =  $SA_Message + "`r`n Attempt : $Flag of 5 :: File ("+$ExtractFile+") Archived to $dirArchiveFolder\$strDateNow"
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Files Exist `r`n " | Out-File $LogFile -Append
		 $Flag =  6
    }
    else
    {
	    $SA_Message = $SA_Message + "`r`n Attempt : $Flag of 5 :: File ("+$ExtractFile+") not Archived to $dirArchiveFolder\$strDateNow"
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Files Not Present , Sleeping for 40 seconds. Iteration No: $Flag of 5 `r`n " | Out-File $LogFile -Append
		 $Flag = $Flag + 1
		 Write-PubSub -Subject "RegressionTest.ScriptAdapter" -Title "RegressionTest Script Adapter"
		 Start-Sleep -Seconds 40 
    }
	}While($flag -lt 6 )
    
}
else
{
	$SA_Message = "File ("+$ExtractFile+") not downloaded to \\services.hcmlp.com\DeliveryStore\RegressionTest through Receive Service, So <b>Not kicking off SA Job</b> <br/>"
	Write-Output "'r'n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") File ("+$ExtractFile+") not downloaded to archive location :: \\services.hcmlp.com\DeliveryStore\RegressionTest.  " | Out-File $LogFile -Append
}
 $SA_ServiceStatus1 = Get-Service -Name "Siepe Script Adapter Service" -ComputerName "HCMV07"|Select Status | Select -Unique
 $SA_ServiceStatus = $SA_ServiceStatus1.status
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Script Adapter Service Test Completed : `r`n FileInArchive =  $FileInArchive `r`n  SA_Message = $SA_Message `r`n sc_Error_Message = $sc_Error_Message `r`n " |   Out-File $LogFile -Append
 
 
 
$Excel_Error_Message = ""
$Excel_Message = ""
######################################## Excel Connectivity ############################################
$SourceFolder = "$dirSourceFolder\"
$ExcelRegressioTestFile = "$dirSourceFolder\EXCELRegressionTest.xlsx"

$ExcelData = New-Object System.Data.DataTable
Get-ExcelData -path $ExcelRegressioTestFile -Query "SELECT * FROM Sheet1" -DataTable ([ref]$ExcelData)
$ExcelMessage  = $ExcelData.Rows[1].F2

#RefDataSetDate 
[string]$dtDataSetDate1 	= get-date -format "yyyyMMdd"
$RefDataSetDate = ([datetime]::ParseExact($dtDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring()

$StrFileName = "EXCELRegressionTest.xlsx"
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportRegressionTest.dtsx `r`n Variable passed here are : `r`n  FileName = EXCELRegressionTest.xlsx `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
  & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportRegressionTest.dtsx" /set "\package.variables[FileName].Value;$StrFileName"  /set "\package.variables[Label].Value;$ExcelRefDataSetLabel" /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Regression Test Import : file ( EXCELRegressionTest.xlsx ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")GS Swap Position  : file ( $strFileName ) imported" | Out-File $LogFile -Append

	 $DataSource = "PHCMDB01"
	$DatabaseName = "DataFeeds"
	$ConnectionString = "Data Source=" +$DataSource +";Initial Catalog="+ $DatabaseName +";Database="+ $DatabaseName +";Integrated Security=SSPI;"
	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
	$dbCmd = $dbConn.CreateCommand()
	$dbCmd.CommandTimeout = 0

	$dbCmd.CommandText = "		DECLARE  @Message Varchar(20)
		, @CrtDate DATETIME 
	
		SELECT @CrtDate = CreatedDate FROM DataFeeds..vRefDataSet Where RefDataSetID = "+$RefDataSetID +"
		SELECT @Message = RT.Message FROM DataFeeds..tRegressionTest RT 
		JOIN DataFeeds..vRefDataSet R ON R.RefDataSetID = RT.ReFDataSetID
		WHERE R.CreatedDate > @CrtDate 
		SELECT @Message AS Message"
$tstQry =  "		DECLARE  @Message Varchar(20)
		, @CrtDate DATETIME 
	
		SELECT @CrtDate = CreatedDate FROM DataFeeds..vRefDataSet Where RefDataSetID = "+$RefDataSetID +"
		SELECT @Message = RT.Message FROM DataFeeds..tRegressionTest RT 
		JOIN DataFeeds..vRefDataSet R ON R.RefDataSetID = RT.ReFDataSetID
		WHERE R.CreatedDate > @CrtDate 
		SELECT @Message AS Message"
		
		$tstQry 
	$dbConn.Open()
	$SSISMessage = $dbCmd.ExecuteScalar().ToString()
	$dbConn.Close()
		$SSISMessage
	IF($ExcelMessage  -eq "TestExcelData" -and $SSISMessage -eq "TestExcelData")
	{
		$Excel_Message=  "Excel is able to open connection from powershell and ssis."
		 $ExcelConnectivity =1
	}
	ELSE 
	{
		IF ($ExcelMessage -ne "TestExcelData") 
		{
		$Excel_Message=  $Excel_Message +  "Issue with openning  excel from PowerShell"
		
		Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ISSUE with excel connectivity from powershell `r`n  $SSISEXCEPTIONMessage `r`n " | Out-File $LogFile -Append 	
		}
		IF($SSISMessage -ne "TestExcelData")
		{
		
		$Excel_Message=  $Excel_Message + "Issue with ssis connectivity with excel."
		
			$dbCmd1 = $dbConn.CreateCommand()
		$dbCmd1.CommandTimeout = 0

		$dbCmd1.CommandText = "	 DECLARE @ERRORMSG Varchar(500)
		Select @ERRORMSG = EventDescription  from DataFeeds..vSSISImportEventLog EL JOIN DataFeeds..vRefDataSet R ON R.RefDatasetID = EL.RefDataSetID 
		wheRE R.Label = 'RegressionTest Excel'  AND R.RefDataSetID > "+$RefDataSetID+"
			SELECT @ERRORMSG AS ERRROMSG "
			$SSISEXCEPTIONMessage = $dbCmd1.ExecuteScalar().ToString()
			
			$Excel_Error_Message = $Excel_Error_Message +" <br> " +$SSISEXCEPTIONMessage 
				Write-Output " ################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ISSUe with excel connectivity from ssis `r`n  $SSISEXCEPTIONMessage `r`n " | Out-File $LogFile -Append 	
		}
	}
	
	$dbConn.Close()
$Excel_ServiceStatus = "N/A"
$Excel_ServiceStatus
	
	
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Script Adapter Service Test Completed : `r`n FileInArchive =  $FileInArchive `r`n  SA_Message = $SA_Message `r`n sc_Error_Message = $sc_Error_Message `r`n " |   Out-File $LogFile -Append

[Boolean]$AllSuccess = $false 
If ($FileInDeliveryStore -eq 1 -and $FileInArchive -eq 1 -and $FileInSFTP -eq 1 -and $FileInWSOOnDemand -eq 1 -and $FileDownloadEmailAdapter -eq 1 -and $ExcelConnectivity -eq 1)
{
	 fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel $RefDataSetLabel -rdsStatusCode "P" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	$AllSuccess = $true
}
else
{ 
	fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel $RefDataSetLabel -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	$AllSuccess = $false
}

$body = "<html>
				<head>
					<style type=""text/css"">
					.style H1
					{
						font-size: 15px;
						font-weight: bold;
						font-family: calibri;
					}
					.style table
					{
						border-collapse: collapse;
						border-spacing: 0;
						width: 100%;
						margin: 0px;
						padding: 0px;
					}
					.style p
			        {
			            font-size: 15px;
			            font-family: calibri;
			            font-weight: bold;
			            border-bottom: 3px solid #3B3131;
			        }
					.style tr:hover th
					{
						background-color: #c9c1c1;
					}
					.style th
					{
						vertical-align: middle;
						border: 1px solid #000000;
						border-width: 0px 1px 1px 0px;
						text-align: left;
						padding: 7px;
						font-size: 12px;
						font-weight: bold;
						font-family: calibri;
						border-width: 0px 1px 0px 0px;
						border: 1px solid #000000;
						background-color: #cccccc;
					}
					.style td
					{
						vertical-align: middle;
						border: 1px solid #000000;
						border-width: 0px 1px 1px 0px;
						padding: 7px;
						font-size: 13px;
						font-family: calibri;
						font-weight: normal;
						border-width: 0px 1px 0px 0px;
						border: 1px solid #000000;
					}
					.style1
					{
						background-color: #00FF00;
						width: 80px;
					}
					.style2
					{
						background-color: #FF0000;
						width: 80px;
						text-align: right ;
					}
					.FailureCell
                    {
                    background-color: #FF0000;
                    font-weight: bold;
                    }
				</style>
			</head>
			<body><div class=""style"">"
			
$ServiceList = "Notification","Delivery","Receivce","Script Adapter"
#if($FileInDeliveryStore -eq 1) {"Success"} else {"Failure"}
#if($FileInArchive -eq 1) {"Success"} else {"Failure"}
#$DS_Error_Message.ToString()

 $Ns_ServiceStatus = $Ns_ServiceStatus[0]
  $RS_ServiceStatus = $RS_ServiceStatus[0]
  $DS_ServiceStatus = $DS_ServiceStatus[0]
  $SA_ServiceStatus = $SA_ServiceStatus[0]
  $WSO_ServiceStatus = $WSO_ServiceStatus[0]
  
#If ($FileInDeliveryStore -eq 1 -and $FileInArchive -eq 1 -and $FileInSFTP -eq 1)

$HTML = (@{$true="
<table style =""width100%""> 
            <tr> 
                <th>PrimaryOwner</th>
				<th>SecondryOwner</th>
			</tr>
              <tr>
                 <td>masim</td>
				 <td>BLeValley</td>
              </tr>
</table>
";$false=""}[$AllSuccess -ne $true ])+"
<br>
<br>
    <table style =""width100%""> 
            <tr> 
                <th>Service Name</th>
				 <th>Service Status</th>
				<th>Job ID</th>
                <th>Job Name</th>
                <th>Test Status</th>
                <th>Note</th>
                <th>Error Message</th>
              </tr>
              <tr>
                    <td><a href=""http://admintools.hcmlp.com/ReportSubscription"">Notification</a></td>
					<td  "+ (@{$false="Class=""FailureCell"""}[$Ns_ServiceStatus -eq "Running"]) +">"+$Ns_ServiceStatus+"</td>
					<td>2395</td>
                    <td>RegressionTest_Mail_Notification</td>
                    <td "+ (@{$false="Class=""FailureCell"""}[$NsResult -eq "Success"]) +">"+$NsResult+"</td>
                    <td>An Email Should sent out to <b>Data.In@hcmlp.com</b> with Email Subject: <b>Highland - Regression Test - Report Subscription - EMail Notification Service </b> </td>
                    <td>"+$NsError+"</td>
               </tr>
               <tr>
                    <td><a href=""http://admintools.hcmlp.com/ReportSubscription"">Delivery</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$DS_ServiceStatus -eq "Running"]) +">"+$DS_ServiceStatus+"</td>
                    <td>2446</td>
                    <td>RegressionTest_Delivery_Service</td>
                    <td "+ (@{$false="Class=""FailureCell"""}[$FileInSFTP -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$FileInSFTP -eq 1])+"</td>
                    <td>$DS_Message</td>
                    <td>$DS_Error_Message</td>
                </tr>
                <tr>
                    <td><a href=""http://admintools.hcmlp.com/ReportSubscription"">Receive</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$RS_ServiceStatus -eq "Running"]) +">"+$RS_ServiceStatus+"</td>
                    <td>2447</td>
                    <td>RegressionTest_Receive_Service</td>
                    <td "+ (@{$false="Class=""FailureCell"""}[$FileInDeliveryStore -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$FileInDeliveryStore -eq 1])+"</td>
                    <td>$RS_Message</td>
                    <td>$Rs_Error_Message</td>
                </tr>
                <tr>
                    <td><a href=""http://admintools.hcmlp.com/ScriptAdapter"">Script Adapter</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$SA_ServiceStatus -eq "Running"]) +">"+$SA_ServiceStatus+"</td>
                    <td>291</td>
                    <td>RegressionTest_ScriptAdapter</td>                                        
                    <td  "+ (@{$false="Class=""FailureCell"""}[$FileInArchive -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$FileInArchive -eq 1])+"</td>
                    <td>$SA_Message</td>
                    <td>$sc_Error_Message</td>
                 </tr>
				 <tr>
                    <td><a href=""http://portal.hcmlp.com/administration/WSOReportingOnDemand"">WSO Adapter</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$WSO_ServiceStatus -eq "Running"]) +">"+$WSO_ServiceStatus+"</td>
					<td>2500</td>
                    <td>RegressionTest_WSOAdapter</td> 
					<td "+ (@{$false="Class=""FailureCell"""}[$FileInWSOOnDemand -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$FileInWSOOnDemand -eq 1])+"</td>
                    <td>$WSOAdapter_Message</td>
                    <td>$WSOAdapter_Error_Message</td>
                 </tr>
				  <tr>
                    <td><a href=""http://admintools.hcmlp.com/ReportSubscription"">EMail Adapter</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$EMailAdapter_ServiceStatus -eq "Running"]) +">"+$EMailAdapter_ServiceStatus+"</td>
                    <td>2395</td>
                    <td>RegressionTest_EMailAdapter</td>                                        
                    <td "+ (@{$false="Class=""FailureCell"""}[$FileDownloadEmailAdapter -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$FileDownloadEmailAdapter -eq 1])+"</td>
                    <td>$EMailAdapter_Message</td>
                    <td>$EMailAdapter_Error_Message</td>
                 </tr>
				   <tr>
                    <td><a href=""http://admintools.hcmlp.com/ReportSubscription"">Excel</a></td>
					<td "+ (@{$false="Class=""FailureCell"""}[$Excel_ServiceStatus -eq "N/A"]) +">"+$Excel_ServiceStatus+"</td>
                    <td>N/A</td>
                    <td>RegressionTest_ExcelConnectivity</td>                                        
                    <td "+ (@{$false="Class=""FailureCell"""}[$ExcelConnectivity -eq 1]) +">"+(@{$true="Success";$false="<b>Failure</b>"}[$ExcelConnectivity -eq 1])+"</td>
                    <td>$Excel_Message</td>
                    <td>$Excel_Error_Message</td>
                 </tr>
				 
</table>
<br>
<br>
<p><h6>Job which is kicking off this report:: RSID : 2448; Name :<a href=""http://admintools.hcmlp.com/ReportSubscription"">Process_JobServices_Test</a> <br> 
"+(@{$true="<br>!!AssignTo:masim!!<br>!!AssignTo:BLeValley!!<br>!!Company:HCMLP!!<br>!!Contact:defaultcontact@hcmlp.com!! ";$false=""}[$AllSuccess -ne $true ])+"</h6> </p>"

#<p>Note: Configuring beta version, please contact rkari@siepe.com; if you have suggestions/concerns.</p>

$body = $body +$HTML

$smtpserver = "email-smtp.us-east-1.amazonaws.com"
# SES Credentials
$smtpUserName = "AKIAIUBARKKYHWSVB3TA"
$smtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force)
$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword))
$EmailFrom = "help@siepe.com"



Function Send-Mail{
[cmdletbinding()]
Param (
[string[]]$To,
[string]$From,
[string]$SmtpServer = "email-smtp.us-east-1.amazonaws.com",
[string]$SmtpUsername = "AKIAIUBARKKYHWSVB3TA",
$SmtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force),
[string]$Subject = "Subject",
[string]$Body = "Body",
$EmailTimeOut = 240,
$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword)),
[bool]$asHtml =$true
) 
# End of Parameters
    
    Send-MailMessage -SmtpServer $SmtpServer -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -port 587 -UseSsl -credential $Credential -Priority $MailPriority
}


$MailPriority = "Low"
if ($AllSuccess -eq $true){
	#[string[]]$EmailTo = "rkari@siepe.com"
	[string[]]$EmailTo = "All-Offshore@siepe.com","pjaiswal@siepe.com","rrutledge@siepe.com";
	#$EmailTo = "nkumar@siepe.com;masim@siepe.com;myadav@siepe.com;rkari@siepe.com;hgupta@Siepe.com;pjaiswal@siepe.com;rrutledge@siepe.com;"
	$subject = "Highland - Job Tools/Services Test - Success"
}else {
	$EmailTo =  "help@siepe.com" , "rkari@siepe.com" ,"BLeValley@siepe.com","pjaiswal@siepe.com","All-Highland@siepe.com"
	#$EmailTo = "rkari@siepe.com"
	$subject = "Highland - Job Tools/Services Test - Fail"
	$MailPriority = "High"
	#Send-Mail -To "help@siepe.com" -From $EmailFrom -SmtpServer $smtpserver -SmtpUsername $smtpUserName -SmtpPassword $smtpPassword -Subject $subject -Body "!!AssignTo:masim!!<br>!!AssignTo:PJaiswal!!<br>!!Company:HCMLP!!<br>!!Contact:defaultcontact@hcmlp.com!!" -EmailTimeOut $EmailTimeOut -Credential $Credential
	
}


  Send-Mail -To $EmailTo -From $EmailFrom -SmtpServer $smtpserver -SmtpUsername $smtpUserName -SmtpPassword $smtpPassword -Subject $subject -Body $Body -EmailTimeOut $EmailTimeOut -Credential $Credential

#Send-MailMessage -SmtpServer  "mail.hcmlp.com" -From  "help@siepe.com" -To $EmailTo -Subject $Subject -Body $Body  -Priority $MailPriority -BodyAsHtml
<#
 #Init Mail address objects
[string] $smtpServer  = "mail.hcmlp.com"; 
[string] $sender      = "ITDevelopment@hcmlp.com"; 
[string] $receiver    = "rkari@siepe.com";   
[bool]   $asHtml      = $true; 
[string] $subject     = "HCM:VM User logged in list"; 


$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 


#$body= $emailBody
$subject = "Regression Test"

$smtpClient.UseDefaultCredentials = $false
$smtpClient.Credentials = New-Object System.Net.NetworkCredential("Relay.Account", "R3layacct");

$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
$mailMsg.To.Add("rkari@siepe.com")
$mailMsg.IsBodyHtml = $asHtml; 
$smtpClient.Send($mailMsg)
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
