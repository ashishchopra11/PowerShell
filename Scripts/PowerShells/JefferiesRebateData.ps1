############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\JefferiesExcelCleanup.ps1
. .\fSSISExitCode.ps1
. .\ConnectionStrings.config.ps1
. .\IOFunctions.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\JefferiesRebate."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append

#Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$ServerName = "PHCMDB01" 
$ServiceDir = "$dirServicesDeliveryStoreFolder\Jefferies Rebate Data"
$CustodianInDir = "$dirDataFeedsArchiveFolder\Jefferies\Rebate"
$CustodianArchiveDir = "$dirDataFeedsArchiveFolder\Jefferies Rebate Data\Archive"
$newfile = "RebateSummary.xls"
[bool]$FileExists = $False

Write-Output " ServerName			= $ServerName" |  Out-File $LogFile -Append
Write-Output " ServiceDir			= $ServiceDir" |  Out-File $LogFile -Append
Write-Output " CustodianInDir		= $CustodianInDir" | Out-File $LogFile -Append
Write-Output " CustodianArchiveDir	= $CustodianArchiveDir" | Out-File $LogFile -Append
Write-Output " newfile				= $newfile" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile				= $LogFile `r`n" | Out-File $LogFile -Append


#Move-Item "$ServiceDir\*Rebate-Summary*"  "$CustodianInDir" -Force | Out-File $LogFile -Append

#Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Move Files from $ServiceDir\*Rebate-Summary* to $CustodianInDir " | Out-File $LogFile -Append

Set-Location $ServiceDir
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $ServiceDir " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Jefferies Rebate starts here " | Out-File $LogFile -Append

foreach ($file in Get-ChildItem	 -Path $ServiceDir | Where-Object {$_.Name -ilike "*Rebate-Summary*"}) {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Jefferies Rebate: file ( $file ) processing " | Out-File $LogFile -Append
	$file
	$dateStr = ""
	$filePath = $ServiceDir + "\$file"
    $FileExists = $True
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Jefferies source file to find RefDataSetDate" | Out-File $LogFile -Append
	$splitstr = $file.Name.Split("_")[1]
	$dateStr =  $splitstr.Substring(0,8)
	
	$date =  ([datetime]::ParseExact($dateStr.Trim(),"yyyyMMdd",$null))
	$Account =  $file.Name.substring(0,8)
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Jefferies Rebate: renaming file ($file) to new file ($newfile) " | Out-File $LogFile -Append
	Rename-Item $file -NewName ($newfile)
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractCustodianJefferiesRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date `r`n  FileDirectory = $ServiceDir `r`n  Account = $Account `r`n FileName = $newfile " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[FileDirectory].Value;$ServiceDir" /set "\package.variables[FileName].Value;$newfile" /set "\package.variables[AccountID].Value;$Account" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	Write-Output "****************** Jefferies Rebate: file ($newfile) imported ******************" | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") renaming file ( RebateSummary.xls ) to new file ( RebateSummary.$Account.$dateStr.xls ) " | Out-File $LogFile -Append
	$NewFileName = "RebateSummary.$Account.$dateStr.xls"
	Rename-Item $newfile -NewName ($NewFileName)
	
	
	Move-Item "RebateSummary.$Account.$dateStr.xls" $CustodianArchiveDir -Force
 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( RebateSummary.$Account.$dateStr.xls ) to location ( $CustodianArchiveDir ) " | Out-File $LogFile -Append
 	
	
}

If ($FileExists -eq $True)
{
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianJefferiesRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	# If there is an issue with generic normalization, just switch the comments of the two lines below	
	$GenericNormaliztaionJobID = 	69
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $date -pLogFile $LogFile -pScriptName $null
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Jefferies Rebate: file ( $newfile ) NormalizeCustodianJefferiesRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
	
	### Create your insert statement
     $SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000097  ,@InstIdentifierTypeList = '1,2,13,3'  ,@ViewResults = 1"  
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: $ServerName" | Out-File $LogFile -Append
	### make database connection
      $ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=DataFeeds;Database=Reference;Integrated Security=SSPI;"
      $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
      $dbconn.Open()
      $dbCmd = $dbConn.CreateCommand()
      $dbCmd.CommandTimeout = 0
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing SQL:: $SQL " | Out-File $LogFile -Append
	
	### Execute $SQL
      $dbCmd.CommandText      = $SQL
	  $dbCmd.ExecuteScalar()
	  
	### close the connection
      $dbCmd.Dispose()
      $dbConn.Close()
      $dbConn.Dispose()
	
	### cleanup
      Remove-Variable dbCmd
      Remove-Variable dbConn
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianJefferiesRebate.dtsx `r`n "| Out-File $LogFile -Append  
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$Label = "Jefferies - tInstRebate"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushInstRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Jefferies Rebate: file ( $newfile ) PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Jefferies Rebate: file ( $newfile ) pushed " | Out-File $LogFile -Append
	
	
	Start-Sleep -S 10
 
	#Write-PubSub -Subject "DataWarehouse.Datafeeds.Incoming" -Title "Jefferies Rebate ($Account) Loaded for $date" -Description "$date"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.Datafeeds.Incoming`" -Title `"Jefferies Rebate ($Account) Loaded for $date`" -Description `"$date`" " | Out-File $LogFile -Append

}
If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( *Rebate-Summary* ) not exist at :: $ServiceDir " | Out-File $LogFile -Append    
}	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
