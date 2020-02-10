﻿
$scriptPath = "D:\Siepe\Data\Scripts\PowerShells"

$File = "D:\Siepe\Data\CSV FILES\Sample.csv"
$OutputFile = "D:\Siepe\Data\CSV FILES\NonGenericTest.csv"

rm $File -ea ig

rm $OutputFile -ea ig

# $File = Import-Csv $File -Header  VarSourceFilePath, FullVarSourceFolderName ,FullVarArchiveFolderName ,IsFolderMatching
"PowerShell , SourceFolderName, ArchiveFolderName,IsFolderMatching" |out-file $File 
# $result = @()
foreach ($strFileName in Get-ChildItem  -Path $scriptPath -Recurse| Where-Object {$_.Name -ilike "GenevaEODPositions.ps1"})
{   
$isSourceFolderExist = 0
$VarSourceFilePath = ""
$VarSourceFolderName = ""
$VarArchiveFilePath = ""
$VarArchiveFolderName = ""
$IsFolderMatching =""
$search = "dirServicesDeliveryStoreFolder"
$ImportSearch = "fGenericImportJob"
    $FileContent = Get-Content -Path $strFileName.FullName
    $FileContent = $FileContent.ToUpper()
      [String]$FilePath = $strFileName.FullName
      $LineNumber = Select-String $search $strFileName.FullName | Select-Object -ExpandProperty LineNumber
      $ImportLineNumber = Select-String $ImportSearch $strFileName.FullName | Select-Object -ExpandProperty LineNumber
 #$FileContent.IndexOf(". .\FGENERICIMPORTJOB.PS1")

    if ($LineNumber -gt 0 -and $ImportLineNumber -lt 0)
    {
    $isSourceFolderExist = 1
    $SourceFolderName = Get-Content -Path $strFileName.FullName | select -Index ($LineNumber[0]-1)
    $FullVarSourceFolderName = $SourceFolderName
    $val=$SourceFolderName.IndexOf("\",1)

        if ($SourceFolderName.IndexOf("\",$val+1) -eq -1 -and $SourceFolderName -like "*## Sou*")
        {
        $VarSourceFilePath = $FilePath
        $VarSourceFolderNameResult = $SourceFolderName.Substring($val+1,(($SourceFolderName.Length)-1-$val)-1)
        $VarSourceFolderName = $VarSourceFolderNameResult.Substring(0,$VarSourceFolderNameResult.IndexOf("""",1))
        $VarSourceFolderName = $VarSourceFolderName.Replace("""","")
        
        }
    
        if ($SourceFolderName.IndexOf("\",$val+1) -eq -1 )
        {
        $VarSourceFilePath = $FilePath
        $VarSourceFolderName = $SourceFolderName.Substring($val+1,(($SourceFolderName.Length)-1-$val)-1)
       $VarSourceFolderName = $VarSourceFolderName.Replace("""","")
        }
        
        else
        {
        $VarSourceFilePath = $FilePath
        #$VarSourceFolderName = $SourceFolderName.Substring($val+1,$SourceFolderName.IndexOf("\",$val+1)-$val-1)
        $VarSourceFolderName = $SourceFolderName.Substring($val+1,$SourceFolderName.Length-$val-1)
       $VarSourceFolderName = $VarSourceFolderName.Replace("""","")
        }     
    }

    $search = @("dirArchiveHCM46DriveFolder","dirArchiveHCM97DriveFolder","dirDataFeedsArchiveFolder")
    $ImportSearch = "fGenericImportJob"
     $FileContent = Get-Content -Path $strFileName.FullName
    $FileContent = $FileContent.ToUpper()
      [String]$FilePath = $strFileName.FullName
      $LineNumber = Select-String $search $strFileName.FullName | Select-Object -ExpandProperty LineNumber
      $ImportLineNumber = Select-String $ImportSearch $strFileName.FullName | Select-Object -ExpandProperty LineNumber
      if( $isSourceFolderExist -eq 0 ){
        $VarSourceFilePath = $FilePath
    }
 

    if ($LineNumber -gt 0 -and $ImportLineNumber -lt 0) 
    {
        for($i = 0; $i -lt $LineNumber.Length; $i++)
        {

    
    $SourceFolderName = Get-Content -Path $strFileName.FullName | select -Index ($LineNumber[$i]-1)
    $FullVarArchiveFolderName = $SourceFolderName
    $val=$SourceFolderName.IndexOf("\",1)
    
    $VarArchiveFolderName = $SourceFolderName.Substring($val+1,$SourceFolderName.Length-$val-1)
    $VarArchiveFolderName=($VarArchiveFolderName.Replace("\Archive","")).Replace("""","")
    # $VarArchiveFolderName
        #    if( $FullVarArchiveFolderName.Substring(0) -eq "#"){
        #        continue
        #    } 
    
    if ($VarSourceFolderName -eq "" -and $VarArchiveFolderName -eq "")
    {
        $IsFolderMatching = ""
    }
    if ($VarSourceFolderName -eq $VarArchiveFolderName -and $VarSourceFolderName -ne "" -and $VarArchiveFolderName -ne "")
    {
        $IsFolderMatching = "Y"
    }
    if ($VarSourceFolderName -ne $VarArchiveFolderName)
    {
        $IsFolderMatching = "N"
    }

    if($VarSourceFilePath -eq "")
    {
    $VarSourceFilePath = $VarArchiveFilePath
    }

    if($VarArchiveFilePath -eq "")
    {
    $VarArchiveFilePath = $VarSourceFilePath
    }
    if($FullVarArchiveFolderName -like "#*" -eq $false){
    
    "$VarSourceFilePath , $FullVarSourceFolderName,  $FullVarArchiveFolderName,$IsFolderMatching" |out-file $File -Append
    }
    
    # $details = @(
    #     VarSourceFilePath = $VarSourceFilePath
    #     FullVarSourceFolderName = $FullVarSourceFolderName 
    #     FullVarArchiveFolderName = $FullVarArchiveFolderName
    #     IsFolderMatching = $IsFolderMatching
    # )
    # $result += New-Object PSObject -Property $details
    

    
    # # Add-Content -Path $File -Value'"VarSourceFilePath","FullVarSourceFolderName","FullVarArchiveFolderName","IsFolderMatching"'
    # # $data = @(
    # #     '""'
    # # )
        }
    }
} 

# $result | Export-Csv -Path $File -NoTypeInformation


#  Import-csv $File | Where-Object { $_.PSObject.Properties.Value -ne '' } | Export-Csv $OutputFile -NoTypeInformation



