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

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\ExtractCustodianSocGenFuturePosition."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\SocGenFuturePositionFile"

#$dirSourceFolder  = "C:\HCM\DataFeeds\SocGen"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\SocGenFuturePositionFile\Archive"
#$dirArchiveFolder = "C:\HCM\DataFeeds\SocGen\Future\Archive"

Write-Output " dirSourceFolder		= $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	    = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " StrDateNow		    = $strDateNow  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here if not exists " | Out-File $LogFile -Append


foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*ALL_FUTURES_*.CSV"}) 
{    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SocGen Future Position   : file ( $strFileName ) processing " | Out-File $LogFile -Append
     Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
    
	
	### Get RefDataSet Date from File Content
    $RefDataSetDate1 = $strFileName.BaseName.Split("_")[2]  
    #$RefDataSetDate = Get-Date -Format ”MMM dd yyyy” 
	$RefDataSetDate2 = ([datetime]::ParseExact($RefDataSetDate1.Trim(),”yyyyMMdd”,$null))
    
    $RefDataSetDate = $RefDataSetDate2.toshortdatestring()
	
    
	##SSIS Status Variables
    [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianSocieteGeneraleFuturesPositionRec.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $strFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianSocieteGeneraleFuturesPositionRec.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Future Position : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Future Position : file ( $strFileName ) imported" | Out-File $LogFile -Append
	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianSocGenPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	## Normalize  SocGen 
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSocieteGeneraleFuturesPositionRec.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
	$GenericNormalizationJobID = 21
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Future Positions : NormalizeCustodianSocieteGeneraleFuturesPositionRec.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")SocGen  Future Positions  : Normalization Complete" | Out-File $LogFile -Append

	
	 ### Move imported file to Archive Directory
	Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
