CLS

#. "C:\HCM\Scripts\Config.ps1"

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

## Variables
 $SourceFilesDir = "$dirServicesDeliveryStoreFolder\WSOOnDemand"
  
 $RootDir		 = "D:\Siepe\Data\Scripts\WSO" 
 $ImportSSISDir	 = "D:\Siepe\Data\SSIS\ExtractWSO"
 #$LogDir		 = "$RootDir\Log"

 [bool]$FileExists = $False
 
 
 
 	$runDate 		= Get-Date
	$yymmddDate 	= $runDate.ToString("yyyyMMdd")
	$FullDayString  = $runDate.ToShortDateString()
	##$FileName       = "StateStreetPositions"+$yymmddDate+".csv"
	#$logFile 		= $dirLogFolder+"\ImportWSOPrincipalCashBalance"+$yymmddDate+".txt"
	
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$logFile 		= "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"
    $ArchiveDir     = "$dirDataFeedsArchiveFolder\WSOOnDemand\Archive\"
    
$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

Write-Output " SourceFilesDir		= $SourceFilesDir" |  Out-File $LogFile -Append
Write-Output " logFile				= $LogDir" |  Out-File $LogFile -Append
Write-Output " ArchiveDir			= $ArchiveDir" |  Out-File $LogFile -Append
Write-Output " ImportSSISDir		= $ImportSSISDir" |  Out-File $LogFile -Append

## Create Archive Directory If not exists    
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Creating Archive Directory if not exists :: $ArchiveDir " | Out-File $LogFile -Append
if(!(Test-Path -Path $ArchiveDir ))
{
    New-Item -ItemType directory -Path $ArchiveDir
}

$filePrefix = "PrincipalCashBalance_";
##$RefDataSetDate="07/01/2014"
foreach ($strFileName in Get-ChildItem	 -Path $SourceFilesDir | Where-Object {$_.Name -ilike "$filePrefix*.CSV"}) 
{
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  WSO Cash: file ( $strFileName ) processing " | Out-File $LogFile -Append

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
    $dateString = $strFileName.Name.Substring($filePrefix.Length,8).ToString();
	$RefDataSetDate = [DateTime]::ParseExact($dateString, "yyyyMMdd",$null).ToString("MM/dd/yyyy");
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Parsed RefDataSetDate from file Name ( $strFileName ) :: $RefDataSetDate " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
    $FileExists = $True
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractPrincipalCashBalance.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceFilesDir `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$ImportSSISDir\ExtractPrincipalCashBalance.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$SourceFilesDir" /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
     ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss")  WSO Cash : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss")  WSO Cash : file ( $strFileName ) imported" | Out-File $LogFile -Append
	
    
    ###Move imported file to Archive Directory
    Move-Item -Force -Path $SourceFilesDir\$strFileName $ArchiveDir\ | Out-File $logFile -Append
    	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $SourceFilesDir\$strFileName ) to location ( $ArchiveDir\ ) " | Out-File $LogFile -Append
}

If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file (PrincipalCashBalance_*.CSV) not exist at :: $SourceFilesDir " | Out-File $LogFile -Append    
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append