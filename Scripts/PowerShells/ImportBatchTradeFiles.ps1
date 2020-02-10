############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fRefDataSetIU.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\SeiIboxxETF."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hsh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


##----------------------------------------------------- 
##----  Import Daily File
##----------------------------------------------------- 
#$process_date = Get-Date
$process_date = Get-Datesss
#$runDate = $process_date.AddDays(-1)
#$FileDate = $runDate.ToString("yyyyMMdd"

#$DeliveryService = "D:\Siepe\Applications\Services\Production\Delivery\Hcmlp.Shared.Service.Delivery.DeliveryTool.exe" 
#$fileready = 0
$download_dir = "$dirServicesDeliveryStoreFolder\AIM Batch Trade File\" 

#$download_dir = "C:\AMishra\" 

foreach ($strFileName in Get-ChildItem -Path $download_dir | Where-Object {$_.Name -ilike "*.xml*"})
     {
           $FileName = "$strFileName"
           $FileName = $FileName -Replace ".xml", ""
           $runDate = $FileName.split('.')[2]
            #$runDate = $FileName.split('-')[0]
           $LabelHoldings = $FileName -Replace ("." + $runDate),""
           $runDate = [datetime]::parseexact($runDate, 'yyMMdd', $null)
           $FileDate = $runDate.ToString("yyyyMMdd")
     

$ArchiveDirDayString  = $FileDate 
 
#$download_dir = "D:\Siepe\DataFeeds\SEI\"  ###TEST
#$dirDataFeedsArchiveFolder = "\\hcm97\PMPDataFeeds"


#$dirDataFeedsArchiveFolder = "D:\Siepe\DataFeeds"
##Set download directory
#$file_name_Holdings = $FileDate + "_ETF_Pyxis_holdings.xml"


$file_name_Holdings = $FileName +".xml"
#$file_name_Holdings = $FileDate + $FileName +".xml"

$downloadHoldings = $download_dir + $file_name_Holdings ###SEI Holdings

##Set Datafeeds directoyr

#$fileHoldings = $file_dir + $file_name_Holdings

$fileHoldings = $downloadHoldings

$file_dir_Archive = "$dirArchiveHCM97DriveFolder\AIM Batch Trade File\"

##Archive Directory
$filearchiveHoldings = $file_dir_Archive + $file_name_Holdings

Write-Output " process_date                = $process_date" |  Out-File $LogFile -Append
Write-Output " FileDate                          = $FileDate" |  Out-File $LogFile -Append
Write-Output " ArchiveDirDayString         = $ArchiveDirDayString" |  Out-File $LogFile -Append
Write-Output " DeliveryService             = $DeliveryService" |  Out-File $LogFile -Append
Write-Output " download_dir                = $download_dir" |  Out-File $LogFile -Append
Write-Output " downloadHoldings            = $downloadHoldings" |  Out-File $LogFile -Append
    
       $ServerName = "PHCMDB01"  
 
### Set varaibles here

$date_string = Get-Date -Date $runDate -UFormat %x 

$RefDataSourceID = "31"
$RefDataSource = "Bloomberg AIM"
$rdsserverName = "PHCMDB01"
$rdsdatabaseName = "datafeeds"
$RefDataSetDate = $date_string

$RefDatasetTypeHoldings = "Trade"
#$LabelHoldings = "ETF Pyxis holdings"
$LabelHoldings 


### call fRefDataSetID function to get a RefDataSetID
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
     $RefDataSetIDHoldings=fRefDataSetIU 0 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings "I" $date_string $rdsserverName
     $RefDataSetIDHoldings2 = $RefDataSetIDHoldings
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDHoldings2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Reading the XML file into a variable " | Out-File $LogFile -Append
### Read in your XML file into a variable
      #$XMLContents=Get-Content $FilePath 
       $XMLContentsHoldings=Get-Content $fileHoldings 
       $fileHoldings  
       #$XMLContentsHoldings

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating SQL Statement " | Out-File $LogFile -Append
### Create your insert statement
      $SQL  = "insert into datafeeds.AIM.tBatchTradeFile(RefDataSetID, XmlDoc) values ("+$RefDataSetIDHoldings+",'"+$XMLContentsHoldings+"')"

       #$SQL  = "insert into datafeeds.AIM.tBatchTradeFile(RefDataSetID, XmlDoc) values (1018412,'"+$XMLContentsHoldings+"')"
      
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating connection :: $ServerName" | Out-File $LogFile -Append
### make database connection
      $ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
      $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
      $dbconn.Open()
      $dbCmd = $dbConn.CreateCommand()
      $dbCmd.CommandTimeout = 0
       

### Execute $SQL
      $dbCmd.CommandText      = $SQL
      
#     $RefDataSetId           = $dbCmd.ExecuteScalar()

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDHoldings " | Out-File $LogFile -Append
     $RefDataSetIDHoldings       = $dbCmd.ExecuteScalar()


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Closing connection :: $ServerName" | Out-File $LogFile -Append
### close the connection
      $dbCmd.Dispose()
      $dbConn.Close()
      $dbConn.Dispose()

### cleanup
      Remove-Variable dbCmd
      Remove-Variable dbConn

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: calling fRefDataSetIU with Pass Status" | Out-File $LogFile -Append
#### IF successful to this point
#### call fRefDataSetIU with Pass Status 
$RefDataSetIDHoldings2=fRefDataSetIU $RefDataSetIDHoldings2 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings "P" $date_string $rdsserverName
     
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
      
##Archive
Move-Item -path "$fileHoldings" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileHoldings ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append
}