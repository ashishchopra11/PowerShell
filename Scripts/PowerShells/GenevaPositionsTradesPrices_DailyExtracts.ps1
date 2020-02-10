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

## Log File Creation
$logTime = (Get-Date).ToString("yyyyMMddTHHmmss")
#$logFile = "$dirLogFolder\ExtractGeneva.$logTime.txt" 

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$logTime+".txt"
$PositionErrorFile = "InsertPositionErrorFile."+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

Write-Output " XMLFolderPath	= $XMLFolderPath" |  Out-File $LogFile -Append
Write-Output " logFile			= $logFile" |  Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Extract Geneva starts here " | Out-File $LogFile -Append

#$start_day = Get-Date -Date "1/05/2009"
#$end_day = Get-Date -Date "1/19/2009"
#
#while ($start_day -le $end_day) {
#$curr_day = Get-Date -Date $start_day
$curr_day = Get-Date
##$curr_day = Get-Date -Date "9/18/2015"



if ($curr_day.DayOfWeek -eq "Sunday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Sunday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
elseif ($curr_day.DayOfWeek -eq "Monday") {
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Monday so process will not run :: $curr_day " | Out-File $LogFile -Append
break ;
}
elseif ($curr_day.DayOfWeek -eq "Tuesday") {
$rpt_date_list = $curr_day.AddDays(-3), $curr_day.AddDays(-2), $curr_day.AddDays(-1)
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Today is Tuesday so Process will run for past 3 days `r`n $rpt_date_list " | Out-File $LogFile -Append
}
else {
$rpt_date_list = $curr_day.AddDays(-1)
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  The Process will run for one day :: $rpt_date_list " | Out-File $LogFile -Append
}
 




$rpt_date_list | Sort-Object | ForEach-Object -Process {
$rpt_date = [datetime]$_ 
$date_string = Get-Date -Date $rpt_date -UFormat %x
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPosition.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPosition.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success " | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append


	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaPositionPL.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	 & $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaPositionPL.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append

	
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	<##Do not add back in, has been removed for a reason
	###& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositionsCSV.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string"
	#>
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[ErrorFilePath].Value;$dirLogFolder" /set "\package.variables[ErrorFileName].Value;$PositionErrorFile" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: NormalizeGenevaPositions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPositions.dtsx `r`n "| Out-File $LogFile -Append

		############### Send Error file which generated by NormalizeGenevaPositions on OLEDB Command ############### 
		$ErrorFile = "$dirLogFolder\$PositionErrorFile"
		$ErrCount = Import-CSV $ErrorFile | Measure-Object | Select-Object -ExpandProperty count
		If ($ErrCount -gt 0)
		{
			## Send mail with and error file atttachment
			[string] $smtpServer  = "mail.hcmlp.com"; 
			[string] $sender      = "sqldatafeeds@hcmlp.com"; 
			[string] $receiver    = "All-Highland@siepe.com";
			[string] $subject     = "Highland - Geneva NormalizeGenevaPositions Error records - "+ $date_string; 

			$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
			$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
			$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 

			$smtpClient.Credentials = New-Object System.Net.NetworkCredential("Relay.Account", "R3layacct");
			$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
			$mailMsg.Attachments.Add($ErrorFile)
			$smtpClient.Send($mailMsg)
		}

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaTrades.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaTrades.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaTradesCopy.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaTradesCopy.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Copy: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva Copy: Imported" | Out-File $LogFile -Append


	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaTrade.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaTrade.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva:  NormalizeGenevaTrade.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaTrade.dtsx `r`n "| Out-File $LogFile -Append
		
		
## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaInvPrices.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaInvPrices.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: Imported" | Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaPrices.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaPrices.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: file ( $newfile ) NormalizeGenevaPrices.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaPrices.dtsx `r`n "| Out-File $LogFile -Append
		
# SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractGenevaFXTrades.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaFXTrades.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva FX trades Not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva FX Trade : Imported" | Out-File $LogFile -Append


## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeGenevaYTDPnLDifference.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaYTDPnLDifference.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile  -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Extract Geneva: file ( $newfile ) NormalizeGenevaYTDPnLDifference.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeGenevaYTDPnLDifference.dtsx `r`n "| Out-File $LogFile -Append
	
	
 Write-PubSub -Subject "DataWarehouse.GenevaData.Loaded" -Title "Data Warehouse GenevaData Load Completed for $date_string" -Description "$date_string" 
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.GenevaData.Loaded`" -Title `"Data Warehouse GenevaData Load Completed for $date_string`" -Description `"$date_string`" " | Out-File $LogFile -Append

 Write-PubSub -Subject "Reporting.Geneva.UnmappedPortfolio"
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"Reporting.Geneva.UnmappedPortfolio`"  " | Out-File $LogFile -Append
 
}
#$start_day = $start_day.AddDays(1)
#}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
