<#
    .SYNOPSIS
    Authenticate to Rackspace API
    
    .DESCRIPTION
    Authenticate to Rackspace API to retirve APi token and details of endpoints.
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>



$CloudUsername = Read-Host "Enter cloud username"
$APIkey = Read-Host "Enter API key"
$CloudAccountNum = Read-Host "Enter cloud account number"

$obj = @{
   "auth" = @{
        "RAX-KSKEY:apiKeyCredentials" = 
                    @{
                    "apiKey" = $APIkey;
                    "username" = $CloudUsername;
        
                    };     
        };
};  

$Creds= $obj | ConvertTo-Json -Depth 10
$Creds 

#$Auth = Invoke-RestMethod -Uri https://identity.api.rackspacecloud.com/v2.0/tokens -Method Post -Body '{"auth" : {"RAX-KSKEY:apiKeyCredentials" : {"username" : "$CloudUserName", "apiKey" : "fd9856e5leaf3984h5j72j78fea69f"}}}' -ContentType application/json
$Auth = Invoke-RestMethod -Uri https://identity.api.rackspacecloud.com/v2.0/tokens -Method Post -Body $Creds -ContentType application/json
#Retrevie your token and see all the endpoints.
$Auth | ConvertTo-Json -Depth 6 
$token = $Auth.access.token.id 


