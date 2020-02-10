############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\ConnectionStrings.config.ps1
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
. .\fSSISExitCode.ps1
#################################################################################### 

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "D:\Siepe\Data\Logs\ImportCustodianJPMFutureDailyStatement"+$strDateNow+".txt" ##Log file path
#$logFile = "$dirLogFolder\ImportCustodianUniversalBondMarks"+$strDateNow+".txt" ##Log file path

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Variable Initialization `r`n" |  Out-File $LogFile -Append
 
$dirPDFSourceFolder = "$dirServicesDeliveryStoreFolder\Universal Price Import" ## Source File location

#$dirArchiveFolder = "$dirPDFSourceFolder\Archive\Bonds"
$dirArchiveFolder = "$dirDataFeedsArchiveFolder\Universal Price Import\Archive"

$dirSourceFolder = "$dirPDFSourceFolder\Converted"

Write-Output " dirPDFSourceFolder		= $dirPDFSourceFolder" |  Out-File $LogFile -Append
Write-Output " dirArchiveFolder			= $dirArchiveFolder" |  Out-File $LogFile -Append
Write-Output " dirSourceFolder			= $dirSourceFolder" |  Out-File $LogFile -Append
Write-Output " logFile					= $logFile" |  Out-File $LogFile -Append

Remove-Item -path "$dirSourceFolder\*.txt"  -Force | Out-File $logFile -Append
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Removing files from $dirSourceFolder\*.txt " | Out-File $LogFile -Append

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Universal Bond Marks starts here " | Out-File $LogFile -Append

##Convert PDF file to Text
& D:\Siepe\Tools\PDFParser\PDFParser.exe $dirPDFSourceFolder "txt" ##PDF Converter exec location

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Converting .pdf File to .txt " | Out-File $LogFile -Append

$strFileName  = $Null

foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "*BESTAND*.txt"})
{   
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Universal Bond Marks: file ( $strFileName ) processing " | Out-File $LogFile -Append
 
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Creating Archive Folder : $dirArchiveFolder\$strDateNow " | Out-File $LogFile -Append
	if (!(Test-Path -path $dirArchiveFolder\$strDateNow)) 
    { 
        New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory 
    }
	
    $File = $strFileName.FullName
    $FileName = $strFileName.BaseName
   	
	$strPDFFileName = $strFileName.BaseName+".pdf"
	
   	##Bonds
    $StartPatteran1			= "Securities - Bonds"
 	$EndPatteran		   	= "Total*Asset Backed Securities"
	$EndPatteran1		   	= "PDU_BEST_LIST"
	$PatternCounterCount	= 0
	$PatternCounterCountT	= 0
	
	##Transactions
	$StartPatteranT		= "Transactions Securities since"
 	$EndPatteranT		= "Legend"
	$EndPatteran1T		= "PDU_BEST_LIST"
	
    $content = get-content $File    #| where {($_ -ne "") -and ($_ -notMatch "^\s*#")}
    
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsing the file to fetch the values :  $File " | Out-File $LogFile -Append
	$A = $content | Select-String -Pattern $StartPatteran1
 	$B = $content | Select-String -Pattern $StartPatteranT
	
	
	##Getting NAV and (Sum USD vs.EUR)
	$NAVPatteranT		=	"Net Asset Value"
	$FXForwards			=	"Sum USD vs.EUR"
	$UnrealGL			=	"Unreal. G&L in EUR"
	
	$NAVRow = $content | Select-String -Pattern $NAVPatteranT
	[System.Array]$FXRow = $content | Select-String -Pattern $FXForwards
	$NAV=$NAVRow[2].ToString()
	for($i=94;$i -gt 0;$i--)
	{
		if($NAV[$i] -eq ' ')
			{break}
	}
	$FinalNAV=$NAV.Substring($i+1,(94-$i))
	#$FinalNAV
	
	$FX=$FXRow[0].ToString()
	for($i=131;$i -gt 0;$i--)
	{
		if($FX[$i] -eq ' ')
			{break}
	}
	$FinalFX=$FX.Substring($i+1,(131-$i))
	#$FinalFX
	
	for($i=220;$i -gt 0;$i--)
	{
		if($FX[$i] -eq ' ')
			{break}
	}
	$FinalFUnrealGL=$FX.Substring($i+1,(220-$i))
	#$FinalFUnrealGL
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed values are `r`n  Net Asset Value = $FinalNAV `r`n  Sum USD vs.EUR = $FinalFX `r`n  Unreal. G&L in EUR = $FinalFUnrealGL " | Out-File $LogFile -Append
#	$StartFrom=$FX.LastIndexOf($FXForwards)
#	$StartFrom
#	$FinalFX=$FX.Substring($StartFrom+14,(133-$StartFrom))
#	$FinalFX=$FinalFX.Trim()
#	$FinalFX
	
	if (Test-Path -path "$dirSourceFolder\NAV_$FileName.txt")  
		{
		Remove-Item -path "$dirSourceFolder\NAV_"+$FileName+".txt" -Force | Out-File $logFile -Append
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Removing the file $dirSourceFolder\NAV_$FileName.txt if already Exists  " | Out-File $LogFile -Append
	
	$outfileNAV	= "$dirSourceFolder\NAV_"+$FileName+".txt";
	$NAVPatteranT + "|" +  $FinalNAV | Out-File -encoding ASCII -append -filePath $outfileNAV
	$FXForwards + "|" +  $FinalFX | Out-File -encoding ASCII -append -filePath $outfileNAV
	$UnrealGL + "|" +  $FinalFUnrealGL | Out-File -encoding ASCII -append -filePath $outfileNAV
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  All the parsed values are stored in a file :: $outfileNAV " | Out-File $LogFile -Append
	
	$outfileNAV1="NAV_"+$FileName+".txt"
    [array]$fnlines= $A | ForEach-object {new-object psobject -property @{ lineNo =($_.lineNumber)}} | sort-object -property lineNo 
    [array]$fnlinesT= $B | ForEach-object {new-object psobject -property @{ lineNo =($_.lineNumber)}} | sort-object -property lineNo
	$fnlines.Length
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Parsing the txt file to get the content for Bonds " | Out-File $LogFile -Append
	#Bonds
    while ($PatternCounterCount -lt $fnlines.Length) 
	{
		$StartIndex	 = 0
		$EndIndex	 = 0
		$StartIndex	 =$fnlines[$PatternCounterCount]
        $StartIndexNo1 = $StartIndex.lineNo
		$StartIndexNo = $StartIndexNo1 + 8
        $LineIndex = $StartIndexNo
		
		
		While ($LineIndex -ge $StartIndexNo)
		{
			$Str = $content[$LineIndex-1]
			
			if ($Str -ne $null -and ($Str -like "*"+$EndPatteran+"*" -or $Str -like "*"+$EndPatteran1+"*" ))
			{
				if ($Str -like "*"+$EndPatteran1+"*")
				{
					$EndIndex = $LineIndex-2
				}
				else 
				{
					$EndIndex = $LineIndex-1
				}
				break;
			}
			
         	$LineIndex++;
	     	
		}
       
        $LineIndex = $StartIndexNo
		
		if (!(Test-Path -path "$dirSourceFolder\Bonds_$FileName.txt"))  
		{
			$outfile	= "$dirSourceFolder\Bonds_"+$FileName+".txt";
		}
        
		While ($LineIndex -ge $StartIndexNo -and $LineIndex -le ($EndIndex-1))
		{	
			
			$Str = $content[$LineIndex-1]
			$AddSpace = 0
			 
            $AddSpace = (217 - $Str.Length) ##Fixed in SSIS(217)
			if ($AddSpace -ge 1)
			{
				$Str =  $Str + " " * $AddSpace
			}
			
			if ($Str.Trim() -eq "")
			{
				$Str =  $null
			}
			
			if (!(Test-Path -path $outfile )) 
			{ 
			   
				##New-Object -TypeName System.IO.FileInfo($outfile);
				New-Item -path $outfile -ItemType file
			}
			
			$Str | Out-File -encoding ASCII -append -filePath $outfile
			
 		    $LineIndex++;
	     
	   }
	$PatternCounterCount++;
    #$KeepLastEndIndex = $EndIndex
}		
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: All the parsed content for Bond file has been stored in file :: $outfile " | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Parsing the txt file to get the content for Transaction " | Out-File $LogFile -Append
	#Transaction
	$fnlinesT.Length
    while ($PatternCounterCountT -lt $fnlinesT.Length) 
	{
		$StartIndex	 = 0
		$EndIndex	 = 0
		$StartIndex	 =$fnlinesT[$PatternCounterCountT]
        $StartIndexNo1 = $StartIndex.lineNo
		$StartIndexNo = $StartIndexNo1 + 8
        $LineIndex = $StartIndexNo
		
		
		While ($LineIndex -ge $StartIndexNo)
		{
			$Str = $content[$LineIndex-1]
			
			if ($Str -ne $null -and ($Str -like "*"+$EndPatteranT+"*" -or $Str -like "*"+$EndPatteran1T+"*" ))
			{
				if ($Str -like "*"+$EndPatteran1T+"*")
				{
					$EndIndex = $LineIndex-3
				}
				else 
				{
					$EndIndex = $LineIndex-5
				}
				break;
			}
			
         	$LineIndex++;
	     	
		}
       
        $LineIndex = $StartIndexNo
		
		if (!(Test-Path -path "$dirSourceFolder\Transaction_$FileName.txt"))  
		{
			$outfile	= "$dirSourceFolder\Transaction_"+$FileName+".txt";
		}
        
		While ($LineIndex -ge $StartIndexNo -and $LineIndex -le ($EndIndex-1))
		{	
			
			$Str = $content[$LineIndex-1]
			$AddSpace = 0
			 
            $AddSpace = (322 - $Str.Length) ##Fixed in SSIS(322)
			if ($AddSpace -ge 1)
			{
				$Str =  $Str + " " * $AddSpace
			}
			
			if ($Str.Trim() -eq "")
			{
				$Str =  $null
			}
			
			if (!(Test-Path -path $outfile )) 
			{ 
			   
				##New-Object -TypeName System.IO.FileInfo($outfile);
				New-Item -path $outfile -ItemType file
			}
			$Str | Out-File -encoding ASCII -append -filePath $outfile
			
 		    $LineIndex++;
	     
	   }
	   $PatternCounterCountT++;
	}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: All the parsed content for Transaction file has been stored in file :: $outfile " | Out-File $LogFile -Append
	
	##Import the data
	foreach ($file1 in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Bonds_*.txt"})
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Universal Bond Marks: file ( $file1 ) processing " | Out-File $LogFile -Append
	$DateStr = $file1.Name.substring( $file1.BaseName.Length-10,10)
	$dtDataSetDate = ([datetime]::ParseExact($DateStr,"d.M.yyyy",$null)).toshortdatestring()
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from file Name ( $file1 ):: $dtDataSetDate " | Out-File $LogFile -Append
	
	$dtDate = get-date 
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianUniversalMarkBonds.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate `r`n  FilePath = $dirSourceFolder `r`n  FileName = $file1 `r`n  FileNAV = $outfileNAV1 " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianUniversalMarkBonds.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[FileName].Value;$file1" /set "\package.variables[FileNAV].Value;$outfileNAV1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond Marks: file ( $file1 ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond Marks: file ( $file1 ) imported" | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Removing item $file1 " | Out-File $LogFile -Append
	Remove-Item -Path $file1.FullName-Force
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Removing item $outfileNAV " | Out-File $LogFile -Append
	Remove-Item -Path $outfileNAV -Force
	}
	
	foreach ($file1 in Get-ChildItem -Path $dirSourceFolder | Where-Object {$_.Name -ilike "Transaction_*.txt"})
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Universal Bond Marks: file ( $file1 ) processing " | Out-File $LogFile -Append	
	$DateStr = $file1.Name.substring( $file1.BaseName.Length-10,10)
	$dtDataSetDate = ([datetime]::ParseExact($DateStr,"d.M.yyyy",$null)).toshortdatestring()
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") ::  Parsed RefDataSetDate from file Name ( $file1 ):: $dtDataSetDate1 " | Out-File $LogFile -Append
	$dtDate = get-date 
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling ImportCustodianUniversalMarkTransaction.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate `r`n  FilePath = $dirSourceFolder `r`n  FileName = $file1 " | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISExtractCustodian\ImportCustodianUniversalMarkTransaction.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[FilePath].Value;$dirSourceFolder" /set "\package.variables[FileName].Value;$file1" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $logFile -Append
	## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond Marks: file ( $file1 ) not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond Marks: file ( $file1 ) imported" | Out-File $LogFile -Append
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Removing item $file1 " | Out-File $LogFile -Append
	Remove-Item -Path $file1.FullName-Force

	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUniversalMarkTransaction.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate `r`n PowerShellLocation = $ScriptName" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append

	## Normalize  Universal Marks Transaction
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUniversalMarkTransaction.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" | Out-File $LogFile -Append

	## Check SSIS is success or not 
		If ($lastexitcode -ne 0 ) {
				$SSISErrorMessage = fSSISExitCode $lastexitcode;
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Mark Transaction : NormalizeCustodianUniversalMarkTransaction.dtsx is not success" | Out-File $LogFile -Append
				Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
				Exit
			}
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff")Universal Mark Transaction  : Normalization Complete" | Out-File $LogFile -Append
	}
	
	###Remove Convertedd Text files
  	Remove-Item -path $dirSourceFolder\$strFileName -Force | Out-File $logFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Removing file ( $dirSourceFolder\$strFileName ) " | Out-File $LogFile -Append
	
	###Move PDF file to Archive Directory
    Move-Item -Path $dirPDFSourceFolder\$strPDFFileName $dirArchiveFolder\$strDateNow   | Out-File $logFile -Append
    Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") moved file ( $dirPDFSourceFolder\$strPDFFileName ) to location ( $dirArchiveFolder\$strDateNow ) " | Out-File $LogFile -Append
    
    ## Normalize Universal Marks 
    
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUniversalMarkBound.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUniversalMarkBound.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $logFile -Append
    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond Marks:  NormalizeCustodianUniversalMarkBound.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
		
	## SSIS Status Variables
	[Int]$lastexitcode = $null
	[String]$SSISErrorMessage = $null
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling NormalizeCustodianUniversalMarkBoundNAV.dtsx `r`n Variable passed here are : `r`n  RefDataSetDate = $dtDataSetDate" | Out-File $LogFile -Append
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: SSIS Log" | Out-File $LogFile -Append
	& $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianUniversalMarkBoundNAV.dtsx" /set "\package.variables[RefDataSetDate].Value;$dtDataSetDate" /set "\package.variables[PowerShellLocation].Value;$ScriptName" |  Out-File $logFile -Append
    ## Check SSIS is success or not 
	If ($lastexitcode -ne 0 ) {
			$SSISErrorMessage = fSSISExitCode $lastexitcode;
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Universal Bond NAV :  NormalizeCustodianUniversalMarkBoundNAV.dtsx is not success" | Out-File $LogFile -Append
			Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $SSISErrorMessage" | Out-File $LogFile -Append
			Exit
		}
	
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Completed NormalizeCustodianUniversalMarkBound.dtsx `r`n "| Out-File $LogFile -Append
	
}
If($strFileName -eq $null)
	{
		
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Source File doesn't exists : $dirSourceFolder\*BESTAND*.txt " | Out-File $LogFile -Append
	}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append
