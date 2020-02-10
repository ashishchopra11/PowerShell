. d:\Siepe\Data\Scripts\PROD\FortyActHelperFunctions.ps1
$smtpServer="mail.hcmlp.com"
$fromAddress = "intranet@hcmlp.com"
$logfile="D:\Siepe\Data\Scripts\FortyActMonitoring\FortyActMonitoring.log"
Try
{

    	$toList = $highlandToList
		$ccList = $highlandCCList
		$fundName="All"
		$date = get-date -format ("MM/dd/yyyy")
		$subject= "Daily 1940 Act Monitoring for " + $date
		Invoke-FortyAct -preliminary "false" -fallback "true" -env "production" -schedule "Late"

}
Catch [system.exception]
{
	log-item $logfile "failed final HFA monitoring"
	
	$ErrorMessage = $_.Exception.Message
	log-item $logfile $ErrorMessage
    
    Send-MailMessage -SmtpServer $smtpServer -From $fromAddress -To "pelliott@hcmlp.com" -Subject "Final HFA Warning Failed" -Body $ErrorMessage
}