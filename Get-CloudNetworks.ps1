
<#
    .SYNOPSIS
    List Rackspace cloud Netowrks
    
    .DESCRIPTION
    List Rackspace cloud Netowrks, can be used to obtain if of Rackconnect network

    UUID for ServiceNet ="11111111-1111-1111-1111-111111111111"
    UUID for PublicNet  ="00000000-0000-0000-0000-000000000000"
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>

#Auhtenticate to Rackspace to retrieve API token update %username% and api key 
$creds = Import-Csv $PoshAPIAccounts

$Region = $creds.Region
$CloudUsername = $creds.CloudUsername
$APIkey = $creds.CloudAPIKey
$CloudAccountNum = $creds.TenantId

<#
$CloudUsername = Read-Host "Enter cloud username"
$APIkey = Read-Host "Enter API key"
$CloudAccountNum = Read-Host "Enter cloud account number"
#>

$obj = @{
   auth = @{
        "RAX-KSKEY:apiKeyCredentials" = 
                    @{
                    "apiKey" = $APIkey;
                    "username" = $CloudUsername;
        
                    };     
        };
};  

$Creds= $obj | ConvertTo-Json -Depth 10
$Creds 

$Auth = Invoke-RestMethod -Uri https://identity.api.rackspacecloud.com/v2.0/tokens -Method Post -Body $Creds -ContentType application/json
#Retreive your token and see all the endpoints.
$Auth | ConvertTo-Json -Depth 6 
$token = $Auth.access.token.id 

$ListNetworks= Invoke-RestMethod -Uri https://$Region.networks.api.rackspacecloud.com/v2.0/networks -Method GET -Headers @{"X-Auth-Token"=$token} -ContentType application/json

$Networks = $ListNetworks.networks


          
