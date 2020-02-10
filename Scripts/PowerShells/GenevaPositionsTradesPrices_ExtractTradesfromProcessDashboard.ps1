############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
. .\IOFunctions.ps1

####################################################################################
Add-Type -AssemblyName "Microsoft.SqlServer.ManagedDTS, Version=13.0.0.0, Culture=Neutral, PublicKeyToken=89845dcd8080cc91" 
$ssisApplication = New-Object "Microsoft.SqlServer.Dts.Runtime.Application" 

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Log file
$strDateNow = get-date -format "yyyyMMddTHHmmss"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName."+$strDateNow+".txt"
#$logFile = "$dirLogFolder\GenevaTradeAdHoc.$strDateNow.txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"



#$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"
#$XMLFolderPath="\\hcmlp.com\data\public\IT\DataFeeds\Geneva"
$XMLFolderPath="$dirArchiveHCM46DriveFolder\Geneva"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
Write-Output " XMLFolderPath		= $XMLFolderPath" | Out-File $LogFile -Append
Write-Output " strDateNow			= $strDateNow" | Out-File $LogFile -Append
Write-Output " LogFile				= $LogFile `r`n" | Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn `r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject : Geneva.Trades.Reload.Started, Title : Geneva Trades Reload has been started" |  Out-File $LogFile -Append
 Write-PubSub -Subject "Geneva.Trades.Reload.Started" -Title "Geneva Trades Reload has been started"

$curr_day = Get-Date 

if ($curr_day.DayOfWeek -eq "Sunday") {
	$curr_day = $curr_day.AddDays(-2)
}
elseif ($curr_day.DayOfWeek -eq "Monday") {
	$curr_day = $curr_day.AddDays(-3)
}
else {
	$curr_day = $curr_day.AddDays(-1)
}

$date_string = Get-Date -Date $curr_day -UFormat %x


## SSIS Status Variables
[Int]$lastexitcode = $null
[String]$SSISErrorMessage = $null

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractGenevaTrades.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string `r`n  XMLFolderPath = $XMLFolderPath " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
# & $2012DTEXEC32 /f "$dirSSISExtractGeneva\ExtractGenevaTrades.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" /set "\package.variables[XMLFolderPath].Value;$XMLFolderPath"  | Out-File $logFile -Append
   
   $SSIS_PackagePath = "$dirSSISExtractGeneva\ExtractGenevaTrades.dtsx"
   $SSIS_Package = $ssisApplication.LoadPackage($SSIS_PackagePath,$null) 
   $SSIS_Package.Variables["User::RefDataSetDate"].Value = $date_string 
   $SSIS_Package.Variables["User::XMLFolderPath"].Value = $XMLFolderPath
   $SSIS_Package.Variables["User::PowerShellLocation"].Value = $ScriptName
   $SSIS_Package.Execute() 
   $SSIS_Error = $SSIS_Package.Errors
   $SSIS_Execution_Result= $SSIS_Package.ExecutionResult
   Write-Output $SSIS_Error | Out-File $logFile -Append
   
   ## Check SSIS is success or not
   if($SSIS_Execution_Result -ne "Success"){
		Write-Output "Fail" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Extract Geneva Trades not success" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSIS_Error " | Out-File $LogFile -Append
		Write-PubSub -Subject "Geneva.Trades.Reload.Failed" -Title "Geneva Trades have been failed"
		Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Extract Geneva Trades imported" | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeGenevaTrade.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $date_string " | Out-File $LogFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
#& $2012DTEXEC32 /f "$dirSSISNormalizeGeneva\NormalizeGenevaTrade.dtsx" /set "\package.variables[RefDataSetDate].Value;$date_string" 

   $SSIS_PackagePath = "$dirSSISNormalizeGeneva\NormalizeGenevaTrade.dtsx"
   $SSIS_Package = $ssisApplication.LoadPackage($SSIS_PackagePath,$null) 
   $SSIS_Package.Variables["User::RefDataSetDate"].Value = $date_string 
   $SSIS_Package.Variables["User::PowerShellLocation"].Value = $ScriptName
   $SSIS_Package.Execute()
   $SSIS_Error = $SSIS_Package.Errors
   $SSIS_Execution_Result= $SSIS_Package.ExecutionResult
   Write-Output $SSIS_Error | Out-File $logFile -Append
   
   ## Check SSIS is success or not
   if($SSIS_Execution_Result -ne "Success"){
		Write-Output "Fail" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Normalize Geneva Trades not success" | Out-File $LogFile -Append
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSIS_Error " | Out-File $LogFile -Append
		Write-PubSub -Subject "Geneva.Trades.Reload.Failed" -Title "Geneva Trades have been failed"
		Exit
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Geneva Trades Normalized Successfully" | Out-File $LogFile -Append
	
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: PubSub :: Subject : Geneva.Trades.Reload.Complete, Title : Geneva Trades have been reloaded" |  Out-File $LogFile -Append
 Write-PubSub -Subject "Geneva.Trades.Reload.Complete" -Title "Geneva Trades have been reloaded"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append


