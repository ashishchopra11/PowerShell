############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\ImportCWProjectDetails"+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
 
$SourceDir = "$dirServicesDeliveryStoreFolder\ConnectWise"
$ArchiveDir = "$dirArchiveHCM46DriveFolder\Connectwise Dashboard Projects\Archive"
 

[bool]$FileExists = $False

Write-Output " SourceDir			= $SourceDir" |  Out-File $LogFile -Append
Write-Output " ArchiveDir			= $ArchiveDir" |  Out-File $LogFile -Append
Write-Output " logFile					= $logFile" |  Out-File $LogFile -Append


Move-Item "$dirServicesDeliveryStoreFolder\ConnectWise\ProjectDetails*"  "$SourceDir" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Move Files from $dirServicesDeliveryStoreFolder\ConnectWise\ProjectDetails.xlsx to $SourceDir " | Out-File $LogFile -Append

Move-Item "$dirServicesDeliveryStoreFolder\ConnectWise\TicketDetails*"  "$SourceDir" -Force
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Move Files from $dirServicesDeliveryStoreFolder\ConnectWise\TicketDetails.xlsx to $SourceDir " | Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Creating Archive Folder : $ArchiveDir\$strDateNow " | Out-File $LogFile -Append
###Create Archive folder
if (!(Test-Path -path $ArchiveDir\$strDateNow )) { 
    New-Item -path $ArchiveDir\$strDateNow -ItemType directory 
    }
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Connectwise project details starts here " | Out-File $LogFile -Append

###Import ActivityExtracts
foreach ($strFileName1 in Get-ChildItem	 -Path $SourceDir | Where-Object {$_.Name -ilike "*ProjectDetails*"})
{ 
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Connectwise project details: file ( $strFileName1 ) processing " | Out-File $LogFile -Append
    $dtDate = Get-Date
    $FileExists = $True
	$dtDataSetDate1  = ($dtDate).toshortdatestring()
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from file Name ( $strFileName1 ):: $dtDataSetDate1 " | Out-File $LogFile -Append
	 
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportProjectDetails.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate1 `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName1 `r`n PowerShellLocation;$ScriptName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISDataTransfer\ImportProjectDetails.dtsx" /set "\package.variables[FileName].Value;$strFileName1"/set "\package.variables[FolderName].Value;$SourceDir" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
    
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  ProjectDetails: file ( $strFileName1 ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ProjectDetails Imported : file ( $strFileName1 ) imported" | Out-File $LogFile -Append
 
    ###Move file to Archive Directory
    Move-Item -Path $SourceDir\$strFileName1 $ArchiveDir\$strDateNow\ -Force  | Out-File $logFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $SourceDir\$strFileName1 ) to location ( $ArchiveDir\$strDateNow\ ) " | Out-File $LogFile -Append
}

If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( ProjectDetails.xls ) not exist at :: $SourceDir " | Out-File $LogFile -Append    
} 
$FileExists = $False

<#
##TicketDetails
foreach ($strFileName1 in Get-ChildItem	 -Path $SourceDir | Where-Object {$_.Name -ilike "*TicketDetails*"})
{ 
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Connectwise Ticket Details: file ( $strFileName1 ) processing " | Out-File $LogFile -Append
    $dtDate = Get-Date
    $FileExists = $True
	$dtDataSetDate1  = ($dtDate).toshortdatestring()
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from file Name ( $strFileName1 ):: $dtDataSetDate1 " | Out-File $LogFile -Append
	 
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportProjectDetails.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate1 `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName1 `r`n PowerShellLocation;$ScriptName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISDataTransfer\ImportCWTicketDetail.dtsx" /set "\package.variables[FileName].Value;$strFileName1"/set "\package.variables[FolderName].Value;$SourceDir" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
    
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  TicketDetails: file ( $strFileName1 ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") TicketDetails  : file ( $strFileName1 ) imported" | Out-File $LogFile -Append
 
    ###Move file to Archive Directory
    Move-Item -Path $SourceDir\$strFileName1 $ArchiveDir\$strDateNow\ -Force  | Out-File $logFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $SourceDir\$strFileName1 ) to location ( $ArchiveDir\$strDateNow\ ) " | Out-File $LogFile -Append
}
If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( TicketDetails.xls ) not exist at :: $SourceDir " | Out-File $LogFile -Append    
} 
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append