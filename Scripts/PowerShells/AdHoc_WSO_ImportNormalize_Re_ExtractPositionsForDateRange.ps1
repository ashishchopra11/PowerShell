############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################


$working_dir = "D:\Siepe\DataFeeds\WSOReports"
$day = Get-Date -date "2017-04-11"
$end_date = Get-Date -date "2017-04-14"
$archive_dir = "D:\Siepe\DataFeeds\WSOReports\ReExtract"
$XMLFolderPath="\\hcm97\PMPDataFeeds\Geneva"
#$SSIS_Extract_Dir = "C:\HCM\SSIS2012.Datawarehouse\ExtractWSO\bin"
#$SSIS_Normalize_Dir = "C:\HCM\SSIS2012.Datawarehouse\NormalizeWSO\bin"
#$GVExtract_dir = "C:\HCM\SSIS2012.DataWarehouse\ExtractGeneva\bin"
#$GVNormalize_Dir = "C:\HCM\SSIS2012.DataWarehouse\NormalizeGeneva\bin"

$ITD_Flag = "No"
$runDate 		= Get-Date
$logTime	 	= $runDate.ToString("yyyyMMdd")
#$logFile 		= $dirLogFolder+"\ReloadWSOPositions"+$logTime+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Set-Location -path $working_dir

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

while ($day -le $end_date) {
	$ArchiveDirDayString  = $day.Year.ToString() + $day.Month.ToString().PadLeft(2, "0") + $day.Day.ToString().PadLeft(2, "0")
	$FullDayString = $day.ToShortDateString()
	Set-Location $working_dir
	Write-Output $day

	### WSO Extract
#	Remove-Item *.CSV
#	Write-Output "[Reports]" > Extracts.ini
#	Write-Output " 1=Report=ExtractPosition@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractPosition##False@;@PRP_AsOfDate=False|Today|$FullDayString|@;@PRP_Portfolios=ALL" >> Extracts.ini
#	Write-Output " 2=Report=ExtractSettleUnsettleComplete@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractSettleUnsettleComplete##False@;@PRP_StartEndDate=False|Month to Date|$FullDayString|$FullDayString@;@PRP_Portfolios=ALL@;@PRP_BaseCurrency=1@;@PRP_AsOfDate=False|First of This Month|$FullDayString|" >> Extracts.ini
#	Write-Output " 3=Report=ExtractRealUnReal@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractRealUnReal##False@;@PRP_StartEndDate=False|Month to Date|$FullDayString|$FullDayString@;@PRP_Portfolios=ALL@;@PRP_BaseCurrency=1" >> Extracts.ini
#	Write-Output " 4=Report=ExtractPerformance@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractPerformance##False@;@PRP_StartEndDate=False|Month to Date|$FullDayString|$FullDayString@;@PRP_Portfolios=ALL@;@PRP_LedgerAccounts=@;@PRP_BaseCurrency=1" >> Extracts.ini
###	Write-Output " 5=Report=ExtractPositionMap@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractPositionMap##False" >> Extracts.ini
###  Write-Output " 6=Report=ExtractPositionCloseDate@;@ExtractType=Excel (CSV)@;@ExtractPath=$working_dir@;@ExtractName=ExtractPositionCloseDate##False@;@PRP_StartEndDate=False|Month to Date|$FullDayString|$FullDayString@;@PRP_Portfolios=All@;@PRP_BaseCurrency=1@;@PRP_AsOfDate=False|First of This Month|$FullDayString|  " >> Extracts.ini
##& cmd.exe /S /C "CD $working_dir && wsRptCmdLineUtil.exe Extracts.ini" | Out-Null

	New-Item -type directory $archive_dir\$ArchiveDirDayString
	Copy-Item $working_dir\*.CSV $archive_dir\$ArchiveDirDayString

#	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractPosition.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractPosition.CSV"""
##	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractPositionMap.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractPositionMap.CSV"""
#	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractSettleUnsettle.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractSettleUnsettleComplete.CSV"""
#	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractRealUnreal.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractRealUnReal.CSV"""
#	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractPerformance.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractPerformance.CSV"""
##	& $2016DTEXEC32 /f "$dirSSISExtractWSO\ExtractPositionCloseDate.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayString" /set "\package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];""$archive_dir\$ArchiveDirDayString\ExtractPositionCloseDate.CSV"""
	& $2016DTEXEC32 /f "$dirSSISNormalizeWSO\NormalizeWSOPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[ItdFlag].Value;$ITD_Flag" /set "\package.variables[PowerShellLocation].Value;$ScriptName"

##Write-PubSub -Subject "DataWarehouse.WSOData.Reloaded" -Title "Data Warehouse WSOData Load Completed for $FullDayString" -Description "$FullDayString"
#
#	$date_string = Get-Date -Date $day -UFormat %x
#
#	# Geneva Extract
#	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"
#	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"
#
#<##Do not add back in, has been removed for a reason
#	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositionsCSV.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" 
##>
#	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" 
#
#
##Write-PubSub -Subject "DataWarehouse.GenevaData.Reloaded" -Title "Data Warehouse GenevaData Load Completed for $FullDayString" -Description "$FullDayString"

	$day = $day.AddDays(1)
}
