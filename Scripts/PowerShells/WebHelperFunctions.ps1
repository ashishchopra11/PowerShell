$highlandToList = "closurveillance@hcmlp.com;pelliott@hcmlp.com"

function Invoke-Web([string] $env){
	$portalEndpoints = @{"production" = "portal"; "development" = "betaportal"}
	$endpoint = $portalEndpoints.get_Item($env)
	$uri = "http://" + $endpoint + ".hcmlp.com/Reconciliation/api/Trustee/Email/InconsistentOverrides?daysOffset=-1&tag=Acis&toList="+ $highlandToList
	echo $uri
	Invoke-WebRequest -Method POST -Uri $uri -UseDefaultCredentials -UseBasicParsing
	
}

function Invoke-Bulk([string] $prelim){

	$uri = "http://portal.hcmlp.com/Reconciliation/api/Trustee/Email/Send?preliminary="+$prelim
	echo $uri
	Invoke-WebRequest -Method POST -Uri $uri -UseDefaultCredentials -UseBasicParsing
	
}


function log-item([string] $logfile, [string]$logMessage){
	$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
	$logText = $LogTime + " " + $logMessage
	Add-Content $logfile $logText
}