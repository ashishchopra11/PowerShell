############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\IOFunctions.ps1
. .\fSSISExitCode.ps1
####################################################################################

Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

###Create Archive folder
$strDateNow = Get-Date -format "yyyyMMddTHHmmss"
#$logFile    = "$dirLogFolder\WSOMarksResponse"+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append


$dirDataFeedsFolder  	= "$dirServicesDeliveryStoreFolder\MarkIt\Marks"
$dirArchiveFolder 		= "$dirArchiveHCM46DriveFolder\WSOMarksResponse\Archive"
New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory


#Writing variables to Log File.
Write-Output " dirDataFeedsFolder			= $dirDataFeedsFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder 			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " logFile						= $logFile" |  Out-File $LogFile -Append

Start-Sleep -s 60

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSO Marks Response starts here " | Out-File $LogFile -Append

foreach ($strFileName in Get-ChildItem	 -Path $dirDataFeedsFolder | Where-Object {$_.Name -ilike "*.txt"})
{
   Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  WSO Marks Response : file ( $strFileName ) processing " | Out-File $LogFile -Append
  	
	$strFileNameStr  = $strFileName.Name
	$startindex = $strFileNameStr.indexof(".MarkImport")
	$endindex 	= $strFileNameStr.indexof(".xml")
	$DatePartStr 	= $strFileNameStr.substring($startindex+1,$endindex-$startindex-1).Replace("MarkImport","")
	$dtDataSetDate = ([datetime]::ParseExact($DatePartStr,"yyyyMMddHHmmss",$null)).toshortdatestring() 
	#$dtDataSetDate = "2018/02/25"
	
	[string]$MarksUpdated = ""
	[string]$MarksNotUpdatedSecurityIssues = ""
	[string]$MarksNotupdatedMissingMarks = ""
	[string]$MarksNotupdatedExceptions = ""
	[string]$Label = ""
	
	$content = get-content $strFileName.FullName 
	
	[string]$S1 = $content | Select-string   -Pattern "Marks Updated" | Select-Object -first 1		
	[string]$S2 = $content | Select-string   -Pattern "Exceptions" | Select-Object -first 1		
	[string]$S3 = $content | Select-string   -Pattern "Missing Marks" | Select-Object -first 1		
	[string]$S4 = $content | Select-string   -Pattern "Security Issues" | Select-Object -first 1		
		
	$MarksUpdated = $($S1.Replace("/>","").Split("=")[2]).Replace('"',"").Trim()	
	$MarksNotupdatedExceptions = $($S2.Replace("/>","").Split("=")[2]).Replace('"',"").Trim()	
	
	$MarksNotupdatedMissingMarks = $($S3.Replace("/>","").Split("=")[2]).Replace('"',"").Trim()	
	$MarksNotUpdatedSecurityIssues = $($S4.Replace("/>","").Split("=")[2]).Replace('"',"").Trim()	
	
	[datetime]$Date1 = Get-Date
	$FileModifiedDate  = Get-Date (Get-Item "$dirDataFeedsFolder\$strFileName").LastWriteTime 
	$FileModifiedHour = $FileModifiedDate.get_Hour()
	
	##Label	
	if($FileModifiedHour -ge 21 )
	{
		$Label = "Marks Response Evening"
	}
	else
	{
		$Label = "Marks Response Morning"
	}
	
	<###Label	
	if($Date1.Hour -ge 21 )
	{
		$Label = "Marks Response Evening"
	}
	else
	{
		$Label = "Marks Response Morning"
	}#>
	
		
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ExtractWSOWebMarksResponse.dtsx `r`n Variable passed here are : `r`n  FileName = $strFileName `r`n  FolderName = $dirDataFeedsFolder `r`n  RefDataSetDate = $dtDataSetDate " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	
   	& $2016DTEXEC32 /F "$dirSSISExtractWSO\ExtractWSOWebMarksResponse.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirDataFeedsFolder" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[Label].Value;$Label" /set "\package.variables[MarksUpdated].Value;$MarksUpdated"/set "\package.variables[MarksNotupdatedExceptions].Value;$MarksNotupdatedExceptions"/set "\package.variables[MarksNotupdatedMissingMarks].Value;$MarksNotupdatedMissingMarks"/set "\package.variables[MarksNotUpdatedSecurityIssues].Value;$MarksNotUpdatedSecurityIssues" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	<#
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage =  fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSO Ratings Response: file ( $strFileName ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	#>
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") WSO Ratings Response: file ( $strFileName ) imported" | Out-File $LogFile -Append
	
	
	#Move-Directory -sourcePath $($dirDataFeedsFolder+"\") -destinationPath $($dirArchiveFolder+"\"+$strDateNow+"\") -dirName $strFileName
    Move-Item -Path $dirDataFeedsFolder\$strFileName $dirArchiveFolder\$strDateNow
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $strFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append

	
	
}

<#Write-PubSub -Subject "DataIntegrity.WSO.Response" -Title "DataIntegrity.WSO.Response" -Description "DataIntegrity.WSO.Response"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Publish Pub Sub to run Integrity Report RS ID --> 2479 " | Out-File $LogFile -Append
#>

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append