CLS
############################# Configuration ############################# 
$ConfigRootFOlder = $env:Powershell_ConfigRootLocation
Set-Location $ConfigRootFOlder
. .\fSSISExitCode.ps1
. .\DirLocations.Config.ps1
. .\DTExec.Config.ps1
#Set-Location "C:\HCM\Scripts"
#. .\Config.ps1

 $RootDir		 = "D:\Siepe\Data"
 $LogDir		 = "$RootDir\Logs"
 $yymmddDate	 = Get-Date -Format "yyyyMMddThhmmss"
 #$logFile 		= $LogDir+"\WSOFlash"+$yymmddDate+".txt"
 
 $PSScriptName = $MyInvocation.MyCommand.Name.ToString()
 $PSScriptName = $PSScriptName.Replace(".ps1","")
 $logFile 	   = "$LogDir\$PSScriptName."+$yymmddDate+".txt"

###Create Log folder, if needed
if(!(Test-Path -Path $LogDir )){
    New-Item -ItemType directory -Path $LogDir
}
 
$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: $ScriptName START `r`n" |   Out-File $LogFile -Append
 
############################# Validate Argument ############################# 
## Default to 01/01/1900
#[Datetime]$ArgDate = "07/13/2017"

if ($args[0] -ne $null)
{
    [String]$ArgValue = $args[0]
    
 	Try
	{
    	[Datetime]$ArgDate  = $ArgValue
	}
	catch
	{
        [string]$ArgDate_Invalid = $ArgValue
		Write-Output "Invalid RefDataSetDate passed for PowerShell argument. Value :: $ArgDate_Invalid "   | Out-File $LogFile -Append
		Exit
	}
}    
"Argument Passed :: Date :: $ArgDate" |   Out-File $LogFile -Append
##############################################################################
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Add PowerShell PubSub SnapIn HCMLP.Data.PowerShell.PubSubSnapIn`r`n" |  Out-File $LogFile -Append
Add-PSSnapin Siepe.Tools.PowerShell.PubSubSnapIn

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

#$WSOOnDemand_dir 	= "\\services.hcmlp.com\DeliveryStore\WSOOnDemand"
$WSOOnDemand_dir 	= "$dirServicesDeliveryStoreFolder\WSOOnDemand"
$WSOReports_dir 	= "C:\Temp\WSOReports"
$working_dir 		= "C:\Temp\WSOReports\Flash"
$archive_dir 		= "C:\ReExtractFlash"
#$SSIS_Extract_Dir   = "C:\HCM\SSIS2012.Datawarehouse\ExtractWSO\bin"
#$SSIS_Normalize_Dir = "C:\HCM\SSIS2012.Datawarehouse\NormalizeWSO\bin"
$SSIS_Extract_Dir = "$dirSSISExtractWSO\High"
$SSIS_Normalize_Dir = $dirSSISNormalizeWSO

##[datetime]$curr_day = Get-Date
if($ArgDate -ne "2017/07/13" -and $ArgDate -ne $null)
{
    [datetime]$FullDayStringEnd = $ArgDate
}
else
{
	$OnDemand_day = Get-Date
	$now_day = $OnDemand_day
	$curr_day = (Get-Date -Year ($now_day.Year) -Month ($now_day.Month) -Day ($now_day.Day) 23:59)
	$extract_end_day = $curr_day.AddDays(-1)
	#$extract_start_day = (Get-Date -Year ($extract_end_day.Year) -Month ($extract_end_day.Month) -Day 1 00:00)
	$FullDayString       = $now_day.date.ToString("MM/dd/yyyy")
	$FullDayStringStart = $extract_start_day.ToShortDateString()
    [datetime]$FullDayStringEnd = $extract_end_day.ToShortDateString()
}
    ## Re-extract files ...
    $FullDayStringEnd 
    $OnDemandDayString  = $FullDayStringEnd.Year.ToString() + $FullDayStringEnd.Month.ToString().PadLeft(2, "0") + $FullDayStringEnd.Day.ToString().PadLeft(2, "0")
    $ArchiveDirDayString  = $FullDayStringEnd.Year.ToString() + $FullDayStringEnd.Month.ToString().PadLeft(2, "0") + $FullDayStringEnd.Day.ToString().PadLeft(2, "0")

### Set File Names
$WSOOnDemandFileNamePosition = "Flash_ExtractPosition_"+$OnDemandDayString+".CSV"
$WSOOnDemandFileNamePerform  = "Flash_ExtractPerformance_"+$OnDemandDayString+".CSV"
$WSOOnDemandFileNameReal     = "Flash_ExtractRealUnReal_"+$OnDemandDayString+".CSV"
$WSOOnDemandFileNameSettle   = "Flash_ExtractSettleUnsettleComplete_"+$OnDemandDayString+".CSV"
$WSOOnDemandFileNameMap      = "Flash_ExtractPositionMap_"+$OnDemandDayString+".CSV"
$WSOOnDemandFileNameClosing  = "Flash_ExtractPositionCloseDate_"+$OnDemandDayString+".CSV"



