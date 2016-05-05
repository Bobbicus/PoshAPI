
<#
    .SYNOPSIS
    Create a Rackspace cloud load balancer
    
    .DESCRIPTION
    Create a Rackspace cloud load balancer
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>

#Auhtenticate to Rackspack to retrieve API token update %username% and api key
$creds = Import-Csv $PoshAPIAccounts

$region = $creds.Region
$CloudUsername = $creds.CloudUsername
$APIkey = $creds.CloudAPIKey
$CloudAccountNum = $creds.TenantId

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

$JSON = '{
    "loadBalancer": {
        "virtualIps": [
            {
                "type": "PUBLIC"
            }
        ], 
        "protocol": "HTTP", 
        "name": "WebLB", 
        "algorithm": "ROUND_ROBIN", 
        "port": 80
    }
}'

$CreateLB = Invoke-RestMethod -Uri "https://$Region.loadbalancers.api.rackspacecloud.com/v1.0/$CloudAccountNum/loadbalancers" -Method Post -Headers @{"X-Auth-Token"=$token} -Body $JSON -ContentType application/json
