############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\DTExec.Config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\fOffsetDate.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericImportJobID = 13
	$GenericNormaliztaionJobID = 34

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
    
	$ScriptName = $MyInvocation.MyCommand.Definition

 
#****** Generic Import ******
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate

#****** Generic Normalization ******
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

#****** Custom Pledge Normalization ******
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	$RefDataSetDate = fOffsetDate $RefDataSetDate -offsetType "T" -offsetDirection "+" -offsetAmount "1"
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianBNYCustodianRetailData_PositionPledge.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate_In = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	## Load data to table 
	
	Write-Output "NormalizeCustodianBNYCustodianRetailData_PositionPledge started at: $($dtDate.ToString())" | Out-File $logFile -Append
	$GenericNormaliztaionJobID = 61
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
    
    Write-Output "NormalizeCustodianBNYCustodianRetailData_PositionPledge_New started at: $($dtDate.ToString())" | Out-File $logFile -Append
	$GenericNormaliztaionJobID = 72
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	
    #& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBNYCustodianRetailData_PositionPledge.dtsx" /set "\package.variables[RefDataSetDate_In].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
    
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianBNYCustodianRetailData_PositionPledge (RefDataSetDate_In = $RefDataSetDate) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianBNYCustodianRetailData_PositionPledge (RefDataSetDate_In = $RefDataSetDate) success" | Out-File $LogFile -Append			
