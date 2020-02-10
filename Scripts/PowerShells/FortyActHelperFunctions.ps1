$highlandToList = "cstoops@hcmlp.com;wmabry@hcmlp.com;jpalmer@hcmlp.com;"
$highlandCCList = "etsimberg@hcmlp.com;pelliott@hcmlp.com;"

function Invoke-FortyAct([string] $preliminary, [string] $fallback, [string] $env, [string] $schedule){
	$portalEndpoints = @{"production" = "portal"; "development" = "betaportal"}
	$endpoint = $portalEndpoints.get_Item($env)
	$date = get-date -format ("MM/dd/yyyy")
	$uri = "http://" + $endpoint + ".hcmlp.com/HFACompliance/api/Tests/Alerts/DailyMonitoring?isPreliminary=" + $preliminary + "&isFallback=" + $fallback +"&schedule=" + $schedule
	echo $uri
	Invoke-WebRequest -Method POST -Uri $uri -UseDefaultCredentials -UseBasicParsing
	
}

function executeStoredProc([string] $procName,[hashtable] $params, [string] $env){
  $connections = @{"production" = "PHCMDB01"; "development" = "DHCMDB01"}
  $conn = $connections.get_Item($env)
  $argList = "Data Source=" + $conn + ";Initial Catalog=HCM;Database=HCM;Integrated Security=SSPI;"
  
  $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $argList
  $dbconn.Open()
  $dbCmd = $dbConn.CreateCommand()
  $dbCmd.CommandTimeout = 0
  
  $dbCmd.CommandText  = $procName
  $dbCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
  if($params){
  	foreach($p in $params.GetEnumerator()){
		$dbCmd.Parameters.AddWithValue($p.Name, [string]$p.Value)
	}
  }
  
  $returnData = $dbCmd.ExecuteScalar()
  $dbCmd.Dispose()
  $dbConn.Close()
  $dbConn.Dispose()

  Remove-Variable dbCmd
  Remove-Variable dbConn
  
  return $returnData
}

function log-item([string] $logfile, [string]$logMessage){
	$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
	$logText = $LogTime + " " + $logMessage
	Add-Content $logfile $logText
}