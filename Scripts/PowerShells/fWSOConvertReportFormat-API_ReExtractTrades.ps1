FUNCTION fWSOConvertReportFormat-API
{
	Param
	{
		[string]$WSO_Extracts_DIR
		,[datetime]$process_date
		,[string]$LogFile
	}
  
	$ScriptName = $MyInvocation.MyCommand.Name

	Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName :: $ScriptName START `r`n" |   Out-File $LogFile -Append

	Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append

	$PriorstrDateNow = get-date $process_date -format "yyyyMMdd"

	$OnDemandDir = "$dirServicesDeliveryStoreFolder\WSOOnDemand"

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
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-API: moving file ( $OnDemandDir\ReExtractTrades_Extract*_$PriorstrDateNow.csv ) to new file ( $dirSourceFolder ) " | Out-File $LogFile -Append
	move-Item -Path "$OnDemandDir\ReExtractTrades_Extract*_$PriorstrDateNow.csv" -destination $dirSourceFolder -force

	#CHECK EXISTENCE OF SOURCE FOLDER WHERE PRODUCTION API FILES GOT COPIED ATER CONVERTED TO ANSI FORMAT
	if (!(Test-Path -path $APIDestinationFolder)) 
	{ 
		New-Item -path $APIDestinationFolder -ItemType directory 
	}
		
	# REMOVE EXISTING CONVERTED FILES FROM CONVERT FOLDER :-	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Remove files ( $APIDestinationFolder\ReExtractTrades_Extract*_$PriorstrDateNow.csv ) " | Out-File $LogFile -Append
	Remove-Item "$APIDestinationFolder\ReExtractTrades_Extract*_$PriorstrDateNow.csv"

	#CONVERTING UTF FORMAT FILES TO ANSI FORMAT :-
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") CONVERTING UTF FORMAT FILES TO ANSI FORMAT " | Out-File $LogFile -Append
	Foreach($strFileName in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "ReExtractTrades_Extract*_$PriorstrDateNow.csv"})
	{
		 $DestinationFile = "$APIDestinationFolder\$strFileName"
		 $DestinationFile
		 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  fWSOConvertReportFormat-API: Converting file ( $strFileName ) to  $DestinationFile " | Out-File $LogFile -Append
		 $FullPath = $strFileName.FullName
		 $filecontent = get-content $FullPath
		 $filecontent | out-file $DestinationFile -encoding ascii
		 Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Remove Item ( $dirSourceFolder\$strFileName ) " | Out-File $LogFile -Append
		 Remove-Item "$dirSourceFolder\$strFileName"
	}

	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
}
