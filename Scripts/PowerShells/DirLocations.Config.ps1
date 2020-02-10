$dirRoot                  		= "D:\Siepe\Data"

$dirLogFolder					= "$dirRoot\Logs"
$dirScriptsFolder           	= "$dirRoot\Scripts"
$dirSSISRootFolder              = "$dirRoot\SSIS"

#$dirDevHcmlpDataFeedsFolder     = "\\hcm41\DataFeeds$"
#$dirProdHcmlpDataFeedsFolder    = "\\hcmlp.com\data\public\IT\DataFeeds"
$dirServicesDeliveryStoreFolder = "\\services.hcmlp.com\DeliveryStore"
#$dirServicesDeliveryStoreFolder = "D:\Siepe\DataFeeds"
$dirArchiveHCM46DriveFolder 	= "\\hcm97\PMPDataFeeds"
$dirArchiveServicesIfolder		= "\\services\i$\DataFeeds"
$dirArchiveHCM97DriveFolder 	= "\\hcm97\PMPDataFeeds"
$dirDataFeedsArchiveFolder	    = "\\hcm97\PMPDataFeeds"
#$dirArchiveHCM46DriveFolder 	= "D:\Siepe\DataFeeds"
#$dirDataFeedsArchiveFolder 	= "D:\Siepe\DataFeeds"

## Data Transfer
$dirSSISDataTransfer   		= $dirSSISRootFolder  + "\DataTransfer"

## Import SSIS
$dirSSISExtractCustodian   		= $dirSSISRootFolder  + "\ExtractCustodian"
$dirSSISExtractGeneva      		= $dirSSISRootFolder  + "\ExtractGeneva"
$dirSSISExtractVendor      		= $dirSSISRootFolder  + "\ExtractVendor"
$dirSSISExtractWSO      		= $dirSSISRootFolder  + "\ExtractWSO"


## Normalize SSIS
$dirSSISNormalizeCustodian   	= $dirSSISRootFolder  + "\NormalizeCustodian"
$dirSSISNormalizeGeneva      	= $dirSSISRootFolder  + "\NormalizeGeneva"
$dirSSISNormalizeVendor      	= $dirSSISRootFolder  + "\NormalizeVendor"
$dirSSISNormalizeWSO      		= $dirSSISRootFolder  + "\NormalizeWSO"


## Push SSIS
$dirSSISPush      				= $dirSSISRootFolder  + "\PushToHCM"

## Aspose.Cells DLL
$dirAsposeCellsDLL      		= $dirScriptsFolder  + "\Aspose\Aspose.Cells.DLL"
$dirAsposeCellsLic 				= $dirScriptsFolder + "\Aspose\Aspose.lic"

## Aspose DLL V4
$dirAsposeCellsDLLv4 	= $dirScriptsFolder + "\Aspose\v4\Aspose.Cells.dll"

## Aspose DLL V8
$dirAsposeCellsDLLv8    = $dirScriptsFolder + "\Aspose\v8\Aspose.Cells.dll"
