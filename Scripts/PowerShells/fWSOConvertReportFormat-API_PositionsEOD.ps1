FUNCTION fWSOConvertReportFormat-APIPositionEOD
{
	Param
	{
		[string]$WSO_Extracts_DIR
		,[datetime]$process_date
		,[string]$LogFile
	}
  ## 10/12/2007
  
	#$ScriptName = $MyInvocation.MyCommand.Name
	#$ScriptName = "fWSOConvertReportFormat-API"
	#$ScriptName = $MyInvocation.MyCommand.Name
	IF ($ScriptName -eq $null)
	{
	$ScriptName = $MyInvocation.MyCommand.Name
	}
	ELSE 
	{$ScriptName = $ScriptName}
$ScriptName 
	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName :: $ScriptName START `r`n" |   Out-File $LogFile -Append

	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

	#$strDateNow = get-date -format "yyyyMMdd"
	#$PriorstrDateNow = (Get-date).ADDDAYS(-1).ToString("yyyyMMdd")
	$PriorstrDateNow = get-date $process_date -format "yyyyMMdd"
	
	#$dirAPIfolder = "$dirAPIfolder\Archive"
	$OnDemandDir = "\\services.hcmlp.com\deliverystore\WSOOnDemand"
	#$OnDemandDir = "$dirServicesDeliveryStoreFolder\WSOOnDemand"

	#$strDateNow = "20151102"
	#$PriorstrDateNow = $strDateNow - 1
	$dirSourceFolder = "$WSO_Extracts_DIR\$PriorstrDateNow\API"
	$APIDestinationFolder = "$dirSourceFolder\Converted"	

	Write-Output " PriorstrDateNow			= $PriorstrDateNow" |  Out-File $LogFile -Append
	Write-Output " OnDemandDir				= $OnDemandDir" |  Out-File $LogFile -Append
	Write-Output " dirSourceFolder			= $dirSourceFolder" |  Out-File $LogFile -Append
	Write-Output " APIDestinationFolder		= $APIDestinationFolder" |  Out-File $LogFile -Append

	# CHECK EXISTENCE OF SOURCE FOLDER WHERE PRODUCTION API FILES GOT COPIED AND COPY FILES THERE
	if (!(Test-Path -path $dirSourceFolder)) 
	    { 
		    New-Item -path $dirSourceFolder -ItemType directory 
	    }


	#MOVE FILES FROM ONDEMAND TO WSOREPORTS
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-API: moving file ( $OnDemandDir\EOD*_$PriorstrDateNow.csv ) to new file ( $dirSourceFolder ) " | Out-File $LogFile -Append
	move-Item -Path "$OnDemandDir\EOD*_$PriorstrDateNow.csv" -destination $dirSourceFolder

	#CHECK EXISTENCE OF SOURCE FOLDER WHERE PRODUCTION API FILES GOT COPIED ATER CONVERTED TO ANSI FORMAT
	if (!(Test-Path -path $APIDestinationFolder)) 
	{ 
		New-Item -path $APIDestinationFolder -ItemType directory 
	}
		
	# REMOVE EXISTING CONVERTED FILES FROM CONVERT FOLDER :-	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Remove files ( $APIDestinationFolder\EOD*_$PriorstrDateNow.csv ) " | Out-File $LogFile -Append
	Remove-Item "$APIDestinationFolder\EOD*_$PriorstrDateNow.csv"

	#CONVERTING UTF FORMAT FILES TO ANSI FORMAT :-
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") CONVERTING UTF FORMAT FILES TO ANSI FORMAT " | Out-File $LogFile -Append
	Foreach($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "EOD*_$PriorstrDateNow.csv"})
	{
		 $DestinationFile = "$APIDestinationFolder\$strFileName"
		 $DestinationFile
		 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-APIPositionsEOD: Converting file ( $strFileName ) to  $DestinationFile " | Out-File $LogFile -Append
		 $FullPath = $strFileName.FullName
		 $filecontent = get-content $FullPath
		 $filecontent | out-file $DestinationFile -encoding ascii
		 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Remove Item ( $dirSourceFolder\$strFileName ) " | Out-File $LogFile -Append
		 Remove-Item "$dirSourceFolder\$strFileName"
	}
<#
	#RENAMING THE API FILE NAMES :-
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") RENAMING THE API FILE NAMES " | Out-File $LogFile -Append
	Foreach($strFileName in Get-ChildItem -Path $APIDestinationFolder | Where-Object {$_.Name -ilike "Daily_Extract*_$PriorstrDateNow.csv"})
	{ 
		IF($strFileName -match "PriorDate_.*")
		{
			$strFileName1 = $strFileName.ToString()
			$pos = $strFileName1.IndexOf("PriorDate")
			$leftPart = $strFileName1.Substring(0, $pos)+".csv"
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-API: renaming file ( $APIDestinationFolder\$strFileName1 ) to new file ( $APIDestinationFolder\$leftPart ) " | Out-File $LogFile -Append
			Rename-Item $APIDestinationFolder\$strFileName1 $APIDestinationFolder\$leftPart -Force
		} 
		ELSE
		{
			$strFileName1 = $strFileName.ToString()
			$pos = $strFileName1.IndexOf("_")
			$leftPart = $strFileName1.Substring(0, $pos)+".csv"
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-API: renaming file ( $APIDestinationFolder\$strFileName1 ) to new file ( $APIDestinationFolder\$leftPart ) " | Out-File $LogFile -Append
			Rename-Item $APIDestinationFolder\$strFileName1 $APIDestinationFolder\$leftPart -Force
		}
	}
#>    
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
