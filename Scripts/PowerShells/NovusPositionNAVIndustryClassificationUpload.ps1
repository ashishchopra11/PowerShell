############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

[System.Reflection.Assembly]::LoadFrom($dirAsposeCellsDLLv4)


## Aspose License
$license = New-Object Aspose.Cells.License
$license.SetLicense($dirAsposeCellsLic);


#----------------------------------------------------- 
#----  Release Object Reference
#----------------------------------------------------- 
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("GenerateNovusFile."+$strDateNow+".txt")
#$logFile = "$dirLogFolder\GenerateNovusFile.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append


$RefDatasetDate = get-date -format "yyyyMMdd"

$SourceFile = "\\hcmlp.com\data\public\Investments-Research\Teams\Team Equity\Portfolio Management\Portfolio Sheets\IndustryClassifications.xlsm"
$DestinationFile = "D:\Siepe\Data\Scripts\DataTransfer\Novus\IndustryClassifications1.xlsm"
$ExcelFilePath = "D:\Siepe\Data\Scripts\DataTransfer\Novus"

$ArchivePath = "$dirArchiveHCM46DriveFolder\Novus\Archive\RawFile"


$DestinationPath = "$dirArchiveHCM46DriveFolder\Novus"
$FileSaveName = "$DestinationPath\NovusUpload"+$RefDatasetDate+".csv" 


If (Test-Path $FileSaveName)   {
    Remove-Item  -Path $FileSaveName -Force
} 


If ((Test-Path $DestinationFile) -eq $false) {
    New-Item -ItemType File -Path $DestinationFile -Force
} 

Copy-Item -Path $SourceFile -Destination $DestinationFile -Force

#----------------------------------------------------- 
#----  Actual work of the file
#-----------------------------------------------------


$FileName = "NovusMacroFile.$RefDatasetDate.xls"

 if (!(Test-Path -path $ArchivePath\$strDateNow )) 
    { 
	    New-Item -path $ArchivePath\$strDateNow -ItemType directory 
    }
	
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Making Excel Object `r`n" |  Out-File $LogFile -Append


$excelfile = "$ExcelFilePath\$FileName"
$sheet ='Sheet1' 
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Excel file variables `r`n" |  Out-File $LogFile -Append


##Create New excel
$WB = New-Object Aspose.Cells.Workbook;
$WB.Save($excelfile);


$ExcelWorkbook = New-Object Aspose.Cells.Workbook($excelfile);
	
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Open file  `r`n" |  Out-File $LogFile -Append
 
#$ExcelWorkSheet = $Excel.Worksheets.Item($Sheet)
$ExcelWorkSheet = $ExcelWorkbook.Worksheets[$Sheet]

$IndustryWB = New-Object Aspose.Cells.Workbook($DestinationFile);
$Sheet1="Classifications"
$IndustryWS = $IndustryWB.Worksheets[$Sheet1]


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Open Sheet  `r`n" |  Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


Write-Output " FileSaveName		        = $FileSaveName `r`n" | Out-File $LogFile -Append
Write-Output " RefDatasetDate	        = $RefDatasetDate `r`n" | Out-File $LogFile -Append
Write-Output " LogFile 		        = $LogFile  `r`n" | Out-File $LogFile -Append
Write-Output " strDateNow		        = $strDateNow  `r`n" | Out-File $LogFile -Append
 


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Assigning values to Excel cells `r`n" |  Out-File $LogFile -Append

