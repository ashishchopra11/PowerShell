CLS  
FUNCTION fSSISExitCode()
{
    param 
    (
     [int]$ExitCode=$null
	 ,[string]$ExitMessage
	)	
	$tabName = "ExitCodeList"

	#Create Table object
	$table = New-Object system.Data.DataTable “$tabName"

	#Define Columns
	$col1 = New-Object system.Data.DataColumn Code,([string])
	$col2 = New-Object system.Data.DataColumn Message,([string])

	#Add the Columns
	$table.columns.add($col1)
	$table.columns.add($col2)

	#Create a row
	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "0"
	$row["Message"] = "The package executed successfully."
	$table.Rows.Add($row)

	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "1"
	$row["Message"] = "The package failed"
	$table.Rows.Add($row)

	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "3"
	$row["Message"] = "The package was canceled by the user."
	$table.Rows.Add($row)

	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "4"
	$row["Message"] = "The utility was unable to locate the requested package. The package could not be found."
	$table.Rows.Add($row)

	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "5"
	$row["Message"] = "The utility was unable to load the requested package. The package could not be loaded."
	$table.Rows.Add($row)

	$row = $table.NewRow()
	#Enter data in the row
	$row["Code"] = "6"
	$row["Message"] = "The utility encountered an internal error of syntactic or semantic errors in the command line."
	$table.Rows.Add($row)
	 
	#Display the table
	#$table | format-table -AutoSize 
	 
	$ExitMessageRow  = $table.Select( )| Where-Object{$_.Code -eq $ExitCode};
	$ExitMessage =  $ExitMessageRow.Message
	Return $ExitMessage
	 
} 
<#
	0 	The package executed successfully.
	1 	The package failed.
	3 	The package was canceled by the user.
	4 	The utility was unable to locate the requested package. The package could not be found.
	5 	The utility was unable to load the requested package. The package could not be loaded.
	6 	The utility encountered an internal error of syntactic or semantic errors in the command line.
#>