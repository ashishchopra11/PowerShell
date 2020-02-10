############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################
[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);


$runDate 		= Get-Date
$yymmddDate 	= $runDate.ToString("yyyyMMdd")
$FullDayString  = $runDate.ToShortDateString()
#$LogFile 		= $dirLogFolder+"\TMRSPositionUnzip"+$yymmddDate+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$yymmddDate+".txt"


$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add-PSSnapin :: HCMLP.Data.PowerShell.PubSubSnapIn `r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Variables
	$PositionFilesDir = "$dirServicesDeliveryStoreFolder\StateStreet\TMRSPositionFiles"
	$StateSreetPositionRecDir = "$dirServicesDeliveryStoreFolder\StateStreet\Position Files\PY4A"
 
 	$hourDate = $runDate.ToString("HH")
	$minuteDate = $runDate.ToString("mm")
	$RawZIPFile    = "attachment.zip"
	$RawUnZIPFile  = "Positions PY4A (RM).csv"
	$NewUnZIPFile  = "Highland_TMRS_Daily_holdings.xls"
	$ArchiveDir     = "$dirArchiveHCM46DriveFolder\StateStreetTMRSPositionFiles\Archive\"+$yymmddDate
	$archive     = @("*Archive*");
	$RawZIPFilePath = $PositionFilesDir+"\"+$RawZIPFile
	$RawUnZIPFilePath = $PositionFilesDir+"\"+$RawUnZIPFile
	$NewUnZIPFilePath = $PositionFilesDir+"\"+$NewUnZIPFile
	
 Write-Output " PositionFilesDir			= $PositionFilesDir" | Out-File $LogFile -Append
 Write-Output " StateSreetPositionRecDir	= $StateSreetPositionRecDir" | Out-File $LogFile -Append
 Write-Output " HourDate					= $hourDate" | Out-File $LogFile -Append
 Write-Output " MinuteDate					= $minuteDate" | Out-File $LogFile -Append
 Write-Output " RawZIPFile					= $RawZIPFile" | Out-File $LogFile -Append
 Write-Output " RawUnZIPFile				= $RawUnZIPFile" | Out-File $LogFile -Append
 Write-Output " NewUnZIPFile				= $NewUnZIPFile" | Out-File $LogFile -Append
 Write-Output " ArchiveDir					= $ArchiveDir" | Out-File $LogFile -Append
 Write-Output " Archive						= $archive" | Out-File $LogFile -Append
 Write-Output " RawZIPFilePath				= $RawZIPFilePath" | Out-File $LogFile -Append
 Write-Output " RawUnZIPFilePath			= $RawUnZIPFilePath" | Out-File $LogFile -Append
 Write-Output " NewUnZIPFilePath			= $NewUnZIPFilePath" | Out-File $LogFile -Append
 Write-Output " LogFile						= $LogFile `r`n" | Out-File $LogFile -Append
 
 
 
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Set Location : $PositionFilesDir `r`n" |  Out-File $LogFile -Append
 
Set-Location $PositionFilesDir

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Removing Item : Highland_TMRS_Daily_holdings.xls,Positions PY4A (RM).csv  `r`n" |  Out-File $LogFile -Append
 
Remove-Item "Highland_TMRS_Daily_holdings.xls"
Remove-Item "Positions PY4A (RM).csv"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Started TMRSPositionUnzip `r`n" |  Out-File $LogFile -Append
## Create Archive Directory with Current date.    
if(!(Test-Path -Path $ArchiveDir )){
    New-Item -ItemType directory -Path $ArchiveDir
}
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Created Directory : $ArchiveDir `r`n" |  Out-File $LogFile -Append
if((Test-Path -Path $RawZIPFilePath)){
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Unzipping started for file ($RawZIPFile) `r`n" |  Out-File $LogFile -Append

	# UnRAR the file. -y responds Yes to any queries UnRAR may have.
	&  "C:\Program Files\WinRAR\Winrar.exe" x -y -o+ $RawZIPFile $PositionFilesDir | Wait-Process 
	
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Unzipping completed for file ($RawZIPFile) `r`n" |  Out-File $LogFile -Append

	if((Test-Path -Path $RawUnZIPFilePath)){
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Coping $RawZIPFile to $StateSreetPositionRecDir `r`n" |  Out-File $LogFile -Append
		Copy-Item -force $RawZIPFile $StateSreetPositionRecDir
		
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: StateStreet.PositionFile.Received.PY4A ,Title : , Description :  `r`n" |  Out-File $LogFile -Append
		Write-PubSub -Subject "StateStreet.PositionFile.Received.PY4A" -Title "" -Description ""

		Move-Item -force $RawZIPFile $ArchiveDir   
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Moved $RawZIPFile to $ArchiveDir `r`n" |  Out-File $LogFile -Append
		
		$wb = New-Object Aspose.Cells.Workbook($RawUnZIPFilePath);
	
		
	$ws = $wb.Worksheets[0]
	
	$wb.Save($NewUnZIPFilePath)
	
	$wb1 = New-Object Aspose.Cells.Workbook($NewUnZIPFilePath);
		
	$ws = $wb1.Worksheets[0]
	$ws.Name = "Positions PY4A (RM)"
	
	$wb1.Save($NewUnZIPFilePath)

	
	<#	$xl = New-Object -ComObject "Excel.Application"
		$xl.DisplayAlerts = $false
		$xl.Visible = $false
		$wb = $xl.Workbooks.OpenText($RawUnZIPFilePath)
		$wb = $xl.ActiveWorkbook
		$wb.SaveAs($NewUnZIPFilePath, 51)
		$xl.Quit() | Out-File -encoding ASCII -append -FilePath $logFile#>
		
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed TMRSPositionUnzip `r`n" |  Out-File $LogFile -Append
		
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: File.TMRSPositions.Unzipped ,Title : TMRS Positions unzipped and ready for delivery, Description : $FullDayString `r`n" |  Out-File $LogFile -Append
		Write-PubSub -Subject "File.TMRSPositions.Unzipped" -Title "TMRS Positions unzipped and ready for delivery" -Description "$FullDayString"		
	} 
	else {
		Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: File.TMRSPositions.BadFile ,Title : TMRS Positions attachment.zip did not contain correct contents, Description : $FullDayString `r`n" |  Out-File $LogFile -Append
		Write-PubSub -Subject "File.TMRSPositions.BadFile" -Title "TMRS Positions attachment.zip did not contain correct contents" -Description "$FullDayString"
	}
} 
else {
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject: File.TMRSPositions.Missing ,Title : TMRS Positions attachment.zip was missing, Description : $FullDayString `r`n" |  Out-File $LogFile -Append
	Write-PubSub -Subject "File.TMRSPositions.Missing" -Title "TMRS Positions attachment.zip was missing" -Description "$FullDayString"
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
