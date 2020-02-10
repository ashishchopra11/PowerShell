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
	$GenericImportJobID = 95

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\NorthernTrustCustodianUCITSCash"
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*Cash Activity Detail - Custody.XLS*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace("`,",'') | Set-Content -Path $FileName
		(Get-Content -Path $FileName).Replace("`t",',') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*Cash Activity Detail - Custody.XLS*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".XLS", ".csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate

	##SSIS Status Variables
    [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianNTCashWorksheetAccount.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n  PowerShellLocation = $PSScriptName    " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


    & $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianNTCashWorksheetAccount.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$PSScriptName"|  Out-File $logFile  -Append

	## Check SSIS is success or not 
	
    If ($lastexitcode -ne 0 ) {
	    $SSISErrorMessage = fSSISExitCode $lastexitcode;
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeCustodianNTCashWorksheetAccount : file ( $strFileName ) not success" | Out-File $LogFile -Append
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
	    Exit
		} 
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $PSScriptName END " | Out-File $LogFile -Append