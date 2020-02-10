FUNCTION fWSOArchive-ZipFilesAPIPositionsEOD {
    Param
	{
	  [string]$WSO_Extracts_DIR
	  ,[datetime]$process_date
	  ,[string]$LogFile
	  }
   Clear-Host
	$ScriptName = $MyInvocation.MyCommand.Name
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
	
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
	
$strDateNow = get-date $process_date -format "yyyyMMdd"

#$strDate = get-date -format "yyyyMMddTHHmmss"

#$FullDayString = ($process_date).ADDDAYS(-1).ToString("MM/dd/yyyy")
#$FullDayString = ($process_date).ADDDAYS(0).ToString("MM/dd/yyyy")
#$strDateNow = "20151102"
$PriorstrDateNow = $strDateNow - 1
$strDate = get-date -format "yyyyMMddTHHmmss"
#$strDate = "20151103T000000"
#$PriorstrDateNow = "20151103"
#$FullDayString = "11/03/2015"
$WSO_Extracts_DIR1 		= "$WSO_Extracts_DIR\$strDateNow\API\Converted"
$ArchiveFolder = "$WSO_Extracts_DIR1\Archive"

Write-Output " WSO_Extracts_DIR1		= $WSO_Extracts_DIR1" |  Out-File $LogFile -Append
Write-Output " ArchiveFolder			= $ArchiveFolder" |  Out-File $LogFile -Append
Write-Output " FullDayString			= $FullDayString" |  Out-File $LogFile -Append
Write-Output " PriorstrDateNow			= $PriorstrDateNow" |  Out-File $LogFile -Append


if (!(Test-Path -path $ArchiveFolder\$strDate)) 
    { 
	    New-Item -path $ArchiveFolder\$strDate -ItemType directory 
    }
	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Archiving/Zipping WSO-API files starts here " | Out-File $LogFile -Append

##Move file to Archive Directory
    Move-Item -Path "$WSO_Extracts_DIR1\EOD*_$strDateNow.csv" "$ArchiveFolder\$strDate" 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $WSO_Extracts_DIR1\EOD*_$strDate.csv ) to location ( $ArchiveFolder\$strDate ) " | Out-File $LogFile -Append
    
	##COMPRESS THE FILES##
	& "C:\Program Files\WinRAR\winrar.exe" a -r -ep1 -df -ed -ibck "$ArchiveFolder\$strDate.rar" "$ArchiveFolder\$strDate" 
	sleep -Seconds 10
	Remove-Item $ArchiveFolder\$strDate
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Compressed the source files " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
	}
	