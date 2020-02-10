
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$start_day = Get-Date -Date "03/01/2018"
$end_day = Get-Date -Date "03/19/2018"

while ($start_day -le $end_day) {

	$current_date = $start_day
	$current_string = $current_date.ToString("yyyy-MM-ddT00:00:00Z")
	$current_payload = "<ReportParameters><ReportId>7</ReportId><RunDate>$current_string</RunDate></ReportParameters>"
	$enc = [system.Text.Encoding]::UTF8
	$current_payload_encoded = $enc.GetBytes($current_payload) 

	Write-PubSub -Subject "WSOAdapter.Reports.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $current_payload_encoded
	
	$start_day = $start_day.AddDays(1)
}
