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
	$GenericImportJobID =  75
	$GenericNormaliztaionJobID = 	67


	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\BAML Rebate"
 
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "XHIHFTPFD1_E10AMTD*.txt*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$FileName = $FileName.SubString(0,84)
		$NewName = $FileName -Replace ".txt.asc", ".csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
	}
 
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "XHIHFTPFD1_E10AMTD*.csv*"})
	{	
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace('|',',') | Set-Content -Path $FileName
		
		$HeaderLine =	'RunDate','BusinessDate','PeriodDate','AccountNumberMLPro','FundID','ClientName','ProductDesc','ProductSDesc',
			'ISIN','CUSIP','TickerSymbol','QuickCode','SEDOL','RicCode','StandardCompositeID','USCompositeID','PaymentCurrency','Date',
			'CollateralType','Description','SettledPosition','MarketPrice','MarketValue','RatePercent','DailyRebate','FailureToDeliver'
		
		$import = Import-CSV $FileName -Header $HeaderLine		
		$import | Export-Csv $FileName -Force -NoTypeInformation
	}
    
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
    
#****** Normalization ******
	$RefDatasetDate = $ReturnDate
	
	
	# If there is an issue with generic normalization, just switch the comments of the two lines below	
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBAMLRebateData.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append
    
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	  	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianBAMLRebateData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
    
		
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BAMLLoadMtd Rebate : NormalizeCustodianBAMLRebateData.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Normalization Complete" | Out-File $LogFile -Append
    
		### Create your insert statement
      	$SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000131  ,@InstIdentifierTypeList = '1,2,13,3'"  
	    
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Create SQL Query $SQL for PUSH Process `r`n " | Out-File $LogFile -Append
		
		### make database connection
      	$ConnectionString = "Data Source=" + $ServerName +";Initial Catalog=DataFeeds;Database=Reference;Integrated Security=SSPI;"
      	$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
      	$dbconn.Open()
      	$dbCmd = $dbConn.CreateCommand()
      	$dbCmd.CommandTimeout = 0
    
        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Make DataBase Connection with ConnectionString = $ConnectionString  `r`n " | Out-File $LogFile -Append
		
		
		### Execute $SQL
      	$dbCmd.CommandText      = $SQL
		$dbCmd.ExecuteScalar()
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Execute SQL  $SQL `r`n " | Out-File $LogFile -Append
		
		### close the connection
      	$dbCmd.Dispose()
      	$dbConn.Close()
      	$dbConn.Dispose()
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Close the connection `r`n " | Out-File $LogFile -Append
		
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : Proc pInstArbitrationByRefDataSource executed `r`n " | Out-File $LogFile -Append
		
		### cleanup
      	Remove-Variable dbCmd
      	Remove-Variable dbConn
		 
	  ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$Label = "BAML - tInstRebate"
		  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling PushInstRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDatasetDate `r`n  Label = $Label" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
		& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDatasetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
		
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BAMLLoadMtd Rebate : PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")BAMLLoadMtd Rebate  : PUSH Complete" | Out-File $LogFile -Append