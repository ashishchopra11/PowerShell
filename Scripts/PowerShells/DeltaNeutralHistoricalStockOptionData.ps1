############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
#################################################################################### 

	Add-Type -AssemblyName System.IO.Compression.FileSystem

#****** Initialize variables ******
	$GenericImportJobID = 72
	
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""

	$dirSourceFolder  = "$dirServicesDeliveryStoreFolder\Delta Neutral Historical Stock Option Data"
	foreach ($strFileNamezip in Get-ChildItem	 -Path $dirSourceFolder -Recurse | Where-Object {$_.Name -ilike "stockhistory*.zip"})
	{
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Expand file : $strFileNamezip " | Out-File $LogFile -Append
		 
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$dirSourceFolder\$strFileNamezip", "$dirSourceFolder")
		Write-Output "$dirSourceFolder" | Out-File $LogFile -Append
		
		Start-Sleep -s 10
		foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder -Recurse -Include "stockhistory*.csv")
		{
			$FullPath = $strFileName.FullName
			Move-Item -Path $FullPath -Destination $dirSourceFolder -force
		}
		Start-Sleep -s 10
		Remove-Item -Path $dirSourceFolder\$strFileNamezip
		Remove-Item -Path "$dirSourceFolder\ftp" -Recurse -Force
	}
 
#****** Generic Import ******
	[DateTime] $RefDataSetDate = Get-Date -Format "MM/dd/yyyy"
	#Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $RefDataSetDate -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
