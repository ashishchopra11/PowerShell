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
	$GenericImportJobID = 41													##### NEED TO UPDATE #####	
	$GenericNormaliztaionJobID = 	66										##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	$newfile = "DailyStockLoanExtract.csv"
	$dirServicesDeliveryStoreFolder
    $ServiceDir = "$dirServicesDeliveryStoreFolder\BAML Gpro Rebate Data"
	
	foreach ($file in Get-ChildItem	 -Path $ServiceDir | Where-Object {$_.Name -ilike "DailyStockLoanExtract*"}) {
	$year="20"+$file.Name.substring(49,2)
	$dateStr =  Get-Date -Year $year -Month $file.Name.substring(52,2) -Day $file.Name.substring(55,2) -Format "yyyyMMdd"
	$date =  Get-Date -Year $year -Month $file.Name.substring(52,2) -Day $file.Name.substring(55,2) -Format d
    
	$file.fullpath
	$newFile1="DailyStockLoanExtract.$dateStr.csv"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Renaming File $file to $newFile1  $date" | Out-File $LogFile -Append
	Rename-Item $file.FullName -NewName ($newFile1) -Force 
	
	}

#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	
#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	
	
	# If there is an issue with generic normalization, just switch the comments of the two lines below	
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBAMLGproRebateData.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate"/set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append

	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianBAMLGproRebateData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BAML Load G pro Rebate: file ( $newfile ) NormalizeCustodianBAMLGproRebateData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	
	$ServerName = "PHCMDB01"
	
	### Create your insert statement
    $SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000134  ,@InstIdentifierTypeList = '1,2,13,3'"  
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

	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianBAMLGproRebateData.dtsx `r`n "| Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$Label = "BAMLGPro - tInstRebate"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushInstRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate"/set "\package.variables[PowerShellLocation].Value;$PSScriptName" /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BAML Load G pro Rebate: file ( $newfile ) PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-PubSub -Subject "DataWarehouse.Datafeeds.Rebate" -Title "Rebate Loaded for $date" -Description "$RefDataSetDate"