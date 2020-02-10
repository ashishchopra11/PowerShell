########################################################################################################
######################################### Unzip files function #########################################

<#
Description:
Function unzip the zip folder to specified location.

Parameters: (mandatory as starred*)
$file* is the zip folder location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\options_20130701.zip")
$destination* is the location where the zip folder will unzip the files ("C:\Siepe\DataFeeds\DeltaNeutral\")

Function Call:
Expand-ZIPFile –File $file –Destination $destination
#>

function Expand-ZIPFile($File, $Destination) {
$shell = new-object -com shell.application
$zip = $shell.NameSpace($File)
foreach($item in $zip.items()) {
$shell.Namespace($Destination).copyhere($item)
}
}


########################################################################################################
######################################### Zip files function #########################################

<#
Description:
Function zips the source directory into the specified file name

Parameters: (mandatory as starred*)
$zipfilename: path to the zip file name.  Can be relative
$sourcedir: source directory the contents of which will be zipped

Function Call:
ZipFiles $zipFileName $zipFolderName
#>

function ZipFiles( $zipfilename, $sourcedir )
{
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}


########################################################################################################
######################################### Create a new directory #####################################

<#==========================================================
Description:
Create a new directory on the specific path.

Parameters:
$path is the directory location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$dirName is the directory name which will be create("Position_20141112")

Function Call:
Create-Directory –Path $path –DirName $dirName
===========================================================#>

function Create-Directory ($path,$dirName) 
{ 	
	if((Test-Path $path\$dirName) -eq 0)
	{
		New-Item -path $path\$dirName -ItemType directory
	}
}

########################################################################################################
######################################### Remove directory #####################################

<#==========================================================
Description:
Remove directory from the specific path.

Parameters: (mandatory as starred*)
$path is the directory location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$dirName is the directory name which will be remove("Position_20141112")

Function Call:
Remove-Directory –Path $path –DirName $dirName
===========================================================#>

function Remove-Directory ($path,$dirName) 
{ 	
	if((Test-Path $path\$dirName) -eq 1)
	{
		Remove-Item -path $path\$dirName -Force -Recurse
	}
}

########################################################################################################
######################################### Move directory #####################################

<#==========================================================
Description:
Move directory from the source to destination path.

Parameters: (mandatory as starred*)
$sourcePath is the source directory location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$destinationPath is the destination location directory location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\Archive\")
$dirName is the directory name which will move("Position_20141112")

Function Call:
Move-Directory –SourcePath $sourcePath -DestinationPath $destinationPath  –DirName $dirName
===========================================================#>

function Move-Directory ($sourcePath,$destinationPath,$dirName) 
{ 	
	if((Test-Path $sourcePath\$dirName) -eq 1 -and (Test-Path $destinationPath) -eq 1 -and (Test-Path $destinationPath\$dirName) -eq 0)
	{
		Move-Item -Path $sourcePath\$dirName $destinationPath\$dirName
	}
}

########################################################################################################
######################################### Create file #####################################

<#==========================================================
Description:
Create file on the specific path.

Parameters: (mandatory as starred*)
$path is the file location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$fileName is the file name with extenstion("Position_20141112.csv")

Function Call:
Create-File –Path $path –FileName $fileName
===========================================================#>

function Create-File ($path,$fileName) 
{ 	
	if((Test-Path $path) -eq 1 -and (Test-Path $path\$fileName) -eq 0)
	{
		New-Item -path $path\$fileName -ItemType file
	}
}

########################################################################################################
######################################### Remove file #####################################

<#==========================================================
Description:
Remove file from the specific path.

Parameters: (mandatory as starred*)
$path is the file location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$fileName is the file name with extenstion("Position_20141112.csv")

Function Call:
Remove-File –Path $path –FileName $fileName
===========================================================#>

function Remove-File ($path,$fileName) 
{ 	
	if( (Test-Path $path\$fileName) -eq 1)
	{
		Remove-Item -path $path\$fileName -Force -Recurse
	}
}

########################################################################################################
######################################### Move file #####################################

<#==========================================================
Description:
Move file from source to destination path.

Parameters: (mandatory as starred*)
$sourcePath is the source file location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\")
$destinationPath is the destination file location in double quotes ("C:\Siepe\DataFeeds\DeltaNeutral\Archive\")
$fileName is the file name with extenstion("Position_20141112.csv")

Function Call:
Move-File -SourcePath $sourcePath -DestinationPath $destinationPath -FileName $fileName
===========================================================#>

function Move-File ($sourcePath,$destinationPath,$fileName) 
{ 	
	if((Test-Path $sourcePath\$fileName) -eq 1 -and (Test-Path $destinationPath) -eq 1 -and (Test-Path $destinationPath\$fileName) -eq 0)
	{
		Move-Item -Path $sourcePath\$fileName $destinationPath\$fileName
	}
}



