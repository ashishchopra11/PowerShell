CLS
function Get-ExcelData {
    [CmdletBinding(DefaultParameterSetName='Worksheet')]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [String] $Path,

        [Parameter(Position=1, ParameterSetName='Worksheet')]
        [String] $WorksheetName = 'Sheet1',

        [Parameter(Position=1, ParameterSetName='Query')]
        [String] $Query = 'SELECT * FROM [Sheet1$]',
		
		[Parameter(Position=1, ParameterSetName='SheetIndex')]
        [Int] $SheetIndex = -1,
		
		[Parameter(Position=1, ParameterSetName='Worksheet_Like')]
        [String] $Worksheet_Like = 'Sheet1*',
		
		[ref]$DataTable,
		[ref]$SheetName
    )
	
    if ((Get-Item -Path $Path).Extension -eq 'xls') {
	    $Provider = 'Microsoft.Jet.OLEDB.4.0'
		
	    $ExtendedProperties = 'Excel 8.0;HDR=NO;IMEX=1'
	} else {
	    $Provider = 'Microsoft.ACE.OLEDB.12.0'
	    $ExtendedProperties = 'Excel 12.0;HDR=NO'
	}
	
	
	
	# Build the connection string and connection object
	$ConnectionString = 'Provider={0};Data Source={1};Extended Properties="{2}"' -f $Provider, $Path, $ExtendedProperties
	#$ConnectionString = 'OLEDB;Provider={0};Data Source={1};Extended Properties="{2}"' -f $Provider, $Path, $ExtendedProperties
	$Connection = New-Object System.Data.OleDb.OleDbConnection $ConnectionString

	#$pscmdlet.ParameterSetName
	switch ($pscmdlet.ParameterSetName) {
        'Worksheet' {
            $Query = 'SELECT * FROM [{0}$]' -f $WorksheetName
            break
        }
        'Query'	{
            # Make sure the query is in the correct syntax (e.g. 'SELECT * FROM [SheetName$]')
            $Pattern = '.*from\b\s*(?<Table>\w+).*'
            if($Query -match $Pattern) {
                $Query = $Query -replace $Matches.Table, ('[{0}$]' -f $Matches.Table)
				break
            }
        }
		'SheetIndex'{
	        # Open connection with the database.
	        $Connection.Open()
	        # Get the data table containg the schema guid
	        $ExcelSheets = $Connection.GetOleDbSchemaTable([System.Data.OleDb.OleDbSchemaGuid]::Tables,$null); ;
			$Connection.Close()
 
			If(($ExcelSheets.Rows.Count-1) -ge 0) {
				$WorksheetName = $ExcelSheets.Rows[$SheetIndex].TABLE_NAME
				if($SheetName.GetType -ne $null)
				{
					$SheetName.Value = $WorksheetName.Replace("$","")
				}
				$Query = 'SELECT * FROM [{0}]' -f $WorksheetName
			}
			else {
				Write-Error "No sheet exists at SheetIndex $SheetIndex"
				return
			}
			break
		}
		'Worksheet_Like'{
			$Connection.Open()
	        # Get the data table containg the schema guid
	        $ExcelSheets = $Connection.GetOleDbSchemaTable([System.Data.OleDb.OleDbSchemaGuid]::Tables,$null); ;
			$Connection.Close()
			$Worksheet_Like = "'$Worksheet_Like'"
			$Ctr = 1
			$MatchFound = 0
			$Cnt = $ExcelSheets.Rows.Count
			while($Ctr -le  $Cnt)
			{
				$WorksheetName = $ExcelSheets.Rows[$Ctr].TABLE_NAME
				if($WorksheetName -ilike $Worksheet_Like)
				{
					$Query = 'SELECT * FROM [{0}]' -f $WorksheetName
										
					if($SheetName.GetType -ne $null)
					{
					$SheetName.Value = $($WorksheetName.Replace("$","")).Replace("'",'')
					}
                    $MatchFound++
				}
				$Ctr++
			}
			
			if ($MatchFound -gt 1)
			{
				Write-Error "Multiple sheets exists for Sheetname $Worksheet_Like"
				return	
			}
		}
    }
	
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

<#
$Path = "C:\Siepe\DataFeeds\BNP\Client Stmt Contact_HAYMAN CAPITAL MF LP.xls"
$ExcelData = New-Object System.Data.DataTable
Get-ExcelData -Path $Path -SheetIndex 1 -DataTable ([ref]$ExcelData)

$ExcelData#>