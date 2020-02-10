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

	Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn
#################################################################################### 


#****** Initialize other variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirSourceFolderFile1 = "$dirServicesDeliveryStoreFolder\StateStreet\Pledge\File1"
	$dirSourceFolderFile2 = "$dirServicesDeliveryStoreFolder\StateStreet\Pledge\File2"
	$ScriptName = $MyInvocation.MyCommand.Definition


#****** Unzip files ******
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Remove .CSV files from zip" | Out-File $LogFile -Append
	
	Remove-Item -Path "$dirSourceFolderFile1\*.csv" -Force
	Expand-ZIPFile  –File "$dirSourceFolderFile1\attachment.zip" -Destination $dirSourceFolderFile1  | Out-File $logFile -Append
	
	Remove-Item -Path "$dirSourceFolderFile2\*.csv" -Force
	Expand-ZIPFile  –File "$dirSourceFolderFile2\attachment.zip" -Destination $dirSourceFolderFile2  | Out-File $logFile -Append

	

#****** Generic Import ******
	$GenericImportJobID = 47

	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

#****** Generic Import ******
	$GenericImportJobID = 48

	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)

	$RefDatasetDate = $ReturnDate

#****** Custom Pledge Normalization ******
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianStateStreetPositionPledge.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	## Load data to table 
	
	Write-Output "Normalize Custodian StateStreet PositionPledge started at: $($dtDate.ToString())" | Out-File $logFile -Append
	$GenericNormaliztaionJobID = 	59
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	
    #& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianStateStreetPositionPledge.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
    
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianStateStreetPositionPledge (RefDataSetDate = $RefDataSetDate) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NormalizeCustodianStateStreetPositionPledge (RefDataSetDate = $RefDataSetDate) success" | Out-File $LogFile -Append			

	$GenericNormaliztaionJobID = 73
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

	Remove-Item "$dirSourceFolderFile1\attachment.zip"
	Remove-Item "$dirSourceFolderFile2\attachment.zip"

	Write-PubSub -Subject "PledgeTool.ReferenceData.STST" -Title "Normalize State Street Pledge Data" -Description "Normalize State Street Pledge Data"
