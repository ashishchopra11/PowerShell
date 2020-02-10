############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\IOFunctions.ps1
. .\DirLocations.Config.ps1
#################################################################################### 
###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\LoadRiskDataReport."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" | Out-File $LogFile -Append


    $RefDataSetDate = Get-Date -Format "yyyy/MM/dd"


    ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling RiskFundDailyPLByNav.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	### RiskFundDailyPLByNav Report
	   
    & $2016DTEXEC32 /F "$dirSSISDataTransfer\RiskFundDailyPLByNav.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	  
	    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RiskFundDailyPLByNav not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RiskFundDailyPLByNav imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling RiskPositionMarkReport.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	### Extract ImportCWTicketDetail 
	   
     & $2016DTEXEC32 /F "$dirSSISDataTransfer\RiskPositionMarkReport.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	 
	    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RiskPositionMarkReport not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RiskPositionMarkReport imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null

   
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling RiskVARDataUnderlyingReturns.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FolderName = $SourceDir `r`n  FileName = $strFileName " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	### Extract ImportCWTicketDetail 
	   
    & $2016DTEXEC32 /F "$dirSSISDataTransfer\RiskVARDataUnderlyingReturns.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	 
	    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  RiskVARDataUnderlyingReturns not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RiskVARDataUnderlyingReturns imported" | Out-File $LogFile -Append
	
   
 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append