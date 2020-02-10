############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
#################################################################################### 

#****** Initialize variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\BNP Rebate"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.csv*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".csv.pgp", ""
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*GloReb001*.csv*"})
	{	
		$FileName = "$dirDataFeedsFolder\$strFileName"		
		$NewFileName = "$dirDataFeedsFolder\" + "1_" + "$strFileName"
		$Data = Get-Content $FileName
		$Data = $Data -Replace "Daily Fee/Rebate,MTD Fee/Rebate,Daily Fee/Rebate,MTD Fee/Rebate,", "Daily Fee/Rebate-Local,MTD Fee/Rebate-Local,Daily Fee/Rebate-Reporting,MTD Fee/Rebate-Reporting,"
		$Data | select -Skip 1  | Out-File $NewFileName
		Remove-Item $FileName
	}
 
#***** Generic Import ******
	$GenericImportJobID = 1
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 76
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
#****** Normalization ******
	$RefDatasetDate = $ReturnDate
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*GloReb001*"})
	{
		Remove-Item "$dirDataFeedsFolder\$strFileName"
	}
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SLRebIntSum*"})
	{
		Remove-Item "$dirDataFeedsFolder\$strFileName"
	}
	
		## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianBNPRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	# If there is an issue with generic normalization, just switch the comments of the two lines below	
	$GenericNormaliztaionJobID = 	68
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNPRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $strFileName ) NormalizeCustodianBNPRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
	
	$ServerName = "PHCMDB01"
	### Create your insert statement
     $SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000230  ,@InstIdentifierTypeList = '1,13'  ,@ViewResults = 1"  
	
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
	
	& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $strFileName ) PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNP Rebate: file ( $newfile ) pushed " | Out-File $LogFile -Append