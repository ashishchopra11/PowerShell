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
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


##----------------------------------------------------- 
##----  Import Daily File
##----------------------------------------------------- 
#$process_date = Get-Date
$process_date = Get-Date
#$runDate = $process_date.AddDays(-1)
#$FileDate = $runDate.ToString("yyyyMMdd"
 
#$DeliveryService = "D:\Siepe\Applications\Services\Production\Delivery\Hcmlp.Shared.Service.Delivery.DeliveryTool.exe" 
#$fileready = 0
$download_dir = "$dirServicesDeliveryStoreFolder\SEI iBoxx ETF Performance NAV Admin Position\" 

foreach ($strFileName in Get-ChildItem	 -Path $download_dir | Where-Object {$_.Name -ilike "*ETF_Pyxis_holdings*"})
	{
		$FileName = "$strFileName"
		$FileName = $FileName -Replace ".xml", ""
		$runDate = $FileName.split('_')[0]
		$runDate = [datetime]::parseexact($runDate, 'yyyyMMdd', $null)
		$FileDate = $runDate.ToString("yyyyMMdd")
	}
 
$ArchiveDirDayString  = $FileDate 
 
#$download_dir = "D:\Siepe\DataFeeds\SEI\"  ###TEST
#$dirDataFeedsArchiveFolder = "\\hcm97\PMPDataFeeds"

#$dirDataFeedsArchiveFolder = "D:\Siepe\DataFeeds"
##Set download directory
$file_name_Holdings = $FileDate + "_ETF_Pyxis_holdings.xml"
$file_name_HoldingsCash = $FileDate + "_ETF_Pyxis_holdings_cash.xml"
$file_name_Bbdaily = $FileDate + "_ETF_Pyxis_bbdaily.xml"
$file_name_Blackbar = $FileDate + "_ETF_Pyxis_blackbar.xml"
$file_name_4Qtr = $FileDate + "_ETF_Pyxis_4_qtr_prem_disc.xml"
$file_name_LstQtr = $FileDate + "_ETF_Pyxis_lst_qtr_prem_disc.xml"
$file_name_QtrToDate = $FileDate + "_ETF_Pyxis_qtr_to_date_prem_disc.xml"

$downloadHoldings = $download_dir + $file_name_Holdings ###SEI Holdings
$downloadHoldingsCash = $download_dir + $file_name_HoldingsCash ###SEI HoldingsCash
$downloadBbdaily = $download_dir + $file_name_Bbdaily ###SEI Bbdaily
$downloadBlackbar = $download_dir + $file_name_Blackbar ###SEI Blackbar
$download4Qtr = $download_dir + $file_name_4Qtr ###SEI 4Qtr
$downloadLstQtr = $download_dir + $file_name_LstQtr ###SEI Lst Qtr
$downloadQtrToDate = $download_dir + $file_name_QtrToDate ###SEI Qtr To Date

##Set Datafeeds directoyr
#$file_dir = "$dirDataFeedsArchiveFolder\SEI\iBoxx\"  
$file_dir = $download_dir
$file_dir_Archive = "$dirDataFeedsArchiveFolder\SEI iBoxx ETF Performance NAV Admin Position\Archive\"
$fileHoldings = $file_dir + $file_name_Holdings
$fileBbdaily = $file_dir + $file_name_Bbdaily
$fileBlackbar = $file_dir + $file_name_Blackbar
$file4Qtr = $file_dir + $file_name_4Qtr
$fileLstQtr = $file_dir + $file_name_LstQtr
$fileQtrToDate = $file_dir + $file_name_QtrToDate

##Archive Directory
$filearchiveHoldings = $file_dir_Archive + $file_name_Holdings
$filearchiveBbdaily = $file_dir_Archive + $file_name_Bbdaily
$filearchiveBlackbar = $file_dir_Archive + $file_name_Blackbar
$filearchive4Qtr = $file_dir_Archive + $file_name_4Qtr
$filearchiveLstQtr = $file_dir_Archive + $file_name_LstQtr
$filearchiveQtrToDate = $file_dir_Archive + $file_name_QtrToDate

