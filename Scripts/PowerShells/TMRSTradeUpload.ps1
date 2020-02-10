############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
####################################################################################
$runDate 		= Get-Date
$yymmddDate 	= $runDate.ToString("yyyyMMdd")
$FullDayString  = $runDate.ToShortDateString()
#$LogFile 		= $dirLogFolder+"\TMRSTradeFile"+$yymmddDate+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add-PSSnapin :: HCMLP.Data.PowerShell.PubSubSnapIn `r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

## Variables
 	$TradeFilesDir = "$dirServicesDeliveryStoreFolder\StateStreet\TMRSTradeFiles"
 	$hourDate = $runDate.ToString("HH")
	$minuteDate = $runDate.ToString("mm")
	$RawFile  = "Purchase and Sales.xlsx"
	$NewFile  = "Highland_TMRS_Weekly_Trades.xlsx"
    $ArchiveDir     = "$dirArchiveHCM46DriveFolder\StateStreet\TMRSTradeFiles\Archive\"+$yymmddDate
    $archive     = @("*Archive*");
	$RawFilePath = $TradeFilesDir+"\"+$RawFile
	$NewFilePath = $TradeFilesDir+"\"+$NewFile
	$ArchivePath = $ArchiveDir+"\"+$NewFile
    
 Write-Output " TradeFilesDir	= $TradeFilesDir" | Out-File $LogFile -Append
 Write-Output " HourDate		= $hourDate" | Out-File $LogFile -Append
 Write-Output " MinuteDate		= $minuteDate" | Out-File $LogFile -Append
 Write-Output " RawFile			= $RawFile" | Out-File $LogFile -Append
 Write-Output " NewFile			= $NewFile" | Out-File $LogFile -Append
 Write-Output " ArchiveDir		= $ArchiveDir" | Out-File $LogFile -Append
 Write-Output " Archive			= $archive" | Out-File $LogFile -Append
 Write-Output " RawFilePath		= $RawZIPFilePath" | Out-File $LogFile -Append
 Write-Output " NewFilePath		= $NewUnZIPFilePath" | Out-File $LogFile -Append
 Write-Output " LogFile			= $LogFile `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Set Location : $TradeFilesDir `r`n" |  Out-File $LogFile -Append
Set-Location $TradeFilesDir

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Removing Item : $NewFile  `r`n" |  Out-File $LogFile -Append
Remove-Item $NewFile


## Create Archive Directory with Current date.    
if(!(Test-Path -Path $ArchiveDir )){
    New-Item -ItemType directory -Path $ArchiveDir
}
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::Created Directory : $ArchiveDir `r`n" |  Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Renaming file $RawFile to $NewFile  `r`n" |  Out-File $LogFile -Append
Rename-Item -Force $RawFile $NewFile

if((Test-Path -Path $NewFilePath)){
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Coping file $NewFilePath to $ArchivePath  `r`n" |  Out-File $LogFile -Append
	Copy-Item -force -Path $NewFilePath -Destination $ArchivePath   
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: File.TMRSTrades.Ready ,Title : TMRS Trades ready for delivery, Description : $FullDayString `r`n" |  Out-File $LogFile -Append
	Write-PubSub -Subject "File.TMRSTrades.Ready" -Title "TMRS Trades ready for delivery" -Description "$FullDayString"		
} else {
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: File.TMRSTrades.Missing ,Title : TMRS Trade File was missing, Description : $FullDayString `r`n" |  Out-File $LogFile -Append
	Write-PubSub -Subject "File.TMRSTrades.Missing" -Title "TMRS Trade File was missing" -Description "$FullDayString"
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
