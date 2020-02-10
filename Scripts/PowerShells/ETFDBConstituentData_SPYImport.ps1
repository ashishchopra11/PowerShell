############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directoryo -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
#$logFile 				= "$dirLogFolder\ImportVendorETFDBHoldings.$strDateNow.txt"


$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

########################General Ledger ###############################
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\EtfDB\SPY"
$dirArchiveFolder 		= "$dirArchiveHCM46DriveFolder\EtfDB\SPY\Archive"	  

New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
#
##Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Log starts here " | Out-File $LogFile -Append


## Import

foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder -Recurse | Where-Object {$_.Name -ilike "*holdings*.csv"})
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  File ( $strFileName ) processing " | Out-File $LogFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
    $FullPath = $strFileName.FullName  
    
		
	$AA = Get-Content -Path $FullPath | Select-String -pattern "Fund Holdings as of"
	$DatasetDate =   ($AA.Line -split ':')[1] 
    $DatasetDate =     $DatasetDate.Trim()

    $dtDataSetDate = ([datetime]::ParseExact($DatasetDate,”yyyy-MM-dd”,$null)).toshortdatestring()

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   	& $2016DTEXEC64 /f "$dirSSISExtractVendor\ImportVendorETFDBConstituentDataSpyImport.dtsx"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate"  /set "\package.variables[FileName].Value;$strFileName" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile  -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") File ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") File ( $strFileName ) imported" | Out-File $LogFile -Append
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
	
}


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append