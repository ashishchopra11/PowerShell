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
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"

###Create Log file


$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("WSORatingsResponse."+$strDateNow+".txt")
#$logFile 				= "$dirLogFolder\WSORatingsResponse.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\WSO Ratings Comparison"
$dirArchiveFolder 		= "$dirArchiveHCM46DriveFolder\WSORatingsResponse\Archive"
$XSDPath                = "$dirArchiveHCM46DriveFolder\WSORatingsResponse\XSD\WSOWebOverrideRatingResponse.xsd"
#$dirArchiveFolder 		= "E:\Siepe\DataFeeds\WSORatingsResponse\Archive"
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory


#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append
Write-Output " XSDPath						= $XSDPath" |  Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSO Ratings Response starts here " | Out-File $LogFile -Append
$dateStr=""

foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.WSORatingsOverride_*.CSV.xml"})
{
   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSO Ratings Response : file ( $strFileName ) processing " | Out-File $LogFile -Append
   $DatePart = ($strFileName.BaseName -split '_')[1]
   $DateStr=$DatePart.Substring(0,8)
  	
	$dtDataSetDate = ([datetime]::ParseExact($DateStr,"yyyyMMdd",$null)).toshortdatestring()
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from $strFileName Column [DataSetDate] :: $dtDataSetDate " | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportWSOWebOverrideRatingResponse.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $dtDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   	& $2016DTEXEC32 /F "$dirSSISDataTransfer\ImportWSOWebOverrideRatingResponse.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate"  /set "\package.variables[XSDPath].Value;$XSDPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSO Ratings Response: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSO Ratings Response: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
	
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append