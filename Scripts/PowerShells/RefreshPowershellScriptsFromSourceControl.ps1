############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
. .\fRefDataSetIU.ps1
####################################################################################


###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

[string]$strDateNow 	= get-date -format "yyyyMMddTHH"
#[string]$logFile 		= "$dirLogFolder\RefreshPowershellScriptsFromSourceControl"+$strDateNow+".txt" ##Log file path

[string]$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
[string]$PSScriptName 	= $PSScriptName.Replace(".ps1","")
[string]$logFile 		= "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

[string]$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	$SourceDir = "$/Siepe.Data/SSIS2016.Datawarehouse/Powershell"
	$DestinationDir = "D:\Siepe\Data\Scripts\SourceControl\"
	$ProdDir = "D:\Siepe\Data\Scripts\PROD\"
	$Error.Clear()
	
### make the connection
$ServerName = "PHCMDB01"
$DatabaseName = "HCM"

[datetime]$dtDataSetDate  = get-date -Format "MM/dd/yyyy"
[int]$RefDataSetID = 0

	## Create RefDataSet					
	$RefDataSetID = fRefDataSetIU -rdsRefDataSetID 0 -rdsRefDataSetType "Process" -rdsRefDataSource "Highland" -rdsLabel "Powershell Source Control Refresh" -rdsStatusCode "I" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	
try {
	$Tfsdownloadexe = "D:\Siepe\Tools\TFSDownload\TFSDownload.exe"

	Write-Output "################  SourceDir = $SourceDir `r`n" |   Out-File $LogFile -Append
	Write-Output "################  DestinationDir = $DestinationDir `r`n" |   Out-File $LogFile -Append
	Write-Output "################  ProdDir = $ProdDir `r`n" |   Out-File $LogFile -Append

	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Delete Files/Folders  under Dir:: $DestinationDir `r`n" |   Out-File $LogFile -Append
	Get-ChildItem -Path $DestinationDir | foreach { $_.Delete()}

	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Download PS files from TFS Dir:: $SourceDir to local Dir:: $DestinationDir `r`n" |   Out-File $LogFile -Append
	& $Tfsdownloadexe $SourceDir $DestinationDir
<#
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Delete Files/Folders  under Dir:: $ProdDir `r`n" |   Out-File $LogFile -Append
	Get-ChildItem -Path $ProdDir -Recurse | Remove-Item -Force -Recurse

	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Copy PS files from  Dir:: $DestinationDir to Final Dir:: $ProdDir `r`n" |   Out-File $LogFile -Append
	$DestinationDir = $DestinationDir  + "*"
	Copy-item -Path $DestinationDir -Destination $ProdDir -Force -Recurse 
#>
	$exclude = '$tf'
      Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Delete Files/Folders  under Dir:: $ProdDir `r`n" |   Out-File $LogFile -Append
      Get-ChildItem -Path $ProdDir*.ps1 | Remove-Item -Force -Recurse

      Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Copy PS files from  Dir:: $DestinationDir to Final Dir:: $ProdDir `r`n" |   Out-File $LogFile -Append
      $DestinationDir = $DestinationDir  + "*.ps1"
      Copy-item -Path $DestinationDir -Destination $ProdDir -Force -Recurse 

}
catch
{
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Exception  while refresh `r`n" |   Out-File $LogFile -Append
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Exception Type :: $($_.Exception.GetType().FullName) `r`n" |   Out-File $LogFile -Append
}

finally{
	if($Error.Count -eq 0){
		fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Process" -rdsRefDataSource "Highland" -rdsLabel "Powershell Source Control Refresh" -rdsStatusCode "P" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	}
	else
	{ 
		Write-Output "################ Error:: `r`n" | Out-File $LogFile -Append
		Write-Output $Error[0] | Out-File $LogFile -Append
		Write-Output $Error[0].Exception | Out-File $LogFile -Append
		
		fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Process" -rdsRefDataSource "Highland" -rdsLabel "Powershell Source Control Refresh" -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName $ServerName -rdsdatabaseName $DatabaseName
	}
}
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName END `r`n" |   Out-File $LogFile -Append