Write-Output " process_date				= $process_date" |  Out-File $LogFile -Append
Write-Output " FileDate					= $FileDate" |  Out-File $LogFile -Append
Write-Output " ArchiveDirDayString		= $ArchiveDirDayString" |  Out-File $LogFile -Append
Write-Output " DeliveryService			= $DeliveryService" |  Out-File $LogFile -Append
Write-Output " download_dir				= $download_dir" |  Out-File $LogFile -Append
Write-Output " downloadHoldings			= $downloadHoldings" |  Out-File $LogFile -Append
Write-Output " downloadHoldingsCash		= $downloadHoldingsCash" |  Out-File $LogFile -Append
Write-Output " downloadBbdaily			= $downloadBbdaily" |  Out-File $LogFile -Append
Write-Output " downloadBlackbar			= $downloadBlackbar" |  Out-File $LogFile -Append
Write-Output " download4Qtr				= $download4Qtr" |  Out-File $LogFile -Append
Write-Output " downloadLstQtr			= $downloadLstQtr" |  Out-File $LogFile -Append
Write-Output " downloadQtrToDate		= $downloadQtrToDate" |  Out-File $LogFile -Append
Write-Output " fileHoldings				= $fileHoldings" |  Out-File $LogFile -Append
Write-Output " fileBbdaily				= $fileBbdaily" |  Out-File $LogFile -Append
Write-Output " fileBlackbar				= $fileBlackbar" |  Out-File $LogFile -Append
Write-Output " file4Qtr					= $file4Qtr" |  Out-File $LogFile -Append
Write-Output " fileLstQtr				= $fileLstQtr" |  Out-File $LogFile -Append
Write-Output " fileQtrToDate			= $fileQtrToDate" |  Out-File $LogFile -Append
Write-Output " filearchiveHoldings		= $filearchiveHoldings" |  Out-File $LogFile -Append
Write-Output " filearchiveBbdaily		= $filearchiveBbdaily" |  Out-File $LogFile -Append
Write-Output " filearchiveBlackbar		= $filearchiveBlackbar" |  Out-File $LogFile -Append
Write-Output " filearchive4Qtr			= $filearchive4Qtr" |  Out-File $LogFile -Append
Write-Output " filearchiveLstQtr		= $filearchiveLstQtr" |  Out-File $LogFile -Append
Write-Output " filearchiveQtrToDate		= $filearchiveQtrToDate" |  Out-File $LogFile -Append

$sleepCounter= 0
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  SeiIboxxETF starts here " | Out-File $LogFile -Append


#Set-Location $download_dir
Start-Sleep -s 60;
  
 

IF ((Test-Path $downloadHoldings) -and (Test-Path $downloadBbdaily) -and (Test-Path $downloadBlackbar) -and (Test-Path $download4Qtr) -and (Test-Path $downloadLstQtr)  -and (Test-Path $downloadQtrToDate)) {

<#
Move-Item -path "$downloadHoldings" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $downloadHoldings ) to location ( $file_dir ) " | Out-File $LogFile -Append

Move-Item -path "$downloadBbdaily" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $downloadBbdaily ) to location ( $file_dir ) " | Out-File $LogFile -Append

Move-Item -path "$downloadBlackbar" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $downloadBlackbar.csv ) to location ( $file_dir ) " | Out-File $LogFile -Append

Move-Item -path "$download4Qtr" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $download4Qtr.csv ) to location ( $file_dir ) " | Out-File $LogFile -Append

Move-Item -path "$downloadLstQtr" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $downloadLstQtr.csv ) to location ( $file_dir ) " | Out-File $LogFile -Append

Move-Item -path "$downloadQtrToDate" -destination $file_dir -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $downloadQtrToDate.csv ) to location ( $file_dir ) " | Out-File $LogFile -Append
#>
### Set Database Server Name
  	          ### <<< Change this when going to prod.
	  $ServerName = "PHCMDB01"  

