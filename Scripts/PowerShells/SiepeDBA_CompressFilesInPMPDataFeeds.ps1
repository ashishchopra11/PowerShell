CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
. .\fArchiveFile.ps1

###Create Log folder, if needed
if(!(Test-Path -Path $dirLogFolder )){
    New-Item -ItemType directory -Path $dirLogFolder
}

$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$LogFile = "$dirLogFolder\ArchivePMPDataFeeds."+$strDateNow+".txt"

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$LogFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

$ScriptName = $MyInvocation.MyCommand.Definition
Write-Output "################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: $ScriptName START `r`n" |   Out-File $LogFile -Append

$FinalRar=$null
$ArchiveFolder=$null
$StrFileLocation=$null

$Array = New-Object System.Collections.ArrayList
$ArrayArchiveFile = New-Object System.Collections.ArrayList
$ListFileNotZipped = New-Object System.Collections.ArrayList

$PMPDataFeeds = "\\hcm97\PMPDataFeeds"
$DataSource = "PHCMDB01"

$process_date = Get-Date  
#$process_date = Get-Date "2018/03/11"
$FullDayString = $process_date.ToShortDateString()
#$FullDayString = "04/08/2018"
# Push prices to Geneva ...
$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=$DataSource;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: $DataSource" | Out-File $LogFile -Append
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0

$str_Date = $process_date.ToString("yyyyMMdd")

################## Create dataSet ####################
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet" |   Out-File $LogFile -Append
	$dbCmd.CommandText = "EXEC DataFeeds.dbo.pRefDataSetIU	
						@RefDataSetID		= 0 ,	
						@RefDataSetDate	    = '" +$FullDayString +"' ,	
						@RefDataSetType		= 'Report' ,	
						@RefDataSource		= 'Highland' ,	
						@Label				= 'Compress PMPDataFeeds'" 
	$dbCmd.ExecuteScalar()

	######## Get RefDataSetID ###########
	$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID FROM  DataFeeds.dbo.vRefDataSet 
							WHERE RefDataSetDate = '" +$FullDayString +"' 
							AND RefDataSetType = 'Report' 
							AND RefDataSource = 'Highland' 
							AND Label = 'Compress PMPDataFeeds' ORDER BY 1 DESC"
	$RefDataSetID = $dbCmd.ExecuteScalar()	
		

