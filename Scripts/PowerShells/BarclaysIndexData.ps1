############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fGenericImportJob.ps1
	. .\fGenericNormalization.ps1
	. .\fSSISExitCode.ps1
	. .\DTExec.Config.ps1
#################################################################################### 

#****** Initialize variables ******
	$GenericNormaliztaionJobID = 	10										##### NEED TO UPDATE #####

	$strDateNow = get-date -format "yyyyMMddTHHmmss"
	$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
	$PSScriptName 	= $PSScriptName.Replace(".ps1","")
	$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
	$ReturnDate = ""
	
	$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\Barclays\HY"
	$dirArchiveFolder 		= "$dirArchiveHCM97DriveFolder\Barclays\HY"

 
	foreach ($ZipFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.zip"})
	{
    
	$FileZipExists = $True
	##Remove existing files
	$RawZIPFilePath = $ZipFileName.FullName
	
	$RefDataSetDate1 = $ZipFileName.BaseName
	$RefDataSetDate = ([datetime]::ParseExact("$RefDataSetDate1","yyyyMMdd",$null)).toshortdatestring()
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Barclays Index Data : RefDataSetDate is  $RefDataSetDate " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Barclays Index Data : Unzip File $RawZIPFilePath " | Out-File $LogFile -Append
	
	# UnRAR the file. -y responds Yes to any queries UnRAR may have.
	&  "C:\Program Files\WinRAR\Winrar.exe" x -y -o+  $RawZIPFilePath $dirDataFeedsFolder  "-phighland" | Wait-Process 
	
	#&  "D:\WinRAR\Winrar.exe" x -y -o+  $RawZIPFilePath $dirDataFeedsFolder  "-phighland" | Wait-Process 
    
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Barclays Index Data : Unzip Done " | Out-File $LogFile -Append
    
    
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Barclays Index Data : file ( $strFileName ) processing " | Out-File $LogFile -Append
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*bonds*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$NewName = $FileName -Replace ".txt", ".csv"
		Rename-Item "$dirDataFeedsFolder\$strFileName" -NewName $NewName
		#Remove-Item $FileName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*bonds*"})
	{
		$FileName = "$dirDataFeedsFolder\$strFileName"
		(Get-Content -Path $FileName).Replace('|',',') | Set-Content -Path $FileName
		#Remove-Item $FileName
	}
	
	foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*bonds*"})
	{	
		$FileName = "$dirDataFeedsFolder\$strFileName"
		$HeaderLine =	'Cusip','ISIN','Issuer','Ticker','Coupon','MaturDate','QualityB','QualityE','Currency','IssrClsL1','IssrClsL2',
		'IssrClsL3','IssrClsL4','Country','OutstandB','OutstandE','PriceB','PriceE','AccrIntB','AccrIntE','MrkValBeg','MrktValue','YldWorstE',
		'YldMatE','Maturity','AvgLife','ISMA_MDur','DurAdjMod','DurMatMod','DurWrsMod','OasSprDur','ConvAdj','OAS_bp','RetTotal','RetPrice',
		'RetCoupon','RetPayDwn','RetCurncy','RUCash','RUDurAdjM','RUMVCash','RUMVSecry','RUMVTotal','RUMVTotLc','RUOutsBas','RUOutsLoc', 'Ignore'

    
		
		$import = Import-CSV $FileName -Header $HeaderLine | Select -Skip 1
		$import | Export-Csv $FileName -Force -NoTypeInformation
	}
 
#****** Generic Import ******
	Parameters - [int] $pGenericImportJobID, [String] $pdirSourceFolder, [String] $pRefDatasetDate, [String] $pLabel, [String] $pLogFile, [string] $pFileName, [string] $pDirArchiveFolder, [Ref]$ReturnRefDataSetDate=""
	$GenericImportJobID = 101
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 102
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 103
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 104
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$GenericImportJobID = 105
	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)


	$RefDatasetDate = $ReturnDate
	##normalize Indexes
	    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeBarclaysIndexData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	      Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	      
	        & $2016DTEXEC32 /F "$dirSSISNormalizeVendor\NormalizeBarclaysIndexData.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$PSScriptName" | Out-File $logFile -Append
	      
	      ## Check SSIS is success or not 
	      If ($lastexitcode -ne 0 ) {
	                  $SSISErrorMessage = fSSISExitCode $lastexitcode;
	                  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeVendorBarclaysHYBonds was not successful" | Out-File $LogFile -Append
	                  Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
	                  Exit
	            }
	      Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeVendorBarclaysHYBonds normalized" | Out-File $LogFile -Append
	      
		  

	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $RawZIPFilePath $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ($RawZIPFilePath ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
