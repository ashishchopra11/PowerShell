CLS
function fCleanWSOPriceSourceFile {
    Param ([DateTime]$ArgDate
	,[string]$LogFile
	)

$strDateNow = get-date -format "yyyyMMddTHHmmss"
 
$ScriptName = $MyInvocation.MyCommand.Name
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")Cleaning process is starting now" | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Passed ArgDate :: $ArgDate" | Out-File $LogFile -Append
## Passed date 
[Datetime]$InvalidDate = "01/01/1900"
if ($ArgDate -eq $null -or $ArgDate -eq ""){
[Datetime]$ArgDate = "01/01/1900"
}
[Datetime]$PriorWeekdayDate = $InvalidDate
[Datetime]$RefDataSetDate = $InvalidDate

$ArgDate = Get-Date -Format "MM/dd/yyyy" $ArgDate
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Initial Varialbles " | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: ArgDate :: $ArgDate" | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PriorWeekdayDate :: $PriorWeekdayDate" | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: RefDataSetDate :: $RefDataSetDate" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Finiding Last Weekday Date  " | Out-File $LogFile -Append
## Finiding Last Weekday Date ($PriorWeekdayDate)
[DateTime]$CurrDate = Get-Date -Format "MM/dd/yyyy"
#$CurrDate = $CurrDate.AddDays(-1)
if ('Sunday' -contains $CurrDate.DayOfWeek) {
	$PriorWeekdayDate = $CurrDate.AddDays(-2)
} 
elseif ('Monday' -contains $CurrDate.DayOfWeek){
	$PriorWeekdayDate = $CurrDate.AddDays(-3)
}
else {
	$PriorWeekdayDate = $CurrDate.AddDays(-1)
}	

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: CurrDate :: $CurrDate" | Out-File $LogFile -Append
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PriorWeekdayDate :: $PriorWeekdayDate" | Out-File $LogFile -Append

$RefDataSetDate = $ArgDate

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: RefDataSetDate :: $RefDataSetDate " | Out-File $LogFile -Append

$PriorstrDateNow = $RefDataSetDate.ToString("yyyyMMdd")

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PriorstrDateNow :: $PriorstrDateNow " | Out-File $LogFile -Append


$SourceDir = "D:\Siepe\DataFeeds\WSOReports\$PriorstrDateNow\API\Converted"
$SourceFile = "$SourceDir\PriceRefresh_ExtractMarks_$PriorstrDateNow.csv"
$ArchiveFile = "$SourceDir\Archive\PriceCleanUp\PriceRefresh_ExtractMarks_$PriorstrDateNow.csv"

###Create Archive folder
if (!(Test-Path -path "$SourceDir\Archive\PriceCleanUp" )) 
{ 
	New-Item -path "$SourceDir\Archive\PriceCleanUp" -ItemType directory 
}

if([System.IO.File]::Exists($SourceFile)){
     
     Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Taking Source File backup :: ($SourceFile) to ($ArchiveFile)" | Out-File $LogFile -Append
	 Move-Item $SourceFile $ArchiveFile -Force
	 [DateTime]$MaxDate = $RefDataSetDate
     Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Source File which is cleaning :: $SourceFile " | Out-File $LogFile -Append
	 $dt = import-csv -Path $ArchiveFile | Where-Object {[DateTime]$_.'MarkPrice_MarkDate' -le $MaxDate} | Export-Csv $SourceFile -NoTypeInformation
     Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed Cleaning :: $SourceFile " |Out-File $LogFile -Append
}
else {
	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Source File ($SourceFile ) not present." |Out-File $LogFile -Append
}
}