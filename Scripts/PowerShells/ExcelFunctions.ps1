#----------------------------------------------------- 
#----  Release Object Reference
#----------------------------------------------------- 
function Release-Ref ($ref) { 
([System.Runtime.InteropServices.Marshal]::ReleaseComObject( 
[System.__ComObject]$ref) -gt 0) 
[System.GC]::Collect() 
[System.GC]::WaitForPendingFinalizers()  
} 

#----------------------------------------------------- 
#----  Excel Delete a row in Worksheet
#----------------------------------------------------- 
function ExcelRemoveRow
{
	param
	(
	[string]$FileFullName
	,[string]$SheetName
	,[int]$RowToDelete=1
	)
	
	#### Instantiate Excel object
	$objExcel = new-object -comobject excel.application 
	$objExcel.Visible = $True 
	$objWorkbook = $objExcel.Workbooks.Open($FileFullName)
	
	#### Activate Sheet
	$objWorksheet = $objWorkbook.Worksheets.Item($SheetName) 
	[void] $objWorksheet.Activate() 
	
	#### Delete First Rows
	$Range = $objWorksheet.Cells.Item($RowToDelete, 1).EntireRow
	$a = $Range.Delete()
	
	$objWorkbook.Save()
	$objExcel.Quit()

	$a = Release-Ref($objWorksheet) 
	$a = Release-Ref($objWorkbook) 
	$a = Release-Ref($objExcel)
}

#----------------------------------------------------- 
#----  Excel Rename a Worksheet
#----------------------------------------------------- 
function ExcelRenameWorksheet
{
	param
	(
	[string]$FileFullName
	,[string]$OldSheetName
	,[string]$NewSheetName
	)
	
	#### Instantiate Excel object
	$objExcel = new-object -comobject excel.application 
	$objExcel.Visible = $True 
	$objWorkbook = $objExcel.Workbooks.Open($FileFullName)
	
	#### Activate Sheet
	$objWorksheet = $objWorkbook.Worksheets.Item($OldSheetName) 
	[void] $objWorksheet.Activate() 
	
	### Rename Sheet
	$objWorksheet.Name = $NewSheetName
	
	$objWorkbook.Save()
	$objExcel.Quit()

	$a = Release-Ref($objWorksheet) 
	$a = Release-Ref($objWorkbook) 
	$a = Release-Ref($objExcel)
}

#----------------------------------------------------- 
#----  Excel Unfreeze Panes
#----------------------------------------------------- 
function ExcelUnfreezePanes
{
	param
	(
	[string]$FileFullName
	,[string]$SheetName
	)
	
	#### Instantiate Excel object
	$objExcel = new-object -comobject excel.application 
	$objExcel.Visible = $True 
	$objWorkbook = $objExcel.Workbooks.Open($FileFullName)
	
	#### Activate Sheet
	$objWorksheet = $objWorkbook.Worksheets.Item($SheetName) 
	[void] $objWorksheet.Activate() 
	
	#### UnfreezePanes
	$objExcel.ActiveWindow.FreezePanes = $false
	
	$objWorkbook.Save()
	$objExcel.Quit()

	$a = Release-Ref($objWorksheet) 
	$a = Release-Ref($objWorkbook) 
	$a = Release-Ref($objExcel)
}
