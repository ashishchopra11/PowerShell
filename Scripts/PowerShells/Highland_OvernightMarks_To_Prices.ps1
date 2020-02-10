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
#$LogFile = "$dirLogFolder\NormalizeInstPrice."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$RefDataSetDate = Get-Date
$PriceDate = $RefDataSetDate.AddDays(-1).ToShortDateString()
$RefDataSetDate
$FullDayString  = $RefDataSetDate.ToString("MM/dd/yyyy")

Write-Output " LogFile			= $LogFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Normalize Inst Price starts here " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Getting Current date as RefDataSetDate :: $FullDayString " | Out-File $LogFile -Append
## SSIS Status Variables
	[Int]$lastexitcode 			= $null
	[String]$SSISErrorMessage 	= $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeInstPrice.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	## NormalizeInstPrice
	& $2016DTEXEC32 /F "$dirSSISDataTransfer\NormalizeInstPrice.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Normalize Inst Price: NormalizeInstPrice.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeInstPrice.dtsx `r`n "| Out-File $LogFile -Append

# Calling for Geneva.fPriceXML(Curr_Date/RefDataSetDate) - this powerShell is pointing to Production PHCMDB01
$command = "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-PushPricesToGeneva.ps1 –RefDataSetDate $PriceDate  -LogFile $logFile"
Invoke-Expression $command
#& "D:\Siepe\Data\Scripts\PROD\BloombergBackOffice-PushPricesToGeneva.ps1" -LogFile $LogFile –RefDataSetDate $PriceDate 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append