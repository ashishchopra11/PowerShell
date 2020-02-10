############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\InstBetaHistoricalCalc."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$curr_date = Get-Date 

if ($curr_date.DayOfWeek -eq "Sunday") {
    $process_days_list = ($curr_date).AddDays(-2)
} elseif ($curr_date.DayOfWeek -eq "Monday") {
    $process_days_list = ($curr_date).AddDays(-3)
} elseif ($curr_date.DayOfWeek -eq "Tuesday") {
  ## Load Saturday, Sunday, and Monday on Tuesday morning ...
  $process_days_list = ($curr_date).AddDays(-3),($curr_date).AddDays(-2),($curr_date).AddDays(-1)
} else {
  $process_days_list = ($curr_date).AddDays(-1)
}
Write-Output " process_days_list : `n $process_days_list" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Inst Beta Historical Calc starts here " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append

$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=HCM;Database=HCM;Integrated Security=SSPI;"
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0


$process_days_list | Sort-Object | ForEach-Object -Process {

	$process_date = $_
	$FullDayString = $process_date.ToShortDateString()
	

	######### Creating DataSet ##############
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet"
	$dbCmd.CommandText = "EXEC HCM.dbo.pRefDataSetIU	@RefDataSetID		= 0 ,	@RefDataSetDate	    = '" +$FullDayString +"' ,	@RefDataSetType		= 'InstCalc' ,	@RefDataSource		= 'UNKNOWN' ,	@Label				= 'InstBetaHistorical'" 
	$dbCmd.ExecuteScalar()	
	
	######## Get RefDataSetID ###########
	$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID FROM  HCM.dbo.vRefDataSet WHERE RefDataSetDate = '" +$FullDayString +"' AND RefDataSetType = 'InstCalc' AND RefDataSource = 'UNKNOWN' AND Label = 'InstBetaHistorical' ORDER BY 1 DESC"
	$RefDataSetID = $dbCmd.ExecuteScalar()	
	
	##################### Load Data for InstValueTypeID = 12 #####################
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: InstCalc.pInstBetaHistorical  `r`n Arguments passed here are : `r`n  @InstValueTypeID = 12 `r`n @CalcDate = $FullDayString `r`n" | Out-File $LogFile -Append
	$dbCmd.CommandText = "EXEC InstCalc.pInstBetaHistorical @InstValueTypeID = 12, @CalcDate = '" + $FullDayString + "'" #S&P 500
	$dbCmd.ExecuteScalar()

    ##################### Load Data for InstValueTypeID = 14 #####################
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: InstCalc.pInstBetaHistorical  `r`n Arguments passed here are : `r`n  @InstValueTypeID = 14 `r`n @CalcDate = $FullDayString `r`n" | Out-File $LogFile -Append
	$dbCmd.CommandText = "EXEC InstCalc.pInstBetaHistorical @InstValueTypeID = 14, @CalcDate = '" + $FullDayString + "'" #CS HY
	$dbCmd.ExecuteScalar() 

    ##################### Load Data for InstValueTypeID = 15 #####################
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: InstCalc.pInstBetaHistorical  r`n Arguments passed here are : `r`n  @InstValueTypeID = 15 `r`n @CalcDate = $FullDayString `r`n" | Out-File $LogFile -Append
	$dbCmd.CommandText = "EXEC InstCalc.pInstBetaHistorical @InstValueTypeID = 15, @CalcDate = '" + $FullDayString + "'" #CS LL
	$dbCmd.ExecuteScalar() 
	
	######## Set Status of RefDataSet Record ###########

	$dbCmd.CommandText = "SELECT COUNT(*) FROM HCM.InstCalc.tInstValue WHERE InstValueTypeID = 12 AND ValueDate = '" +$FullDayString +"'"
	$CountSP = $dbCmd.ExecuteScalar()
	
		
	$dbCmd.CommandText = "SELECT COUNT(*) FROM HCM.InstCalc.tInstValue WHERE InstValueTypeID = 14 AND ValueDate ='" +$FullDayString +"'"
	$CountCSHY = $dbCmd.ExecuteScalar()
	
		
	$dbCmd.CommandText = "SELECT COUNT(*) FROM HCM.InstCalc.tInstValue WHERE InstValueTypeID = 15 AND ValueDate ='" +$FullDayString +"'"
	$CountCSLL = $dbCmd.ExecuteScalar()
	
	if($CountSP -gt 0 -and $CountCSHY -gt 0 -and $CountCSLL -gt 0)
	{$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'InstCalc' , 	@RefDataSource		= 'UNKNOWN' ,	@Label		= 'InstBetaHistorical',	@StatusCode         = 'P'"
	$dbCmd.ExecuteScalar()
	}
	else
	{
	$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'InstCalc' , 	@RefDataSource		= 'UNKNOWN' ,	@Label		= 'InstBetaHistorical',	@StatusCode         = 'F'"
	$dbCmd.ExecuteScalar()
	}
	
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Closing the Connection:: " | Out-File $LogFile -Append

$dbCmd.Dispose()
$dbConn.Close()
$dbConn.Dispose()

Remove-Variable dbCmd
Remove-Variable dbConn

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append