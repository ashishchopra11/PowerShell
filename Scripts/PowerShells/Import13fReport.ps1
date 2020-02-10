############## Reference to configuration files ###################################
	CLS

	$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

	Set-Location $ConfigRootFOlder
	. .\ConnectionStrings.config.ps1
	. .\DTExec.Config.ps1
	. .\IOFunctions.ps1
	. .\DirLocations.Config.ps1
	. .\fOffsetDate.ps1
    . .\fSSISExitCode.ps1
#################################################################################### 

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"

###Create Log file
Create-File -path $($dirLogFolder+"\") -fileName $("Import13fReport."+$strDateNow+".txt")
$logFile = "$dirLogFolder\Import13fReport.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$PDFSourceFolder = "$dirServicesDeliveryStoreFolder\13fReport"
$dirSourceFolder = "$dirServicesDeliveryStoreFolder\13fReport"
$SourceFolder = "$dirServicesDeliveryStoreFolder\13fReport\converted"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\13fReport\Archive"

New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory
$dirArchiveFolder = $dirArchiveFolder+"\"+$strDateNow

Write-Output " dirSourceFolder`t`t`t= $dirSourceFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder`t`t`t= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " strDateNow`t`t`t= $strDateNow" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Import starts here " | Out-File $LogFile -Append

& C:\Tools\PDFParser\PDFParser.exe $dirSourceFolder "txt" 

$Today = [datetime]::today
$StartDate =Get-Date $Today -Month ([math]::ceiling($Today.Month/4)*3-2) -Day 1
$EndDate = $StartDate.AddMonths(3).AddSeconds(-1)
$RefDataSetDate=$EndDate.ToString('yyyy-MM-dd')

foreach ($strFileName in Get-ChildItem  -Path $SourceFolder | Where-Object {$_.Name -ilike "*Reportable Securities List.txt*"}) 
{

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::   file ( $strFileName ) processing " | Out-File $LogFile -Append


	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from $strFileName Column [POSITIONDATE] :: $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling Import13fReport.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $SourceFolder `r`n  RefDataSetDate = $RefDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	& $2016DTEXEC32 /F "$dirSSISRootFolder\Import13fReport.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$SourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" | Out-File $LogFile -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  file ( $strFileName ) imported" | Out-File $LogFile -Append

	Move-Item -Path $SourceFolder\$strFileName $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $SourceFolder\$strFileName ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

}

foreach ($PDFfile in Get-ChildItem -Path $PDFSourceFolder | Where-Object {$_.Name -ilike "*Reportable Securities List.pdf*"}) 
{
    Move-Item -Path $PDFSourceFolder\$PDFfile $dirArchiveFolder 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $PDFSourceFolder\$PDFfile ) to location ( $dirArchiveFolder ) " | Out-File $LogFile -Append

}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append

