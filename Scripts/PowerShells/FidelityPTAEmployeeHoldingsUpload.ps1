############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fRefDataSetIU.ps1
. .\fSSISExitCode.ps1
####################################################################################

################################
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}
$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
#$logFile = "$dirLogFolder\FidelityEmployeeHoldingTransfer.$strDateNow.txt"


$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

##Set variables
$process_date = (Get-Date).AddDays(-1)
$ArchiveDirDayString  = $process_date.Year.ToString() + $process_date.Month.ToString().PadLeft(2, "0") + $process_date.Day.ToString().PadLeft(2, "0")
$dirArchiveHCM46DriveFolder = "\\hcm97\PMPDataFeeds"
$archive_dir = "$dirArchiveHCM46DriveFolder\PTAFidelity\Archive"
$UserName = "\Dev.Prod.EXT02"
$Password = "XL7si3K%6"
$SFTPposition = "FILESYSTEM::Z:\FIDPOS"+$ArchiveDirDayString+".TXT"
$SFTPtransaction = "Z:\FIDTRD"+$ArchiveDirDayString+".TXT"
$SFTPaccount = "Z:\FIDNAM"+$ArchiveDirDayString+".TXT"

Write-Output " process_date		        = $process_date `r`n" | Out-File $LogFile -Append
Write-Output " ArchiveDirDayString	        = $ArchiveDirDayString `r`n" | Out-File $LogFile -Append
Write-Output " archive_dir	        = $archive_dir `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append
Write-Output " UserName		        = $UserName  `r`n" | Out-File $LogFile -Append
Write-Output " Password		        = $Password  `r`n" | Out-File $LogFile -Append
Write-Output " SFTPposition		        = $SFTPposition  `r`n" | Out-File $LogFile -Append
Write-Output " SFTPtransaction		        = $SFTPtransaction  `r`n" | Out-File $LogFile -Append
Write-Output " SFTPaccount		        = $SFTPaccount  `r`n" | Out-File $LogFile -Append


##$cycloneposition = "C:\CycloneActivator\data\sft7184\other\FIDPOS"+$ArchiveDirDayString+".TXT"
##$cyclonetransaction = "C:\CycloneActivator\data\sft7184\other\FIDTRD"+$ArchiveDirDayString+".TXT"

Net use Z: \\hcmext02\fidelity_pta$ /user:$UserName $Password 
net use /persistent:yes

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating temp connection to \\hcmext02\fidelity_pta with : `r`n User : $UserName `r`n  Password : $Password  `r`n" |  Out-File $LogFile -Append


################################
##Copy
##Copy-Item -path "$cycloneposition" -destination $archive_dir
##Copy-Item -path "$cyclonetransaction" -destination $archive_dir
Copy-Item -path "$SFTPposition" -destination $archive_dir | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::Copied text file from $SFTPposition to $archive_dir `r`n" |  Out-File $LogFile -Append

Copy-Item -path "$SFTPtransaction" -destination $archive_dir | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::Copied text file from $SFTPtransaction to $archive_dir `r`n" |  Out-File $LogFile -Append

Copy-Item -path "$SFTPaccount" -destination $archive_dir | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::Copied text file from $SFTPaccount to $archive_dir `r`n" |  Out-File $LogFile -Append

net use z: /d
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::Deleted Temporary connection. `r`n" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
