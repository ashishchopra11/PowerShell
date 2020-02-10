############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1

####################################################################################


if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+$strDateNow+".txt"
#$logFile 				= "$dirLogFolder\ImportCustodianBNPRebate.$strDateNow.txt"


$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\MizuhoRepoPositions"
$dirArchiveFolderCashFlow 		= "$dirDataFeedsArchiveFolder\MizuhoRepoPositions\Archive"
New-Item -path $dirArchiveFolderCashFlow\$strDateNow -ItemType directory

#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolderCashFlow" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append

$RefDataSetDate = ""

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  BNYMellonCashImport starts here " | Out-File $LogFile -Append



################################################ LEDGER TRANSACTIONS #############################################################

<#
##Create Archive folder
if (!(Test-Path -path $dirArchiveFolder))
    { 	
	    New-Item -path $dirArchiveFolder -ItemType directory 
    }
#>
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "HIGHLAND GLOBAL*.xlsx"}) 
{
   $RefDataSetDate = $null
  
   
   <#
   $SplitArray = $strFileName.BaseName.split("–")
	$RefDataSetDateStr = $SplitArray[1].TrimEnd(".")
    $RefDataSetDateStr = $RefDataSetDateStr.substring(9,6)
	$RefDataSetDateStr = 	$RefDataSetDateStr.Trim()
	$pRefDataSetDate = ([datetime]::ParseExact($RefDataSetDateStr,”Mdyy”,$null)).toshortdatestring()
	 #>
    $FileName = $strFileName.Name
    $RefDataSetDateStr = $strFileName.Name.Substring(15,4)
    $RefDataSetDateStr = 	$RefDataSetDateStr.Trim(".")
    $pRefDataSetDate = ([datetime]::ParseExact($RefDataSetDateStr,”M.d”,$null)).toshortdatestring()
	
	

	Write-Output "RefDatasetDate : $pRefDataSetDate " | Out-File $logFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractCustodian\ImportCustodianMSUSAFIMarginReport.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayString `r`n  ArchiveFolder = $ArchiveFolderTran `r`n  FolderName = $WSO_Extracts_DIRTran `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


 & $2016DTEXEC32 /f "$dirSSISExtractCustodian\ImportCustodianMSUSAFIMarginReport.dtsx" /set "\package.variables[RefDataSetDate].Value;$pRefDataSetDate" /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[FileName].Value;$FileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Ledger Transaction : $dirSSISExtractCustodian\ImportCustodianMSUSAFIMarginReport.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
	else{
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  Ledger Transaction : $dirSSISExtractCustodian\ExtractLedgerTransactions.dtsx Completed " | Out-File $LogFile -Append
		}
		
	
#Remove-Item $FinalFile

	Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolderCashFlow\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolderCashFlow\$strDateNow ) " | Out-File $LogFile -Append
    

}