### include fRefDataSetID powershell script
#	. D:\Siepe\Data\Scripts\Configurations\fRefDataSetIU.ps1

### Set varaibles here

$date_string = Get-Date -Date $runDate -UFormat %x
#$Path = "$dirProdHcmlpDataFeedsFolder\SEI\iBoxx"
#$FileName = "20120814_0208_20120813_ETF_Yorkville_holdings.xml"
#$FilePath = $Path + "\"+ $FileName
$RefDataSourceID = "37"
$RefDataSource = "SEI"
$rdsserverName = "PHCMDB01"
$rdsdatabaseName = "datafeeds"
$RefDataSetDate = $date_string

$RefDatasetTypeHoldings = "Position"
$LabelHoldings = "ETF Pyxis holdings"

$RefDatasetTypeBbdaily = "Performance"
$LabelBbdaily = "ETF Pyxis bbdaily"

$RefDatasetTypeBlackbar = "Performance"
$LabelBlackbar = "ETF Pyxis blackbar"

$RefDatasetType4Qtr = "Performance"
$Label4Qtr = "ETF Pyxis 4 qtr prem disc"
 
$RefDatasetTypeLstQtr = "Performance"
$LabelLstQtr = "ETF Pyxis lst qtr prem disc"

$RefDatasetTypeQtrToDate = "Performance"
$LabelQtrToDate = "ETF Pyxis qtr to date prem disc"

### call fRefDataSetID function to get a RefDataSetID
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetIDHoldings=fRefDataSetIU 0 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings "I" $date_string $rdsserverName
	 $RefDataSetIDHoldings2 = $RefDataSetIDHoldings
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDHoldings2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeBbdaily $RefDataSource $LabelBbdaily `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetIDBbdaily=fRefDataSetIU 0 $RefDatasetTypeBbdaily $RefDataSource $LabelBbdaily "I" $date_string $rdsserverName
	 $RefDataSetIDBbdaily2 = $RefDataSetIDBbdaily
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDBbdaily2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeBlackbar $RefDataSource $LabelBlackbar `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetIDBlackbar=fRefDataSetIU 0 $RefDatasetTypeBlackbar $RefDataSource $LabelBlackbar "I" $date_string $rdsserverName
	 $RefDataSetIDBlackbar2 = $RefDataSetIDBlackbar
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDBlackbar2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetType4Qtr $RefDataSource $Label4Qtr `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetID4Qtr=fRefDataSetIU 0 $RefDatasetType4Qtr $RefDataSource $Label4Qtr "I" $date_string $rdsserverName
	 $RefDataSetID4Qtr2 = $RefDataSetID4Qtr
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetID4Qtr2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeLstQtr $RefDataSource $LabelLstQtr `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetIDLstQtr=fRefDataSetIU 0 $RefDatasetTypeLstQtr $RefDataSource $LabelLstQtr "I" $date_string $rdsserverName
	 $RefDataSetIDLstQtr2 = $RefDataSetIDLstQtr
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDLstQtr2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling fRefDataSetIU 0 $RefDatasetTypeQtrToDate $RefDataSource $LabelQtrToDate `"I`" $date_string $rdsserverName " | Out-File $LogFile -Append
	 $RefDataSetIDQtrToDate=fRefDataSetIU 0 $RefDatasetTypeQtrToDate $RefDataSource $LabelQtrToDate "I" $date_string $rdsserverName
	 $RefDataSetIDQtrToDate2 = $RefDataSetIDQtrToDate	 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Returns the value : $RefDataSetIDQtrToDate2 " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Reading the XML file into a variable " | Out-File $LogFile -Append
