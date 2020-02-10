############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

#Add-PSSnapin HCMLP.Data.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

##LogFile
$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\Geneva Uploads."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
$LogFile

############################ Calling D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-BloombergPushPricesToGeneva2.ps1 #################################
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PowerShell : D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-BloombergPushPricesToGeneva2.ps1 `r`n" |   Out-File $LogFile -Append
$command = "D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFX-BloombergPushPricesToGeneva2.ps1  -LogFile $LogFile"
Invoke-Expression $command

$LogFile

############################ Calling D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaFXRates.ps1 #################################
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PowerShell : D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaFXRates.ps1 `r`n" |   Out-File $LogFile -Append
$command = "D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFX-UploadGenevaFXRates.ps1  -LogFile $LogFile"
Invoke-Expression $command

$LogFile

### THIS SECTION COMMENTED OUT BY MD ON 2018-12-17 - MIGRATED TO REPORT SUBSCRIPTION ###
<#
	############################ Calling D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockSplit.ps1 #################################
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PowerShell : D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockSplit.ps1 `r`n" |   Out-File $LogFile -Append
	$command = "D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockSplit.ps1  -LogFile $LogFile"
	Invoke-Expression $command

	$LogFile

	############################ Calling D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockDiv.ps1 #################################
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PowerShell : D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockDiv.ps1 `r`n" |   Out-File $LogFile -Append
	$command = "D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXStockDiv.ps1  -LogFile $LogFile"
	Invoke-Expression $command

	$LogFile

	############################ Calling D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXCashDiv.ps1 #################################
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling PowerShell : D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXCashDiv.ps1 `r`n" |   Out-File $LogFile -Append
	$command = "D:\Siepe\Data\Scripts\PROD\GenevaUpload_PricesFXCorporateActions-UploadGenevaBBCAXCashDiv.ps1  -LogFile $LogFile"
	Invoke-Expression $command

	$LogFile
#>

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
