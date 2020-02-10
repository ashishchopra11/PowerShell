##################################################################
##	
##	BloombergPushPricesToGeneva.ps1
##	Push Bloomberg EOD Prices to Geneva
##	
##################################################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
####################################################################################

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

##LogFile
#$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\BloombergBackOfice.BloombergPushPricesToGeneva."+$strDateNow+".txt"

param(
[String]$LogFile 

)

If ($LogFile -eq $null)
{
##LogFile
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$LogFile = "$dirLogFolder\BloombergBackOfice.BloombergPushPricesToGeneva.$LogTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$GV_PRD_WFM_DIR = "\\PHCMGVAPP01\input"

$process_date = Get-Date #"07/07/2015"

## 10/12/2007
$FullDayString = $process_date.ToShortDateString()

Write-Output " $GV_PRD_WFM_DIR`t`t`t= $GV_PRD_WFM_DIR" |  Out-File $LogFile -Append
Write-Output " FullDayString`t`t`t= $FullDayString" |  Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Bloomberg Push Prices To Geneva starts here " | Out-File $LogFile -Append

# Push prices to Geneva ...
$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0

$str_Date = $process_date.ToString("yyyyMMdd")

################## Create dataSet ####################
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet"
	$dbCmd.CommandText = "EXEC DataFeeds.dbo.pRefDataSetIU	@RefDataSetID		= 0 ,	@RefDataSetDate	    = '" +$FullDayString +"' ,	@RefDataSetType		= 'Geneva Prices' ,	@RefDataSource		= 'Advent Geneva' ,	@Label				= 'GenevaPricesXMLCreation'" 
	$dbCmd.ExecuteScalar()

	######## Get RefDataSetID ###########
	$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID FROM  DataFeeds.dbo.vRefDataSet WHERE RefDataSetDate = '" +$FullDayString +"' AND RefDataSetType = 'Geneva Prices' AND RefDataSource = 'Advent Geneva' AND Label = 'GenevaPricesXMLCreation' ORDER BY 1 DESC"
	$RefDataSetID = $dbCmd.ExecuteScalar()	
	
# Send Geneva-loadable Prices XML to Geneva	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing SQL:: SELECT Geneva.fPriceXML('" + $FullDayString + "') " | Out-File $LogFile -Append

$dbCmd.CommandText = "SELECT Geneva.fPriceXML('" + $FullDayString + "')"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Bloomberg Push Prices To Geneva :: Generating XML File ( $GV_PRD_WFM_DIR\Prices.$str_Date.xml ) " | Out-File $LogFile -Append

[String] $StartTime = (Get-Date) -f "yyyy-MM-dd hh:mm:ss"

$dbCmd.ExecuteScalar() | Out-File -FilePath "$GV_PRD_WFM_DIR\Prices.$str_Date.xml"

Sleep -Seconds 45

[String] $EndTime = (Get-Date) -f "yyyy-MM-dd hh:mm:ss"



################## Check the status for generated XML ############################

$dbConn1 = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMGVAPP01;Initial Catalog=SiepeGeneva;Database=SiepeGeneva;Integrated Security=SSPI;"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMGVAPP01" | Out-File $LogFile -Append
$dbconn1.Open()
$dbCmd1 = $dbConn1.CreateCommand()
$dbCmd1.CommandTimeout = 0


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Input parameter : str_Date : $str_Date; StartTime : $StartTime; EndTime : $EndTime" | Out-File $LogFile -Append

$Command = "SELECT 1 FROM SiepeGeneva.dbo.vGenevaActivityRun WHERE Source = 'C:\INPUT\Prices."+ $str_Date +".xml'
AND [StatusCode] IN ('n','e') AND [StartDateTime] BETWEEN '"+ $StartTime + "' AND '"+$EndTime + "'"


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SQL Query : $Command " | Out-File $LogFile -Append

$dbCmd1.CommandText = $Command

$Data=$null

$Data = $dbCmd1.ExecuteScalar()

$StartTime | Out-File $LogFile -Append
$EndTime | Out-File $LogFile -Append
$Data | Out-File $LogFile -Append

################################### Update Status of DataSet ##################################################

IF($Data -eq $null)
{
$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'Geneva Prices' , 	@RefDataSource		= 'Advent Geneva' ,	@Label		= 'GenevaPricesXMLCreation',	@StatusCode         = 'F'"
	$dbCmd.ExecuteScalar()
}
ELSE
{
$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$FullDayString +"' , 	@RefDataSetType		= 'Geneva Prices' , 	@RefDataSource		= 'Advent Geneva' ,	@Label		= 'GenevaPricesXMLCreation',	@StatusCode         = 'P'"
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

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

#Write-PubSub -Subject "Process.Geneva.Daily.Upload.BloombergPricesTwo" -Title "Complete - next Upload FX Rates" -Description "Complete - next Upload FX Rates"
