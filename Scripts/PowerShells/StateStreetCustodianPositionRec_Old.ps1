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

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-PubSub -Subject "File.SSCustPositions.Received" -Title "File State Street CustPositions Received"  

[bool]$FileZipExists = $False

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ImportCustodianStateStreetCustPosition."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

## Source Folder Paths
$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\StateStreet\Position Files - Cust"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\StateStreet\Position Files - Cust\Archive"
#$strFileName = "Custody Position Rec.CSV"
$strFileName = "Positions by Settle Location (JT).CSV"

#$dirSourceFolder = "D:\Siepe\DataFeeds\StateStreet\Pledge"

Write-Output " StrFileName			= $strFileName" | Out-File $LogFile -Append
Write-Output " DirSourceFolder		= $dirSourceFolder" | Out-File $LogFile -Append
Write-Output " DirArchiveFolder		= $dirArchiveFolder" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append

New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Created the archive directory :: $dirArchiveFolder\$strDateNow " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  StateStreet Cust Position starts here " | Out-File $LogFile -Append

foreach ($ZipFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "attachment*.zip"}) 
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  StateStreet Cust Position: zIP file ( $ZipFileName ) processing " | Out-File $LogFile -Append
	##Remove existing files
	Get-ChildItem -Path $dirSourceFolder -Include "Custody Position Rec*.CSV" -Recurse | foreach { $_.Delete()}
	$FileZipExists=$True
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Delete [Positions by Settle Location*.CSV] file from ( $dirSourceFolder )  " | Out-File $LogFile -Append
	#Get-ChildItem -Path $dirSourceFolder -Include "Positions by Settle Location*.CSV" -Recurse | foreach { $_.Delete()}
	
	##Unzip all the source file
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Unzipped the $ZipFileName file  " | Out-File $LogFile -Append
	Expand-ZIPFile –File "$dirSourceFolder\$ZipFileName" –Destination $dirSourceFolder 
	 
	$logTime = Get-Date
	$FileExist = 0
#	
#	foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Custody Position Rec*.CSV"}) 
#	foreach ($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Positions by Settle Location*.CSV"}) 
#	{
		Start-Sleep -s 10

		
		$FullPath = $strFileName.FullName
		
		$dtDate = Get-Date
		$FileExist = 1
		$runDate 		= Get-Date
			if ($runDate.DayOfWeek -eq "Monday") {
			$runDate	= $runDate.AddDays(-4)
		}
		elseif ($runDate.DayOfWeek -eq "Tuesday") 
		{
		$runDate	= $runDate.AddDays(-4)
		}
		else 
		{
			$runDate	= $runDate.AddDays(-2)
		}
		
		$FullDayString  = $runDate.ToShortDateString()
		
				
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Parsed RefDataSetDate from Currentdate :: $FullDayString " | Out-File $LogFile -Append
		
		## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
	
		### Extract ImportCustodianBNPPositions 
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ImportCustodianStateStreetCustodyPositionRec.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianStateStreetCustodyPositionRec.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
		
		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet CustPosition: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet CustPosition: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet CustPosition:Remove file $dirSourceFolder\$strFileName " | Out-File $LogFile -Append
	Remove-File –Path $dirSourceFolder –FileName $strFileName
		
#	}

	if($FileExist -eq 1)
	{	
		## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
	
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianStateStreetCustodyPositionRec.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianStateStreetCustodyPositionRec.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
		$GenericNormalizationJobID = 22
		& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
	
		## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet Cust Position: file ( $strFileName ) NormalizeCustodianStateStreetCustodyPositionRec.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") StateStreet Cust Position: file ( $strFileName ) normalized " | Out-File $LogFile -Append
	
	
	}
		
	Move-Item -Path "$dirSourceFolder\$ZipFileName" $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $ZipFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append

}


If ($FileZipExists -eq $False)
{
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Source file (attachment*.zip) not exist at :: $dirSourceFolder " | Out-File $LogFile -Append    
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