### Read in your XML file into a variable
      #$XMLContents=Get-Content $FilePath 
	  $XMLContentsHoldings=Get-Content $fileHoldings 
	  $XMLContentsBbdaily=Get-Content $fileBbdaily 
      $XMLContentsBlackbar=Get-Content $fileBlackbar 
	  $XMLContents4Qtr=Get-Content $file4Qtr 
      $XMLContentsLstQtr=Get-Content $fileLstQtr 
	  $XMLContentsQtrToDate=Get-Content $fileQtrToDate 
	  $XMLContentsHoldingsClean = $XMLContentsHoldings.Replace("'","")
	  Write-Output $XMLContentsHoldingsClean > "$file_dir"+"SeiHoldings.xml"
	  $XMLContentsHoldingsClean = Get-Content "$file_dir"+"SeiHoldings.xml"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating SQL Statement " | Out-File $LogFile -Append
### Create your insert statement
      $SQL  = "insert into datafeeds.Custodian.tSEIiBoxxAdminPositionRecData(RefDataSetID, XmlDoc) values ("+$RefDataSetIDHoldings+",'"+$XMLContentsHoldingsClean+"')"
      $SQL2  = "insert into datafeeds.Custodian.tSeiBbdaily(RefDataSetID, XmlDoc) values ("+$RefDataSetIDBbdaily+",'"+$XMLContentsBbdaily+"')"	  
      $SQL3  = "insert into datafeeds.Custodian.tSeiBlackbar(RefDataSetID, XmlDoc) values ("+$RefDataSetIDBlackbar+",'"+$XMLContentsBlackbar+"')"
      $SQL4  = "insert into datafeeds.Custodian.tSeiQtr(RefDataSetID, XmlDoc) values ("+$RefDataSetID4Qtr+",'"+$XMLContents4Qtr+"')"
      $SQL5  = "insert into datafeeds.Custodian.tSeiQtr(RefDataSetID, XmlDoc) values ("+$RefDataSetIDLstQtr+",'"+$XMLContentsLstQtr+"')"
      $SQL6  = "insert into datafeeds.Custodian.tSeiQtr(RefDataSetID, XmlDoc) values ("+$RefDataSetIDQtrToDate+",'"+$XMLContentsQtrToDate+"')"	  
      
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Creating connection :: $ServerName" | Out-File $LogFile -Append
### make database connection
      $ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
      $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
      $dbconn.Open()
      $dbCmd = $dbConn.CreateCommand()
      $dbCmd.CommandTimeout = 0
	  $dbCmd2 = $dbConn.CreateCommand()
      $dbCmd2.CommandTimeout = 0
	  $dbCmd3 = $dbConn.CreateCommand()
      $dbCmd3.CommandTimeout = 0
	  $dbCmd4 = $dbConn.CreateCommand()
      $dbCmd4.CommandTimeout = 0
	  $dbCmd5 = $dbConn.CreateCommand()
      $dbCmd5.CommandTimeout = 0
	  $dbCmd6 = $dbConn.CreateCommand()
      $dbCmd6.CommandTimeout = 0

### Execute $SQL
      $dbCmd.CommandText      = $SQL
      $dbCmd2.CommandText      = $SQL2
	  $dbCmd3.CommandText      = $SQL3
	  $dbCmd4.CommandText      = $SQL4
	  $dbCmd5.CommandText      = $SQL5
	  $dbCmd6.CommandText      = $SQL6
