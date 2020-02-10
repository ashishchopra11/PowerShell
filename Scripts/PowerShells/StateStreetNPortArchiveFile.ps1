############## Reference to configuration files ###################################
CLS
````````
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\StateStreetNPortArchiveFile."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\StateStreet\N-Port"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\StateStreetN-Port\Archive"

Write-Output " dirSourceFolder		= $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	    = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " StrDateNow		    = $strDateNow  `r`n" | Out-File $LogFile -Append
Write-Output " ScriptName		    = $ScriptName  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow
 

foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*.*"}) 
{   
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: State Street N-Port  : file ( $strFileName ) processing " | Out-File $LogFile -Append 
 	
	 ### Move imported file to Archive Directory
	Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder -Force
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

}
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
