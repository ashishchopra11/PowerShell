$logfile="D:\Siepe\Data\Scripts\FortyActMonitoring\FortyActMonitoring.log"
. d:\Siepe\Data\Scripts\PROD\FortyActHelperFunctions.ps1
Try
{	
	$smtpServer="mail.hcmlp.com"
	$fromAddress = "intranet@hcmlp.com"
	log-item $logfile "starting primary 1940 Act monitoring"
	
    $message = executeStoredProc "dbo.pDataSetInsurance" -params @{"@SqlCommand" = 'Select 1'; "@CreateDataSet" = 0; "@EnforceSingleRun" = 1; "@SingleRunRefDataSource" = 'Report Subscription'; "@SingleRunRefDataSetType" = 'Report Stop'; "@SingleRunLabel" = '1940ActMonitor'} -env "production"
	$length = $message.Length
	$commandRan = $message.get_Item($length -1)
	if($commandRan){
		$toList = $highlandToList
		$ccList = $highlandCCList
		$fundName="All"
		Invoke-FortyAct -fallback "false" -preliminary "false" -env "production" -schedule "Early"
	
		log-item $logfile "finished primary 1940 Act monitoring"
	}
	
	
}
Catch [system.exception]
{
	log-item $logfile "failed primary 1940 Act monitoring"
	
	$ErrorMessage = $_.Exception.Message
	log-item $logfile $ErrorMessage
    
    Send-MailMessage -SmtpServer $smtpServer -From $fromAddress -To "pelliott@hcmlp.com" -Subject "1940 Act Warning Failed" -Body $ErrorMessage
}