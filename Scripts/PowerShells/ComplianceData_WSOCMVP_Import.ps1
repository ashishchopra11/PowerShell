
#############################
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################
	
## Variables
 #$SourceFilesDir = "\\services.hcmlp.com\DeliveryStore\WSOOnDemand"
 $SourceFilesDir = "$dirServicesDeliveryStoreFolder\WSOOnDemand"
 
 $RootDir		 = "$dirScriptsFolder\WSO"
 $ImportSSISDir	 = $dirSSISExtractWSO 
 $NormalizeSSISDir = $dirSSISNormalizeWSO
 $LogDir		 = $dirLogFolder
 [bool]$FileExists = $False
 
 ###Create Log folder, if needed
if(!(Test-Path -Path $LogDir )){
    New-Item -ItemType directory -Path $LogDir
}


 	$runDate 		= Get-Date
	$yymmddDate 	= $runDate.ToString("yyyyMMdd")
	$FullDayString  = $runDate.ToShortDateString()
	##$FileName       = "StateStreetPositions"+$yymmddDate+".csv"
	#$logFile 		= $LogDir+"\ExtractWSOCMVP"+$yymmddDate+".txt"
	
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$logFile 		= "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"
	
    $ArchiveDir     = "$dirDataFeedsArchiveFolder\WSOOnDemand\Archive\"
	$filePrefix 	= "SIEPE DO NOT USE Comprehensive Market Value Position_";

	$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $logFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $logFile -Append

Write-Output " SourceFilesDir`t`t`t= $SourceFilesDir" |  Out-File $logFile -Append
Write-Output " RootDir`t`t`t= $RootDir" |  Out-File $logFile -Append
Write-Output " ImportSSISDir`t`t`t= $ImportSSISDir" |  Out-File $logFile -Append
Write-Output " ArchiveDir`t`t`t= $ArchiveDir" |  Out-File $logFile -Append
Write-Output " FilePrefix`t`t`t= $filePrefix" |  Out-File $logFile -Append
Write-Output " LogFile`t`t`t= $logFile" |  Out-File $logFile -Append
	
## Create Archive Directory If not exists    
if(!(Test-Path -Path $ArchiveDir ))
{
    New-Item -ItemType directory -Path $ArchiveDir
    Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Created directory :: $ArchiveDir `r`n" |  Out-File $logFile -Append
    
}

##$RefDataSetDate="07/01/2014"
foreach ($strFileName in Get-ChildItem	 -Path $SourceFilesDir | Where-Object {$_.Name -ilike "$filePrefix*.CSV"}) 
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: WSOCMVP : file ( $strFileName ) processing " | Out-File $logFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSOCMVP source file to find RefDataSetDate" | Out-File $logFile -Append
	
    $dateString = $strFileName.Name.Substring($filePrefix.Length,8).ToString();
	$RefDataSetDate = [DateTime]::ParseExact($dateString, "yyyyMMdd",$null).ToString("MM/dd/yyyy");
	
	##SSIS Status Variables
  	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
    $FileExists = $True
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractWSOCMVP.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceFilesDir `r`n  FileName = $strFileName" | Out-File $logFile -Append
	& $2016DTEXEC64 /F "$ImportSSISDir\ExtractWSOCMVP.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[FolderName].Value;$SourceFilesDir" /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
  
    	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSOCMVP : file ( $strFileName ) not success" | Out-File $logFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $logFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSOCMVP : file ( $strFileName ) imported" | Out-File $logFile -Append

    
    ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeWSOCMVP.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
  	& $2016DTEXEC32 /F "$NormalizeSSISDir\NormalizeWSOCMVP.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  WSO CMVP : file ( $strFileName ) NormalizeWSOCMVP.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeWSOCMVP.dtsx `r`n "| Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	#$RefDataSetDate = "2017/05/02"
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeWSOCMVPAmortizationSchedule.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
  	& $2016DTEXEC32 /F "$NormalizeSSISDir\NormalizeWSOCMVPAmortizationSchedule.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  WSO CMVP : file ( $strFileName ) NormalizeWSOCMVPAmortizationSchedule.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeWSOCMVP.dtsx `r`n "| Out-File $LogFile -Append



    ###Move imported file to Archive Directory
    Move-Item -Force -Path $SourceFilesDir\$strFileName $ArchiveDir\ | Out-File $logFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $ArchiveDir ) " | Out-File $logFile -Append
    
}

If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file (ExtractCMPV_*.CSV) not exist at :: $SourceFilesDir " | Out-File $LogFile -Append    
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append