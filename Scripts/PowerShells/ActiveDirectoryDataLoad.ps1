CLS


$Server     = "PHCMDB01"

$SQLCommand = "SELECT UserName FROM SiepeAdmin.ActiveDirectory.tUser WHERE RefRecStatusID = 1"
$Userlist   =  Invoke-Sqlcmd -ServerInstance $Server -Query $SQLCommand


foreach($User in $Userlist)
{
    
    $i = 0
    $array   = net user $User.UserName /domain 
    $count   = $array.count
    
    $Text=""

    while($i -lt $count) 
    {
        $Text = $Text + "|" +$array[$i];
        $i++
    }

    $Text = $Text -replace "'", "''"

    $SQLCommand = "EXEC SiepeAdmin.ActiveDirectory.pUserDetailGroupI @InputText = '"+$Text+"'"
    Invoke-Sqlcmd -ServerInstance $Server -Query $SQLCommand
    
}
