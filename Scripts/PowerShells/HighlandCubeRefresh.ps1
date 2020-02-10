CLS
$Error.Clear()

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

function process_Cube
{	param($ServerName="localhost", $DBName="Adventure Works DW",$CubeName ="", $ProcessTypeDim="ProcessFull",$ProcessTypeMG="ProcessFull", $Transactional="Y", $Parallel="Y",$MaxParallel=2,$MaxCmdPerBatch=5, $PrintCmd="N")
	## Add the AMO namespace
	$loadInfo = [Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
	if ($Transactional -eq "Y") {$TransactionalB=$true} else {$TransactionalB=$false}
	if ($Parallel -eq "Y") {$ParallelB=$true} else {$ParallelB=$false}
	$server = New-Object Microsoft.AnalysisServices.Server
	$server.connect($ServerName)
	if ($server.name -eq $null) {
	 Write-Output ("Server '{0}' not found" -f $ServerName)
	 break
	}
	$DB = $server.Databases.FindByName($DBName)
	if ($DB -eq $null) {
	 Write-Output ("Database '{0}' not found" -f $DBName)
	 break
	}
	
	foreach ($dim in $DB.Dimensions) {
	  $dim.Process($ProcessTypeDim)
	} # Dimensions
	#Process cubes
	$cube = $DB.Cubes.GetByName($CubeName)
	$DB.Process($ProcessTypeMG)
	

	<#
	 foreach ($mg in $cube.MeasureGroups) {
	  foreach ($part in $mg.Partitions) {
	   $part.Process($ProcessTypeMG)
	  }
	 }
	
	# Separate step to process all linked measure groups. Linke MG does not have partitions
	
	 foreach ($mg in $cube.MeasureGroups) {
	  if ($mg.IsLinked) {
	   $mg.Process($ProcessTypeMG)
	  }
	 }#>
}


$logFile = "D:\Siepe\Data\Logs\"

$currentTime = Get-Date -Format "yyyyMMddHHmmss"

$logFile = $logFile+"PMPerformanceRebuildCube.$currentTime.txt"

$currentTime = Get-Date -Format "yyyyMMddHHmmss"

$ServerName = "PHCMDB01"
$DatabaseName = "HCM"
$FullDayString = Get-Date -Format "yyyy-MM-dd"

$CmdText = "DECLARE @RefDataSetId int
EXEC @RefDataSetId = dbo.pRefDataSetIU	@RefDataSetID = 0 ,	@RefDataSetDate	= '" +$FullDayString +"' ,	@RefDataSetType	= 'Position' ,@RefDataSource = 'Highland' , @Label = 'Cube Refresh'
SELECT @RefDataSetId"

$RefDataSet = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CmdText

[int]$RefDataSetID = $RefDataSet[0][0]


Write-Output "$currentTime|Starting Cube Rebuild"|Out-File $logFile -Append

$Error.Clear()

process_Cube -ServerName "PWSODB01" -DBName "PMPerformance2007" -CubeName "HCM" |Out-File $logFile -Append

#process_Cube -ServerName "HCMV05" -DBName "PMPerformance2007" -CubeName "HCM" |Out-File $logFile -Append

$currentTime = Get-Date -Format "yyyyMMddHHmmss"

$Error|Out-File $logFile -Append

if ($Error.Count -gt 0)
{
	Write-Output "$currentTime|Cube Rebuild failed" |Out-File $logFile -Append
	
	$CmdText ="EXEC dbo.pRefDataSetIU	@RefDataSetID = $RefDataSetID ,	@RefDataSetType	= 'Position' ,@RefDataSource = 'Highland' , @Label = 'Cube Refresh',@StatusCode = 'F'"
	
	Write-Output $CmdText |Out-File $logFile -Append
	
	Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CmdText |Out-File $logFile -Append
	
	Write-Output "Publising Pub Sub having Subject : Cube.Rebuild.Failed" |Out-File $logFile -Append

	Write-PubSub -Subject "Cube.Rebuild.Failed" -Title "Cube.Rebuild.Failed" -Description "Cube.Rebuild.Failed"
		
	exit 1
}
Write-Output "$currentTime|Complete Cube Rebuild" |Out-File $logFile -Append


$CmdText ="EXEC dbo.pRefDataSetIU	@RefDataSetID = $RefDataSetID ,	@RefDataSetType	= 'Position' ,@RefDataSource = 'Highland' , @Label = 'Cube Refresh',@StatusCode = 'P'"

Write-Output $CmdText |Out-File $logFile -Append

Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CmdText |Out-File $logFile -Append


Write-Output "Publising Pub Sub having Subject : Cube.Rebuild.Complete" |Out-File $logFile -Append

Write-PubSub -Subject "Cube.Rebuild.Complete" -Title "Cube.Rebuild.Complete" -Description "Cube.Rebuild.Complete"