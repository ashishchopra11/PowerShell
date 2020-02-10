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
#----  Excel Remove Borrow Rows
#----------------------------------------------------- 
function ExcelRemoveBorrow
{
	param
	(
	[string]$FileFullName
	,[string]$SheetName
	,[string]$ColumnName1
	,[string]$ColumnName2	
	,[string]$ColumnName3		
	,[string]$ColumnName4
	,[string]$ColumnName5		
	,[string]$ColumnName6	
	,[string]$ColumnName7	
	)
	
	#### Instantiate Excel object
	$objExcel = new-object -comobject excel.application 
	$objExcel.Visible = $True 
	$objWorkbook = $objExcel.Workbooks.Open($FileFullName)
	
	#### Activate Sheet
	$objWorksheet = $objWorkbook.Worksheets.Item($SheetName) 
	[void] $objWorksheet.Activate() 

#	Write-Output $objWorksheet
#	Write-Output $ColumnName
#	Write-Output $objRange
#	Write-Output $objWorksheet
#	Write-Output $a
#	Write-Output $i	

	$i = 1 
	$l = 100
	Do { 
    If ($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName1) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName2) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName3) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName4) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName5) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 2).Value() -contains $ColumnName6) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}
	ElseIf 	
		($objWorksheet.Cells.Item($i, 1).Value() -contains $ColumnName7) { 
        $objRange = $objWorksheet.Cells.Item($i, 1).EntireRow 
        $a = $objRange.Delete() 
        $i -= 1 
		$i -le $l
    	}		
		
    $i += 1 
		} 
	#While ($objWorksheet.Cells.Item($i,1).Value() -ne "" -and $objWorksheet.Cells.Item($i,2).Value() -ne "" -and $i -le $l) 
	While ($i -le $l)	
	
	$objWorkbook.Save()
	$objExcel.Quit()

	$a = Release-Ref($objWorksheet) 
	$a = Release-Ref($objWorkbook) 
	$a = Release-Ref($objExcel)
}