############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\StateStreetNAV."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
$runDate = Get-Date
$ProcessDate	= $runDate
$FileDate = $runDate.ToString("yyyyMMdd")

$ServiceDir = "$dirServicesDeliveryStoreFolder\StateStreet NAV"
#$CustodianInDir = "$dirProdHcmlpDataFeedsFolder\StateStreet"
#$dirDataFeedsArchiveFolder = "\\hcm97\PMPDataFeeds"
$CustodianInDir = "$dirDataFeedsArchiveFolder\StateStreet"
$CustodianArchiveDir = "$dirDataFeedsArchiveFolder\StateStreetNAV\Archive"

$filename = "Highland Capital NAVs.XLS"
$file = $ServiceDir + "\Highland Capital NAVs.XLS"
$fileService = $ServiceDir + "\Highland Capital NAVs.XLS"
$ArchiveFile = "$CustodianArchiveDir\Highland Capital NAVs.XLS"

$Date			= $ProcessDate.ToString("MM/dd/yyyy")
$FullDayString 	= $Date

Write-Output " fileService			= $fileService" |  Out-File $LogFile -Append
Write-Output " ArchiveFile			= $ArchiveFile" |  Out-File $LogFile -Append
Write-Output " LogFile				= $LogFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  State Street NAV starts here " | Out-File $LogFile -Append

$FileExists = Test-Path $fileService

