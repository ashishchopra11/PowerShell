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

#****** Initialize variables ******
	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\SPLCD Index Constituents"

	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SPLLL*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace("`t",',') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SPLLC*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace("`t",'|') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
    
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SPLLL"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".SPLLL", "_SPLLL.csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SPLLC*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".SPLLC", "_SPLLC"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
	
	##Declare Refdatasetdate arrray
	$RefDatasetDateArray = @()

    foreach($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*SPBDAL*"})
    {
    $strFileName = $strFileName.Name
    $RefDatasetDateArray+=[datetime]::ParseExact($strFileName.Substring(0,8), "yyyymmdd", $null).ToString('yyyy-mm-dd')
    }
    
    foreach($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "CurrentSpreads*.csv"})
    {
    $strFileName = $strFileName.Name
    $RefDatasetDateArray+=[datetime]::ParseExact($strFileName.Substring(15,8), "yyyymmdd", $null).ToString('yyyy-mm-dd')
    }

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Dates passed to Normalization are : $RefDatasetDateArray `r`n" |  Out-File $LogFile -Append
 
#****** Generic Import ******
	Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	$GenericImportJobID = 109
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	$GenericImportJobID = 116
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	$GenericImportJobID = 117
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
		
	$GenericImportJobID = 118
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	
	#Remove duplicate dates
	$RefDatasetDateArray = $RefDatasetDateArray | select -uniq | sort

	foreach( $DatasetDate in $RefDatasetDateArray)
	{
    	$GenericNormaliztaionJobID1 = 54
    	$GenericNormaliztaionJobID2 = 55
    
		#****** Generic Normalization ******
		$RefDatasetDate = $DatasetDate
		fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID1 -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null
		fGenericNormalization -pGenericNormaliztaionJobID $GenericNormaliztaionJobID2 -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $null

		## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
	   
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeVendorSPLCD.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $DatasetDate `r`n PowerShellLocation : $PSScriptName"| Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		### Extract ImportVendorSPBDAL2 
		   
	    & $2016DTEXEC32 /f "$dirSSISNormalizeVendor\NormalizeVendorSPLCD.dtsx" /set "\package.variables[RefDataSetDate].Value;$DatasetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  | Out-File $LogFile -Append
		
	    ## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) 
	        {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  NormalizeVendorSPLCD :  Failed" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeVendorSPLCD : Success" | Out-File $LogFile -Append
	 
	 
		## PushSPLCD
	 
	   ## SSIS Status Variables
		[Int]$lastexitcode = $null
		[String]$SSISErrorMessage = $null
	   
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling PushSPLCD.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $DatasetDate `r`n PowerShellLocation : $PSScriptName"| Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
		### Extract ImportVendorSPBDAL2 
		   
	    & $2016DTEXEC32 /f "$dirSSISPush\PushSPLCD.dtsx" /set "\package.variables[RefDataSetDate].Value;$DatasetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName"  | Out-File $LogFile -Append
		
	    ## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) 
	        {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  PushSPLCD :  Failed" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") PushSPLCD : Success" | Out-File $LogFile -Append
	 
 

	}

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $PSScriptName END " | Out-File $LogFile -Append
	
