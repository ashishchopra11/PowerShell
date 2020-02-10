FUNCTION fRefDataSetIU 
{
    param 
    (
     [int]$rdsRefDataSetID=0
    ,[string]$rdsRefDataSetType
    ,[string]$rdsRefDataSource
    ,[string]$rdsLabel
    ,[string]$rdsStatusCode
    ,[string]$rdsRefDataSetDate
    ,[string]$rdsserverName="PHCMDB01"
    ,[string]$rdsdatabaseName="datafeeds"

    )
#    [string]$rdsquery="pRefDataSetIU" 
#    
#    $rdsserverName="PHCMDB01"
#    $rdsdatabaseName="datafeeds"
#    $rdsquery="pRefDataSetIU" 
#    $rdsRefDataSetID= 0
#    $rdsRefDataSetType="WSOExtract"
#    $rdsRefDataSource="WSOWeb"
#    $rdsLabel="DB Restore"
#    $rdsStatusCode="I"
#    $rdsRefDataSetDate=Get-Date "2011-10-18"
 
    $rdsquery="pRefDataSetIU"
    
    $rdsconnString = "Server=$rdsserverName;Database=$rdsdatabaseName;Integrated Security=SSPI;" 
    $rdsconn = new-object System.Data.SqlClient.SqlConnection $rdsconnString 
    $rdsconn.Open() 
    $rdscmd = new-object System.Data.SqlClient.SqlCommand("$rdsquery", $rdsconn) 

    $rdscmd.CommandType = [System.Data.CommandType]"StoredProcedure" 

    $rdscmd.Parameters.Add("@RefDataSetID", [System.Data.SqlDbType]"Int") | Out-Null
    $rdscmd.Parameters["@RefDataSetID"].Value = $rdsRefDataSetID 
    $rdscmd.Parameters.Add("@RefDataSetType", [System.Data.SqlDbType]"varchar", 100)  | Out-Null
    $rdscmd.Parameters["@RefDataSetType"].Value = $rdsRefDataSetType 
    $rdscmd.Parameters.Add("@RefDataSource", [System.Data.SqlDbType]"varchar", 100)  | Out-Null
    $rdscmd.Parameters["@RefDataSource"].Value = $rdsRefDataSource 
    $rdscmd.Parameters.Add("@Label", [System.Data.SqlDbType]"varchar", 100)  | Out-Null
    $rdscmd.Parameters["@Label"].Value = $rdsLabel 
    $rdscmd.Parameters.Add("@StatusCode", [System.Data.SqlDbType]"NChar", 15)  | Out-Null
    $rdscmd.Parameters["@StatusCode"].Value = $rdsStatusCode 
    $rdscmd.Parameters.Add("@RefDataSetDate", [System.Data.SqlDbType]"datetime")  | Out-Null
    $rdscmd.Parameters["@RefDataSetDate"].Value = $rdsRefDataSetDate 

    $rdscmd.Parameters.Add("@RowCount", [System.Data.SqlDbType]"Int")  | Out-Null
    $rdscmd.Parameters["@RowCount"].Direction = [System.Data.ParameterDirection]"ReturnValue" 
 
    $rdscmd.ExecuteNonQuery()  | Out-Null
    $rdsconn.Close() 

#    Write-Output "@Rowcount"
	Return $rdscmd.Parameters["@RowCount"].Value 
	
    
#    $rdscmd.Parameters["@RefDataSetID"].Value 
#    $rdscmd.Parameters["@RefDataSetType"].Value 
#    $rdscmd.Parameters["@RefDataSource"].Value 
#    $rdscmd.Parameters["@Label"].Value  
#    $rdscmd.Parameters["@StatusCode"].Value 
#    $rdscmd.Parameters["@RefDataSetDate"].Value 
#    $rdsserverName
#    $rdsdatabaseName

}

#$RefDataSetID= 0
#$RefDataSetID=fRefDataSetIU 0 "WSOExtract" "WSOWeb" "DB Restore" "I" "2011-10-18" "PHCMDB01"
#Write-Output "RefDatasetID"
#Write-Output $RefDataSetID