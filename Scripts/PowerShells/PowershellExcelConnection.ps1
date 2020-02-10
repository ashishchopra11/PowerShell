 ############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\DirLocations.Config.ps1
 
 
$path = $dirScriptsFolder  
 
$pattern = "excel.application"
$pattern1 = "Get-ExcelData"
$pattern2 = "ExcelFunctions" 

[string] $body = [String]::Empty; 

$body = "<html>
				<head>
					<style type=""text/css"">
					.style H1
					{
						font-size: 15px;
						font-weight: bold;
						font-family: calibri;
					}
					.style table
					{
						border-collapse: collapse;
						border-spacing: 0;
						width: 100%;
						margin: 0px;
						padding: 0px;
					}
					.style p
			        {
			            font-size: 20px;
			            font-family: calibri;
			            font-weight: bold;
			            border-bottom: 3px solid #3B3131;
			        }
					.style tr:hover th
					{
						background-color: #c9c1c1;
					}
					.style th
					{
						vertical-align: middle;
						border: 1px solid #000000;
						border-width: 0px 1px 1px 0px;
						text-align: left;
						padding: 7px;
						font-size: 17px;
						font-weight: bold;
						font-family: calibri;
						border-width: 0px 1px 0px 0px;
						border: 1px solid #000000;
						background-color: #cccccc;
					}
					.style td
					{
						vertical-align: middle;
						border: 1px solid #000000;
						border-width: 0px 1px 1px 0px;
						padding: 7px;
						font-size: 15px;
						font-family: calibri;
						font-weight: normal;
						border-width: 0px 1px 0px 0px;
						border: 1px solid #000000;
					}
					.update
					{
					     font-family: Calibri; font-size: 15px; font-weight: normal;
                            width: inherit;
                    }
				</style>
			</head>
			<body><div class=""style"">"
			
 $tableHeader = "<table><tr>
 				<th>File Name</th>
				<th>Line Number</th>
				<th>Line Text</th>
				<th>Modified Date</th>
				</tr>"


   $body  = $body +$tableHeader
 $Scripts = Get-ChildItem -recurse -Path $path | Select-String -pattern $pattern,$pattern1,$pattern2  
 
 Foreach($PSFile in $Scripts)
 {
 	if($PSFile.Path -notlike "*\Monitor\*" -and $PSFile.Path -notlike "*\Configurations\*" -and $PSFile.Path -notlike "*\SourceControl\*" -and $PSFile.Path -notlike "*\PROD\ExcelFunctions.ps1*" -and $PSFile.Path -notlike "*\PROD\Get-ExcelData.ps1*" -and $PSFile.Path -notlike "*\PROD\fGet-ExcelData.ps1*" -and $PSFile.Path -notlike "*\PROD\ExcelDataSheetIndex.ps1*"  -and $PSFile.Path -notlike "*\PROD\RegressionTests-*" -and $PSFile.Path -notlike "*\PROD\CheckExcelConnection* -and $PSFile.Path -notlike "*\PROD\PowershellExcelConnection*"	)
	 {
	 	if($PSFile.Line -notlike "*#*" -and $PSFile.Line -notlike "*<#*")
		{
		 	 $LastRun = $((Get-Item $PSFile.Path).LastWriteTime).ToString();
			  [String] $tableData = ""
				$tableData ="<tr "+$rowbgColor+"> 
			    <td>"+$PSFile.Path+"</td>
			    <td>"+$PSFile.LineNumber +"</td>
			    <td>"+$PSFile.Line +"</td>
			    <td>"+ $LastRun +"</td></tr>"
			
			$body = $body + $tableData
		}
	}
	 
} 
   $body = $body+"</table>"
$body = $body + "</div></body></html>"

$body 

#Write-Output $body | Out-File "D:\MailBody.html"

$Getdate = Get-Date -Format "dd-MMM-yyyy"

[string] $smtpServer  = "mail.hcmlp.com"; 
[string] $sender      = "sqldatafeeds@hcmlp.com"; 

[string] $receiver    = "All-Highland@siepe.com"
[string] $subject     = "PHCMJOB08 | Powershell scripts using excel connection"; 
[bool]   $asHtml      = $true;

$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 

$smtpClient.UseDefaultCredentials = $false
$smtpClient.Credentials = New-Object System.Net.NetworkCredential("Relay.Account", "R3layacct");

#"All-Highland <All-Highland@siepe.com>";
$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
$mailMsg.IsBodyHtml = $asHtml; 
$smtpClient.Send($mailMsg)

Write-Host "Finished";