<#
    .SYNOPSIS
    Add nodes to a Cloud Load Balancer 
    
    .DESCRIPTION
    Add nodes to a Cloud Load Balancer, this will list load balancers and then list the servers and let you choose which servers you want to add.  It uses the internal IP so is based on adding Rackspace cloud servers to CLB.
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>

#Auhtenticate to Rackspace to retrieve API token update this uses creds stored in a csv referenced in PS profile
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


#List Load Balancers
$ListLB = Invoke-RestMethod -Uri "https://$Region.loadbalancers.api.rackspacecloud.com/v1.0/$CloudAccountNum/loadbalancers" -Method GET -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$CLBDetails = $ListLB.loadBalancers

$Num = 0
$CLBList = @()
foreach ($clb in $CLBDetails)

            {
                
                $item = New-Object PSObject 
                $item | Add-Member -MemberType NoteProperty -Name "Number" -Value $Num
                $item | Add-Member -MemberType NoteProperty -Name "CLB ID" -Value $clb.id
                $item | Add-Member -MemberType NoteProperty -Name "CLB Name" -Value $clb.name
                $CLBList +=$item
                $Num += 1

            }

 
$CLBList | ft

#Request user input to pick the CLB they want to add node to
$CLBNum = Read-Host "Enter number of Cloud Load Balancer you would like to use"
$Userclb = $CLBList[$CLBNum]
$CLBid = $Userclb.'CLB ID'
$CLBName = $Userimg.'CLB Name'

#List current Servers on the account
$ListServers = Invoke-RestMethod -Uri "https://$Region.servers.api.rackspacecloud.com/v2/$CloudAccountNum/servers/detail" -Method GET -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$Servers = $ListServers.servers
$Servers.addresses.private

#Create a numbered list of servers, find the private IP of the server.  This is based on using Rackspace servers so we use internal rather than public IP
$Num = 0
$ServersList = @()
foreach ($srv in $Servers)

            {
                
                $item = New-Object PSObject 
                $item | Add-Member -MemberType NoteProperty -Name "Number" -Value $Num
                $item | Add-Member -MemberType NoteProperty -Name "Server ID" -Value $srv.id
                $item | Add-Member -MemberType NoteProperty -Name "Server Name" -Value $srv.name
                $item | Add-Member -MemberType NoteProperty -Name "Server IP" -Value $srv.addresses.private.addr
                $ServersList +=$item
                $Num += 1

            }

$ServersList  | ft

#Request user input to pick the server they want to add to CLB
$SrvNum = Read-Host "Number of cloud Server you want to add to CLB"
$UserSrv = $ServersList[$SrvNum]
$Srvid = $userSrv.'Server ID'
$SrvName = $userSrv.'Server Name'
$SrvIP = $userSrv.'Server IP'

#Let user pick port that server will use port 80 or 8080 etc
$Port = Read-Host "Enter Port to user for Node $SrvName"


#create the Server using details provided. The below we create the JSON object first then pass this as a variable to the API request 
$obj = @{
    nodes = @(
                @{
                "address" = "$SrvIP";
                "port" = $Port;
                "condition" = "ENABLED"
       
                };
                );
};  

$JSON = $obj | ConvertTo-Json -Depth 10
$JSON

$AddNode = Invoke-RestMethod -Uri "https://$Region.loadbalancers.api.rackspacecloud.com/v1.0/$CloudAccountNum/loadbalancers/$CLBid/nodes" -Method Post -Headers @{"X-Auth-Token"=$token} -Body $JSON -ContentType application/json

Write-Host "Adding node $SrvName to Cloud load balancer  $CLBName " -ForegroundColor Green

