CLS 

$folder = "\\hcm97\PMPDatafeeds"
$server = "HCM97"
$threshold = 500


$smtpsettings = @{
	To = "sqldatafeeds@hcmlp.com"
	From = "sqldatafeeds@hcmlp.com"
	SmtpServer = "mail.hcmlp.com"
	Subject = "HCM97: PMPDataFeeds Large Folders List"
}

$htmlhead = "<html>
				<style>
				BODY{font-family: Arial; font-size: 8pt;}
				H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				TABLE{border: 1px solid black; border-collapse: collapse; font-size: 12pt;}
				TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
				TD{border: 1px solid #969595; padding: 5px; }
				td.pass{background: #B7EB83;}
				td.warn{background: #FFF275;}
				td.fail{background: #FF2626; color: #ffffff;}
				td.info{background: #85D4FF;}
				</style>
				<body>
                <H1>Server: $server</H1>
                <H1>Large Folder Report: (>500 MB)</H1>"

$htmltail = "</body></html>"



$array= @() 
 
Get-ChildItem $folder | Where-Object { $_.PSIsContainer } | 
ForEach-Object { 
    $obj = New-Object PSObject  
        
    $SizeSort = [Math]::Round((Get-ChildItem -Recurse $_.FullName | Measure-Object Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB, 2) 
    $Size = "{0:N2}" -f $SizeSort 
	
	$obj |Add-Member -MemberType NoteProperty -Name "Path" $_.FullName     
    $obj |Add-Member -MemberType NoteProperty -Name "SizeMB" $Size 
    $obj |Add-Member -MemberType NoteProperty -Name "SizeMBSort" $SizeSort
    $array +=$obj 
    } 


$html = $array | Where-Object {$_.SizeMBSort -gt $threshold} | Sort-Object -Property SizeMBSort -Descending | select Path,SizeMB | ConvertTo-Html -Fragment

$body = $htmlhead + $html + $htmltail

Send-MailMessage @smtpsettings -body $body -BodyAsHtml


$array | Where-Object {$_.SizeMBSort -gt $threshold} | Sort-Object -Property SizeMBSort -Descending | select Path,SizeMBSort

$strDateNow = get-date -format "yyyy-MM-dd HH:mm:ss"

$insert = @'
	INSERT INTO SiepeAdmin.dbo.tPMPDataFeedsFolders (RunDate,Path,SizeMB)
	VALUES ('{0}','{1}','{2}')
'@
 
	$connectionString = 'Data Source=PHCMDB01;Initial Catalog=SiepeAdmin;Integrated Security=SSPI'
	$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
	$conn.Open()
	$cmd = $conn.CreateCommand()

	$array | Where-Object {$_.SizeMBSort -gt $threshold} | Sort-Object -Property SizeMBSort -Descending | select Path,SizeMBSort |`
		ForEach-Object{
			$cmd.CommandText = $insert -f $strDateNow, $_.Path, $_.SizeMBSort
			$cmd.ExecuteNonQuery()
	}
    #Close the connection
	$conn.Close()