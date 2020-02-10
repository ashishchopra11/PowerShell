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
$dirSourceFolder  = "\\hcmlp.com\data\public\Retail Funds\FUNDS\NPORT\Siepe SEI Upload"
$dirArchiveFolder = "\\hcmlp.com\data\public\Retail Funds\FUNDS\NPORT\Siepe SEI Upload"

Write-Output " dirSourceFolder		= $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	    = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " StrDateNow		    = $strDateNow  `r`n" | Out-File $LogFile -Append
Write-Output " ScriptName		    = $ScriptName  `r`n" | Out-File $LogFile -Append

 
foreach ($strFileName in Get-ChildItem -Path "$dirSourceFolder\restricted securities" | Where-Object {$_.Name -ilike "*.*"}) 
{   
	if(!(Test-Path -Path "$dirSourceFolder\restricted securities\Archive\$strDateNow" )){
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Create archive folder within restricted securities directory." | Out-File $LogFile -Append
		New-Item -ItemType directory -Path "$dirSourceFolder\restricted securities\Archive\$strDateNow"
	}	
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SEI N-Port restricted securities  : file ( $strFileName ) processing " | Out-File $LogFile -Append 
 	
	 ### Move file to Archive Directory
	Move-Item -Path "$dirSourceFolder\restricted securities\$strFileName" "$dirSourceFolder\restricted securities\Archive\$strDateNow" -Force
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirSourceFolder\restricted securities\Archive\$strDateNow ) " | Out-File $LogFile -Append

}
 
  
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
