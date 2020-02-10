############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
. .\fRefDataSetIU.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

[string]$strDateNow 	= get-date -format "yyyyMMddTHH"
#[string]$logFile 		= "$dirLogFolder\RegressionTest_ScriptAdapter_Service_"+$strDateNow+".txt" ##Log file path

[string]$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
[string]$PSScriptName 	= $PSScriptName.Replace(".ps1","")
[string]$logFile 		= "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

[string]$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

## RefDataSetDate and Delivery or Receive File name Setup 
#if((get-date).Dayofweek -eq "Monday")
#{
#	$FileDate =(get-date).AddDays(-3).ToString("yyyyMMdd")
#}
#else
#{
#	$FileDate =(get-date).AddDays(-1).ToString("yyyyMMdd")
#}
$FileDate =(get-date).ToString("yyyyMMddTHH")
[string]$ExtractFile = "RegressionTest*"
[string]$dirSourceFolder = "$dirServicesDeliveryStoreFolder\RegressionTest" ## Source File location
[string]$dirArchiveFolder = "$dirArchiveHCM46DriveFolder\RegressionTest\Archive" ## Archive File location




foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike $ExtractFile})
{   
	$FileFullPath = "$dirSourceFolder\$strFileName.Name"
	$FileName = $strFileName.Name
		
	###Create Archive folder
	$strDate = $strDateNow
	if (!(Test-Path -path "$dirArchiveFolder\$strDate")) 
	{ 
		New-Item -path "$dirArchiveFolder\$strDate" -ItemType directory 
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDate creates here " | Out-File $LogFile -Append

	###Move file to Archive Directory
	Move-Item -Path $dirSourceFolder\$FileName "$dirArchiveFolder\$strDate" -Force | Out-File $logFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $FileName ) to location ( $dirArchiveFolder\$strDate ) " | Out-File $LogFile -Append
	Start-Sleep -Seconds 30
}


################# Deleting & days old Files from pmpdatafeeds ############################
$Now = Get-Date
$Days = "2"
$LastWrite = $Now.AddDays(-$Days)
$Files = Get-Childitem $dirArchiveFolder -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        Write-Output  "Deleting File $File"    | Out-File $LogFile -Append
        Remove-Item $File.FullName  -Recurse 
        }
    else
        {
        Write-Output  "No more files to delete!"  | Out-File $LogFile -Append
        }
    }
#deleting empty folders.
do {
  $dirs = gci $dirArchiveFolder -directory -recurse | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName
  $dirs | Foreach-Object { Remove-Item $_ }
} while ($dirs.count -gt 0)


Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName END `r`n" |   Out-File $LogFile -Append