. d:\Siepe\Data\Scripts\PROD\WebHelperFunctions.ps1
$logfile="D:\Siepe\Data\Scripts\TrusteeRecEmail\Monitoring.log"
Try
{
	log-item $logfile "Calling Web Endpoint"
	Invoke-Bulk -prelim "false"
	log-item $logfile "Finished Sending Early Trustee Rec Email"
}
Catch [system.exception]
{
	log-item $logfile "failed Sending Early Trustee Rec Email"
	
	$ErrorMessage = $_.Exception.Message
	log-item $logfile $ErrorMessage
}