#$ExcelWorkSheet.Cells.Item(1,1) = "InstID" 
$Cells1 = $ExcelWorkSheet.Cells["A1"];
$Cells1.PutValue("InstID");

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,1) = InstID `r`n" |  Out-File $LogFile -Append
#$ExcelWorkSheet.Cells.Item(1,2) = "Ticker"
$Cells2 = $ExcelWorkSheet.Cells["B1"];
$Cells2.PutValue("Ticker");
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,2) = Ticker `r`n" |  Out-File $LogFile -Append
#$ExcelWorkSheet.Cells.Item(1,3) = "Industry"
$Cells3 = $ExcelWorkSheet.Cells["C1"];
$Cells3.PutValue("Industry");
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,3) = Industry `r`n" |  Out-File $LogFile -Append
#$ExcelWorkSheet.Cells.Item(1,4) = "Sector1"
$Cells4 = $ExcelWorkSheet.Cells["D1"];
$Cells4.PutValue("Sector1");

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,4) = Sector1 `r`n" |  Out-File $LogFile -Append
#$ExcelWorkSheet.Cells.Item(1,5) = "Analyst"
$Cells5 = $ExcelWorkSheet.Cells["E1"];
$Cells5.PutValue("Analyst");

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,5) = Analyst `r`n" |  Out-File $LogFile -Append
#$ExcelWorkSheet.Cells.Item(1,6) = "Beta"
$Cells6 = $ExcelWorkSheet.Cells["F1"];
$Cells6.PutValue("Beta");

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Value At (1,6) = Beta `r`n" |  Out-File $LogFile -Append
 
$I = 2
$max=5001
$Ref = 8 


while ($I -le $max)
{

#get value
$get_valueB = $IndustryWS.Cells["B$Ref"].Value
$get_valueE = $IndustryWS.Cells["E$Ref"].Value
$get_valueJ = $IndustryWS.Cells["J$Ref"].Value
$get_valueL = $IndustryWS.Cells["L$Ref"].Value
$get_valueC = $IndustryWS.Cells["C$Ref"].Value


if ($get_valueB -ne $null -and $get_valueB.ToString() -ne "")
{
	if ($get_valueB -eq $null -or  $get_valueB.Length -le 0) {$get_valueB = 0}
	if ($get_valueE -eq $null -or  $get_valueE.Length -le 0) {$get_valueE = 0}
	if ($get_valueE -eq "#N/A N/A") {$get_valueE = ""}
	if ($get_valueJ -eq "#N/A") {$get_valueJ = ""}
		elseif ($get_valueJ -eq $null -or  $get_valueJ.Length -le 0) {$get_valueJ = 0}
	if ($get_valueL -eq $null -or  $get_valueL.Length -le 0) {$get_valueL = 0}
	if ($get_valueC -eq $null -or  $get_valueC.Length -le 0) {$get_valueC = 0}
	
	 #set value
	$ExcelWorkSheet.Cells["B$I"].putvalue($get_valueB)
	$ExcelWorkSheet.Cells["C$I"].putvalue($get_valueE)
	$ExcelWorkSheet.Cells["D$I"].putvalue($get_valueJ)
	$ExcelWorkSheet.Cells["E$I"].putvalue($get_valueL)
	$ExcelWorkSheet.Cells["F$I"].putvalue($get_valueC)
 }
$Ref = $Ref + 1
$I = $I + 1
} 
 

$ExcelWorkbook.Save($excelfile);

Start-Sleep -s 3

$dtDataSetDate = ([datetime]::ParseExact($RefDatasetDate.Trim(),"yyyyMMdd",$null)).toshortdatestring() 
 

## SSIS Status Variables
[Int]$lastexitcode = $null
[String]$SSISErrorMessage = $null


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianNovusPositionNAVIndustryClassification.dtsx `r`n Variable passed here are : `r`n FileName = $FileName `r`n  FolderName = $ExcelFilePath `r`n  DestinationPath = $DestinationPath  `r`n RefDataSetDate = $dtDataSetDate `r`n PowerShellLocation=$ScriptName" | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
### RiskFundDailyPLByNav Report
   
& $2016DTEXEC32 /F "$dirSSISDataTransfer\ImportCustodianNovusPositionNAVIndustryClassification.dtsx" /set "\package.variables[FileName].Value;$FileName"/set "\package.variables[FolderName].Value;$ExcelFilePath" /set "\package.variables[DestinationPath].Value;$DestinationPath" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
		$SSISErrorMessage = fSSISExitCode $lastexitcode;
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ImportNovusFileData not success" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
		Exit
	}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ImportNovusFileData imported" | Out-File $LogFile -Append

Move-Item -Path $ExcelFilePath\$FileName $ArchivePath\$strDateNow 
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $ArchiveDir\$strDateNow ) " | Out-File $LogFile -Append
	
Remove-Item $DestinationFile
 
	  
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
 