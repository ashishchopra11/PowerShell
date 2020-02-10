############## Reference to configuration files ###################################
CLS
````````
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "MMddTHHmmss"
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("ImportCustodianJefferiesRebate"+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ExtractCustodianJefferiesCash.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\Jefferies Cash Import"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\Jefferies Cash Import\Archive"

Write-Output " dirSourceFolder		= $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	    = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " StrDateNow		    = $strDateNow  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here if not exists " | Out-File $LogFile -Append


foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*_*_Global-Position-Summary.xls"}) 
{    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Jefferies Cash   : file ( $strFileName ) processing " | Out-File $LogFile -Append
     Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append

	$FullPath = $strFileName.FullName
    
	
	### Get RefDataSet Date from File Content
    $RefDataSetDate1 = $strFileName.BaseName.Split("_")[1]  
    #$RefDataSetDate = Get-Date -Format "MMM dd yyyy"
    
    $RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1.Trim(),"yyyyMMdd",$null)).toshortdatestring()
    

##SSIS Status Variables
    [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianJefferiesCash.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $strFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianJefferiesCash.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Jefferies Cash : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Jefferies Cash : file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	Move-Item $FullPath $dirArchiveFolder

}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
