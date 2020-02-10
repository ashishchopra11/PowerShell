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

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\WSOPositionYTD."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
 
$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

#RefDataSetDate logic 
#$curr_date = Get-Date  
#$process_date = ($curr_date).AddDays(-1)
#$FullDayString = $process_date.ToString("MM/dd/yyyy")

#location 
$WSO_Extracts_DIR1 = "$dirServicesDeliveryStoreFolder\WSOOnDemand"
$ArchiveDir = "$dirArchiveHCM46DriveFolder\WSOYTDPositions\Archive"
$strDateNow = get-date -format "yyyyMMddTHHmmss"
New-Item -path $ArchiveDir\$strDateNow -ItemType directory
$ArchiveDir= $ArchiveDir+"\"+$strDateNow

#$WSO_Extracts_DIR1 = "\\services\DeliveryStore\WSOOnDemand"
#$dirSSISExtractWSO ="$dirArchiveHCM46DriveFolder\WSOOnDemand\YTD"
#$ScriptName = "Test.ps1"

$SourceFileName = "YTD_ExtractPerformance_*.csv"
$Label = "Performance YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[2]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPerformance.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPerformance.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPerformance : $dirSSISExtractWSO\High\ExtractPerformance.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPerformance : $dirSSISExtractWSO\High\ExtractPerformance.dtsx Completed " | Out-File $LogFile -Append
	}
	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}


$SourceFileName = "YTD_ExtractPosition_*.csv"
$Label = "Position YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[2]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $SourceFileName
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPosition.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPosition.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPerformance : $dirSSISExtractWSO\High\ExtractPosition.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPerformance : $dirSSISExtractWSO\High\ExtractPosition.dtsx Completed " | Out-File $LogFile -Append
	}	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}


$SourceFileName = "YTD_ExtractRealUnReal_*.csv"
$Label = "RealUnrealGain YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[2]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $SourceFileName
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractRealUnreal.dtsx"  /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRealUnreal : $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractRealUnreal : $dirSSISExtractWSO\High\ExtractRealUnreal.dtsx Completed " | Out-File $LogFile -Append
	}
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}


$SourceFileName = "YTD_ExtractSettleUnsettleComplete_*.csv"
$Label = "SettleUnsettle YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[2]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $SourceFileName
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractSettleUnsettle : $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractSettleUnsettle : $dirSSISExtractWSO\High\ExtractSettleUnsettle.dtsx Completed " | Out-File $LogFile -Append
	}	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}


$SourceFileName = "YTD_ExtractPositionCloseDate_*.csv"
$Label = "PositionCloseDate YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
$RefDataSetDate1 = $file.BaseName.Split("_")[2]
$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $SourceFileName
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPositionCloseDate : $dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPositionCloseDate : $dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx Completed " | Out-File $LogFile -Append
	}	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}

$SourceFileName = "YTD_ExtractPositionMap_*.csv"
$Label = "PositionMap YTD"
foreach ($file in Get-ChildItem	 -Path $WSO_Extracts_DIR1 | Where-Object {$_.Name -ilike $SourceFileName}) 
{  
#$RefDataSetDate1 = $file.BaseName.Split("_")[2]
#$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMdd”,$null)).toshortdatestring();

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	[String]$SourceFileName = $SourceFileName
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling $dirSSISExtractWSO\High\ExtractPositionMap.dtsx `r`n Variable passed here are : `r`n  Label = $Label `r`n DataSetDate = $RefDataSetDate `r`n  ArchiveFolder = $WSO_Extracts_DIR1 `r`n  FolderName = $WSO_Extracts_DIR1 `r`n  FileName = $file `r`n  ScriptName = $ScriptName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	 
#& $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx" /set "\package.variables[Label].Value;$Label" /set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
 & $2016DTEXEC32 /f "$dirSSISExtractWSO\High\ExtractPositionMap.dtsx" 	/set "\package.variables[Label].Value;$Label" 	/set "\package.variables[DataSetDate].Value;$RefDataSetDate" /set "\package.variables[ArchiveFolder].Value;$WSO_Extracts_DIR1"  /set "\package.variables[FolderName].Value;$WSO_Extracts_DIR1" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPositionMap : $dirSSISExtractWSO\High\ExtractPositionMap.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		}
		else{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ExtractPositionMap : $dirSSISExtractWSO\High\ExtractPositionCloseDate.dtsx Completed " | Out-File $LogFile -Append
	}	
	 ### Move imported file to Archive Directory
	Move-Item -Path $WSO_Extracts_DIR1\$file $ArchiveDir
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $ArchiveDir ) " | Out-File $LogFile -Append
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append