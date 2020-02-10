Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

$enc = [system.Text.Encoding]::UTF8
$string1 = "27" 
$data1 = $enc.GetBytes($string1) 

Write-PubSub -Subject "WSOAdapter.Report.Run" -Title "WSOAdapter.Reports.Run" -Description "WSOAdapter.Reports.Run" -Payload $data1
