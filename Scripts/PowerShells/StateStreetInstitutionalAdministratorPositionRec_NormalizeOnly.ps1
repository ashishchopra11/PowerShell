##Prod
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

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ImportCustodianStateStreetInstitutionalAdministratorPositionNormalizeDaily."+$strDateNow+".txt"

$PSScriptName 	= $MyInvocation.MyCommand.Name.ToString()
$PSScriptName 	= $PSScriptName.Replace(".ps1","")
$LogFile 		= "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
 
Write-Output " LogFile					= $LogFile" |  Out-File $LogFile -Append
Write-Output " dirSourceFolder			= $dirSourceFolder" |  Out-File $LogFile -Append
Write-Output " dirDestinationFolder		= $dirDestinationFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder			= $dirArchiveFolder" |  Out-File $LogFile -Append

###Create Archive folder 
#New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory -force 

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Creating Archive Folder ::  $dirArchiveFolder\$strDateNow " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  StateStreet Institutional Administrator Position starts here " | Out-File $LogFile -Append
##RefDatasetDate T-1 

$runDate 		= Get-Date 

if ($runDate.DayOfWeek -eq "Monday") 
{
	$runDate	= $runDate.AddDays(-3)
}
else
{
	$runDate	= $runDate.AddDays(-1)
}

$FullDayString  = $runDate.ToShortDateString()

###Run for hard coded date
##$FullDayString = "2018/03/14"
	
########################################################################
######For Bond MV - Longhorn A
########################################################################
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional  Position [RefDatasetDate]: $FullDayString" | Out-File $LogFile -Append		
#DF_Label	
$DF_RefDataSource = "StateStreet"
$DF_RefDataSetType = "Position"
$DF_Label = "Bond MV - Longhorn A"


##Find MAX RefDataset data from Datafeeds
$DF_RefDataSetDate = "1/1/1900" 

#Ref_Label
$Ref_RefDataSource = "State Street (Administrator) Supplemental"
$Ref_RefDataSetType = "Position"
$Ref_Label = "Bond MV - Longhorn A"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional AdminBondMV Position: Assigning Labels" | Out-File $LogFile -Append

Write-Output " DF_RefDataSource			= $DF_RefDataSource" |  Out-File $LogFile -Append
Write-Output " DF_RefDataSetType		= $DF_RefDataSetType" |  Out-File $LogFile -Append
Write-Output " DF_Label					= $DF_Label" |  Out-File $LogFile -Append
Write-Output " Ref_RefDataSource		= $Ref_RefDataSource" |  Out-File $LogFile -Append
Write-Output " Ref_RefDataSetType		= $Ref_RefDataSetType" |  Out-File $LogFile -Append
Write-Output " Ref_Label				= $Ref_Label" |  Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizePositionGeneric.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DF_RefDataSetDate].Value;$DF_RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
	$GenericNormalizationJobID = 4
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	## Check SSIS is success or not
	
	#For Bond MV - Longhorn B
	#$DF_Label=""
	#$DF_Label = "Bond MV - Longhorn B"
	#$Ref_Label = "Bond MV - Longhorn B"
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DF_RefDataSetDate].Value;$DF_RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
	
	$GenericNormalizationJobID = 5
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional AdminBondMV Position: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional AdminBondMV Position: file Normalized" | Out-File $LogFile -Append
	
########################################################################
######Traded Report
########################################################################
#DF_Label	
$DF_RefDataSource = "StateStreet"
$DF_RefDataSetType = "Position"
$DF_Label  = "Traded Report - Longhorn A"

#Ref_Label
$Ref_RefDataSource = "State Street (Administrator) Supplemental"
$Ref_RefDataSetType = "Position"
$Ref_Label = "Traded Report - Longhorn A"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional TradedReport Position: Assigning Labels" | Out-File $LogFile -Append

Write-Output " DF_RefDataSource			= $DF_RefDataSource" |  Out-File $LogFile -Append
Write-Output " DF_RefDataSetType		= $DF_RefDataSetType" |  Out-File $LogFile -Append
Write-Output " DF_Label					= $DF_Label" |  Out-File $LogFile -Append
Write-Output " Ref_RefDataSource		= $Ref_RefDataSource" |  Out-File $LogFile -Append
Write-Output " Ref_RefDataSetType		= $Ref_RefDataSetType" |  Out-File $LogFile -Append
Write-Output " Ref_Label				= $Ref_Label" |  Out-File $LogFile -Append

## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizePositionGeneric.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $FullDayString " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
		
	#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DF_RefDataSetDate].Value;$DF_RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
	$GenericNormalizationJobID = 6
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	
	#For Bond MV - Longhorn B
		#$DF_Label=""
		#$DF_Label = "Traded Report - Longhorn B"
		#$Ref_Label = "Traded Report - Longhorn B"
		#& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[DF_RefDataSetDate].Value;$DF_RefDataSetDate" /set "\package.variables[DF_RefDataSource].Value;$DF_RefDataSource" /set "\package.variables[DF_RefDataSetType].Value;$DF_RefDataSetType" /set "\package.variables[DF_Label].Value;$DF_Label" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile -Append
	
	$GenericNormalizationJobID = 7
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizePositionGeneric.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayString" /set "\package.variables[GenericNormalizationJobID].Value;$GenericNormalizationJobID"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional TradedReport Position: file not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") State Street Institutional TradedReport Position: file Normalized" | Out-File $LogFile -Append
  

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
