CLS

[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ConfigRootFolder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFolder
. .\DirLocations.Config.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ExternalWebsiteRefresh-NexPointRes."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile 	  = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$webClient = New-Object System.Net.WebClient

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

$url="https://www.nexpointres.com/z_refresh_fund_data/"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Refreshing the URL :: $url " | Out-File $LogFile -Append

$result = $webClient.DownloadString("$url");
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Result :: $result" | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
