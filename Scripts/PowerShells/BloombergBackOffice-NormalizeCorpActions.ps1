#############################
#### Normalize CAX
#############################
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

param([String]$LogFile = $Null ,[datetime]$RefDataSetDate = $NULL)

If ($LogFile -eq $null)
{
##LogFile
$strDateNow= get-date -format "yyyyMMddTHHmmss"
$logTime= get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\BloombergBackOfice.NormalizeVendorBloombergEquityCorpActions."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

}

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append



#$BackOffice_data = "$dirArchiveHCM46DriveFolder\Bloomberg Back Office"
$BackOffice_data = "$dirServicesDeliveryStoreFolder\Bloomberg\Bloomberg Back Office"
$curr_date = Get-Date

$dirArchiveFolder  = "$dirArchiveHCM46DriveFolder\Bloomberg Back Office"
 

$ArchiveDirDayString  = $curr_date.Year.ToString() + $curr_date.Month.ToString().PadLeft(2, "0") + $curr_date.Day.ToString().PadLeft(2, "0")
$BackOffice_data_ZipFolder = "$dirServicesDeliveryStoreFolder\Bloomberg\Bloomberg Back Office\$ArchiveDirDayString"

Write-Output " BackOffice_data`t`t`t= $BackOffice_data" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder`t`t`t= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " ArchiveDirDayString`t`t`t= $ArchiveDirDayString" |  Out-File $LogFile -Append
Write-Output " BackOffice_data_ZipFolder`t`t`t= $BackOffice_data_ZipFolder" |  Out-File $LogFile -Append
Write-Output " logFile`t`t`t= $logFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Bloomberg Equity Corp Actions starts here " | Out-File $LogFile -Append
#$RefDataSetDate = $RefDataSetDate.addDays(-1)

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergEquityCorpActions.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergEquityCorpActions.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergEquityCorpActions.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Equity Corp Actions : NormalizeVendorBloombergEquityCorpActions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergEquityCorpActions.dtsx `r`n "| Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Bloomberg CorpAction Shareholder Meetings starts here " | Out-File $LogFile -Append
#$RefDataSetDate = $RefDataSetDate.addDays(-1)

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionShareholderMeetings.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionShareholderMeetings.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionShareholderMeetings.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Shareholder Meetings : NormalizeVendorBloombergCorpActionShareholderMeetings.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionShareholderMeetings.dtsx `r`n "| Out-File $LogFile -Append


## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionCashDividends.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionCashDividends.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionCashDividends.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Shareholder Meetings : NormalizeVendorBloombergCorpActionCashDividends.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionCashDividends.dtsx `r`n "| Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionStockDividends.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionStockDividends.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionStockDividends.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Stock Dividends: NormalizeVendorBloombergCorpActionStockDividends.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionStockSplits.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionStockSplits.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionStockSplits.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Stock Dividends: NormalizeVendorBloombergCorpActionStockSplits.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionInstAcquisition.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstAcquisition.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstAcquisition.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Inst Acqusition: NormalizeVendorBloombergCorpActionInstAcquisition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionInstAcquisition.dtsx `r`n "| Out-File $LogFile -Append

## --push Instruments  into HCM
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstruments.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append  
     & $2016DTEXEC32 /f "$dirSSISPush\PushInstruments.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  BBG Corp Action : $dirSSISPush\PushInstruments.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BBG Corp Action : $dirSSISPush\PushInstruments.dtsx Completed " | Out-File $LogFile -Append
	}

#################################### Inst Relation in Reference ##############################################
		
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionInstRelation.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstRelation.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstRelation.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Inst Relation: NormalizeVendorBloombergCorpActionInstRelation.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionInstRelation.dtsx `r`n "| Out-File $LogFile -Append

## --push Instruments  into HCM
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstruments.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append  
     & $2016DTEXEC32 /f "$dirSSISPush\PushInstruments.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  BBG Corp Action : $dirSSISPush\PushInstruments.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BBG Corp Action : $dirSSISPush\PushInstruments.dtsx Completed " | Out-File $LogFile -Append
	}

## --push Inst Relation  into HCM
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISPush\PushInstRelation.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append  
     & $2016DTEXEC32 /f "$dirSSISPush\PushInstRelation.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  BBG Corp Action : $dirSSISPush\PushInstRelation.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") BBG Corp Action : $dirSSISPush\PushInstRelation.dtsx Completed " | Out-File $LogFile -Append
	}



	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Inst Acqusition: NormalizeVendorBloombergCorpActionInstAcquisition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionInstAcquisition.dtsx `r`n "| Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeVendorBloombergCorpActionInstSpinOff.dtsx " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
IF ($RefDataSetDate -eq $null)
{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstSpinOff.dtsx"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}
ELSE{
& $2016DTEXEC64 /f "$dirSSISNormalizeVendor\NormalizeVendorBloombergCorpActionInstSpinOff.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
}


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Bloomberg Inst SpinOff: NormalizeVendorBloombergCorpActionInstSpinOff.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeVendorBloombergCorpActionInstSpinOff.dtsx `r`n "| Out-File $LogFile -Append

Set-Location $BackOffice_data
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $BackOffice_data " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Adding Archive Folder :: $dirArchiveFolder\$ArchiveDirDayString  " | Out-File $LogFile -Append
New-Item -type directory $BackOffice_data_ZipFolder

Set-Location "$BackOffice_data\Securities & Pricing"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $BackOffice_data\Securities & Pricing " | Out-File $LogFile -Append

Move-Item *.enc $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.enc ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.out $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.out ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.px  $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.px ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.dif $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.dif ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.cax $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.cax ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.hpc $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.hpc ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.txt $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.txt ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

Move-Item *.rpx $BackOffice_data_ZipFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( *.rpx ) to location ( $dirArchiveFolder\$ArchiveDirDayString ) " | Out-File $LogFile -Append

	##COMPRESS THE FILES##
	& "C:\Program Files\WinRAR\winrar.exe" a -r -ep1 -df -ed -ibck "$BackOffice_data_ZipFolder\$ArchiveDirDayString.rar" $BackOffice_data_ZipFolder 
	sleep -Seconds 300
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Compressed the source files ($BackOffice_data_ZipFolder\$ArchiveDirDayString.rar) " | Out-File $LogFile -Append
	
	## MOVE COMPRESSED FILES
	Move-Item -Path "$BackOffice_data_ZipFolder\$ArchiveDirDayString.rar" -Destination $dirArchiveFolder -Verbose -Force *>&1 | Out-File $LogFile -Append
	sleep -Seconds 5 
	Remove-Item -Path $BackOffice_data_ZipFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Moved compresses file ($BackOffice_data_ZipFolder\$ArchiveDirDayString.rar) to $dirArchiveFolder " | Out-File $LogFile -Append

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
