. d:\Siepe\Data\Scripts\PROD\FortyActHelperFunctions.ps1
$smtpServer="mail.hcmlp.com"
$fromAddress = "intranet@hcmlp.com"
$logfile="D:\Siepe\Data\Scripts\FortyActMonitoring\FortyActMonitoring.log"
Try
{
	log-item $logfile "starting preliminary HFA monitoring"
	
       $toList = "wmabry@hcmlp.com;pelliott@hcmlp.com;etsimberg@hcmlp.com;"
	$ccList = ";"
	$fundName="All"
	$date = get-date -format ("MM/dd/yyyy")
	$subject= "Daily 1940 Act Monitoring for " + $date
	Invoke-FortyAct -preliminary "true" -fallback "false" -env "production" -schedule "Late"

	log-item $logfile "finished preliminary HFA monitoring"
}
Catch [system.exception]
{
	log-item $logfile "failed preliminary HFA monitoring"
	
	$ErrorMessage = $_.Exception.Message
	log-item $logfile $ErrorMessage
    
    Send-MailMessage -SmtpServer $smtpServer -From $fromAddress -To "etsimberg@hcmlp.com;pelliott@hcmlp.com" -Subject "Preliminary HFA Warning Failed" -Body $ErrorMessage
}