############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\DTExec.Config.ps1
	. .\fSSISExitCode.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 63													##### NEED TO UPDATE #####
	$GenericNormaliztaionJobID = 	60										##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	$ServerName 			= "PHCMDB01" 
	
	Write-Output " ServerName			= $ServerName" |  Out-File $LogFile -Append

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianPershingRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $ReturnDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianPershingRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$ReturnDate"	/set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append
	
	#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: NormalizeCustodianPershingRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
	### Create your insert statement
      $SQL  = "EXEC reference.dbo.pInstArbitrationByRefDataSource  @RefDataSourceID = 1000000132  ,@InstIdentifierTypeList = '1,2,13,3'  ,@ViewResults = 1"  
	    
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
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianPershingRebate.dtsx `r`n "| Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	$Label = "Pershing - tInstRebate"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PushInstRebate.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $ReturnDate `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISPush\PushInstRebate.dtsx" /set "\package.variables[RefDataSetDate].Value;$ReturnDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  /set "\package.variables[Label].Value;$Label" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: PushInstRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Pershing Rebate: file pushed " | Out-File $LogFile -Append

	Write-PubSub -Subject "DataWarehouse.Datafeeds.Incoming" -Title "Jefferies Rebate ($Account) Loaded for $ReturnDate" -Description "$ReturnDate"