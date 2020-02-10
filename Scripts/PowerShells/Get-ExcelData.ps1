function Get-ExcelData {
    [CmdletBinding(DefaultParameterSetName='Worksheet')]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [String] $Path,

        [Parameter(Position=1, ParameterSetName='Worksheet')]
        [String] $WorksheetName = 'Sheet1',

        [Parameter(Position=1, ParameterSetName='Query')]
        [String] $Query = 'SELECT * FROM [Sheet1$]',		
		
		[ref]$DataTable
    )

    switch ($pscmdlet.ParameterSetName) {
        'Worksheet' {
            $Query = 'SELECT * FROM [{0}$]' -f $WorksheetName
            break
        }
        'Query' {
            # Make sure the query is in the correct syntax (e.g. 'SELECT * FROM [SheetName$]')
            $Pattern = '.*from\b\s*(?<Table>\w+).*'
            if($Query -match $Pattern) {
                $Query = $Query -replace $Matches.Table, ('[{0}$]' -f $Matches.Table)
            }
        }
    }

	if ((Get-Item -Path $Path).Extension -eq 'xls') {
	    $Provider = 'Microsoft.Jet.OLEDB.4.0'
		
	    $ExtendedProperties = 'Excel 8.0;HDR=YES;IMEX=1'
	} else {
	    $Provider = 'Microsoft.ACE.OLEDB.12.0'
	    $ExtendedProperties = 'Excel 12.0;HDR=YES'
	}

	# Build the connection string and connection object
	$ConnectionString = 'Provider={0};Data Source="{1}";Extended Properties="{2}"' -f $Provider, $Path, $ExtendedProperties
	#$ConnectionString = 'OLEDB;Provider={0};Data Source={1};Extended Properties="{2}"' -f $Provider, $Path, $ExtendedProperties
	$Connection = New-Object System.Data.OleDb.OleDbConnection $ConnectionString

	try {
	    # Open the connection to the file, and fill the datatable
	    $Connection.Open()
	    $Adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $Query, $Connection
	    #$DataTable = New-Object System.Data.DataTable
	    $Adapter.Fill($DataTable.Value) | Out-Null
	}
	catch {
	    # something went wrong 🙁
	    Write-Error $_.Exception.Message
	}

	finally {
	    # Close the connection
	    if ($Connection.State -eq 'Open') {
	        $Connection.Close()
	    }
	}
	#return $DataTable
}