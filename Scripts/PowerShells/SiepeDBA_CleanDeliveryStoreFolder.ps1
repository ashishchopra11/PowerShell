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
###Create Log file

$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
#Create-File -path $($dirLogFolder+"\") -fileName $PSScriptName+"."+$strDateNow+".txt"
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#Create-File -path $($dirLogFolder+"\") -fileName $("CleanDeliveryStore."+$strDateNow+".txt")
#$LogFile = "$dirLogFolder\CleanDeliveryStore.$strDateNow.txt"

$ScriptName = $MyInvocation.MyCommand.Definition

$sourceRoot =  "\\services\deliverystore"
$destinationRoot = "\\hcm97\PMPDataFeeds"

$date = (get-date).AddMonths(-2)
$RefDataSetdate = (Get-Date).ToShortDateString() 


$dbConn = New-Object -typeName System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=PHCMDB01;Initial Catalog=DataFeeds;Database=DataFeeds;Integrated Security=SSPI;"
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Creating connection :: PHCMDB01" | Out-File $LogFile -Append
$dbconn.Open()
$dbCmd = $dbConn.CreateCommand()
$dbCmd.CommandTimeout = 0

################## Create dataSet ####################
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss") :: Executing Procedure:: Creating DataSet"
	$dbCmd.CommandText = "EXEC HCM.dbo.pRefDataSetIU	@RefDataSetID		= 0 ,	@RefDataSetDate	    = '" +$RefDataSetdate +"' ,	@RefDataSetType		= 'File' ,	@RefDataSource		= 'Highland' ,	@Label	= 'CleanDeliveryStore'" 
	$dbCmd.ExecuteScalar()
	
	######## Get RefDataSetID ###########
	$dbCmd.CommandText = "SELECT TOP 1 RefDataSetID FROM  HCM.dbo.vRefDataSet WHERE RefDataSetDate = '" +$RefDataSetdate +"' AND RefDataSetType = 'File' AND RefDataSource = 'Highland' AND Label = 'CleanDeliveryStore' ORDER BY 1 DESC"
	$RefDataSetID = $dbCmd.ExecuteScalar()	
	

<#
############################################################################ Test Script #####################################################
# Move only one file type in a folder at a time for Ad-hoc basis
$source  = "\\hcmlp.com\data\public\IT\DataFeeds\Bloomberg Back Office\temp"
$destination =  "\\hcm46\i$\DataFeeds\Bloomberg Back Office\temp"

foreach ($strFileName in Get-ChildItem	 -Path $source | Where-Object {$_.Name -ilike "*.xml" -and $_.LastWriteTime -lt $date}) 
{
	Move-Item -Path $source\$strFileName $destination  -force 
}
#>

<#
############################################################################ Test Script #####################################################
# Move complte folder with subfolders and files at a time for Ad-hoc basis

$source =  "\\hcmlp.com\data\public\IT\DataFeeds\RatingsXpress\"
$destination = "\\hcm46\i$\DataFeeds\RatingsXpress\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source | #Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	#$_.FullName
    Move-Item $_.FullName -destination $destination -force -ErrorAction:SilentlyContinue
}
#>

<#
############################################################################ Test Script #####################################################
# Move one file at a time for Ad-hoc basis
$source =  "\\hcmlp.com\data\public\IT\DataFeeds\RatingsXpress\Master\GISF_IMM_2010_09_01_00_00_00.txt.zip"
$destination = "\\hcm46\i$\DataFeeds\RatingsXpress\Master\"

Move-Item $source -destination $destination -force -ErrorAction:SilentlyContinue
#>



############################################################################ Moving oms.notifications\EmailAttachments files #####################################################
$source_EA =  "$sourceRoot\oms.notifications\EmailAttachments\"
$destination_EA = "$destinationRoot\oms.notifications\EmailAttachments\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_EA | Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	$_.FullName
    Remove-Item -path $_.FullName  -Recurse
}


