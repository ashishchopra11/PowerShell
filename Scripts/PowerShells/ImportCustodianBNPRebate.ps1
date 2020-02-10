############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\ConnectionStrings.config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\fGenericImportJob.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file
Create-File -path $($dirLogFolder+"\") -fileName $("ImportCustodianBNPRebate."+$strDateNow+".txt")
$logFile 				= "$dirLogFolder\ImportCustodianBNPRebate.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\BNP"
$dirArchiveFolder 		= "$dirDataFeedsArchiveFolder\BNP\Archive"
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory


#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append

$RefDataSetDate = ""

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  BNP Retail starts here " | Out-File $LogFile -Append

## ImportCitiPositions
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "07L_GloReb001*.csv.pgp"})
{
   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  BNP Retail: file ( $strFileName ) processing " | Out-File $LogFile -Append
   
   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
	
	
	$DateFromFileName=$strFileName.Name.Substring(14,4) + "-" +$strFileName.Name.Substring(18,2) + "-" + $strFileName.Name.Substring(20,2) 
    $dtDate = Get-Date $DateFromFileName
	$RefDataSetDate = $dtDate.toshortdatestring()
	 
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from $strFileName Column [DataSetDate] :: $RefDataSetDate " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianBNPRebate.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   	& $2016DTEXEC64 /F "$dirSSISExtractCustodian\ImportCustodianBNPRebate.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"/set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BNP Rebate: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BNP Rebate: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append

		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianBNPRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNPRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $strFileName ) NormalizeCustodianBNPRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
	
	### Create your insert statement
     $SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000233  ,@InstIdentifierTypeList = '1,13'  ,@ViewResults = 1"  
	
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
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianBNPRebate.dtsx `r`n "| Out-File $LogFile -Append  
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$Label = "BNP - tInstRebate"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushInstRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $strFileName ) PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $newfile ) pushed " | Out-File $LogFile -Append

}

$GenericImportJobID=1

fGenericImportJob $GenericImportJobID $dirDataFeedsFolder $null $null $LogFile 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
