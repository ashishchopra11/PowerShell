############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1

####################################################################################


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Archive folder
$strDateNow = Get-Date -format "yyyyMMddTHHmmss"
#$logFile    = "$dirLogFolder\WSOLedgerTransactions"+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

##
## WSO DW Load Script
##

#. .\RunExtracts.conf.ps1

Clear-Host

$curr_date = Get-Date 
	
	#$process_date = ($curr_date).AddDays(-1)
	$process_date = $curr_date
	

$strDateNow = get-date $process_date -format "yyyyMMdd"
$dirRoot = "D:\Siepe"
$WSO_Extracts_DIR 		= "$dirRoot\DataFeeds\WSOReports\LedgerExtract"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\WSOReports\$strDateNow\Archive\LedgerExtract"


Write-Output " WSO_Extracts_DIR			= $WSO_Extracts_DIR" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder			= $dirArchiveFolder" |  Out-File $LogFile -Append



################################################ LEDGER TRANSACTIONS #############################################################
Move-Item "$dirServicesDeliveryStoreFolder\WSOOnDemand\ExtractLedgerTransactions*.csv" $WSO_Extracts_DIR 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Moved file from $dirServicesDeliveryStoreFolder\WSOOnDemand to $WSO_Extracts_DIR " | Out-File $LogFile -Append

##Create Archive folder
if (!(Test-Path -path $dirArchiveFolder))
    { 	
	    New-Item -path $dirArchiveFolder -ItemType directory 
    }

foreach ($strFileName in Get-ChildItem	 -Path $WSO_Extracts_DIR | Where-Object {$_.Name -ilike "ExtractLedgerTransactions_*.csv"}) 
{
   $RefDataSetDate = $null
  
   
	 
    $FileName = $strFileName.Name.Substring(26,8)
	#$RefDataSetDate = ([datetime]::ParseExact($strFileName.Name.Substring(26,8),”yyyyMMdd”,$null)).toshortdatestring()
	
	##11:00 PM Check For (T or T-1)
	$Date = $null
    [datetime]$getDate = get-date
    $11PM = Get-Date "1/1/9999 11:00 PM" 
	$Date = ([datetime]::ParseExact($strFileName.Name.Substring(26,8),”yyyyMMdd”,$null)) 
	
	if ($getDate.ToShortDateString() -eq $Date.ToShortDateString() -and $getDate.TimeOfday -lt $11PM.TimeOfday ) 
	{
	  $RefDataSetDate = $Date.AddDays(-1).ToShortDateString()
	}
	else
	{
	 $RefDataSetDate = $Date.ToShortDateString()
	}
	

	Write-Output "RefDatasetDate : $RefDataSetDate " | Out-File $logFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractLedgerTransactions.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $ArchiveFolderTran `r`n  FolderName = $WSO_Extracts_DIRTran `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


 & $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractLedgerTransactions.dtsx" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.Connections[Source - ExtractLedgerTransactions.csv].Properties[ConnectionString];""$WSO_Extracts_DIR\$strFileName""" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Transaction : $dirSSISExtractWSO\ExtractLedgerTransactions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Transaction : $dirSSISExtractWSO\ExtractLedgerTransactions.dtsx Completed " | Out-File $LogFile -Append
		}
		
	
	Move-Item "$WSO_Extracts_DIR\$strFileName" $dirArchiveFolder
    
	Write-Output "Source file $strFileName moved to folder $dirArchiveFolder" | Out-File $logFile -Append
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


    & $2016DTEXEC64 /F "$dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Transactions : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Transactions : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerTransactions.dtsx Completed " | Out-File $LogFile -Append
		}
		
    
    
}

############################### LEDGER ACCOUNT ############################

Move-Item "$dirServicesDeliveryStoreFolder\WSOOnDemand\ExtractLedgerAccounts*.csv" $WSO_Extracts_DIR 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Moved file from $dirServicesDeliveryStoreFolder\WSOOnDemand to $WSO_Extracts_DIR " | Out-File $LogFile -Append

##Create Archive folder
if (!(Test-Path -path $dirArchiveFolder))
    { 	
	    New-Item -path $dirArchiveFolder -ItemType directory 
    }



foreach ($strFileName in Get-ChildItem	 -Path $WSO_Extracts_DIR | Where-Object {$_.Name -ilike "ExtractLedgerAccounts_*.csv"}) 
{

	$RefDataSetDate = $null
    $FileName = $strFileName.Name.Substring(22,8)
	#$RefDataSetDate = ([datetime]::ParseExact($strFileName.Name.Substring(22,8),”yyyyMMdd”,$null)).toshortdatestring()
	
	##11:00 PM Check For (T or T-1)
	$Date = $null
    [datetime]$getDate = get-date
    $11PM = Get-Date "1/1/9999 11:00 PM" 
	$Date = ([datetime]::ParseExact($strFileName.Name.Substring(22,8),”yyyyMMdd”,$null)) 
	
	if ($getDate.ToShortDateString() -eq $Date.ToShortDateString() -and $getDate.TimeOfday -lt $11PM.TimeOfday ) 
	{
	  $RefDataSetDate = $Date.AddDays(-1).ToShortDateString()
	}
	else
	{
	 $RefDataSetDate = $Date.ToShortDateString()
	}
	
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $ArchiveFolderTran `r`n  FolderName = $WSO_Extracts_DIRTran `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


 & $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractLedgerAccounts.dtsx" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR" /set "\package.Connections[Source - ExtractLedgerAccount.csv].Properties[ConnectionString];""$WSO_Extracts_DIR\$strFileName""" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Account : $dirSSISExtractWSO\ExtractLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Account : $dirSSISExtractWSO\ExtractLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
		}
		
	
	Move-Item "$WSO_Extracts_DIR\$strFileName" $dirArchiveFolder
    
	Write-Output "Source file $strFileName moved to folder $dirArchiveFolder" | Out-File $logFile -Append
	
	
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


 & $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Accounts : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Accounts : $dirSSISNormalizeWSO\NormalizeWSOExtractLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
		}
		
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushLedgerAccounts.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


 & $2016DTEXEC32 /f "$dirSSISPush\PushLedgerAccounts.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")Push  Ledger Accounts : $dirSSISPush\PushLedgerAccounts.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Push Ledger Accounts : $dirSSISPush\PushLedgerAccounts.dtsx Completed " | Out-File $LogFile -Append
		}
		
    
    
}