#     $RefDataSetId           = $dbCmd.ExecuteScalar()

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDHoldings " | Out-File $LogFile -Append
     $RefDataSetIDHoldings       = $dbCmd.ExecuteScalar()

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDBbdaily " | Out-File $LogFile -Append
	 $RefDataSetIDBbdaily        = $dbCmd2.ExecuteScalar()

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDBlackbar " | Out-File $LogFile -Append
	 $RefDataSetIDBlackbar       = $dbCmd3.ExecuteScalar()
	 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetID4Qtr " | Out-File $LogFile -Append
	 $RefDataSetID4Qtr           = $dbCmd4.ExecuteScalar()
	 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDLstQtr " | Out-File $LogFile -Append
	 $RefDataSetIDLstQtr         = $dbCmd5.ExecuteScalar()
	 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Executing SQL :: RefDataSetIDQtrToDate " | Out-File $LogFile -Append
	 $RefDataSetIDQtrToDate      = $dbCmd6.ExecuteScalar()


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
#	# $RefDataSetID2=fRefDataSetIU $RefDataSetID2 $RefDatasetType $RefDataSource $Label "P" $date_string $rdsserverName
	 $RefDataSetIDHoldings2=fRefDataSetIU $RefDataSetIDHoldings2 $RefDatasetTypeHoldings $RefDataSource $LabelHoldings "P" $date_string $rdsserverName
	 $RefDataSetIDBbdaily2=fRefDataSetIU $RefDataSetIDBbdaily2 $RefDatasetTypeBbdaily $RefDataSource $LabelBbdaily "P" $date_string $rdsserverName
	 $RefDataSetIDBlackbar2=fRefDataSetIU $RefDataSetIDBlackbar2 $RefDatasetTypeBlackbar $RefDataSource $LabelBlackbar "P" $date_string $rdsserverName
	 $RefDataSetID4Qtr2=fRefDataSetIU $RefDataSetID4Qtr2 $RefDatasetType4Qtr $RefDataSource $Label4Qtr "P" $date_string $rdsserverName
	 $RefDataSetIDLstQtr2=fRefDataSetIU $RefDataSetIDLstQtr2 $RefDatasetTypeLstQtr $RefDataSource $LabelLstQtr "P" $date_string $rdsserverName
	 $RefDataSetIDQtrToDate2=fRefDataSetIU $RefDataSetIDQtrToDate2 $RefDatasetTypeQtrToDate $RefDataSource $LabelQtrToDate "P" $date_string $rdsserverName

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
 Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
 
Write-PubSub -Subject "DataWarehouse.Datafeeds.SeiETF" -Title "SEI ETF Load Completed for $runDateStr"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.Datafeeds.SeiETF`" -Title `"JSEI ETF Load Completed for $runDateStr`" " | Out-File $LogFile -Append

##Calling Normalize SEI Admin Positions ####
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
####***** MD Note: We are now loading SEI NAVs & Position Rec from a different file, so this record is no longer needed *****####
####	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
####	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
###### Normalize Positions 
####	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
####	$GenericNormalizationJobID = 23
####	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
####
####	## Check SSIS is success or not 
####	If ($lastexitcode -ne 0 ) {
####			$SSISErrorMessage = fSSISExitCode $lastexitcode;
####			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: file ( $newfile ) NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
####			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
####			Exit
####		}
####	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx `r`n "| Out-File $LogFile -Append
####
##### Calling Push SEI NAV ############
####$FullDayString = $RefDataSetDate
######SSIS Status Variables
####   [Int]$lastexitcode = $null
####	[String]$SSISErrorMessage = $null
####	
####	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling PushSeiNav.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate `r`n  FilePath = $dirSourceFolder `r`n  FileName = $file1" | Out-File $LogFile -Append
####	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
####
###### PushSeiNav
####& $2016DTEXEC32 /f "$dirSSISPush\PushSeiNav.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
####
####			## Check SSIS is success or not 
####	If ($lastexitcode -ne 0 ) {
####			$SSISErrorMessage = fSSISExitCode $lastexitcode;
####			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Push Sei Nav : file ( $file1 ) not success" | Out-File $LogFile -Append
####			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
####			Exit
####		}
####		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") PushSeiNav: RefDatasetDate ( $FullDayString ) " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

 Write-PubSub -Subject "Nav.Loaded.SEI" -Title "SEI NAV Load Completed for $FullDayString" -Description "$FullDayString"

##Archive
Move-Item -path "$fileHoldings" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileHoldings ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append

Move-Item -path "$fileBbdaily" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileBbdaily ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append

Move-Item -path "$fileBlackbar" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileBlackbar ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append

Move-Item -path "$file4Qtr" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file4Qtr ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append

