 function fArchiveFile
 {
  param([System.Collections.ArrayList]$FolderList ,
        [string]$ArchiveLocation)
		
	New-Item $ArchiveLocation -type directory 
	ForEach($Folder in $FolderList)
	{
		Move-Item $Folder  $ArchiveLocation
	}
	#$Dest = $ArchiveLocation+"_"
	$a=$ArchiveLocation.Substring($ArchiveLocation.Length - 2 , 2)
	$Dest = $ArchiveLocation.Substring(0,$ArchiveLocation.Length - 2 )+"_"+$a
	$rarDest = $Dest + ".rar"
IF(!(Test-Path -Path $rarDest))
{
	 & "C:\Program Files\WinRAR\winrar.exe" a -r -ep1 -df -ed -ibck $Dest $ArchiveLocation 
}
ELSE
{
	& "C:\Program Files\WinRAR\rar.exe" a -df -ed -ibck $Dest $ArchiveLocation	
}
	
	Get-Process winrar | Wait-Process
	
	$a = dir $ArchiveLocation -recurse | ?{!$_.PsIsContainer} | Measure-Object -sum length
	While ( $a -eq $null -and (Test-Path -Path $ArchiveLocation))
	{
	
	Remove-Item -Path $ArchiveLocation -Recurse -Force 
	}
}