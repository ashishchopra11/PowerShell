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

[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);


###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"
$ReturnDate = ""

#Create-File -path $($dirLogFolder+"\") -fileName $("NorthernTrustAdministratorNavCashPositionRecPLPriceData."+$strDateNow+".txt")
#$logFile 				= "$dirLogFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData"
$dirArchiveFolder 		= "$dirDataFeedsArchiveFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData\Archive"



#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append

<#$runDate  = Get-Date
  
	if ($runDate.DayOfWeek -eq "Sunday")
	{
		$process_days_list 	= $runDate.AddDays(-2).ToString("MM/dd/yyyy")
	} 
	if ($runDate.DayOfWeek -eq "Monday")
	{
		$process_days_list 	= $runDate.AddDays(-3).ToString("MM/dd/yyyy")
	}
	Else
	{
		$process_days_list 	= $runDate.AddDays(-1).ToString("MM/dd/yyyy")
	}
$RefDataSetDate = $process_days_list
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  NT HoldingPositionRec and NAV starts here " | Out-File $LogFile -Append

### Position Rec
#$dirArchiveFolder 		= "$dirDataFeedsArchiveFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData\Archive\PositionRec"
#foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "Fund Accounting Portfolio Holdings Report.XLSX"})
#{
#   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  NT HoldingPositionRec: file ( $strFileName ) processing " | Out-File $LogFile -Append
    
#   #New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
   	
#	#$xls = "$dirDataFeedsFolder\$strFileName"
#	#$wb = New-Object Aspose.Cells.Workbook($xls);
#	#$ws = $wb.WorkSheets[0];
#	#$Cell = $ws.Cells["A2"];
#	#$dataSetDate = $Cell.get_DisplayStringValue()
#	#$RefDataSetDate = ([datetime]::ParseExact($dataSetDate,"MM/dd/yyyy",$null)).toshortdatestring()
	
#	#Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from $strFileName Column [ValuationDate] :: $RefDataSetDate " | Out-File $LogFile -Append
	

	
#	## SSIS Status Variables
#	[Int]$lastexitcode = $null
#	[String]$SSISErrorMessage = $null
	
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianNTHoldingPosition.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
#	$GenericImportJobID = 119
#   	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
#	$RefDatasetDate = $ReturnDate
	
#	## Check SSIS is success or not 
#	If ($lastexitcode -ne 0 ) {
#			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT Holding Position: file ( $strFileName ) not success" | Out-File $LogFile -Append
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
#			Exit
#		}
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT Holding Position: file ( $strFileName ) imported" | Out-File $LogFile -Append

##	#DF_Label	
##	$DF_RefDataSource = "Northern Trust"
##	$DF_RefDataSetType = "P&L By Company"
##	$DF_Label = "NT P&L Data"
##
##	#Ref_Label
##	$Ref_RefDataSource = "Northern Trust Position Rec"
##	$Ref_RefDataSetType = "Position"
##	$Ref_Label = "Position Rec"	
##	
##	# SSIS Status Variables
##	[Int]$lastexitcode = $null
##	[String]$SSISErrorMessage = $null
##	
##	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizePositionGeneric.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n  DF_RefDataSource = $DF_RefDataSource  `r`n DF_RefDataSetType = $DF_RefDataSetType `r`n DF_Label = $DF_Label `r`n Ref_RefDataSource = $Ref_RefDataSource `r`n Ref_RefDataSetType = $Ref_RefDataSetType `r`n Ref_Label = $Ref_Label `r`n PowerShellLocation = $ScriptName"  | Out-File $logFile -Append 
##	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
##	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
##	$GenericNormalizationJobID = 8
##	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
##	
##	## Check SSIS is success or not 
##	If ($lastexitcode -ne 0 ) {
##			$SSISErrorMessage = fSSISExitCode $lastexitcode;
##			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NT Holding Position: file ( $strFileName ) NormalizePositionGeneric.dtsx is not success" | Out-File $LogFile -Append
##			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
##			Exit
##		} 
##	
##	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT Holding Position: file ( $strFileName ) normalized" | Out-File $LogFile -Append

#	$GenericNormalizationJobID = 8
#	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormalizationJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $PSScriptName

#	##Normalize NT InstPrice
#	# SSIS Status Variables
#	[Int]$lastexitcode = $null
#	[String]$SSISErrorMessage = $null
	
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeNTInstPrice.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n PowerShellLocation = $ScriptName"  | Out-File $logFile -Append 
#	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
#	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeNTInstPrice.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append

#	## Check SSIS is success or not 
#	If ($lastexitcode -ne 0 ) {
#			$SSISErrorMessage = fSSISExitCode $lastexitcode;
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NT Inst Price: file ( $strFileName ) NormalizeNTInstPrice is not success" | Out-File $LogFile -Append
#			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
#			Exit
#		} 
	
#	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT Inst Price: file ( $strFileName ) normalized" | Out-File $LogFile -Append
 
