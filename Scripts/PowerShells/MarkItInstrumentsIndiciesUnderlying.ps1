## DW Load Marks Script
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}
New-Variable curr_date 
$curr_date = (Get-Date)

$strDateNow = Get-Date -format "yyyyMMddTHHmmss"
#$logFile    = "$dirLogFolder\MarkIT_FacilityMarksChannel"+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$dirDataFeedsFolder = "$dirServicesDeliveryStoreFolder\MarkIt Instruments Indices and Underlying"
$dirArchiveFolder= "$dirArchiveHCM46DriveFolder\MarkIt Instruments Indices and Underlying"

Write-Output " dirDataFeedsFolder	= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " logFile				= $logFile" |  Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  DW Load Daily Marks starts here " | Out-File $LogFile -Append
### Do not load on Saturday or Sunday ... and always load after 3:10 PM  (4:00 PM EST) ...
if ($curr_date.DayOfWeek -ne "Sunday" -and $curr_date.DayOfWeek -ne "Saturday" -and $curr_date.TimeOfDay.TotalHours -ge 15.20) {

	$FullDayString = $curr_date.ToShortDateString()
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Parsing RefDataSetDate as current date :: $FullDayString " | Out-File $LogFile -Append
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	  
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractCustodianMarkItFacilityUpdatesChannel.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString `r`n  DataFeedsDir = $dirDataFeedsFolder " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC64 /f "$dirSSISExtractCustodian\ExtractCustodianMarkItFacilityUpdatesChannel.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DataFeedsDir].Value;$dirDataFeedsFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks : Imported" | Out-File $LogFile -Append
	
Move-Item "$dirDataFeedsFolder\Facilities*.xml"  $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Moved Facilities*.XML to  $dirArchiveFolder " | Out-File $LogFile -Append

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianMarkItFacilityChannel.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC64 /f "$dirSSISNormalizeCustodian\NormalizeCustodianMarkItFacilityChannel.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: NormalizeCustodianMarkItFacilityChannel.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianMarkItFacilityChannel.dtsx `r`n "| Out-File $LogFile -Append
		
	$dirDataFeedsFolder= "$dirServicesDeliveryStoreFolder"
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: Updating the value of dirDataFeedsFolder :: $dirDataFeedsFolder" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractCustodianMarkItMarksChannel.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString `r`n  DataFeedsDir = $dirDataFeedsFolder  " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC64 /f "$dirSSISExtractCustodian\ExtractCustodianMarkItMarksChannel.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DataFeedsDir].Value;$dirDataFeedsFolder" /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $LogFile -Append
	## Check SSIS is success or not 
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: Imported" | Out-File $LogFile -Append
	
		
Move-Item "$dirDataFeedsFolder\AllMarks*.xml"  $dirArchiveFolder
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Moved AllMarks*.XML to  $dirArchiveFolder " | Out-File $LogFile -Append

	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeCustodianMarkItMarksChannel.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC64 /f "$dirSSISNormalizeCustodian\NormalizeCustodianMarkItMarksChannel.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") DW Load Daily Marks: NormalizeCustodianMarkItMarksChannel.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeCustodianMarkItMarksChannel.dtsx `r`n "| Out-File $LogFile -Append
 }
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append

