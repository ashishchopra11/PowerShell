##################################################################
##	
##	BloombergPushPricesToGeneva.ps1
##	Push Bloomberg EOD Prices to Geneva
##	
##################################################################
param([String]$LogFile = $Null , [String]$RefDataSetDate = $null)
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
####################################################################################

#Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}


If ($LogFile -eq $null)
{
##LogFile
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$logTime = $strDateNow
#$logFile = "$dirLogFolder\BloombergBackOfice.BloombergPushPricesToGeneva."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$GV_PRD_WFM_DIR = "\\HCMV12\input"
 $process_date = Get-Date  #"07/07/2015"

IF ($RefDataSetDate -eq $null)
{
## 10/12/2007
$FullDayString = $process_date.ToShortDateString()
}
ELSE{
$FullDayString = $RefDataSetDate
}

Write-Output " $GV_PRD_WFM_DIR`t`t`t= $GV_PRD_WFM_DIR" |  Out-File $LogFile -Append
Write-Output " FullDayString`t`t`t= $FullDayString" |  Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Bloomberg Push Prices To Geneva starts here " | Out-File $LogFile -Append

# Push prices to Geneva ...
# $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"

$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0

$str_Date = $process_date.ToString("yyyyMMdd")

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing SQL:: SELECT Geneva.fPriceXML('" + $FullDayString + "') " | Out-File $LogFile -Append
# Send Geneva-loadable Prices XML to Geneva
$dbCmd.CommandText = "SELECT Geneva.fPriceXML('" + $FullDayString + "')"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Bloomberg Push Prices To Geneva :: Generating XML File ( $GV_PRD_WFM_DIR\Prices.$str_Date.xml ) " | Out-File $LogFile -Append
$dbCmd.ExecuteScalar() | Out-File -FilePath "$GV_PRD_WFM_DIR\Prices.$str_Date.xml"

$dbCmd.Dispose()
$dbConn.Close()
$dbConn.Dispose()

Remove-Variable dbCmd
Remove-Variable dbConn
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

# Write-PubSub -Subject "Process.Bloomberg.Daily.ImportNormalize.BackofficeStepFour" -Title "Complete - next Extract Lookup Values" -Description "Complete - next Extract Lookup Values"
