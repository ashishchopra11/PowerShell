
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$enc = [system.Text.Encoding]::UTF8

$today_date = get-date
$current_date = ($today_date).AddDays(-1)
$current_string = $current_date.ToString("yyyy-MM-ddT00:00:00Z")
$current_payload = "<ReportParameters><ReportId>4</ReportId><RunDate>$current_string</RunDate></ReportParameters>"
$current_payload_encoded = $enc.GetBytes($current_payload) 

######Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $current_payload_encoded