###################################################### LEDGER ACCOUNT PORTFOLIO MAP ###############################
## File moved from DeliveryStore to local :-
Move-Item "$dirServicesDeliveryStoreFolder\WSOOnDemand\ExtractLedgerAccountPortfolioMap*.csv" $WSO_Extracts_DIR 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Moved file from $dirServicesDeliveryStoreFolder\WSOOnDemand to $WSO_Extracts_DIR " | Out-File $LogFile -Append

##Create Archive folder
if (!(Test-Path -path $dirArchiveFolder))
    { 	
	    New-Item -path $dirArchiveFolder -ItemType directory 
    }

## ExtractLedgerAccountPortfolioMap :-
foreach ($strFileName in Get-ChildItem	 -Path $WSO_Extracts_DIR | Where-Object {$_.Name -ilike "ExtractLedgerAccountPortfolioMap_*.csv"}) 
{

    $FileName = $strFileName.Name.Substring(33,8)
	#$RefDataSetDate = ([datetime]::ParseExact($strFileName.Name.Substring(33,8),”yyyyMMdd”,$null)).toshortdatestring()
	
	##11:00 PM Check For (T or T-1)
	$Date = $null
    [datetime]$getDate = get-date
    $11PM = Get-Date "1/1/9999 11:00 PM" 
	$Date = ([datetime]::ParseExact($strFileName.Name.Substring(33,8),”yyyyMMdd”,$null)) 
	
	if ($getDate.ToShortDateString() -eq $Date.ToShortDateString() -and $getDate.TimeOfday -lt $11PM.TimeOfday ) 
	{
	  $RefDataSetDate = $Date.AddDays(-1).ToShortDateString()
	}
	else
	{
	 $RefDataSetDate = $Date.ToShortDateString()
	}

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractLedgerAccountPortfolioMap.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $ArchiveFolder `r`n  FolderName = $WSO_Extracts_DIR `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


   	& $2016DTEXEC32 /F "$dirSSISExtractWSO\ExtractLedgerAccountPortfolioMap.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append

  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Account portfolio Map : $dirSSISExtractWSO\ExtractLedgerAccountPortfolioMap is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Account portfolio Map : $dirSSISExtractWSO\ExtractLedgerAccountPortfolioMap Completed " | Out-File $LogFile -Append
		}
		
	
	Move-Item "$WSO_Extracts_DIR\$strFileName" $dirArchiveFolder
    
	Write-Output "Source file $strFileName moved to folder $dirArchiveFolder\$strDateNow" | Out-File $logFile -Append
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


    & $2016DTEXEC32 /F "$dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Account portfolio Map : $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Account portfolio Map : $dirSSISNormalizeWSO\NormalizeWSOPortfolioLedgerMap.dtsx Completed " | Out-File $LogFile -Append
		}
		
  
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

