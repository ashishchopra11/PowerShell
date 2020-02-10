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
	$GenericImportJobID = 107
	$GenericNormaliztaionJobID = 	56

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\PershingPositionRecandPledge"

	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*psh_pos.out*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".out.", "_out_"
		$NewName = $NewName + ".csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*psh_pos_out*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace('|',',') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
	

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Normalization ******
	$RefDatasetDate = $ReturnDate
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

	## Normalize Pledge
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianPershingPledgeOnly.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $LogFile -Append
	
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Pershing Positions: file ( $strFileName ) NormalizeCustodianPershingPledgeOnly.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n############ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizePledge `r`n "| Out-File $LogFile -Append