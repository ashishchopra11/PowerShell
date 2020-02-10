############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
. .\ConnectionStrings.config.ps1
. .\fGenericImportJob.ps1
. .\fGenericNormalization.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $("ExtractCustodianSocGenPositions."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ImportCustodianFIInstIDCPrices.$strDateNow.txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirArchiveHCM46DriveFolder\IDC\FUNDRUN"
 #$dirSourceFolder  = "C:\HCM\DataFeeds\IDC"
$dirArchiveFolder = "$dirArchiveHCM46DriveFolder\IDC\FUNDRUN\Archive"
#$dirArchiveFolder = "C:\HCM\DataFeeds\IDC\Archive"

Write-Output " dirSourceFolder		        = $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	        = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here if not exists " | Out-File $LogFile -Append


## ExtractCustodianMSEquitySwapPositions :-
foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "HIGHLAND_*.TXT"}) 
{    $Size = $strFileName.Length

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: IDC FundRun  : file ( $strFileName ) processing " | Out-File $LogFile -Append
     Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append

	$FullPath = $strFileName.FullName
	$FileExists = $True
    
	$RefDataSetDate1 = Get-Date
	$RefDataSetDate = $RefDataSetDate1.toshortdatestring()
	$File = "FIInstIDCPrices.txt"
	$outfile ="$dirSourceFolder\$File"
	

	##Create another text file :-
	$reader = New-Object System.IO.StreamReader($FullPath)
	
 $upperbound = 141
while(($line = $reader.ReadLine())-ne $null)
{ $line.Length
if($line.Length -ge 141)
{
$line2 = $line.Substring(0,141)
$line2 |Out-File $outfile -Append

}
}
	$reader.Close()
    ##SSIS Status Variables
   [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportVendorIDCFundRunPrices.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $strFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	### Extract ImportCustodianSocGenPositions 
	& $2016DTEXEC32 /F "$dirSSISExtractVendor\ImportVendorIDCFundRunPrices.dtsx" /set "\package.variables[FileName].Value;$File"  /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")FI Inst IDC Prices : file ( $File ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") FI Inst IDC Prices  : file ( $strFileName ) imported" | Out-File $LogFile -Append

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeVendorIDCFundRunPrices.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	## Normalize  IDC Fundrun 
	$GenericNormaliztaionJobID = 71
	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
	
	#& $2016DTEXEC32 /F "$dirSSISNormalizeVendor\NormalizeVendorIDCFundRunPrices.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") IDC Fund Run prices : NormalizeVendorIDCFundRunPrices.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")IDC Fund Run prices  : Normalization Complete" | Out-File $LogFile -Append


##Remove temp file :-
#Remove-Item $outfile
	Move-Item -Path $outfile $dirArchiveFolder #Archive modified file as well


    ### Move imported file to Archive Directory
	Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append