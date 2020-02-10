############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################


$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("JefferiesLoadHaircuts_SSIS."+$strDateNow+".txt")
#$LogFile = "$dirLogFolder\JefferiesLoadHaircuts_SSIS.$strDateNow.txt"

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

#$jefferies_dir = "$dirProdHcmlpDataFeedsFolder\Jefferies"
#$jefferies_dir = "D:\Siepe\DataFeeds\Jefferies"

$jefferies_dir = "$dirServicesDeliveryStoreFolder\Jefferies Haircut Data"
$jefferies_dir_Archive = "$dirDataFeedsArchiveFolder\Jefferies Haircut Data\Archive\$strDateNow"

$ScriptName = $MyInvocation.MyCommand.Definition

Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

Write-Output " jefferies_dir		        = $jefferies_dir `r`n" | Out-File $LogFile -Append
Write-Output " jefferies_dir_Archive	        = $jefferies_dir_Archive `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append

###Create Archive folder
if (!(Test-Path -path $jefferies_dir_Archive )) { 
    New-Item -path $jefferies_dir_Archive -ItemType directory 
    }
	
foreach ($file in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*Portfolio-Margin-Detail.xls"}) 
{
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Jefferies Haircuts  : file ( $file ) processing " | Out-File $LogFile -Append

$date =  Get-Date -Year $file.Name.substring(9,4) -Month $file.Name.substring(13,2) -Day $file.Name.substring(15,2) -Format d
$fund =  $file.Name.substring(0,8)

& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesHaircutData.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[FundId].Value;$fund" /set "\package.variables[Directory].Value;$jefferies_dir" /set "\package.variables[FileName].Value;$file" /set "\package.variables[PowerShellLocation].Value;$ScriptName"/set "\package.variables[ArchiveDirectory].Value;$jefferies_dir_Archive" | Out-File $LogFile -Append

Move-Item -Path $file.FullName -Destination $jefferies_dir_Archive -Force

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $file ) to location ( $jefferies_dir_Archive ) " | Out-File $LogFile  -Append



}
<#
foreach ($file1 in Get-ChildItem	 -Path $jefferies_dir | Where-Object {$_.Name -ilike "*_Margin-Detail.xls"}) {

$date1 =  Get-Date -Year $file1.Name.substring(9,4) -Month $file1.Name.substring(13,2) -Day $file1.Name.substring(15,2) -Format d
$fund1 =  $file1.Name.substring(0,8)

& $2012DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesMarginDetail.dtsx" /set "\package.variables[RefDataSetDate].Value;$date1" /set "\package.variables[AccountId].Value;$fund1" /set "\package.variables[FileDirectory].Value;$jefferies_dir" /set "\package.variables[FileName].Value;$file1"
Move-Item -Path $file1.FullName -Destination $jefferies_dir_Archive
}
#>

& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesHaircutData.dtsx" /set "\package.variables[RefDataSetDate].Value;$date" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
#& $2016DTEXEC64 /F "$dirSSISNormalizeCustodian\NormalizeCustodianJefferiesMargin.dtsx" /set "\package.variables[RefDataSetDate].Value;$date1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

Write-PubSub -Subject "DataWarehouse.Datafeeds.Incoming" -Title "Jefferies Haircuts Loaded for pkg 1 - $date and pkg 2 - $date1" -Description "Jefferies has 2 seperate packages for 2 separate files that run Haircuts"

#Write-PubSub -Subject "Process.Jefferies.PosMarAssTran.StepFour" -Title "Complete - next Extract Jefferirs Assignment" -Description "Complete - next Extract Jefferirs Assignment"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
