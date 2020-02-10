<#==========================================================
Description:
Return the connection string.

Parameters: (mandatory as starred*)
$serverName* is the DataSource for connection string like ("003D01.siepe.local")
$databaseName* is the Initial Catalog for connection string like ("Feeds")
$userID* is the user ID for connection string like ("datafeeds")
$password* is the Password for connection string ("Siepe2012")

Function Call:
$ConnectionString = Connection-String -ServerName $serverName -databaseName $databaseName -UseID $userID -Password $password
===========================================================#>

function Connection-String 
{ 	
	param($serverName,$databaseName,$userID,$password ) 
	
	#$connStr = "Data Source=003D01.siepe.local,52155;User ID=datafeeds;Initial Catalog=Feeds;Provider=SQLNCLI11.1;Persist Security Info=True;Auto Translate=False;Password=Siepe2012"
	$connStr = "Data Source="+ $serverName +";User ID="+ $userID +";Initial Catalog="+ $databaseName +";Provider=SQLNCLI11.1;Persist Security Info=True;Auto Translate=False;Password=" + $password
	
	return $connStr
	
}