############## Reference to configuration files ###################################
CLS

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
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $("ExtractCustodianSocGenPositions."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\ExtractCustodianSocGenPositions.$strDateNow.txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\SocGenPositionFile"
 
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\SocGenPositionFile\Archive"

Write-Output " dirSourceFolder		        = $dirSourceFolder `r`n" | Out-File $LogFile -Append
Write-Output " dirArchiveFolder	        = $dirArchiveFolder `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append

##Create Current date time folder in Archive folder
#Create-Directory -path $($dirArchiveFolder+"\") -dirName $strDateNow
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archive Folder $dirArchiveFolder\$strDateNow creates here if not exists " | Out-File $LogFile -Append

[bool]$FileExists = $False
$DateFrom = $null

## ExtractCustodianMSEquitySwapPositions :-
foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*TD_COMBINED_POS*.csv"} ) 
{    $Size = $strFileName.Length

 if ( $Size -le 1kb)
 {
	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SocGen Positions   : file ( $strFileName ) is blank" | Out-File $LogFile -Append
	 return
	 }
	 else
	 {
	 	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SocGen Positions   : file ( $strFileName ) processing " | Out-File $LogFile -Append
     Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append

	$FullPath = $strFileName.FullName
	$FileExists = $True
    
	$RefDataSetDate = $null
	### Get RefDataSet Date from File Content
	$SourceCsv = Import-Csv -Path $FullPath -Header("RefDataSetDate")
	$SourceCsvRDDate = $SourceCsv[1]
	$RefDataSetDate1 = $SourceCsvRDDate.RefDataSetDate.ToString();
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyy-MM-dd”,$null)).toshortdatestring()
	
	if($RefDataSetDate -ne $null)
	{
	$DateFrom = "FileContent"
	}
	else
	{$DateFrom = "FileName"
	$RefDataSetDate1  = $strFileName.BaseName.Split("_")[1]
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”yyyyMMd”,$null)).toshortdatestring()
	}

    ##SSIS Status Variables
   [Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractCustodianSocieteGeneraleEquityPositionRec.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $strFileName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	### Extract ImportCustodianSocGenPositions 
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ExtractCustodianSocieteGeneraleEquityPositionRec.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[DateFrom].Value;$DateFrom" | Out-File $LogFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Positions : file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Positions : file ( $strFileName ) imported" | Out-File $LogFile -Append

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianSocieteGeneraleEquityPositionRec.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	## Normalize  SocGen 
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianSocieteGeneraleEquityPositionRec.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append

	$GenericNormalizationJobID = 19
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") SocGen Positions : NormalizeCustodianSocieteGeneraleEquityPositionRec.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")SocGen Positions  : Normalization Complete" | Out-File $LogFile -Append

    ### Move imported file to Archive Directory
	Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

	 }
 
	
}
If ($FileExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file ( *TD_COMBINED_POS*.csv) not exist at :: $dirSourceFolder " | Out-File $LogFile -Append    
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