If ($FileExists -eq $True) {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  State Street NAV: file ( $filename ) processing " | Out-File $LogFile -Append

#Move-Item "$ServiceDir\Pyxis Capital NAVs.XLS"  "$CustodianInDir" -force
#Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $ServiceDir\Pyxis Capital NAVs.XLS ) to location ( $CustodianInDir ) " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $ServiceDir " | Out-File $LogFile -Append
Set-Location $ServiceDir


#########################
####  StateStreet NAV
#########################

	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Setting RefDataSetDate as current date :: $FullDayString " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractCustodianStateStreetNav.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString `r`n  FileName = $filename `r`n  FileDirectory = $ServiceDir " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f  "$dirSSISExtractCustodian\ExtractCustodianStateStreetNav.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[FileName].Value;$filename" /set "\package.variables[FileDirectory].Value;$ServiceDir" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: file ( $filename ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street NAV: file ( $filename ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianStateStreetNAV.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeCustodian\NormalizeCustodianStateStreetNAV.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: file ( $filename ) NormalizeCustodianStateStreetNAV.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianStateStreetNAV.dtsx `r`n "| Out-File $LogFile -Append

######### PUSH NAV #################
$ServerName		= "PHCMDB01" 

$DataSource = "State Street (Administrator)"
$Label		= "StateStreet NAV"
$Label_HCM	= "SS tFundTickerNav"

Write-Output " ServerName			= $ServerName" |  Out-File $LogFile -Append
Write-Output " LogFile			= $LogFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Push NAV starts here " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Setting RefDataSetDate as current date :: $FullDayString " | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushNav.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString `r`n  DataSource = $DataSource `r`n  Label = $Label `r`n  DataSource = $DataSource `r`n  Label = $Label_HCM" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /f  "$dirSSISPush\PushNav.dtsx" `
	/set "\package.variables[RefDataSetDate].Value;$FullDayString" `
	/set "\package.variables[DataSource].Value;$DataSource" `
	/set "\package.variables[Label].Value;$Label" `
	/set "\package.variables[Label_HCM].Value;$Label_HCM" `
	/set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Push NAV : PushNav.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Push NAV :  pushed " | Out-File $LogFile -Append
	
###################################################### Check DataSetId

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: $ServerName" | Out-File $LogFile -Append
  ### make the connection
  $ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=HCM;Database=DataFeeds;Integrated Security=SSPI;"
  $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
  $dbconn.Open()
  $dbCmd = $dbConn.CreateCommand()
  $dbCmd.CommandTimeout = 0

  ### get the current RefDataSetid
#  $SQL 					= "select RefDataSetid from hcm.dbo.vRefdataset where RefDataSource = 'Reference'  and RefDataSetType = 'Reference' and Label = 'PNC tFundTickerNav' and StatusCode = 'P' and EffThruDate = '01/01/9999' and RefDataSetDate = '" + $FullDayString + "'"
#  $dbCmd.CommandText 	= $SQL
#  $RefDataSetId_PNC		= $dbCmd.ExecuteScalar()
#
#  $SQL 					= "select RefDataSetid from hcm.dbo.vRefdataset where RefDataSource = 'Reference'  and RefDataSetType = 'Reference' and Label = 'UBS tFundTickerNav' and StatusCode = 'P' and EffThruDate = '01/01/9999' and RefDataSetDate = '" + $FullDayString + "'"
#  $dbCmd.CommandText 	= $SQL
#  $RefDataSetId_UBS		= $dbCmd.ExecuteScalar()
  
  $SQL 					= "select RefDataSetid from hcm.dbo.vRefdataset where RefDataSource = 'Reference'  and RefDataSetType = 'Reference' and Label = 'SS tFundTickerNav' and StatusCode = 'P' and EffThruDate = '01/01/9999' and RefDataSetDate = '" + $FullDayString + "'"
  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing SQL:: $SQL " | Out-File $LogFile -Append
  $dbCmd.CommandText 	= $SQL
  $RefDataSetId_SS		= $dbCmd.ExecuteScalar()  

  If ($RefDataSetid_PNC -eq "")
	{
		$RefDataSetid_PNC="Don't have RefDataSetid or data today, call support"
	}
  ### close the connection
  $dbCmd.Dispose()
  $dbConn.Close()
  $dbConn.Dispose()
  
  ### cleanup
  Remove-Variable dbCmd
  Remove-Variable dbConn


###################################################### send mail
# delay 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Starting Sleep for 10 seconds `r`n "| Out-File $LogFile -Append
Start-Sleep -Seconds 10

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Sending mail `r`n "| Out-File $LogFile -Append

$to_Email 	= "SQLDataFeeds@hcmlp.com"
$from_Email = "$ServerName@hcmlp.com"
$subject 	= "Push NAV to HCM : " + $FullDayString
$message 	= "
RefDataSetDate   : " + $FullDayString + "
RefDataSetId_SS : " + $RefDataSetId_SS# + "
#RefDataSetId_PNC : " + $RefDataSetId_PNC + "
#RefDataSetID_UBS : " + $RefDataSetId_UBS 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: `r`n Variable passed here are : `r`n  to_Email = $to_Email `r`n  from_Email = $from_Email `r`n  subject = $subject `r`n  message = $message"| Out-File $LogFile -Append
$smtp 		= New-Object system.net.mail.smtpclient("mail.hcmlp.com")
$smtp.send($from_Email,$to_Email,$subject,$message)


Write-PubSub -Subject "Fund.NAV.Loaded" -Title "NAVs loaded for $FullDayString" -Description "$FullDayString"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"Fund.NAV.Loaded`" -Title `"NAVs loaded for $FullDayString`" -Description `"$FullDayString`" " | Out-File $LogFile -Append

Write-PubSub -Subject "Nav.Loaded.StateStreet" -Title "State Street NAV Load Completed for $FullDayString" -Description "$FullDayString"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"Nav.Loaded.StateStreet`" -Title `"State Street NAV Load Completed for $FullDayString`" -Description `"$FullDayString`" " | Out-File $LogFile -Append


	Move-Item "$file" $CustodianArchiveDir -force
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $file ) to location ( $CustodianArchiveDir ) " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") renaming file ( $ArchiveFile ) to new file ( Highland Capital NAVs_$FileDate.XLS ) " | Out-File $LogFile -Append
	Rename-Item  "$ArchiveFile" -NewName "Highland Capital NAVs_$FileDate.XLS"
	
}
else
{Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source File Not Exists " | Out-File $LogFile -Append
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

#Write-PubSub -Subject "Process.SS.Daily.Import.NAV2" -Title "Complete - next - SS Push NAV" -Description "Complete - next - SS Push NAV"
