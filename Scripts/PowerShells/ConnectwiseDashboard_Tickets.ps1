############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
#################################################################################### 
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ImportCWTicketDetail."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

## Source Folder Paths
#123 $dirSourceFolder = "D:\HCM\DataFeeds\SP\Copy of Last Six Months Help Desk History" ## Source File location
$SourceDir = "$dirServicesDeliveryStoreFolder\Connectwise"
$ArchiveDir = "$dirArchiveHCM46DriveFolder\Connectwise Dashboard Tickets\Archive"
$strFileName=$null


Write-Output " dirSourceFolder			= $dirSourceFolder" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder				= $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile				= $logFile `r`n" | Out-File $LogFile -Append


##Declare Refdatasetdate arrray
$RefDatasetDateArray = @()


Write-Output "Loading process is starting now" | Out-File $logFile
foreach ($strFileName in Get-ChildItem  -Path $SourceDir | Where-Object {$_.Name -ilike "*TimeDetail*"})
{ 
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Copy of Last Six Months Help Desk : file ( $strFileName ) processing " | Out-File $LogFile -Append
	
    if (!(Test-Path -path $ArchiveDir\$strDateNow )) 
    { 
	    New-Item -path $ArchiveDir\$strDateNow -ItemType directory 
    }


    $RefDataSetDate = $null
	 #$RefDataSetDate1 = $strFileName.BaseName.Split("_")[0]  
    #$RefDataSetDate1 = Get-Date -Format ”MMM dd yyyy” 
    
    #$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1.Trim(),”yyyyMMdd”,$null)).toshortdatestring()
    $RefDataSetDate = Get-Date -Format ”MMM dd yyyy”

    $RefDatasetDateArray += $RefDataSetDate
	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate as getdate :: $RefDataSetDate " | Out-File $LogFile -Append
   
    ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCWTicketDetail.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	### Extract ImportCWTicketDetail 
	   
      & $2016DTEXEC32 /F "$dirSSISDataTransfer\ImportCWTicketDetail.dtsx" /set "\package.variables[FileName].Value;$strFileName"/set "\package.variables[FolderName].Value;$SourceDir" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
    
	    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  ImportCWTicketDetail : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ImportCWTicketDetail: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
    Move-Item -Path $SourceDir\$strFileName $ArchiveDir\$strDateNow 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $ArchiveDir\$strDateNow ) " | Out-File $LogFile -Append

}
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append