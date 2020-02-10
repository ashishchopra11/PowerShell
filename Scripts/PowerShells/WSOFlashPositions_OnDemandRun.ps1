
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$SourceDir = "C:\ReExtractFlash\*"
$DestinationDir = "\\hcm97\PMPDataFeeds\ReExtractFlash\"

Copy-Item -path $SourceDir -destination $DestinationDir -Recurse -Force 
Remove-Item $SourceDir -Recurse -Force

$today_date = get-date

if ($today_date.DayOfWeek -eq "Sunday") {
	$current_date = ($today_date).AddDays(-2)
} elseif ($today_date.DayOfWeek -eq "Monday") {
	$current_date = ($today_date).AddDays(-3)
} else {
	$current_date = ($today_date).AddDays(-1)
}

if ($current_date.DayOfWeek -eq "Sunday") {
	$prior_date = ($current_date).AddDays(-2)
} elseif ($current_date.DayOfWeek -eq "Monday") {
	$prior_date = ($current_date).AddDays(-3)
} else {
	$prior_date = ($current_date).AddDays(-1)
}

$test_date = $prior_date.AddDays(-7) #### See Note 1 below
$prior_month_date = $today_date.AddDays(-($today_date.day)) #### See Note 1 below

if ($prior_month_date.DayOfWeek -eq "Saturday") {
	$prior_month_date = ($prior_month_date).AddDays(-1)
} elseif ($prior_month_date.DayOfWeek -eq "Sunday") {
	$prior_month_date = ($prior_month_date).AddDays(-2)
}

$current_string = $current_date.ToString("yyyy-MM-ddT00:00:00Z")
$prior_string = $prior_date.ToString("yyyy-MM-ddT00:00:00Z")
$prior_month_string = $prior_month_date.ToString("yyyy-MM-ddT00:00:00Z") #### See Note 1 below

$current_payload = "<ReportParameters><ReportId>1</ReportId><RunDate>$current_string</RunDate></ReportParameters>"
$prior_payload = "<ReportParameters><ReportId>1</ReportId><RunDate>$prior_string</RunDate></ReportParameters>"
$prior_month_payload = "<ReportParameters><ReportId>1</ReportId><RunDate>$prior_month_string</RunDate></ReportParameters>" #### See Note 1 below

$enc = [system.Text.Encoding]::UTF8
$current_payload_encoded = $enc.GetBytes($current_payload) 
$prior_payload_encoded = $enc.GetBytes($prior_payload) 
$prior_month_payload_encoded = $enc.GetBytes($prior_month_payload)  #### See Note 1 below

Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $current_payload_encoded
Start-Sleep -Seconds 100
Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $prior_payload_encoded
if (($test_date.Month -ne $today_date.Month) -and ($prior_month_date -ne $current_date) -and ($prior_month_date -ne $prior_date)) { #### See Note 1 below
	Start-Sleep -Seconds 100
	Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $prior_month_payload_encoded #### See Note 1 below
} #### See Note 1 below

 #### Note 1 - David Willmore requested that we re-extract data for the end of the prior month for the first 7 business days of each month. This logic accomplishes that request.
 
