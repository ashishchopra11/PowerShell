CLS
$ServiceLists = @( 	,("HCMV14", "Siepe Notification Service")
					,("HCMV14", "Siepe WsoAdapter Service")
					,("HCMV07","Siepe Script Adapter Service")
					,("PWSODB01","MSSQLSERVER")
					,("PWSODB01","SQLSERVERAGENT")
					,("PWSODB01","MSSQLLaunchpad")
#					,("PWSODB01","C:Program Files:Xpressfeed Loader V5")
					,("PHCMDB01","MSSQLSERVER")
					,("PHCMDB01","SQLSERVERAGENT")
					,("PHCMDB01","SQLSentryServer")
					,("PHCMDB01","MSSQLLaunchpad")
					
)

$ServicesNotRunning = ""

$isStopped = $false
$isStillStoppedAfterTryRestart = $false

$TableHeader = "<tr><th>Server</th>
<th>Service Name</th>
<th>Initial Status</th>
<th>Current Status</th></tr>
"
$TableData = ""
foreach($ServiceList in $ServiceLists)
{	
	$Status = ""
	[String]$Server = $ServiceList[0]
	[String]$Service = 	$ServiceList[1]
	$Status = (Get-Service -Name $Service -ComputerName $Server|Select Status)
	$State = $Status.Status
	
	$TableData = $TableData +"<tr><td>$Server</td><td>$Service</td><td>$State</td>"
	#$State = "Stopped"
	IF($State -ne "Running")
	{
		$isStopped = $true
		Get-Service -Name $Service -ComputerName $Server|Set-Service -Status Running
		$Status = (Get-Service -Name $Service -ComputerName $Server|Select Status)
		$NewState = $Status.Status
		#$ServicesNotRunning = $ServicesNotRunning + $Server+"."+$Service+"<br>"
		$TableData = $TableData + "<td>$NewState</td>"
		IF($NewState -ne "Running")
		{
			$isStillStoppedAfterTryRestart = $true
		}
	}
	Else
	{
		$TableData = $TableData + "<td>$State</td>"
	}
	$TableData  = $TableData + "</tr>"
	#Write-Host "Status of $Service service at $Server is $State"
}
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

#$Body = "<font face=""Calibri"" color=""Black"" size=""3"">"
$Body = $Body + "<p><b>Service's Status</b></p><table>"

#$Body = $Body + $TableHeader+$TableData + "</table></div></body>"

$Body = $Body + $TableHeader+$TableData + "</table></div></body>
<br>
<br>
<p><h6>Job which is kicking off this report:: RSID : 3103; Name :<a href=""http://admintools.hcmlp.com/ReportSubscription"">DBA - Check Service and mail status</a> <br> 
"+"<br>!!Contact:defaultcontact@hcmlp.com!! "

		""
		
[string] $smtpServer  = "mail.hcmlp.com"; 
[string] $sender      = "sqldatafeeds@hcmlp.com"; 

[string] $receiver    = "All-Offshore@siepe.com"
#[string] $receiver    = "blevalley@siepe.com"
[string] $subject     = "Highland:Services Status"; 
[bool]   $asHtml      = $true;

$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 

$smtpClient.UseDefaultCredentials = $false
$smtpClient.Credentials = New-Object System.Net.NetworkCredential("Relay.Account", "R3layacct");

#"All-Highland <All-Highland@siepe.com>";
$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
if($isStopped -eq $true -and $isStillStoppedAfterTryRestart -eq $true)
{
	[string] $sender      = "help@siepe.com"; 
	[string] $receiver    = "help@siepe.com";
	$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
	$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 
	
	$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
	$mailMsg.cc.Add("Highland@siepe.com")
	$mailMsg.Priority = [System.Net.Mail.MailPriority]::High
	$mailMsg.IsBodyHtml = $asHtml; 
	$smtpClient.Send($mailMsg) | Out-File "D:\Siepe\Data\Logs\monitoring.txt"
}
elseif($isStopped -eq $true -and $isStillStoppedAfterTryRestart -eq $false)
{	
	[string] $sender      = "help@siepe.com"; 
	[string] $receiver    = "all-offshore@siepe.com";
	$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
	$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 
	
	$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
	$mailMsg.Priority = [System.Net.Mail.MailPriority]::High
	$mailMsg.IsBodyHtml = $asHtml; 
	$smtpClient.Send($mailMsg) | Out-File "D:\Siepe\Data\Logs\monitoring.txt"
}
else
{
	$mailMsg.Priority = [System.Net.Mail.MailPriority]::Low
	$mailMsg.IsBodyHtml = $asHtml; 
	## Send mail based on time
    $CurrentTime = Get-Date
    $Hour = $CurrentTime.Hour
    $Minute = $CurrentTime.Minute
    [Int[]]$MailRequireHours = 0;
    If($Hour -in $MailRequireHours -and $Minute -ge 0 -and $Minute -le 4 ){
    	$smtpClient.Send($mailMsg)  | Out-File "D:\Siepe\Data\Logs\monitoring.txt"
     }
}
Write-Host "Finished";
