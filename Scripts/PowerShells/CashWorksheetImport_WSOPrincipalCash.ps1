############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$logTime 			= get-date -format "yyyyMMddTHHmmss"
###Create Log file
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+$logTime+".txt"
#$logFile 				= "$dirLogFolder\CashWorkSheetImport_WSOPrincipalCash.$strDateNow.txt"
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName"+$logTime+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


## Variables
 $Date 	= Get-Date -format "yyyyMMdd"	
 $Date	= [datetime]::ParseExact($Date,”yyyyMMdd”,$null)
 
if($Date.DayOfWeek -eq "Monday")
    { 
        $RefDataSetDate = $Date.AddDays(-3).toshortdatestring()

    }
   
    else
    {
      $RefDataSetDate = $Date.AddDays(-1).toshortdatestring()

    }
$RefDataSetDate
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSO Cash Worksheet Account starts here " | Out-File $LogFile -Append

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCashWorksheetWSOPrincipalCash.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

   	& $2016DTEXEC32 /F "$dirSSISNormalizeWSO\NormalizeCashWorksheetWSOPrincipalCash.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
	
		## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")  WSO Cash Worksheet Account: file ( $strFileName ) NormalizeCashWorksheetWSOPrincipalCash.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCashWorksheetWSOPrincipalCash.dtsx `r`n "| Out-File $LogFile -Append


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
