CLS


# Configuration data. 
# Add your machine names to check for to the list: 
#[String[]] $servers   = @("phcmdb01" `
[String[]] $servers   = @("HCMV07"); 
[float]  $levelWarn   = 20.0; 
[float]  $levelAlarm  = 10.0; 
[string] $smtpServer  = "mail.hcmlp.com"; 
[string] $sender      = "sqldatafeeds@hcmlp.com"; 
[string] $receiver    = "All-highland@siepe.com";  
#[string] $receiver    = "hgupta@siepe.com";  
[string] $subject     = "HCMV07:Disk Usage With Large Folders List"; 
[bool]   $asHtml      = $true; 
 
[string] $body = [String]::Empty; 
 
if ($asHtml) 
{ 
    $body += "<head><title>Disk usage report</title> <style>
              .table {border-collapse: collapse;  border: 1px solid #808080;} 
              .paragraph  {font-family: Arial;font-size:large;text-align: left;border} 
              .boldLeft   {font-family: Arial;font-size:large;text-align: left;border: 1px solid #808080;} 
              .boldRight  {font-family: Arial;font-size:large;text-align: right;border: 1px solid #808080;} 
              .smallLeft  {font-family: Arial;text-align: left;border: 1px solid #808080;} 
              .smallRight {font-family: Arial;text-align: right;border: 1px solid #808080;} 
			  </style>
              </head><body>"; 
} 
else 
{ 
    $body += "Disk usage report`n`n"; 
} 
 
Clear-Host; 
Write-Host "Started"; 
### Functions. 
function getTextTableHeader 
{ 
    [String] $textHeader = [String]::Empty; 
    $textHeader += "Drive "; 
    $textHeader += "Vol Name        "; 
    $textHeader += "     Size MB "; 
    $textHeader += "     Free MB "; 
    $textHeader += "    Free % "; 
    $textHeader += "Message      `n"; 
    $textHeader += "--- "; 
    $textHeader += "--------------- "; 
    $textHeader += "------------ "; 
    $textHeader += "------------ "; 
    $textHeader += "---------- "; 
    $textHeader += "------------ `n"; 
     
    return $textHeader; 
} 

function getTextTableHeaderLargeFolder 
{ 
    [String] $textHeader = [String]::Empty; 
    $textHeader += "Folder Location        "; 
    $textHeader += "Size (in MB)"; 
    $textHeader += "--- "; 
    $textHeader += "--------------- ";  
     
    return $textHeader; 
} 
 
 
function getTextTableRow 
{ 
    param([object[]] $rowData) 
    [String] $textRow = [String]::Empty; 
 
    $textRow += $rowData[0].ToString().PadRight(4); 
    $textRow += $rowData[1].ToString().PadRight(16); 
    $textRow += $rowData[2].ToString("N0").PadLeft(12) + " "; 
    $textRow += $rowData[3].ToString("N0").PadLeft(12) + " "; 
    $textRow += $rowData[4].ToString("N1").PadLeft(10) + " "; 
    $textRow += $rowData[5].ToString().PadRight(13); 
    return $textRow; 
} 

function getTextTableRowLargeFolder 
{ 
    param([object[]] $rowData) 
    [String] $textRow = [String]::Empty; 
 
    $textRow += $rowData[0].ToString().PadRight(16); 
    $textRow += $rowData[1].ToString().PadRight(4); 
    return $textRow; 
} 

function getHtmlTableHeader
{ 
    [String] $header = [String]::Empty; 
    $header += "<table style=""width: 100%"" class=""table""><tr class=""boldLeft""> 
                <th class=""boldLeft"">Drive</th> 
                <th class=""boldLeft"">Vol Name</th> 
                <th class=""boldRight"">Size MB</th> 
                <th class=""boldRight"">Free MB</th> 
                <th class=""boldRight"">Free %</th> 
                <th class=""boldLeft"">Message</th></tr>"; 
    return $header; 
} 

function getHtmlTableHeaderLargeFolder
{ 
    [String] $header = [String]::Empty; 
    $header += "<table style=""width: 50%"" class=""table""><tr class=""boldLeft""> 
                <th class=""boldLeft"">Folder Location</th> 
                <th class=""boldRight"">Size (in MB)</th></tr>"; 
    return $header; 
} 
 
function getHtmlTableRow 
{ 
    param([object[]] $rowData) 
    [String] $textRow = [String]::Empty; 
    $textRow += "<tr class=""smallLeft""> 
        <td class=""smallLeft"">"  + $rowData[0].ToString()     + "</td> 
        <td class=""smallLeft"">"  + $rowData[1].ToString()     + "</td> 
        <td class=""smallRight"">" + $rowData[2].ToString("N0") + "</td> 
        <td class=""smallRight"">" + $rowData[3].ToString("N0") + "</td> 
        <td class=""smallRight"">" + $rowData[4].ToString("N1") + "</td> 
        <td class=""smallLeft"">"  + $rowData[5].ToString()     + "</td></tr>"; 
    return $textRow; 
} 

function getHtmlTableRowLargeFolder
{ 
    param([object[]] $rowData) 
    [String] $textRow = [String]::Empty; 
    $textRow += "<tr class=""smallLeft""> 
        <td class=""smallLeft"">"  + $rowData[0].ToString()     + "</td> 
        <td class=""smallRight"">"  + $rowData[1].ToString()     + "</td></tr>"; 
    return $textRow; 
} 
 
$strEmail = " "
 
foreach($server in $servers) 
{ 
    $disks = Get-WmiObject -ComputerName $server -Class Win32_LogicalDisk -Filter "DriveType = 3"; 
 
    if ($asHtml) 
    {   $body += ("<p class=""paragraph""><b>Server: {0}`t</b><br><br>Drives #: {1}</p>`n" -f $server, $disks.Count); 
         $body += getHtmlTableHeader; 
    } 
    else 
    {    $body += ("Server: {0}`tDrives #: {1}`n" -f $server, $disks.Count); 
        $body += getTextTableHeader; 
    } 
 
    foreach ($disk in $disks) 
    { 
        [String] $message = [String]::Empty; 
		
        if (100.0 * $disk.FreeSpace / $disk.Size -le $levelAlarm) 
        {   $message = "Alarm !!!";  
		    $sender = "help@siepe.com"
            $receiver = "help@siepe.com"

} 
        elseif (100.0 * $disk.FreeSpace / $disk.Size -le $levelWarn) 
        {   $message = "Warning !"; 
		    $sender = "help@siepe.com"
            $receiver = "highland@siepe.com" 
			#$receiver = "ssengar@siepe.com"

		} 
         
        [Object[]] $data = @($disk.DeviceID, `
                             $disk.VolumeName, `
                             [Math]::Round(($disk.Size / 1048576), 0), `
                             [Math]::Round(($disk.FreeSpace / 1048576), 0), `
                             [Math]::Round((100.0 * $disk.FreeSpace / $disk.Size), 1), `
                             $message) 
        if ($asHtml) 
        {    $body += getHtmlTableRow -rowData $data;    } 
        else 
        {    $body += getTextTableRow -rowData $data;    } 
         
        $body += "`n"; 
    } 
     
    if ($asHtml) 
    {   $body += "</table><br><br>`n";    } 
    else 
    {    $body += "`n";    } 
	
    
	## Code to get all folders larget than 500 MB
     if ($asHtml) 
    {   $body += ("<p class=""paragraph"">Large Folder Report: (>500 MB)</p>`n" -f $server); 
         $body += getHtmlTableHeaderLargeFolder; 
    } 
    else 
    {    $body += ("Large Folder Report: (>500 MB)`n" -f $server, $disks.Count); 
        $body += getHtmlTableHeaderLargeFolder; 
    } 
    
	foreach ($disk in $disks) 
    {	
    $disk.DeviceID
        if($disk.DeviceID -NotLike "E*")
        {
		  $computer = $server
		  $startFolder = $disk.DeviceID  ###<<<---  Change this to folder you want to monitor
		  $intSize = 500 ###<<<---  Change this to size threshold
		  $colItems = (  Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Where-Object {$_.GetFiles().Count -gt 0} )
    	    
        if ($startFolder.sum / 1MB -gt $intSize) 
            #{$strEmail = $strEmail + "{0:N2}" -f ($startFolder.sum / 1MB) + " MB" +" -- " + $startFolder.FullName +"`n"+"<br>" }  
            {
                        [Object[]] $data1 = @($i.FullName, `
                                ($subFolderItems.sum / 1MB)) 
                                 
                        if ($asHtml) 
                        {    $body += getHtmlTableRowLargeFolder -rowData $data1;    } 
                        else 
                        {    $body += getTextTableRowLargeFolder -rowData $data1;    } 
                        
                        $body += "`n"; 
            }
        
		  foreach ($i in $colItems)
	       {
            	$subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
        	   if ($subFolderItems.sum / 1MB -gt $intSize) 
    				#{$strEmail = $strEmail + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB" +" -- " + $i.FullName +"`n"+"<br>" }
                    {
                        [Object[]] $data1 = @($i.FullName, `
                                [Math]::Round($subFolderItems.sum / 1MB,2)) 
                                 
                        if ($asHtml) 
                        {    $body += getHtmlTableRowLargeFolder -rowData $data1;    } 
                        else 
                        {    $body += getTextTableRowLargeFolder -rowData $data1;    } 
                        
                        $body += "`n"; 
                    }
	       }
         }
	}
    
     if ($asHtml) 
    {   $body += "</table><br><br>`n";    } 
    else 
    {    $body += "`n";    } 
	
	#$body = $body + "<p class=""paragraph"">Large Folder Report: (>500 MB)</p>`n" + $strEmail
} 
 


if ($asHtml) 
{   $body += "</body>";    } 
 
#$body
#write-output $body | out-file "C:\HCM\Scripts\test.html"


#Init Mail address objects 
$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 

If($message -match "Alarm")
{


$body = $body+"<br>
<br>
<p><h6>Job which is kicking off this report:: RSID : 3112; Name :<a href=""http://admintools.hcmlp.com/ReportSubscription"">HCMV07:Disk Usage With Large Folders List</a> <br> 
"+"<br>!!Contact:defaultcontact@hcmlp.com!! "

		""
$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
$mailMsg.CC.Add("highland@siepe.com")

}
else
{
$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body); 
}

$smtpClient.UseDefaultCredentials = $false
$smtpClient.Credentials = New-Object System.Net.NetworkCredential("Relay.Account", "R3layacct");

$mailMsg.IsBodyHtml = $asHtml; 
$smtpClient.Send($mailMsg)

Write-Host "Finished";