############################################################################ Moving oms.notifications files #####################################################
$source_ON =  "$sourceRoot\oms.notifications\"
$destination_ON = "$destinationRoot\oms.notifications\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_ON | Where-Object { $_.LastWriteTime -lt $date -and $_.GetType().Name -eq "FileInfo"} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_ON -force -ErrorAction:SilentlyContinue
}

############################################################################ Moving BloombergAIM2HCM files #####################################################
$source_BAH =  "$sourceRoot\BloombergAIM2HCM\"
$destination_BAH = "$destinationRoot\BloombergAIM2HCM\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_BAH | Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_BAH -force -ErrorAction:SilentlyContinue
}

############################################################################ Moving DeltaNeutral files #####################################################
$source_DN =  "$sourceRoot\DeltaNeutral\"
$destination_DN = "$destinationRoot\DeltaNeutral\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_DN | Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_DN -force -ErrorAction:SilentlyContinue
}

############################################################################ Moving Moodys files #####################################################
$source_MO =  "$sourceRoot\Moodys\"
$destination_MO = "$destinationRoot\Moodys\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_MO | Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_MO -force -ErrorAction:SilentlyContinue
}

############################################################################ Moving WSOOnDemand files #####################################################
$source_WOD =  "$sourceRoot\WSOOnDemand\"
$destination_WOD = "$destinationRoot\WSOOnDemand\"

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_WOD | Where-Object { $_.LastWriteTime -lt $date} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_WOD -force -ErrorAction:SilentlyContinue
}

############################################################################ Moving ReceiveServiceArchive files #####################################################
$source_RCA =  "$sourceRoot\ReceiveServiceArchive\"
$destination_RCA = "$destinationRoot\ReceiveServiceArchive\"
$date_RCA = (get-date).AddMonths(-3)

#Moves all files older than 3 months old from the Source folder to the Target
Get-Childitem -Path $source_RCA | Where-Object { $_.LastWriteTime -lt $date_RCA} |
ForEach {
	$_.FullName
    Move-Item $_.FullName -destination $destination_RCA -force -ErrorAction:SilentlyContinue
}


####################### Check if fill still exits #############################

Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") Check if still any file exists " | Out-File $LogFile -Append

If((Get-Childitem -Path $source_EA | Where-Object { $_.LastWriteTime -lt $date}) -eq $null -and
(Get-Childitem -Path $source_ON | Where-Object { $_.LastWriteTime -lt $date -and $_.GetType().Name -eq "FileInfo"}) -eq $null -and
(Get-Childitem -Path $source_BAH | Where-Object { $_.LastWriteTime -lt $date}) -eq $null -and
(Get-Childitem -Path $source_DN | Where-Object { $_.LastWriteTime -lt $date}) -eq $null -and
(Get-Childitem -Path $source_MO | Where-Object { $_.LastWriteTime -lt $date}) -eq $null  -and
(Get-Childitem -Path $source_RCA | Where-Object { $_.LastWriteTime -lt $date_RCA}) -eq $null  -and
(Get-Childitem -Path $source_WOD | Where-Object { $_.LastWriteTime -lt $date}) -eq $null)
{
$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$RefDataSetdate +"' , 	@RefDataSetType		= 'File' , 	@RefDataSource		= 'Highland' ,	@Label		= 'CleanDeliveryStore',	@StatusCode         = 'P'"
	$dbCmd.ExecuteScalar()
}
else
{
$dbCmd.CommandText = 	"EXEC HCM.dbo.pRefDataSetIU 	@RefDataSetID		= " +$RefDataSetID +" , 	@RefDataSetDate	    = '" +$RefDataSetdate +"' , 	@RefDataSetType		= 'File' , 	@RefDataSource		= 'Highland' ,	@Label		= 'CleanDeliveryStore',	@StatusCode         = 'F'"
	$dbCmd.ExecuteScalar()
}
Write-Output "`r`n################ $(get-date -format "yyyy/MM/dd hh:mm:ss:fff") $ScriptName END " | Out-File $LogFile -Append