$WSOFileNamePosition = "Flash_ExtractPosition_"+$ArchiveDirDayString+".CSV"
$WSOFileNamePerform  = "Flash_ExtractPerformance_"+$ArchiveDirDayString+".CSV"
$WSOFileNameReal     = "Flash_ExtractRealUnReal_"+$ArchiveDirDayString+".CSV"
$WSOFileNameSettle   = "Flash_ExtractSettleUnsettleComplete_"+$ArchiveDirDayString+".CSV"
$WSOFileNameMap      = "Flash_ExtractPositionMap_"+$ArchiveDirDayString+".CSV"
$WSOFileNameClosing  = "Flash_ExtractPositionCloseDate_"+$ArchiveDirDayString+".CSV"


Write-Output " SSIS_Extract_Dir							= $SSIS_Extract_Dir" |  Out-File $LogFile -Append
Write-Output " SSIS_Normalize_Dir						= $SSIS_Normalize_Dir" |  Out-File $LogFile -Append
Write-Output " WSOReports_dir							= $WSOReports_dir" |  Out-File $LogFile -Append
Write-Output " working_dir								= $working_dir" |  Out-File $LogFile -Append
Write-Output " WSOOnDemand_dir							= $WSOOnDemand_dir" |  Out-File $LogFile -Append
Write-Output " FullDayStringStart						= $FullDayStringStart" |  Out-File $LogFile -Append
Write-Output " FullDayStringEnd							= $FullDayStringEnd" |  Out-File $LogFile -Append
Write-Output " OnDemandDayString						= $OnDemandDayString" |  Out-File $LogFile -Append
Write-Output " ArchiveDirDayString						= $ArchiveDirDayString" |  Out-File $LogFile -Append
Write-Output " archive_dir								= $archive_dir" |  Out-File $LogFile -Append
Write-Output " logFile									= $logFile `r`n " |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNamePosition				= $WSOOnDemandFileNamePosition" |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNamePerform				= $WSOOnDemandFileNamePerform" |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNameReal					= $WSOOnDemandFileNameReal" |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNameSettle				= $WSOOnDemandFileNameSettle" |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNameMap					= $WSOOnDemandFileNameMap" |  Out-File $LogFile -Append
Write-Output " WSOOnDemandFileNameClosing				= $WSOOnDemandFileNameClosing" |  Out-File $LogFile -Append
Write-Output " WSOFileNamePosition						= $WSOFileNamePosition" |  Out-File $LogFile -Append
Write-Output " WSOFileNamePerform						= $WSOFileNamePerform" |  Out-File $LogFile -Append
Write-Output " WSOFileNameReal							= $WSOFileNameReal" |  Out-File $LogFile -Append
Write-Output " WSOFileNameSettle						= $WSOFileNameSettle" |  Out-File $LogFile -Append
Write-Output " WSOFileNameMap							= $WSOFileNameMap" |  Out-File $LogFile -Append
Write-Output " WSOFileNameClosing						= $WSOFileNameClosing" |  Out-File $LogFile -Append

Set-Location $WSOReports_dir
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $WSOReports_dir `r`n" | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNamePosition $working_dir\$WSOFileNamePosition
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNamePosition ) to location ( $working_dir\$WSOFileNamePosition ) " | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNamePerform $working_dir\$WSOFileNamePerform
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNamePerform ) to location ( $working_dir\$WSOFileNamePerform ) " | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNameReal $working_dir\$WSOFileNameReal
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNameReal ) to location ( $working_dir\$WSOFileNameReal ) " | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNameSettle $working_dir\$WSOFileNameSettle
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNameSettle ) to location ( $working_dir\$WSOFileNameSettle ) " | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNameMap $working_dir\$WSOFileNameMap
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNameMap ) to location ( $working_dir\$WSOFileNameMap ) " | Out-File $LogFile -Append

Move-Item -Force $WSOOnDemand_dir\$WSOOnDemandFileNameClosing $working_dir\$WSOFileNameClosing
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $WSOOnDemand_dir\$WSOOnDemandFileNameClosing ) to location ( $working_dir\$WSOFileNameClosing ) " | Out-File $LogFile -Append