#}
## NAV
$dirArchiveFolder 		= "$dirDataFeedsArchiveFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData\Archive\NAV"
foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "NAV Activity Report.XLS"})
 {   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  NT NAV  : file ( $strFileName ) processing "  

	
    New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
   
	$strFile = $strFileName.BaseName
 	$xls = "$dirDataFeedsFolder\$strFileName"
	$csv = "$dirDataFeedsFolder\$strFile.csv"
	$csvTmp = "$dirDataFeedsFolder\$strFile"+"Tmp.csv"
	$strFileTmp = "$strFile"+"Tmp.csv"
	
	Remove-Item -Path  $csvTmp -Force 
	Remove-Item -Path  $csv -Force 

	
	$wb = New-Object Aspose.Cells.Workbook($xls);
	$ws = $wb.WorkSheets[0];
	$Cell = $ws.Cells["A5"];
	$dataSetDate = $Cell.get_DisplayStringValue()
	$dataSetDate = $dataSetDate.Split("-")[1]
	$dataSetDate = $dataSetDate.Trim()
	$RefDataSetDate = ([datetime]::ParseExact($dataSetDate,"d MMM yyyy",$null)).toshortdatestring()
	
	$wb.Save($csv);
	
	$csvData = Import-Csv $csv -Header Column1,Column2  
	
	$csvData  | Export-Csv -Path  $csvTmp   -NoTypeInformation
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianNTHoldingPosition.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileTmp `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   	& $2016DTEXEC64 /F "$dirSSISExtractCustodian\ImportCustodianNTNAVActivity.dtsx" /set "\package.variables[FileName].Value;$strFileTmp"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"/set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT NAV: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT NAV: file ( $strFileName ) imported" | Out-File $LogFile -Append

	#SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizePositionGeneric.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n PowerShellLocation = $ScriptName"  | Out-File $LogFile -Append 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianNTNAV.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NT NAV: file ( $strFileName ) NormalizeCustodianBNPRebate.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
		
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT NAV: file ( $strFileName ) normalized" | Out-File $LogFile -Append
	Remove-Item -Path  $csvTmp -Force 
	Remove-Item -Path  $csv -Force 
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$strDateNow -Force
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
 
 
	}
	
################################# NORTHERN TRUST CASH ###################################

Write-Output "Loading process is starting now" | Out-File $logFile -Append
$dirSourceFolder = $dirDataFeedsFolder
foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Cash and Foreign Currency.XLSX"})
{   #$CSVCashFile = $strFileName.BaseName+".csv"
    #$CSVCashPath = "$dirSourceFolder\$CSVCashFile"
    $dirArchiveFolder = "$dirArchiveHCM97DriveFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData\Archive\Cash"
            $strDate = $strDateNow 
            if (!(Test-Path -path $dirArchiveFolder\$strDate)) 
            { 
	            New-Item -path $dirArchiveFolder\$strDate -ItemType directory 
            }
    $FileNamePath = $strFileName.FullName
	
	#$wb = New-Object Aspose.Cells.Workbook($FileNamePath);  
	#$ws = $wb.WorkSheets[0];
    #
    #$wb.Save($CSVCashPath)
	#$DataCash = Import-Csv -Path $CSVCashPath -Header "Valuation Date"
	#$dataSetDate = $DataCash[1]."Valuation Date"
	#$RefDataSetDate = ([datetime]::ParseExact($dataSetDate,”M/dd/yyyy”,$null)).toshortdatestring()
       	   
			$Label='NT Cash Data'   
	        ##SSIS Status Variables
            [Int]$lastexitcode = $null
	        [String]$SSISErrorMessage = $null
	
	    	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianNTCashData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $CSVCashFile `r`n  PowerShellLocation = $ScriptName    " | Out-File $LogFile -Append
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	$GenericImportJobID = 120
   	fGenericImportJob $GenericImportJobID -pDirSourceFolder $null -pRefDataSetDate $null -pLabel $null -pLogFile $LogFile -pFileName $null -pDirArchiveFolder $null ([Ref]$ReturnDate)
	$RefDatasetDate = $ReturnDate
	
	##Remove CSV File
	#Remove-Item $CSVCashPath
		
				## Check SSIS is success or not 
	
                If ($lastexitcode -ne 0 ) {
			        $SSISErrorMessage = fSSISExitCode $lastexitcode;
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ImportCustodianNTCashData : file ( $strFileName ) not success" | Out-File $LogFile -Append
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			        Exit
		        }
<#
	
			        ##SSIS Status Variables
            [Int]$lastexitcode = $null
	        [String]$SSISErrorMessage = $null
	
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianNTCashWorksheetAccount.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n  PowerShellLocation = $ScriptName    " | Out-File $LogFile -Append
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


            & $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianNTCashWorksheetAccount.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"|  Out-File $logFile  -Append

				## Check SSIS is success or not 
	
                If ($lastexitcode -ne 0 ) {
			        $SSISErrorMessage = fSSISExitCode $lastexitcode;
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeCustodianNTCashWorksheetAccount : file ( $strFileName ) not success" | Out-File $LogFile -Append
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			        Exit

				}
	#>			
}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  NT Cash Data : file ( $strFileName ) imported" | Out-File $LogFile -Append


################################# NORTHERN TRUST PROFIT & LOSS ###################################
foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Profit & Loss Report.XLSX"})
{
    $CSVPLFile = $strFileName.BaseName+".csv"
    $CSVPLPath = "$dirSourceFolder\$CSVPLFile"
    $dirArchiveFolder = "$dirArchiveHCM97DriveFolder\NorthernTrustAdministratorNavCashPositionRecPLPriceData\Archive\P&L"
  
            ###Create Archive folder
            
            ##$strDate = get-date -format "yyyyMMdd"
            $strDate = $strDateNow 
            if (!(Test-Path -path $dirArchiveFolder\$strDate)) 
            { 
	            New-Item -path $dirArchiveFolder\$strDate -ItemType directory 
            }
            
      $FileNamePath = $strFileName.FullName
	
	$wb = New-Object Aspose.Cells.Workbook($FileNamePath);  
	$ws = $wb.WorkSheets[0];
   
    $wb.Save($CSVPLPath)
	
	$dataSetDate = $null
	$DataPL = Import-Csv -Path $CSVPLPath -Header "a","b","Through Date"
	$dataSetDate = $DataPL[1]."Through Date"
	$RefDataSetDate = ([datetime]::ParseExact($dataSetDate,”M/dd/yyyy”,$null)).toshortdatestring()
            $Label='Profit & Loss Report'

	        ##SSIS Status Variables
            [Int]$lastexitcode = $null
	        [String]$SSISErrorMessage = $null
	
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianNTPLData.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $dirSourceFolder `r`n  FileName = $CSVPLFile `r`n  PowerShellLocation = $ScriptName    " | Out-File $LogFile -Append
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
            & $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianNTPLData.dtsx" /set "\package.variables[FileName].Value;$CSVPLFile"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$Label"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"|  Out-File $logFile  -Append
	
		 ##Remove CSV File
	Remove-Item $CSVPLPath
	
				## Check SSIS is success or not 
	
                If ($lastexitcode -ne 0 ) {
			        $SSISErrorMessage = fSSISExitCode $lastexitcode;
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ImportCustodianNTPLData : file ( $strFileName ) not success" | Out-File $LogFile -Append
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			        Exit

				}
				
	
 ##SSIS Status Variables
            [Int]$lastexitcode = $null
	        [String]$SSISErrorMessage = $null
	
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianNTFundValue.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n  PowerShellLocation = $ScriptName    " | Out-File $LogFile -Append
	        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append


& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianNTFundValue.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"|  Out-File $logFile  -Append

## Check SSIS is success or not 
	
                If ($lastexitcode -ne 0 ) {
			        $SSISErrorMessage = fSSISExitCode $lastexitcode;
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NormalizeCustodianNTFundValue : file ( $strFileName ) not success" | Out-File $LogFile -Append
			        Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			        Exit

				}
			
	        ###Move file to Archive Directory
            Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder\$strDate   | Out-File $logFile -Append
            Write-Output "Source file $strFileName moved to folder $dirArchiveFolder\$strDate" | Out-File $logFile -Append

	#DF_Label	
	$DF_RefDataSource = "Northern Trust"
	$DF_RefDataSetType = "P&L By Company"
	$DF_Label = "NT P&L Data"

	#Ref_Label
	$Ref_RefDataSource = "Northern Trust Position Rec"
	$Ref_RefDataSetType = "Position"
	$Ref_Label = "Position Rec"	
	
	# SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizePositionGeneric.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate  `r`n  DF_RefDataSource = $DF_RefDataSource  `r`n DF_RefDataSetType = $DF_RefDataSetType `r`n DF_Label = $DF_Label `r`n Ref_RefDataSource = $Ref_RefDataSource `r`n Ref_RefDataSetType = $Ref_RefDataSetType `r`n Ref_Label = $Ref_Label `r`n PowerShellLocation = $ScriptName"  | Out-File $logFile -Append 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
#	$GenericNormalizationJobID = 8
#	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

#	$GenericNormalizationJobID = 8
#	fGenericNormalization -pGenericNormaliztaionJobID $GenericNormalizationJobID -pRefDatasetDate $RefDatasetDate -pLogFile $LogFile -pScriptName $PSScriptName
	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") NT Holding Position: file ( $strFileName ) NormalizePositionGeneric.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		} 
	
	 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") NT Holding Position: file ( $strFileName ) normalized" | Out-File $LogFile -Append

}
	
##Push InstRatings

& $2016DTEXEC32 /F "$dirSSISPush\PushRatings.dtsx"  /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"|  Out-File $logFile  -Append
	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
