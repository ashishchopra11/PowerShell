FUNCTION fWSOPricesToGeneva{
	Param
	{
		[datetime]$process_date
		,[string]$LogFile
	}
	
#	$ScriptName = $MyInvocation.MyCommand.Name
		IF ($ScriptName -eq $null)
	{
	$ScriptName = $MyInvocation.MyCommand.Name
	}
	ELSE 
	{$ScriptName = $ScriptName}
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
	
  $FullDayString = $process_date.ToShortDateString()
  $GV_PRD_WFM_DIR		= "\\phcmgvapp01\input"

Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
Write-Output " GV_PRD_WFM_DIR			= $GV_PRD_WFM_DIR" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOPricesToGeneva starts here " | Out-File $LogFile -Append

  Write-Output "Strat Geneva loop...."
  Write-Output $FullDayString
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append	
  ## Push prices to Geneva ...
   $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
      $dbconn.Open()
  $dbCmd = $dbConn.CreateCommand()
  $dbCmd.CommandTimeout = 0
	
  $str_Date = $process_date.ToString("yyyyMMdd")

  ## Send Geneva-loadable Prices XML to Geneva
  $dbCmd.CommandText = "SELECT Geneva.fPriceXML('" + $FullDayString + "')"
  
  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL:: SELECT Geneva.fPriceXML('`" + $FullDayString + `"') " | Out-File $LogFile -Append
  
  $dbCmd.ExecuteScalar() | Out-File -FilePath "$GV_PRD_WFM_DIR\Prices.$str_Date.xml"
  $dbCmd.Dispose()
  $dbConn.Close()
  $dbConn.Dispose()

	

  Remove-Variable dbCmd
  Remove-Variable dbConn

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOPricesToGeneva :: Starting Sleep for 120s " | Out-File $LogFile -Append
  Start-Sleep -s 120
  
  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append	
  ## Push FXRates to Geneva ...
   $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
      $dbconn.Open()
	  $dbCmd = $dbConn.CreateCommand()
  $dbCmd.CommandTimeout = 0

  ## Send Geneva-loadable FXRates XML to Geneva
  $dbCmd.CommandText = "SELECT Geneva.fFXRateXML('" + $FullDayString + "')"
  
  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL:: SELECT Geneva.fFXRateXML('`" + $FullDayString + `"') " | Out-File $LogFile -Append
  
  $dbCmd.ExecuteScalar() | Out-File -FilePath "$GV_PRD_WFM_DIR\FXRate.$str_Date.xml"

  $dbCmd.CommandText = "hcm.dbo.pReconTradeAssignCloser"
  $dbCmd.ExecuteScalar() 

  $dbCmd.Dispose()
  $dbConn.Close()
  $dbConn.Dispose()
  
  Remove-Variable dbCmd
  Remove-Variable dbConn
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