Set-Location $WSOReports_dir
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Set Current Location :: $WSOReports_dir `r`n" | Out-File $LogFile -Append

    New-Item -Force -type directory $archive_dir\$ArchiveDirDayString
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  Creating new Item :: $archive_dir\$ArchiveDirDayString `r`n" | Out-File $LogFile -Append
	
	Move-Item -Force $working_dir\*$ArchiveDirDayString.CSV $archive_dir\$ArchiveDirDayString
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") moved file ( $working_dir\*$ArchiveDirDayString.CSV ) to location ( $archive_dir\$ArchiveDirDayString ) " | Out-File $LogFile -Append
    
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") ::  WSO Flash starts here " | Out-File $LogFile -Append

 
 ## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractPosition.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n   Label = PositionFlash `r`n SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNamePosition " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPosition.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNamePosition" /set "\package.variables[Label].Value;PositionFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append
  & $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPosition.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNamePosition" /set "\package.variables[Label].Value;PositionFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $LogFile -Append	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNamePosition ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNamePosition ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractRealUnreal.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n   Label = RealUnrealFlash `r`n SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNameReal " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractRealUnreal.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNameReal" /set "\package.variables[Label].Value;RealUnrealFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  	& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractRealUnreal.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNameReal" /set "\package.variables[Label].Value;RealUnrealFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append


	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameReal ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameReal ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractPerformance.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n   Label = PerformanceFlash `r`n SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNamePerform " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPerformance.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNamePerform" /set "\package.variables[Label].Value;PerformanceFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  	
		 & $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPerformance.dtsx" 			/set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set  "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNamePerform" /set "\package.variables[PowerShellLocation].Value;$ScriptName"  /set "\package.variables[Label].Value;PerformanceFlash" | Out-File $LogFile -Append #/set "\package.variables[Label].Value;""Performance_API"""

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNamePerform ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNamePerform ) imported" | Out-File $LogFile -Append
	
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractPositionMap.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n  SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNameMap " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPositionMap.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNameMap" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
	# /set "\package.variables[Label].Value;PositionMapFlash" 
	
	& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPositionMap.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNameMap" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  	
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameMap ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameMap ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractPositionCloseDate.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n  SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNameClosing " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPositionCloseDate.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNameClosing" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  & $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractPositionCloseDate.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNameClosing" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
  
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameClosing ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameClosing ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling ExtractSettleUnsettle.dtsx `r`n Variable passed here are : `r`n  DataSetDate = $FullDayStringEnd `r`n  SourceConnectionFlatFile[ConnectionString] = $archive_dir\$ArchiveDirDayString\$WSOFileNameSettle `r`n   Label = SettleUnsettleFlash" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
	#& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractSettleUnsettle.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\Package.Connections[SourceConnectionFlatFile].Properties[ConnectionString];$archive_dir\$ArchiveDirDayString\$WSOFileNameSettle" /set "\package.variables[Label].Value;SettleUnsettleFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append
& $2016DTEXEC32 /f "$SSIS_Extract_Dir\ExtractSettleUnsettle.dtsx" /set "\package.variables[DataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FolderName].Value;$archive_dir\$ArchiveDirDayString" /set "\package.variables[FileName].Value;$WSOFileNameSettle" /set "\package.variables[Label].Value;SettleUnsettleFlash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameSettle ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: file ( $WSOFileNameSettle ) imported" | Out-File $LogFile -Append
	
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Calling NormalizeWSOPositions.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $RefDataSetDate `r`n  FlashFlag = Flash " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: SSIS Log" | Out-File $LogFile -Append
	
    ## Normalize positions
  	& $2016DTEXEC32 /f "$SSIS_Normalize_Dir\NormalizeWSOPositions.dtsx" /set "\package.variables[RefDataSetDate].Value;$FullDayStringEnd" /set "\package.variables[FlashFlag].Value;Flash" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") WSO Flash: NormalizeWSOPositions.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Completed NormalizeWSOPositions.dtsx `r`n "| Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Starting Sleep for 15 sec `r`n "| Out-File $LogFile -Append
Start-Sleep -s 15
	
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append
	
# # Run dbo.pCalculateFundPLValues ...
#  $dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=HCM;Database=HCM;Integrated Security=SSPI;"
#  $dbconn.Open()
#  $dbCmd = $dbConn.CreateCommand()
#  $dbCmd.CommandTimeout = 0
#
#Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing PROCEDURE :: EXEC dbo.pCalculateFundPLValues " | Out-File $LogFile -Append
#  # CalculateFundPLValues
#  $dbCmd.CommandText = "EXEC dbo.pCalculateFundPLValues"
#  $dbCmd.ExecuteScalar() 
#  $dbCmd.Dispose()
#  $dbConn.Close()
#  $dbConn.Dispose()
#
#  Remove-Variable dbCmd
#  Remove-Variable dbConn

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Starting Sleep for 15 sec `r`n "| Out-File $LogFile -Append
Start-Sleep -s 15

###--##################Write-PubSub -Subject "DataWarehouse.WSOFlash.Loaded" -Title "Data Warehouse WSO Flash Load Completed for $FullDayStringEnd" -Description "$FullDayStringEnd"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") Published PubSub :: Write-PubSub -Subject `"DataWarehouse.WSOFlash.Loaded`" -Title `"Data Warehouse WSO Flash Load Completed for $FullDayStringEnd`" " | Out-File $LogFile -Append
#>
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") $ScriptName END " | Out-File $LogFile -Append
