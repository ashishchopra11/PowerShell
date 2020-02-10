. d:\Siepe\Data\Scripts\PROD\WebHelperFunctions.ps1
$logfile="D:\Siepe\Data\Scripts\TrusteeRecEmail\Monitoring.log"

$RefDataSetdate = (Get-Date).ToShortDateString()
	

$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=HCM;Database=HCM;Integrated Security=SSPI;"
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0


Try
{
	################## Create dataSet ####################
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet"
		$dbCmd.CommandText = "EXEC HCM.dbo.pRefDataSetIU	
								@RefDataSetID		= 0 ,	
								@RefDataSetDate	    = '" +$RefDataSetdate +"' ,	
								@RefDataSetType		= 'Report' ,	
								@RefDataSource		= 'Highland' ,	
								@Label	= 'Trustee Inconsistent Overrides Email'" 
		$dbCmd.ExecuteScalar()
		
		######## Get RefDataSetID ###########
		$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID 
							FROM  HCM.dbo.vRefDataSet 
							WHERE RefDataSetDate = '" +$RefDataSetdate +"'
							AND RefDataSetType = 'Report' 
							AND RefDataSource = 'Highland' 
							AND Label = 'Trustee Inconsistent Overrides Email' ORDER BY 1 DESC"
		$RefDataSetID = $dbCmd.ExecuteScalar()	
		
		log-item $logfile "Calling Web Endpoint"
		Invoke-Web -env "production"
		log-item $logfile "Finished Sending Inconsistent Overrides Email"
		
		################## Update dataSet to pass ####################
		$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	
								@RefDataSetID		= " +$RefDataSetID +" , 	
								@RefDataSetDate	    = '" +$RefDataSetdate +"' , 	
								@RefDataSetType		= 'Report' , 	
								@RefDataSource		= 'Highland' ,	
								@Label		= 'Trustee Inconsistent Overrides Email',	
								@StatusCode         = 'P'"
		$dbCmd.ExecuteScalar()
}
Catch [system.exception]
{
	
	################## Update dataSet to fail ####################
		$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	
								@RefDataSetID		= " +$RefDataSetID +" , 	
								@RefDataSetDate	    = '" +$RefDataSetdate +"' , 	
								@RefDataSetType		= 'Report' , 	
								@RefDataSource		= 'Highland' ,	
								@Label		= 'Trustee Inconsistent Overrides Email',	
								@StatusCode         = 'F'"
		$dbCmd.ExecuteScalar()
		
	log-item $logfile "failed SendingInconsistent Overrides Email"
	
	$ErrorMessage = $_.Exception.Message
	log-item $logfile $ErrorMessage
}
$dbconn.Close() 