#################################################### BNP ##############################################################
#END
$StrFileLocation = $PMPDataFeeds + "\BNP\Archive\Pledge"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
#For Archive files present in "E:\DIKSHANT_MARWAH\Dikshant\Dikshant\PMPDataFeeds\BNP\Archive\Pledge"
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer }|Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"}  )
{
IF($StrName.Name.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*" )
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile += $Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
## NEED to pass parameter of -ArchiveLocation in function fArchiveFile with format LIKE "*yyyyMM" - USED TO CHECK FOR CURRENT MONTH FILES
$FinalRar = $StrFileLocation + "\BNP_Pledge_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append
#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar

Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
		Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

 $ArrayArchiveFile=@()
 $Array = @()
#For Archive files present in "\\hcm97\PMPDataFeeds\BNP\Archive"
$StrFileLocation = $PMPDataFeeds + "\BNP\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer }|Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.Name.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\10P_GExpPosUnd_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

 $ArrayArchiveFile=@()
 $Array = @()
#For Archive files present in "\\hcm97\PMPDataFeeds\BNP\Archive"
$StrFileLocation = $PMPDataFeeds + "\BNP\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*hcapital.ssares.*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 30 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(16,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\hcapital_ssares_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

 $ArrayArchiveFile=@()
 $Array = @()
#For Archive files present in "\\hcm97\PMPDataFeeds\BNP\BNPLuxembourg\Archive"
$StrFileLocation = $PMPDataFeeds + "\BNP\BNPLuxembourg\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\POSI_ALL001_Position_holding_BAYVK_R2_Lux_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
 $ArrayArchiveFile=@()
 $Array = @()
 
#For Archive files present in "E:\DIKSHANT_MARWAH\Dikshant\Dikshant\PMPDataFeeds\BNP\Archive"
$StrFileLocation = $PMPDataFeeds + "\BNP\BVKCash\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\BVKCash_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
 $ArrayArchiveFile=@()
 $Array = @()
#For Archive files present in "E:\DIKSHANT_MARWAH\Dikshant\Dikshant\PMPDataFeeds\BNP\Archive"
$StrFileLocation = $PMPDataFeeds + "\BNP\BVKUniversal\Archive\Bonds"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\BVKUniversal_Bonds_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}


#################################################### Archive ##############################################################
 $ArrayArchiveFile=@()
 $Array = @()

$StrFileLocation = $PMPDataFeeds + "\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
	
#################################################### BAML ##############################################################
$ArrayArchiveFile=@()
 $Array = @()

$StrFileLocation = $PMPDataFeeds + "\BAML\BAML Futures\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Futures_Positions_Summary_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

$ArrayArchiveFile=@()
 $Array = @() 
 
#For Archive files present in "\\hcm97\PMPDataFeeds\BAML\Archive"
$StrFileLocation = $PMPDataFeeds + "\BAML\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "DailyStockLoanExtract.*"})
{
$StrName.BaseName
$StrName.BaseName.Length
IF($StrName.BaseName.Length -eq 30 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$temp = $StrName.BaseName.Substring($StrName.BaseName.Length-8,6)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\DailyStockLoanExtract_Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}


$ArrayArchiveFile=@()
 $Array = @() 
 
#For Archive files present in "\\hcm97\PMPDataFeeds\BNP\Archive"
$StrFileLocation =$PMPDataFeeds + "\BAML\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "DailyStockLoanExtract*"})
{
$StrName.BaseName
$StrName.BaseName.Length
IF($StrName.BaseName.Length -eq 30 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$temp = $StrName.BaseName.Substring($StrName.BaseName.Length-8,6)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\DailyStockLoanExtract_Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

$ArrayArchiveFile=@()
 $Array = @() 

#For Archive files present in "\\hcm97\PMPDataFeeds\BAML\Archive"
$StrFileLocation = $PMPDataFeeds + "\BAML\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation -Recurse |Where-Object {$_.BaseName -ilike "*XHIHFTPAC1.*"})
{
$StrName.FullName
$StrName.BaseName.Length
IF($StrName.BaseName.Length -eq 19 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$temp = $StrName.BaseName.Substring($StrName.BaseName.Length-8,6)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\XHIHFTPAC1_Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

$ArrayArchiveFile=@()
 $Array = @() 
#For Archive files present in "\\hcm97\PMPDataFeeds\BNP\Archive"
$StrFileLocation = $PMPDataFeeds + "\BAML\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation -Recurse |Where-Object {$_.BaseName -ilike "XHIHFTPFD1.E10AMTD.MtdRebate.*"})
{
$StrName.FullName
$StrName.BaseName.Length
IF($StrName.BaseName.Length -eq 37 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$temp = $StrName.BaseName.Substring($StrName.BaseName.Length-8,6)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\XHIHFTPFD1_E10AMTD_MtdRebate_Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BAML\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation -Recurse |Where-Object {$_.BaseName -ilike "HIGHLAND_loc_res_*"})
{
$StrName.BaseName
$StrName.BaseName.Length
IF($StrName.BaseName.Length -eq 45 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array +=$StrName.FullName
	$BAMLSplitArchiveStr = $StrName.BaseName.Split("_")
	$temp = $BAMLSplitArchiveStr[3].SubString(0,6)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\HIGHLAND_loc_res__Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}


#Removing Blank folder if we have 
$files  = Get-ChildItem -Path  $StrFileLocation
Foreach ($file in $files){
$a = dir $file.FullName  -recurse | ?{!$_.PsIsContainer} | Measure-Object -sum length
$a
	While ( $a -eq $null -and (Test-Path -Path $file.FullName))
	{
	Remove-Item -Path $file.FullName -Recurse -Force 
	}
}


#################################################### BNY ##############################################################

$ArrayArchiveFile=@()
$Array = @() 

#$StrFileLocation  = "\\hcm97\PMPDataFeeds\TEST\backup\BNY\Position"
$StrFileLocation = $PMPDataFeeds + "\BNY\Position"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation  |Where-Object {$_.Name -ilike "2B30B-E_Portval_*.xls"})
{
IF($StrName.BaseName.Length -eq 24 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array +=$StrName.FullName
	$BNYSplitArchiveStr = $StrName.BaseName.Split("_")
	#Getting Date in Format yyyyMM
	$temp = $BNYSplitArchiveStr[2].SubString(4,4) + $BNYSplitArchiveStr[2].SubString(0,2)
	$Str1 = $temp
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\2B30B-E_Portval_Archive_" + $ArchiveFolder
#$a = $ArchiveFolder.Substring($ArchiveFolder.Length-2,2) + "-[0-9][0-9]-" + $ArchiveFolder.Substring(0,4)
$BNYYear = $ArchiveFolder.Substring(0,4)
$BNYMonth = $ArchiveFolder.Substring(4,2)
$File = $Array -like "*$BNYMonth[0-9][0-9]$BNYYear*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##\\HCM97\PMPDAtaFeeds\BNY\Ireland\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BNY\Ireland\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Positions_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\HCM97\PMPDAtaFeeds\BNY\Ireland\Archive\Custody
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BNY\Ireland\Archive\Custody"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyValuation_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\HCM97\PMPDAtaFeeds\BNY\Ireland\Archive\Position
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BNY\Ireland\Archive\Position"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}

Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Positions_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
#################################################### BnyMellon ##############################################################

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BnyMellon\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Wilmington_Alternatives_HIGHLAND_NAV_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}


$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BnyMellon\Custody\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\Custody\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Custody_Valuation_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}


$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BnyMellon\NAV\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\TEST\backup\BnyMellon\NAV\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Highland_Capital_NAV_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\hcm97\PMPDataFeeds\Jefferies\Pledge\Archive

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Jefferies\Pledge\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\Jefferies\Pledge\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Margin-Detail_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\Jefferies\Cash\Archive

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Jefferies\Cash\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\Jefferies\Cash\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CASH_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

############################################################################### Start: GoldmanSachs ##################################################################################################
##\\hcm97\PMPDataFeeds\\GoldmanSachs

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\GoldmanSachs\Cash\Archive"
#$StrFileLocation = "\\hcm97\PMPDataFeeds\Jefferies\Cash\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CASH_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\\GoldmanSachs\\SWAP\\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\GoldmanSachs\SWAP\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SWAP_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

############################################################################### SocGen ##################################################################################################
##\\hcm97\PMPDataFeeds\\SocGen\\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SocGen\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SocGen_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\\SocGen\\Archive\\FixedIncome

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SocGen\Archive\FixedIncome"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SocGen_FixedIncome_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\\SocGen\\Cash\\Archive

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SocGen\Cash\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SocGen_Cash_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\\SocGen\\Future\\Archive

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SocGen\Future\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SocGen_Future_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################Start:SEI ##################################################################################################
##\\hcm97\PMPDataFeeds\\SEI\\Archive

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\\SEI\\Archive\\PriceSource
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\Archive\PriceSource"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_PriceSource_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\hcm97\PMPDataFeeds\SEI\\Archive\\New folder
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\Archive\New folder"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_NewFolder_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}


##ETF_Pyxis_4_qtr_prem_disc
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_4_qtr_prem_disc*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 34 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_4_qtr_prem_disc_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##SEI_iBoxx_LstQtr
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_LstQtr_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 25 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(17,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_LstQtr_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##SEI_iBoxx_Holdings
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_Holdings_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 27 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(19,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_Holdings_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SEI_iBoxx_4Qtr
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_4Qtr_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 23 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(15,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_4Qtr_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SEI_iBoxx_QtrToDate
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_QtrToDate_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 28 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(20,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_QtrToDate_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##SEI_iBoxx_Blackbar
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_Blackbar_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 27 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(19,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_Blackbar_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##SEI_iBoxx_Bbdaily
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SEI_iBoxx_Bbdaily_*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 26 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(18,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_iBoxx_Bbdaily_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##ETF_Pyxis_bbdaily
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_bbdaily*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 26 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_bbdaily_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##ETF_Pyxis_blackbar
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_blackbar*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 27 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_blackbar_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##ETF_Pyxis_holdings
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_holdings*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 27 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_holdings_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##ETF_Pyxis_lst_qtr_prem_disc
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_lst_qtr_prem_disc*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 36 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_lst_qtr_prem_disc_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##ETF_Pyxis_qtr_to_date_prem_disc
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\iBoxx\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_ETF_Pyxis_qtr_to_date_prem_disc*"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 40 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ETF_Pyxis_qtr_to_date_prem_disc_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##\\hcm97\PMPDataFeeds\SEI\Trial Balance\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SEI\Trial Balance\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SEI_TrialBalance_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

############################################################################### START : GS  #################################################################################################
##\\hcm97\PMPDataFeeds\GS\OpenPosition
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\GS\OpenPosition"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\OpenPosition_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\hcm97\PMPDataFeeds\GS\Swap Positions
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\GS\Swap Positions"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SwapPositions_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##CustodyMTDTradeDtActivity
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyMTDTradeDtActivity*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyMTDTradeDtActivity_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive

fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##CustodyCashBalances
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CashBalances*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyCashBalances_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CustodyPosition
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyPosition*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyPosition_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CustodyTradeDtActivity
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyTradeDtActivity*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyTradeDtActivity_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CustodyCommission
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyCommission*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyCommission_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CustodyPositionWithHeader
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyPositionWithHeader*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyPositionWithHeader_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CustodyTotalBalances
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CustodyTotalBalances*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CustodyTotalBalances_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##CashActy
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*CashActy*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\CashActy_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##DGnLsChg
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*DGnLsChg*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\DGnLsChg_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##POSDETLS
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*POSDETLS*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\POSDETLS_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##ProcessDateActivity
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*ProcessDateActivity*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ProcessDateActivity_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##PVALANAL
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*PVALANAL*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PVALANAL_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_DailyRebate
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_DailyRebate*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SL_DailyRebate_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_Interest
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_Interest*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SL_Interest_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_MTDRebateSumm
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_MTDRebateSumm*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MTDRebateSumm_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_MTDRebateDetailNoFee
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_MTDRebateDetailNoFee*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MTDRebateDetailNoFee_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_DailyPreBorrowPositionFee
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_DailyPreBorrowPositionFee*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\DailyPreBorrowPositionFee_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##PC_ClientException
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*PC_ClientException*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PC_ClientException_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SRPB
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SRPB*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SRPB_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##SL_MTDPreBorrowAccrualDetail
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_MTDPreBorrowAccrualDetail*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MTDPreBorrowAccrualDetail_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_DlyStkLoanPosn
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_DlyStkLoanPosn*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SL_DlyStkLoanPosn_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##MTDPreBorrowAccrualFeeRebate
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_MTDPreBorrowAccrualFeeRebate*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MTDPreBorrowAccrualFeeRebate_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##SL_DailyPositionReport
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SL_DailyPositionReport*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SL_DailyPositionReport_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##TaxLots
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*TaxLots_*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TaxLots_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##YTDRevExLdg
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\GS\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*YTDRevExLdg_*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\YTDRevExLdg_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##RebateSummary.Reload
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Rebate\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*RebateSummary.Reload*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(30,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\RebateSummary_Reload_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##RebateSummary
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Rebate\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*RebateSummary*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(23,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\RebateSummary_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##Rebate-Summary
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Rebate\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_Rebate-Summary*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(9,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Rebate-Summary_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##Jefferies\Locate\Archive
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Locate\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*lr_*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(3,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\lr_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##Jefferies\Archive\Margin-Detail
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*_Margin-Detail*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(9,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MarginDetail_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##Jefferies\Archive\PositionExtract-
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*-PositionExtract-*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(22,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PositionExtract_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##Jefferies\Archive\TransactionExtract 
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Jefferies\Archive"


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*-TransactionExtract-*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(25,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TransactionExtract_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##\\hcm97\PMPDataFeeds\\Jefferies\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\\Jefferies\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MarginDetail_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

###############################################################################START: SP  #################################################################################################
##\\HCM97\PMPDAtaFeeds\SP\LoanComponents\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\SP\LoanComponents\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\LL_Index_Components_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START: StateStreet  #################################################################################################
##\StateStreet\AdminTieOut\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\AdminTieOut\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PositionsAdmin_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\StateStreet\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\HighlandTotalReturn_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##PyxisCapitalNAVs
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\StateStreet\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*PyxisCapitalNAVs*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(17,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PyxisCapitalNAVs_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##HighlandUnpricedTrades
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\StateStreet\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*HighlandUnpricedTrades*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(23,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\HighlandUnpricedTrades_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##Highland_Extract
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\StateStreet\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*Highland_extract*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(23,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Highland_Extract_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##\StateStreet\MLPFundReports\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\MLPFundReports\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\MLPFundReports_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\StateStreet\Pledge\Archive\File1
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Pledge\Archive\File1"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PositionsByCategory_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\StateStreet\Pledge\Archive\File2
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Pledge\Archive\File2"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PositionsByCategory_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\StateStreet\Position Files\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Position Files\Archive"


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Positions_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\StateStreet\Position Files - Cust\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Position Files - Cust\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PositionFiles_Custodian_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\StateStreet\StateStreetTotalReturn\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\StateStreetTotalReturn\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\StateStreetTotalReturn_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##StateStreet\TMRSPositionFiles\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\TMRSPositionFiles\Archive"


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TMRSPositionFiles_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##StateStreet\TMRSTradeFiles\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\TMRSTradeFiles\Archive"


Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TMRSTradeFiles_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\StateStreet\Trial Balance\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\StateStreet\Trial Balance\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TrialBalance_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

###############################################################################START: USBank#################################################################################################
##\USBank\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\USBank\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\TrialBalance_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\USBank\Archive\PortfolioHoldings
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\USBank\Archive\PortfolioHoldings"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\PortfolioHoldings_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##USBank\ClientHoldings
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\USBank\ClientHoldings"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ClientHoldingsDetailed_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\HCM97\PMPDAtaFeeds\WSOOnDemand\RatingReports

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\WSOOnDemand\RatingReports"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\RatingReports_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\HCM97\PMPDAtaFeeds\WSOOnDemand\YTD

$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\WSOOnDemand\YTD"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\YTD_Extract_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\HCM97\PMPDAtaFeeds\WSORatingsResponse\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\WSOOnDemand\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\WSORatingsResponse_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

###############################################################################START: Barclays #################################################################################################

##\\HCM97\PMPDAtaFeeds\Barclays\HY
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Barclays\HY"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Barclays_HY_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START: Bloomberg #################################################################################################

##\\HCM97\PMPDAtaFeeds\Bloomberg\Port\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Bloomberg\Port\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Bloomberg_Port_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START: Bloomberg Back Office #################################################################################################

##\\HCM97\PMPDAtaFeeds\Bloomberg Back Office
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Bloomberg Back Office"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Started moving archived files into respective year folders " | Out-File $LogFile -Append

$ArrayMoveFile=@()
$ArrayFile = @() 

Foreach ($StrName in Get-ChildItem -Path $StrFileLocation | Where-Object {$_.BaseName -ilike "Archive_[0-9][0-9][0-9][0-9]_[0-9][0-9]"} )
{
	$ArrayFile += $StrName.FullName	
	$Str1 = $StrName.Name.Substring(8,4)

	IF(!($ArrayMoveFile -contains $Str1))
	{
	$ArrayMoveFile +=$Str1
	if(!(Test-Path -Path "$StrFileLocation\$Str1" ))
	{
    	New-Item -ItemType directory -Path "$StrFileLocation\$Str1"
	}
	}
}

Foreach($MoveFolder in $ArrayMoveFile)
{
	$YearFolder = $StrFileLocation + "\" + $MoveFolder
	$Files = $ArrayFile -like "*$MoveFolder*"

	ForEach($File in $Files)
	{
		Move-Item $File $YearFolder
	}
}

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Finished moving archived files into respective year folders " | Out-File $LogFile -Append



###############################################################################START: ReceiveServiceArchive #################################################################################################

##\\HCM97\PMPDAtaFeeds\ReceiveServiceArchive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\ReceiveServiceArchive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 8 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,8)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{

$FinalRar = $StrFileLocation + "\Archive\" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}

} 
}



###############################################################################START: BnyMellon #################################################################################################

##\\HCM97\PMPDAtaFeeds\BnyMellon\Pledge\Prime\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\BnyMellon\Pledge\Prime\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\BnyMellonPrimePledge_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START: Connectwise #################################################################################################

##\\HCM97\PMPDAtaFeeds\Connectwise\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Connectwise\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\ProjectDetails_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

###############################################################################START: IDC #################################################################################################

##\\HCM97\PMPDAtaFeeds\IDC\FUNDRUN\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\IDC\FUNDRUN\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Highland_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START:MarkIt #################################################################################################

##\\HCM97\PMPDAtaFeeds\MarkIt\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\MarkIt\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\LoanLiquidityMetrics_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

##\\HCM97\PMPDAtaFeeds\MarkIt\IboxxUnderlyings\Archive
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\MarkIt\IboxxUnderlyings\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*markit_iboxx_usd_liquid_100*"}-AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(51,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\IboxxUnderlyings_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##\\HCM97\PMPDAtaFeeds\MarkIt\WSOMarksResponse
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\MarkIt\WSOMarksResponse"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\WSOMarksResponse_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}

###############################################################################START:MUFG#################################################################################################

##\\HCM97\PMPDAtaFeeds\MUFG\Archive\Position
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\MUFG\Archive\Position"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Position_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START:Novus #################################################################################################
##\\HCM97\PMPDAtaFeeds\Novus
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Novus"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*NovusUpload*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(11,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\NovusUpload_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
###############################################################################START:Pershing #################################################################################################
##\\HCM97\PMPDAtaFeeds\Pershing\Rebate\Archive
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\Pershing\Rebate\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*SIE_CSSRR102_SIEHIGH*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	$Str1 = $StrName.Name.Substring(21,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\SIE_CSSRR102_SIEHIGH_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}

##\\HCM97\PMPDAtaFeeds\Pershing\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Pershing\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 15 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\Pershing_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
###############################################################################START:RegressionTest#################################################################################################
##\\HCM97\PMPDAtaFeeds\RegressionTest\Archive
$ArrayArchiveFile=@()
$Array = @() 

$StrFileLocation = $PMPDataFeeds + "\Pershing\Archive"
Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |?{ $_.PSIsContainer } |Where-Object {$_.BaseName -ilike "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9]"})
{
$StrName.BaseName
IF($StrName.BaseName.Length -eq 11 -and  $StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrName.FullName
	$Str1 = $StrName.Name.Substring(0,6)
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyyMM").ToString())
{
$FinalRar = $StrFileLocation + "\RegressionTest_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
} 
}
##\\HCM97\PMPDAtaFeeds\WSOTransactions\Archive
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\WSOTransactions\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*MissingInst_*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	#$Str2=$StrName.Name.Substring(12,2)
	#$Str2 = $Str2 -replace "-",""
	$Str1 = $StrName.Name.Substring(16,4)
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyy").ToString())
{
$FinalRar = $StrFileLocation + "\MissingInst_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
##\\HCM97\PMPDAtaFeeds\WSOTransactions\Archive
$ArrayArchiveFile=@()
$Array = @() 
$StrFileLocation = $PMPDataFeeds + "\WSOTransactions\Archive"

Write-Output "`n`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Zipping the Files present in location :: $StrFileLocation `r`n" |  Out-File $LogFile -Append
Foreach ($StrName in Get-ChildItem -Path $StrFileLocation |Where-Object {$_.BaseName -ilike "*MissingPosition_*"} -AND {$_.BaseName -inotlike "*.rar"})
{
$StrName.BaseName
IF($StrName.FullName -like "$StrFileLocation*")
{
	$Array += $StrFileLocation + "\" + $StrName
	#$Str2=$StrName.Name.Substring(12,2)
	#$Str2 = $Str2 -replace "-",""
	$Str1 = $StrName.Name.Substring(21,4)
	
	IF(!($ArrayArchiveFile -contains $Str1))
	{
	$ArrayArchiveFile +=$Str1
	}
}
}
Foreach($ArchiveFolder in $ArrayArchiveFile)
{
IF ($ArchiveFolder -ne (Get-Date -Format "yyyy").ToString())
{
$FinalRar = $StrFileLocation + "\MissingPosition_Archive_" + $ArchiveFolder
$File = $Array -like "*$ArchiveFolder*"

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Calling function fArchiveFile `r`n Variable passed here are : `r`n  -ArchiveLocation = $FinalRar  `r`n -FolderList = $File `r`n `r`n " | Out-File $LogFile -Append

#Calling the Function to Archive 
fArchiveFile -FolderList $File -ArchiveLocation $FinalRar
Foreach ($ArchiveFile in $File)
{
	IF (Test-Path -Path $ArchiveFile )
	{
	Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: File not get Archived : $ArchiveFile " | Out-File $LogFile -Append
		$ListFileNotZipped += $ArchiveFile
	}
}
}
}
###############################################################################END  : GS  #################################################################################################


########################## Report ###########################
$listUnqiue =  $ListFileNotZipped | select -Unique 
IF(!($listUnqiue -eq $null))
{
Write-Output "`r`n `r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") :: Files Not get Archived " | Out-File $LogFile -Append

##SET Status Fail
$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	
							@RefDataSetID		= " +$RefDataSetID +" , 	
							@RefDataSetDate	    = '" +$FullDayString +"' , 	
							@RefDataSetType		= 'Report' ,	
							@RefDataSource		= 'Highland' ,	
							@Label				= 'Compress PMPDataFeeds',
							@StatusCode         = 'F'"
	$dbCmd.ExecuteScalar()


Foreach ($a in $listUnqiue)
{
Write-Output "`r`n $a " | Out-File $LogFile -Append
}
Write-Output "`r`n `r`n  " | Out-File $LogFile -Append
}
else
{
	##SET Status Fail
	$dbCmd.CommandText = 	"EXEC DataFeeds.dbo.pRefDataSetIU 	
							@RefDataSetID		= " +$RefDataSetID +" , 	
							@RefDataSetDate	    = '" +$FullDayString +"' , 	
							@RefDataSetType		= 'Report' ,	
							@RefDataSource		= 'Highland' ,	
							@Label				= 'Compress PMPDataFeeds',
							@StatusCode         = 'P'"
	$dbCmd.ExecuteScalar()
}
########################################## Closing SQL Connections #########################################################
$dbCmd.Dispose()
$dbConn.Close()
$dbConn.Dispose()

Remove-Variable dbCmd
Remove-Variable dbConn
########################################## Closing SQL Connections #########################################################

###########################################Start: Send Mail Alter##################################################################

$smtpserver = "email-smtp.us-east-1.amazonaws.com"
# SES Credentials
$smtpUserName = "AKIAIUBARKKYHWSVB3TA"
$smtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force)
$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword))
$EmailFrom = "help@siepe.com"



Function Send-Mail{
[cmdletbinding()]
Param (
[string[]]$To,
[string]$From,
[string]$SmtpServer = "email-smtp.us-east-1.amazonaws.com",
[string]$SmtpUsername = "AKIAIUBARKKYHWSVB3TA",
$SmtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force),
[string]$Subject = "Subject",
[string]$Body = "Body",
$EmailTimeOut = 240,
$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword)),
[bool]$asHtml =$true
) 
# End of Parameters
    
    Send-MailMessage -SmtpServer $SmtpServer -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -port 587 -UseSsl -credential $Credential -Priority $MailPriority
}


$MailPriority = "Low"
if ($AllSuccess -eq $true)
{
	[string[]]$EmailTo = "hdixit@siepe.com";
	#[string[]]$EmailTo = "All-Offshore@siepe.com","pjaiswal@siepe.com","rrutledge@siepe.com";
	#$EmailTo = "nkumar@siepe.com;ssengar@siepe.com;myadav@siepe.com;rkari@siepe.com;hgupta@Siepe.com;pjaiswal@siepe.com;rrutledge@siepe.com;"
	$subject = "HCM97 - PMPDataFeeds Zipping process - Success"
	$body = "<html>
			<body>
				<div>
					PMPDataFeeds zipping process has been completed..
				</div>
			</body>
		</html>"
}else {


$EmailTo = "hdixit@siepe.com","rkari@siepe.com","myadav@siepe.com","ssengar@siepe.com";
$subject = "HCM97 - PMPDataFeeds Zipping process - Success"
$MailPriority = "Low"
$body = "<html>
			<body>
				<div>
					PMPDataFeeds zipping process has been completed.
				</div>
			</body>
		</html>"	
}
  Send-Mail -To $EmailTo -From $EmailFrom -SmtpServer $smtpserver -SmtpUsername $smtpUserName -SmtpPassword $smtpPassword -Subject $subject -Body $Body -EmailTimeOut $EmailTimeOut -Credential $Credential


Write-Host "Finished";
###########################################END  : Send Mail Alter##################################################################


Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append