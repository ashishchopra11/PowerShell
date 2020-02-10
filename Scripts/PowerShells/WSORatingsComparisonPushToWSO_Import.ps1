############## Reference to configuration files ###################################
CLS
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\WSORatingReportsExtract."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
 
 
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$ScriptName = $MyInvocation.MyCommand.Definition

$WSO_Extracts_DIR1 = "$dirServicesDeliveryStoreFolder\WSOOnDemand"
$ArchiveDir = "$dirArchiveHCM46DriveFolder\WSORatingsComparison\Archive"

New-Item -path $ArchiveDir\$strDateNow -ItemType directory
$ArchiveDir= $ArchiveDir+"\"+$strDateNow

$SourceFileName = "RatingAnalysisReportsAssetNoPos_*"

$FileExist = 0

foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[1]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();
$FileExist = 1
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractRatingAnalysisReportsAssetNoPos.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractRatingAnalysisReportsAssetNoPos.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RatingAnalysisReportsAssetNoPos : $dirSSISExtractWSO\ExtractRatingAnalysisReportsAssetNoPos.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RatingAnalysisReportsAssetNoPos : $dirSSISExtractWSO\ExtractRatingAnalysisReportsAssetNoPos.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}

$SourceFileName = "RatingAnalysisReports_*"

foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[1]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();
$FileExist = 1
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractRatingAnalysisReport.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractRatingAnalysisReport.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRatingAnalysisReport : $dirSSISExtractWSO\ExtractRatingAnalysisReport.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRatingAnalysisReport : $dirSSISExtractWSO\ExtractRatingAnalysisReport.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}
$SourceFileName = "StaleRatingReports_*"

foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[1]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();
$FileExist = 1
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractStaleRatingReport.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractStaleRatingReport.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractStaleRatingReport : $dirSSISExtractWSO\ExtractStaleRatingReport.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractStaleRatingReport : $dirSSISExtractWSO\ExtractStaleRatingReport.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}
$SourceFileName = "RatingOverride_*"

foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[1]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();
$FileExist = 1
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\ExtractRatingOverride.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractRatingOverride.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRatingOverride : $dirSSISExtractWSO\ExtractRatingOverride.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRatingOverride : $dirSSISExtractWSO\ExtractRatingOverride.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}
#if ($FileExist -eq 1)
#{
#	Write-PubSub -Subject "WSORating.Reports.RatingReports"
#	Write-Output "`r`n`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Write-PubSub -Subject : WSORating.Reports.RatingReports `r`n" | Out-File $LogFile -Append
#
#}


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

