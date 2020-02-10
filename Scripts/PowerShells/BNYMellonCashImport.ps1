############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\fGenericImportJob.ps1
####################################################################################
## Apose.Cells
[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv8)

###Create Log folder, if needed
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


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\BnyMellonCashImport"

#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append

$RefDataSetDate = ""

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  BNYMellonCashImport starts here " | Out-File $LogFile -Append


############################### BNY  MELLON CASH FILES - CASHFLOW GCM #######################


foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "Pension Denmark II – Highland*.xlsx"})
{
$GenericImportJobID=9
$dirArchiveFolderCashFlow 		= "$dirDataFeedsArchiveFolder\BnyMellonCashImport\Archive\CashFlow-GCM"
New-Item -path $dirArchiveFolderCashFlow\$strDateNow -ItemType directory

	$SplitArray = $strFileName.BaseName.split("–")
	$RefDataSetDateStr = $SplitArray[1].TrimEnd(".")
    $RefDataSetDateStr = $RefDataSetDateStr.substring(9,6)
	$RefDataSetDateStr = 	$RefDataSetDateStr.Trim()
	$pRefDataSetDate = ([datetime]::ParseExact($RefDataSetDateStr,”Mdyy”,$null)).toshortdatestring()
	
$xls = "$dirDataFeedsFolder\$strFileName"
$FileName = $strFileName.BaseName+".csv"
$FinalFile = "$dirDataFeedsFolder\$FileName"
$LoadOptions = New-Object Aspose.Cells.LoadOptions;
$LoadOptions.Password = "Pensionhigh"
$wb = New-Object Aspose.Cells.Workbook($xls,$LoadOptions);
$wb.Save($FinalFile);

$ReturnDate = ""

$text = [IO.File]::ReadAllText($FinalFile) 
if($text -imatch ",`r`n")
{
$text = $text -replace ",`r`n", "`r`n"
}

[IO.File]::WriteAllText($FinalFile, $text)

fGenericImportJob $GenericImportJobID $null $pRefDataSetDate $null $LogFile $null "$dirArchiveFolderCashFlow\$strDateNow" ([Ref]$ReturnDate)

$RefDataSetDate = $ReturnDate

########### Remove CSV File ####################
Remove-Item $FinalFile

	Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolderCashFlow\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolderCashFlow\$strDateNow ) " | Out-File $LogFile -Append
	
		################### Normalize GCM CashFlow #######################
			## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianBNYMellonCash_GCM_Cashflow_CashWorksheet.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $pRefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNYMellonCash_GCM_Cashflow_CashWorksheet.dtsx" /set "\package.variables[RefDataSetDate].Value;$pRefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") BNY Mellon GCM CASH IMPORT: file ( $strFileName ) NormalizeCustodianStateStreetCashImport_CashWorksheet.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		

}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
