###################################################################################################################
#This script contains the basic steps to get started interacting with the Rackspace cloud API
#-1. Authenticate using API key and username to view  endpoints and retrieve token
#-2. Retrieve Images
#-3. Retrieve Flavors
#-4. Build a basic server Flavors
#-5. List Volumes
#-6. Build Server from Exisiting boot From Volume image
#-7. Build Boot from volume Server
#
# API reference guide https://developer.rackspace.com/docs/cloud-servers/v2/developer-guide/#document-getting-started
###################################################################################################################
# 1 - Auhtenticate to Rackspack to retrieve API token update %username% and api key 

$Auth = Invoke-RestMethod -Uri https://identity.api.rackspacecloud.com/v2.0/tokens -Method Post -Body '{"auth" : {"RAX-KSKEY:apiKeyCredentials" : {"username" : "%username%", "apiKey" : "3213654sdsdgffsdg54s65gf46sd54gsfd46g5"}}}' -ContentType application/json
$Auth | ConvertTo-Json -Depth 6 
$token= $Auth.access.token.id 

# 2 - list All fimages replace %CloudAccountNo%/ with your account number
$ListImg = Invoke-RestMethod -Uri https://ORD.servers.api.rackspacecloud.com/v2/%CloudAccountNo%/images/detail -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$AllImages  | ConvertTo-Json -Depth 6 
$ListImg.images | Select-Object ID,name


# 3 - list All flavors replace %CloudAccountNo%/ with your account number
$ListFlv = Invoke-RestMethod -Uri https://ORD.servers.api.rackspacecloud.com/v2/%CloudAccountNo%//flavors -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$ListFlv.flavors 

# 4 - Create basic server replace %CloudAccountNo%/ with your account number
#Change name, imageref and falvorRef as required 
$CreateServer = Invoke-RestMethod -Uri "https://ORD.servers.api.rackspacecloud.com/v2/%CloudAccountNo%/servers" -Method Post -Headers @{"X-Auth-Token"=$token} -ContentType application/json -Body '{"server": {"name": "APItest","imageRef": "0b2bd620-142a-4cc8-8433-b8d3fb637632", "flavorRef": "4"}}'

# 5 - List volumes to see which volumes are available and retreive IDs

$ListVols = Invoke-RestMethod -Uri https://ORD.blockstorage.api.rackspacecloud.com/v1/%CloudAccountNo%/volumes -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$ListVols.volumes | Select-Object display_name,volume_type,id,size

###################################################################################################################
#  6 - Create a an existing cloned boot from volume disk
###################################################################################################################

#Create JSON object for the API request
#These are required variables to create a Boot from volume server.  Update the fields by using commmands above to see available images, flavors etc
$obj = @{
    server = @{
        "name" = "Server1";
        "flavorRef" = "general1-2";
        "imageRef" = "";
        "block_device_mapping_v2" = @(
                    @{
                    "boot_index" = "0";
                    "uuid" = "7esfd9d9-08d2-42d0-a521-abf9ac8fd8a";
                    "volume_size" = "50";
                    "source_type" = "volume";
                    "destination_type" = "volume";
                    "delete_on_termination" = "false"; 
                    "device_name" =  "test"
                    };
                    );
        };
};  

$JSON = $obj | ConvertTo-Json -Depth 10
$JSON

#Create a Boot From volume server using exisiting cloned BFV image  - replace %CloudAccountNo% with your account number
$CreateBFVServer = Invoke-RestMethod -Uri "https://ORD.servers.api.rackspacecloud.com/v2/%CloudAccountNo%/servers" -Method Post -Headers @{"X-Auth-Token"=$token} -ContentType application/json -Body $JSON
	
###################################################################################################################
# 7 Create a BFV Volume, this creates a new server using an exisint Rackspace vanilla image
###################################################################################################################

#Create JSON object for the API request
#These are required variables to create a Boot from volume server.  Update the fields by using commmands above to see available images, flavors etc
$obj = @{
    server = @{
        "name" = "Server2";
        "flavorRef" = "general1-2";
        #"imageRef" = "";
        "block_device_mapping_v2" = @(
                    @{
                    "boot_index" = "0";
                    "uuid" = "0b2bd620-142a-4cc8-8433-b8d3fb637632";
                    "volume_size" = "50";
                    "source_type" = "image";
                    "destination_type" = "volume";
                    "delete_on_termination" = "false"; 
                    };
                    );
        };
};  

$JSON = $obj | ConvertTo-Json -Depth 10
$JSON

#Create a Boot From volume server using exisiting cloned BFV image  - replace %CloudAccountNo% with your account number
$CreateBFVServer = Invoke-RestMethod -Uri "https://ORD.servers.api.rackspacecloud.com/v2/%CloudAccountNo%/os-volumes_boot" -Method Post -Headers @{"X-Auth-Token"=$token} -ContentType application/json -Body $JSON
	