# SIG # Begin signature block
# MIIIAQYJKoZIhvcNAQcCoIIH8jCCB+4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMwheUKCKW3/er+DPaMvKyjEU
# TeegggXrMIIF5zCCBM+gAwIBAgIKe1JSKwAAAAAERTANBgkqhkiG9w0BAQUFADBS
# MRMwEQYKCZImiZPyLGQBGRYDY29tMRUwEwYKCZImiZPyLGQBGRYFaGNtbHAxJDAi
# BgNVBAMTG0hpZ2hsYW5kIENhcGl0YWwgTWFuYWdlbWVudDAeFw0wNzEwMTcxNDIx
# NThaFw0wODEwMTYxNDIxNThaMHUxEzARBgoJkiaJk/IsZAEZFgNjb20xFTATBgoJ
# kiaJk/IsZAEZFgVoY21scDEPMA0GA1UECxMGRGFsbGFzMQ4wDAYDVQQLEwVVc2Vy
# czELMAkGA1UECxMCSVQxGTAXBgNVBAMTEE1pY2hhZWwgRmVyZ3Vzb24wgZ8wDQYJ
# KoZIhvcNAQEBBQADgY0AMIGJAoGBAPgZqmo92hJEGkujw26Vxeh7qhkWNAnYyUBh
# +6+Te6hdKyj569gN5iQCrq9jwXtlJ2Sz/TftaT3FbJdH98voOylOOOsGpnkErRqI
# G6J10uKpgyJkRr4oXcmtnchbw5Gw7CMTeeKMSoJgSshD3iye4kOUS8SAmdtYLfLY
# MmR/v3ClAgMBAAGjggMeMIIDGjALBgNVHQ8EBAMCB4AwHQYDVR0OBBYEFMkh/5Z4
# DaKFxsXOkqVOLYDYDQfuMCUGCSsGAQQBgjcUAgQYHhYAQwBvAGQAZQBTAGkAZwBu
# AGkAbgBnMB8GA1UdIwQYMBaAFCXZ/x4s6jCUc/qoLIS/Iywf6YBpMIIBJQYDVR0f
# BIIBHDCCARgwggEUoIIBEKCCAQyGgcJsZGFwOi8vL0NOPUhpZ2hsYW5kJTIwQ2Fw
# aXRhbCUyME1hbmFnZW1lbnQsQ049SENNMDIsQ049Q0RQLENOPVB1YmxpYyUyMEtl
# eSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9aGNt
# bHAsREM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RD
# bGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIZFaHR0cDovL2hjbTAyLmhjbWxwLmNv
# bS9DZXJ0RW5yb2xsL0hpZ2hsYW5kJTIwQ2FwaXRhbCUyME1hbmFnZW1lbnQuY3Js
# MIIBNAYIKwYBBQUHAQEEggEmMIIBIjCBvAYIKwYBBQUHMAKGga9sZGFwOi8vL0NO
# PUhpZ2hsYW5kJTIwQ2FwaXRhbCUyME1hbmFnZW1lbnQsQ049QUlBLENOPVB1Ymxp
# YyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24s
# REM9aGNtbHAsREM9Y29tP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1j
# ZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MGEGCCsGAQUFBzAChlVodHRwOi8vaGNtMDIu
# aGNtbHAuY29tL0NlcnRFbnJvbGwvSENNMDIuaGNtbHAuY29tX0hpZ2hsYW5kJTIw
# Q2FwaXRhbCUyME1hbmFnZW1lbnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMDMC4G
# A1UdEQQnMCWgIwYKKwYBBAGCNxQCA6AVDBNNRmVyZ3Vzb25AaGNtbHAuY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQBDuDOguaxG8511Eqqg6SzOCE2BnlYJgFiITav0hUFg
# 2hQZYKIyjjwTiSa9JHv3IusS0H4opbMNyQwOek4I9uSip893TNm+tioohOmXiWuX
# NW4WpL3+HkcNGIdFDWdxdwgrah7LxDj6EA/oc4ApbQ9qHrJFqDXGHq/xAkI7EM48
# vW7mA3Ak9YvoTPsJp5tmP+FfqqufxJEpj0c/8I7BhHG3r7bArGjpi8wc4ECy1zY5
# oGBL19Xy56QFw2yWdEQpT1RaK2Cqvtx89E0qYsP9OAwY9+Apv/eVQGsCh663jCCh
# laox8ITbYSnBBQvN67lzrj0LSwt7RGa9SEKohHYuZLhEMYIBgDCCAXwCAQEwYDBS
# MRMwEQYKCZImiZPyLGQBGRYDY29tMRUwEwYKCZImiZPyLGQBGRYFaGNtbHAxJDAi
# BgNVBAMTG0hpZ2hsYW5kIENhcGl0YWwgTWFuYWdlbWVudAIKe1JSKwAAAAAERTAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQU5YKDrtVXmlA8khlpjqmz82rntdcwDQYJKoZIhvcNAQEB
# BQAEgYA4EZrekiZxTwA42nfH0wGiGOZgIBi9bsIThqU7ejM8AYdarBPn+b2Gq9s2
# D+EsUwM+USrEORcTrTo+1HQrfrue/Jqsjj1lU3wL4ZzrQQBHA3Ygux6AVBb98kJ7
# 774yeX6PZdrb6fu6URiQ7+eE+VuDYDHGdtVWgl+8AIlWs+U9IQ==
# SIG # End signature block