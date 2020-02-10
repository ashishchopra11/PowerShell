############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLL)

#$license = New-Object Aspose.Cells.License
#$license.SetLicense($dirAsposeCellsLic);

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Archive folder
$strDateNow	  = Get-Date -format "yyyyMMddTHHmmss"
#$logFile    = "$dirLogFolder\VendorBloombergFactors"+$strDateNow+".txt"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
## Source Folder Paths
$dirSourceFolder 			= "$dirServicesDeliveryStoreFolder\Bloomberg\Port"
$dirArchiveFolder 			= "$dirArchiveHCM46DriveFolder\Bloomberg\Port\Archive"


$EachFile					= $null

Write-Output " dirSourceFolder`t`t`t`t= $dirSourceFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder`t`t`t`t= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile`t`t`t`t= $logFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Creating Archive directory ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory	

$RefDataSetDate

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Bloomberg Factor starts here " | Out-File $LogFile -Append

foreach ($EachFile in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*.xls"}) 
{	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Bloomberg Factor : file ( $EachFile ) processing " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing source file to find RefDataSetDate" | Out-File $LogFile -Append
	
	$strFullFileName = $EachFile.FullName

	$wb = New-Object Aspose.Cells.Workbook($strFullFileName);
	$ws = $wb.Worksheets["Tracking Error Exposure"]
		
	$Cell = $ws.Cells["B7"];
	$RefDataSetDate1 = $Cell.get_DisplayStringValue()
			
		
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”M/d/yyyy”,$null)).toshortdatestring();
	$strFileName = $EachFile
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from Cell (B7) of file ( $EachFile )  :: $RefDataSetDate " | Out-File $LogFile -Append
		
	if($strFileName -ilike "GL_Factor*.xls")
	{  $FullFilePath = "$dirSourceFolder\$strFileName"
		$Label = "Bloomberg Factor Global Risk - " + $strFileName
		$Label = $Label.Substring(0,$Label.Length-4)
		$dtDate = Get-Date -format "yyyy/MM/dd HH:mm:ss"		
	
	$wb = New-Object Aspose.Cells.Workbook($strFullFileName);
	$ws = $wb.Worksheets["Tracking Error Exposure"]
	
	$a = $ws.Cells.MaxRow + 1 ;
	$b = $ws.Cells.MaxColumn + 1 ;

	
$nCol = $b;
$sChars = "0ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$sCol = "";


    $nChar = $nCol % 26;
    $nCol = ($nCol - $nChar) / 26;
    #$sCol = $sChars[$nChar] + $sCol;
	$sCol = $sChars[$nCol]+$sChars[$nChar]
	if($nCol -eq 0)
	{ $sCol = $sChars[$nChar]
	}
	$ColumnIndexNameGL = $sCol 
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractVendorBloombergFactorsGL.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISExtractVendor\ExtractVendorBloombergFactorsGL.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$Label"  /set "\package.variables[ColumnIndexNameGL].Value;$ColumnIndexNameGL" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) imported" | Out-File $LogFile -Append
	}
	elseif($strFileName -ilike "US_Factor*HCM*.xls")
	{
		##Create a temp file and remove first 13 rows.
		$TempFile = "US_Factor_HCM_Tmp.xls"
		$TempFullFile = "$dirSourceFolder\$TempFile"
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Copy File from  $strFullFileName  to  $TempFullFile " | Out-File $LogFile -Append
		Copy-Item $strFullFileName $TempFullFile -Force
		
		$wb = New-Object Aspose.Cells.Workbook($TempFullFile);
		$ws = $wb.Worksheets["Tracking Error Exposure"]
		
		$a = $ws.Cells.MaxRow + 1 ;
		$b = $ws.Cells.MaxColumn + 1 ;
	 
	
$nCol = $b;
$sChars = "0ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$sCol = "";


    $nChar = $nCol % 26;
    $nCol = ($nCol - $nChar) / 26;
    #$sCol = $sChars[$nChar] + $sCol;
	$sCol = $sChars[$nCol]+$sChars[$nChar]
	if($nCol -eq 0)
	{ $sCol = $sChars[$nChar]
	}
	$ColumnIndexNameHCM = $sCol  


		
				
		$Label = "Bloomberg Factor US Equity - " + $strFileName.BaseName
		#$Label = $Label.Substring(0,$Label.Length-4)
	    $dtDate = Get-Date -format "yyyy/MM/dd HH:mm:ss"
		$FileFormat
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractVendorBloombergFactorsUSEquity.dtsx `r`n Variable passed here are : `r`n  FileName = $TempFile `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate `r`n  Label = $Label" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /F "$dirSSISExtractVendor\ExtractVendorBloombergFactorsUSEquity.dtsx" /set "\package.variables[FileName].Value;$TempFile"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$Label" /set "\package.variables[ColumnIndexNameHCM].Value;$ColumnIndexNameHCM" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) imported" | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Removing Item $TempFullFile " | Out-File $LogFile -Append	
	Remove-Item $TempFullFile -Force
	
	}
	elseif($strFileName -ilike "US_Factor*3000*.xls")
	 {    $FullFilePath = "$dirSourceFolder\$strFileName"
	 
	 
	 $wb = New-Object Aspose.Cells.Workbook($FullFilePath);
	$ws = $wb.Worksheets["Tracking Error Exposure"]
		
	$a = $ws.Cells.MaxRow + 1 ;
	$b = $ws.Cells.MaxColumn + 1 ;
	 	
	 	
$nCol = $b;
$sChars = "0ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$sCol = "";


    $nChar = $nCol % 26;
    $nCol = ($nCol - $nChar) / 26;
    #$sCol = $sChars[$nChar] + $sCol;
	$sCol = $sChars[$nCol]+$sChars[$nChar]
	if($nCol -eq 0)
	{ $sCol = $sChars[$nChar]
	}
	$ColumnIndexName3000 = $sCol 
	
		$Label = "Bloomberg Factor US Equity - " + $strFileName.BaseName
		#$Label = $Label.Substring(0,$Label.Length-4)
	    $dtDate = Get-Date -format "yyyy/MM/dd HH:mm:ss"
		Write-Output "> $($dtDate.ToString()) :: ExtractVendorBloombergFactorsUSEquity started for RefDataSetDate :: $RefDataSetDate" | Out-File $LogFile -Append
		
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractVendorBloombergFactorsUSEquity.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirSourceFolder `r`n  RefDataSetDate = $RefDataSetDate `r`n  Label = $Label " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
& $2016DTEXEC32 /F "$dirSSISExtractVendor\ExtractVendorBloombergFactorsUSEquity.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[Label].Value;$Label" /set "\package.variables[ColumnIndexName3000].Value;$ColumnIndexName3000" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append	 ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) imported" | Out-File $LogFile -Append
	
	}
	
    ### Move imported file to Archive Directory
    Move-Item -Path $dirSourceFolder\$strFileName $dirArchiveFolder\$strDateNow 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Move Files from $dirSourceFolder\$strFileName to $dirArchiveFolder\$strDateNow " | Out-File $LogFile -Append
   
	}
 
if($EachFile -eq $null)
{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Bloomberg Factor : Source file doesnot exist :  $dirSourceFolder\*.xls " | Out-File $LogFile -Append
}
else
{
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeVendorBloombergFactor.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	# Normalize
	& $2016DTEXEC32 /F "$dirSSISNormalizeVendor\NormalizeVendorBloombergFactor.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) NormalizeVendorBloombergFactor.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeVendorBloombergFactor.dtsx `r`n "| Out-File $LogFile -Append
   
   ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling PushBloombergFactor.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	##Push Factor
	& $2016DTEXEC32 /F "$dirSSISPush\PushBloombergFactor.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor: file ( $EachFile ) PushBloombergFactor is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Bloomberg Factor : file ( $EachFile ) pushed " | Out-File $LogFile -Append
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append