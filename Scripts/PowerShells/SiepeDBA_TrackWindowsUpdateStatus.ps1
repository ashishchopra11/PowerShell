############## Reference to configuration files ###################################
CLS

$ConfigRootFOlder = $env:Powershell_ConfigRootLocation

Set-Location $ConfigRootFOlder
. .\fRefDataSetIU.ps1

####################################################################################


$body = ""
$a = "<style>"
$a = $a + " TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;width:100%}
		TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;font-family: Calibri; font-size: small; font-weight: bold;background-color: #D3D3D3;}
		TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;font-family: Calibri; font-size: small; }"
$a = $a + "</style>"

$Servers = "HCM05","HCMV07","HCMV14","HCMV02","HCMV09","HCMV11","HCMV12","HCMV13","HCMV16","HCM42-VM01","HCM40-VM14"
#$Servers = "HCMV07"
$WuList = Get-WUList -ComputerName $Servers

[string]$body = $WuList|Select-Object ComputerName,KB,Size,Title,Status,IsHidden,RebootRequired|ConvertTo-Html -Head $a
$RefDate = Get-Date -Format d
$dtDataSetDate = [datetime]::parseexact($RefDate,"M/d/yyyy",$null).ToShortDateString()

$RefDataSetID = fRefDataSetIU -rdsRefDataSetID 0 -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel "Windows Update" -rdsStatusCode "I" -rdsRefDataSetDate $dtDataSetDate -rdsserverName "PHCMDB01" -rdsdatabaseName "DataFeeds"

$DestConnection = "Data Source=PHCMDB01;Initial Catalog=SiepeAdmin;Trusted_Connection=True;"
$SqlConn = New-Object System.Data.SqlClient.SqlConnection($DestConnection)

$WuList|%{
	$Wupdate = $_
	$ComputerName	 =$Wupdate.ComputerName
	$KB              =$Wupdate.KB
	$Size            =$Wupdate.Size
	$Title           =$Wupdate.Title
	$Status          =$Wupdate.Status
	$IsHidden        =$Wupdate.IsHidden
	$RebootRequired  =$Wupdate.RebootRequired
	
	$SqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $SqlCommand.Connection = $SqlConn
    $SqlCommand.CommandText = "dbo.pWindowUpdateListIU"
    $SqlCommand.CommandType = "StoredProcedure"
    
	$SqlCommand.Parameters.AddWithValue("@ComputerName",$ComputerName)
	$SqlCommand.Parameters.AddWithValue("@KB",$KB)
	$SqlCommand.Parameters.AddWithValue("@Size",$Size)
	$SqlCommand.Parameters.AddWithValue("@Title",$Title)
	$SqlCommand.Parameters.AddWithValue("@Status",$Status)
	$SqlCommand.Parameters.AddWithValue("@IsHidden",$IsHidden)
	$SqlCommand.Parameters.AddWithValue("@RebootRequired",$RebootRequired)

    $SqlConn.Open()
    $SqlCommand.ExecuteNonQuery()
    $SqlConn.Close()
}

$smtpserver = "email-smtp.us-east-1.amazonaws.com"
# SES Credentials
$smtpUserName = "AKIAIUBARKKYHWSVB3TA"
$smtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force)
$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword))
$EmailFrom = "Highland@siepe.com"
$EmailTo = "rrutledge@siepe.com","all-offshore@siepe.com"
#$EmailTo = "rkari@siepe.com"
$subject = "Windows Update list"

Function Send-Mail{
[cmdletbinding()]
Param (
	[string[]]$To,
	[string]$From,
	[string]$SmtpServer = "email-smtp.us-east-1.amazonaws.com",
	[string]$SmtpUsername = "AKIAIUBARKKYHWSVB3TA",
	$SmtpPassword = (ConvertTo-SecureString 'AiPeU0cc7dk1jyXnZBDI8ElBMZIDuud7LM0ooiET4YzT' -AsPlainText -Force),
	[string]$Subject = "Subject",
	[string]$Body = "Body",
	$EmailTimeOut = 240,
	$Credential = (New-Object System.Management.Automation.PSCredential($smtpUserName, $smtpPassword)),
[bool]$asHtml =$true
) 
# End of Parameters
    try 
	{
    Send-MailMessage -SmtpServer $SmtpServer -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -Priority high -port 587 -UseSsl -credential $Credential
	$MailStatus = 1
	}
	Catch 
	{
	$MailStatus = 0
	}
return 	$MailStatus
}

$RefDataSetChech = Send-Mail -To $EmailTo -From $EmailFrom -SmtpServer $smtpserver -SmtpUsername $smtpUserName -SmtpPassword $smtpPassword -Subject $subject -Body $Body -EmailTimeOut $EmailTimeOut -Credential $Credential

IF ($RefDataSetChech -eq 0)
{
fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel "Windows Update" -rdsStatusCode "F" -rdsRefDataSetDate $dtDataSetDate -rdsserverName "PHCMDB01" -rdsdatabaseName "DataFeeds"
}
Else
{
fRefDataSetIU -rdsRefDataSetID $RefDataSetID -rdsRefDataSetType "Job Services" -rdsRefDataSource "Job Services" -rdsLabel "Windows Update" -rdsStatusCode "P" -rdsRefDataSetDate $dtDataSetDate -rdsserverName "PHCMDB01" -rdsdatabaseName "DataFeeds"
}