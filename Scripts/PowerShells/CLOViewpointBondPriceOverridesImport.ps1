
############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DTExec.Config.ps1
. .\DirLocations.Config.ps1
####################################################################################

## Source Folder Paths
$ScriptName = $MyInvocation.MyCommand.Definition
#$dirSourceFolder  = "\\betaservices\DeliveryStore\CLOViewpointBondPriceOverrides"
$dirSourceFolder = "\\services\DeliveryStore\CLOViewpointBondPriceOverrides"
#$dirSourceFolder ="D:\Siepe\Datafeeds\CLOViewpointBondPriceOverrides"
#$dirArchiveFolder = "\\hcm46\I$\DataFeeds\CLOViewpointBondPriceOverrides\Archive"
$dirArchiveFolder = "\\hcm97\PMPDataFeeds\CLOViewpointBondPriceOverrides\Archive"
#$dirArchiveFolder = "$dirSourceFolder\Archive"
$strDateNow = get-date -format "yyyyMMddTHHmmss"
#$logFile = "$dirLogFolder\ImportCustodianBondPriceUpload"+$strDateNow+".txt" 
$PSScriptName = $MyInvocation.MyCommand.Name.ToString()
$PSScriptName = $PSScriptName.Replace(".ps1","")
$logFile = "$dirLogFolder\$PSScriptName."+$strDateNow+".txt"

#

    $dtDate = Get-Date -format "yyyy/MM/dd HH:mm:ss"
 

#$logFile = "D:\CG\Siepe\FILES\Log\"+$strDateNow+".txt"



Write-Output "************************************" | Out-File $logFile -Append

foreach ($strFileName in Get-ChildItem	 -Path $dirSourceFolder | Where-Object {$_.Name -ilike "BondPriceUpload*.csv"}) 
{

if (!(Test-Path -path $dirArchiveFolder\$strDateNow)) 
    { 
	    New-Item -path $dirArchiveFolder\$strDateNow -ItemType directory 
    }
    ############################ Import ############################
	### Get RefDataSet Date from File
	$FullPath = $strFileName.FullName
	$SourceCsv = Import-Csv -Path $FullPath -Header("Cusip","ISIN","Currency","DataSetDate","Price")
	$SourceCsvRDDate = $SourceCsv[4]
	$RefDataSetDate1 = $SourceCsvRDDate.DataSetDate.tostring();
	$RefDataSetDate = ([datetime]::ParseExact($RefDataSetDate1,”M/d/yyyy”,$null)).toshortdatestring();
	$RenamedFileName = $strFileName.BaseName + $strDateNow+".csv"
	
	
	
	
	### ImportCustodianBondPriceUpload
	Write-Output "ImportCustodianBondPriceUpload started at: $($dtDate.ToString()) for refdatasetdate $RefDataSetDate" | Out-File $logFile -Append
	& $2016DTEXEC32  /F "$dirSSISExtractCustodian\ImportCustodianBondPriceUpload.dtsx" /set "\package.variables[FileName].Value;$strFileName"  /set "\package.variables[FolderName].Value;$dirSourceFolder" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"| Out-File $logFile -Append
    Write-Output "ImportCustodianBondPriceUpload completed at: $($dtDate.ToString())" | Out-File $logFile -Append
	
    ###NormalizeCustodianBondPriceUpload
	Write-Output "NormalizeCustodianBondPriceUpload started at: $($dtDate.ToString()) for refdatasetdate $RefDataSetDate" | Out-File $logFile -Append
   & $2016DTEXEC32 /F "$dirSSISNormalizeCustodian\NormalizeCustodianBondPriceUpload.dtsx" /set "\package.variables[RefDataSetDate].Value;$RefDataSetDate"  /set "\package.variables[PowerShellLocation].Value;$ScriptName"  | Out-File $logFile  -Append
    Write-Output "NormalizeCustodianBondPriceUpload completed at: $($dtDate.ToString())" | Out-File $logFile -Append
	
	##Copy File
	#Copy-Item $dirSourceFolder\$strFileName $dirArchiveFolder
  ###Rename File
	Rename-Item $dirSourceFolder\$strFileName $dirSourceFolder\$RenamedFileName
  
	
	### Move imported file to Archive Directory
    Move-Item -Path $dirSourceFolder\$RenamedFileName $dirArchiveFolder\$strDateNow 

    Write-Output "> $($dtDate.ToString()) :: Moved $strFileName file to $dirArchiveFolder\$strDateNow" | Out-File $logFile -Append
    
    ############################ Normalize ############################
 
}
