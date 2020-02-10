############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################
	## Log File Creation
	#$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
	#$LogFile = "$dirLogFolder\UploadGenevaBBCAXCashDiv.$logTime.txt" 
	
	param(
[String]$LogFile 

)

If ($LogFile -eq $null)
{
##LogFile
$LogTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$LogFile = "$dirLogFolder\UploadGenevaBBCAXCashDiv.$LogTime.txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$LogTime+".txt" 
}
	
	New-Variable curr_date
	$curr_date = Get-Date
	$FullDayString = $curr_date.ToShortDateString()
	$str_Date = $curr_date.ToString("yyyyMMdd")

	$GV_PRD_WFM_DIR		= "\\PHCMGVAPP01\input"
	
	# Push FXRates to Geneva ...
	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
	$dbconn.Open()
	$dbCmd = $dbConn.CreateCommand()
	$dbCmd.CommandTimeout = 0
	
	################## Create dataSet ####################
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet"
	$dbCmd.CommandText = "EXEC DataFeeds.dbo.pRefDataSetIU	@RefDataSetID		= 0 ,	@RefDataSetDate	    = '" +$FullDayString +"' ,	@RefDataSetType		= 'Geneva Equities' ,	@RefDataSource		= 'Advent Geneva' ,	@Label				= 'GenevaCashDivXMLCreation'" 
	$dbCmd.ExecuteScalar()

	######## Get RefDataSetID ###########
	$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID FROM  DataFeeds.dbo.vRefDataSet WHERE RefDataSetDate = '" +$FullDayString +"' AND RefDataSetType = 'Geneva Equities' AND RefDataSource = 'Advent Geneva' AND Label = 'GenevaCashDivXMLCreation' ORDER BY 1 DESC"
	$RefDataSetID = $dbCmd.ExecuteScalar()	
	
	
	# Send Geneva-loadable FXRates XML to Geneva
	$dbCmd.CommandText = "EXEC Geneva.pExportBBCAXCashDiv @RefDataSetDate = '$FullDayString'"
	
	[String] $StartTime = (Get-Date) -f "yyyy-MM-dd hh:mm:ss"
	
	$dbCmd.ExecuteScalar() | Out-File -FilePath "$GV_PRD_WFM_DIR\CAXCashDiv.$str_Date.xml"
	
	Sleep -Seconds 15

[String] $EndTime = (Get-Date) -f "yyyy-MM-dd hh:mm:ss"

################## Check the status for generated XML ############################

$dbConn1 = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMGVAPP01;Initial Catalog=SiepeGeneva;Database=SiepeGeneva;Integrated Security=SSPI;"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMGVAPP01" | Out-File $LogFile -Append
$dbconn1.Open()
$dbCmd1 = $dbConn1.CreateCommand()
$dbCmd1.CommandTimeout = 0

$dbCmd1.CommandText = "SELECT 1 FROM dbo.vGenevaActivityRun WHERE Source = 'C:\INPUT\CAXCashDiv.$str_Date.xml'
AND [StatusCode] IN ('n','e') AND [StartDateTime] BETWEEN '"+$StartTime+"' AND '"+$EndTime+"'"

$Data = $null

$Data = $dbCmd1.ExecuteScalar()

$StartTime | Out-File $LogFile -Append
$EndTime | Out-File $LogFile -Append
$Data | Out-File $LogFile -Append

################################### Update Status of DataSet ##################################################

IF($Data -eq $null)
{
$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'Geneva Equities' , 	@RefDataSource		= 'Advent Geneva' ,	@Label		= 'GenevaCashDivXMLCreation',	@StatusCode         = 'F'"
	$dbCmd.ExecuteScalar()
}
ELSE
{
$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'Geneva Equities' , 	@RefDataSource		= 'Advent Geneva' ,	@Label		= 'GenevaCashDivXMLCreation',	@StatusCode         = 'P'"
	$dbCmd.ExecuteScalar()
}

########################################## Closing SQL Connections #########################################################
$dbCmd1.Dispose()
$dbConn1.Close()
$dbConn1.Dispose()

Remove-Variable dbCmd1
Remove-Variable dbConn1

$dbCmd.Dispose()
$dbConn.Close()
$dbConn.Dispose()

Remove-Variable dbCmd
Remove-Variable dbConn