Move-Item -path "$fileLstQtr" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileLstQtr ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append

Move-Item -path "$fileQtrToDate" -destination $file_dir_Archive -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $fileQtrToDate ) to location ( $file_dir_Archive ) " | Out-File $LogFile -Append


#Rename
Rename-Item  "$filearchiveHoldings" -NewName "SEI_iBoxx_Holdings_$ArchiveDirDayString.xml" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchiveHoldings ) to location ( SEI_iBoxx_Holdings_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchiveBbdaily ) to location ( SEI_iBoxx_Bbdaily_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append
Rename-Item  "$filearchiveBbdaily" -NewName "SEI_iBoxx_Bbdaily_$ArchiveDirDayString.xml" -Force

Rename-Item  "$filearchiveBlackbar" -NewName "SEI_iBoxx_Blackbar_$ArchiveDirDayString.xml" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchiveBlackbar ) to location ( SEI_iBoxx_Blackbar_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append

Rename-Item  "$filearchive4Qtr" -NewName "SEI_iBoxx_4Qtr_$ArchiveDirDayString.xml" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchive4Qtr ) to location ( SEI_iBoxx_4Qtr_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append

Rename-Item  "$filearchiveLstQtr" -NewName "SEI_iBoxx_LstQtr_$ArchiveDirDayString.xml" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchiveLstQtr ) to location ( SEI_iBoxx_LstQtr_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append

Rename-Item  "$filearchiveQtrToDate" -NewName "SEI_iBoxx_QtrToDate_$ArchiveDirDayString.xml" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Rename Item ( $filearchiveQtrToDate ) to location ( SEI_iBoxx_QtrToDate_$ArchiveDirDayString.xml ) " | Out-File $LogFile -Append

#Remove Item from Services Directory
#Remove-Item $downloadHoldings
#Remove-Item $downloadHoldingsCash
#Remove-Item $downloadBbdaily
#Remove-Item $downloadBlackbar
#Remove-Item $download4Qtr
#Remove-Item $downloadLstQtr
#Remove-Item $downloadQtrToDate
Remove-Item $download_dir\* -Include *ETF_*.xml
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Remove item $download_dir\* -Include *ETF_*.xml " | Out-File $LogFile -Append

#################################### External Website Normalize SSIS ####################################
	
	###### NormalizeCustodianSEIExternalWebsites
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites.dtsx `r`n "| Out-File $LogFile -Append
	
	###### NormalizeCustodianSEIExternalWebsites-AUM
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-AUM.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-AUM.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-AUM.dtsx `r`n "| Out-File $LogFile -Append

	###### NormalizeCustodianSEIExternalWebsites-Holding 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Holding.dtsx`r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-Holding.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Holding.dtsx`r`n "| Out-File $LogFile -Append

	###### NormalizeCustodianSEIExternalWebsites-Performance
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Performance.dtsx`r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-Performance.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Performance.dtsx`r`n "| Out-File $LogFile -Append
	
	###### NormalizeCustodianSEIExternalWebsites-Return
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Return.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	###### Normalize External Websites 
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-Return.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIiBoxxETFPerformanceNAVAdminPositionRecData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-Return.dtsx `r`n "| Out-File $LogFile -Append

	###### NormalizeCustodianSEIExternalWebsites-PremiumDiscount
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscount.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	###### Normalize External Websites 
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-PremiumDiscount.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscount.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscount.dtsx `r`n "| Out-File $LogFile -Append

	###### NormalizeCustodianSEIExternalWebsites-PremiumDiscountQuater.dtsx
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscountQuater.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	###### Normalize External Websites 
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSEIExternalWebsites-PremiumDiscountQuater.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
	$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscountQuater.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianSEIExternalWebsites-PremiumDiscountQuater.dtsx `r`n "| Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

#Write-PubSub -Subject "Process.SEIiBoxx.Daily.ImportNormalize.ETF2" -Title "Complete - next Push SEI NAV" -Description "Complete - next Push SEI NAV"
