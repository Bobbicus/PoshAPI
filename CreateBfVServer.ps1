###################################################################################################################
# Create a server from an existing cloned boot from volume disk
###################################################################################################################

#Auhtenticate to Rackspack to retrieve API token update %username% and api key 

$CloudUsername = Read-Host "Enter cloud username"
$APIkey = Read-Host "Enter API key"
$CloudAccountNum = Read-Host "Enter cloud account number"

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

#List available Volumes for BfV 
$ListVols = Invoke-RestMethod -Uri https://ORD.blockstorage.api.rackspacecloud.com/v1/$CloudAccountNum/volumes -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
#Filter list to only show volumes with a status of available
$VolList = $ListVols.volumes | Select-Object display_name,volume_type,id,size,status | Where {$_.Status -eq "available"}


#Create Hashtable of Images and number the list 
$VolNum = 0
$BfVolumes = @()
foreach ($vol in $VolList) 

            {
                
                $item = New-Object PSObject 
                $item | Add-Member -MemberType NoteProperty -Name "Number" -Value $VolNum
                $item | Add-Member -MemberType NoteProperty -Name "Volume Name" -Value $Vol.display_name
                $item | Add-Member -MemberType NoteProperty -Name "Volume ID" -Value $Vol.ID
                $item | Add-Member -MemberType NoteProperty -Name "Volume Size" -Value $Vol.size
                $item | Add-Member -MemberType NoteProperty -Name "Volume Type" -Value $Vol.volume_type
                $BfVolumes  +=$item
                $VolNum += 1

            }

 
$BfVolumes | ft

#Request user input to pick the image they want to use
$VolNum = Read-Host "Enter number of Image you would like to use"
$UserVol = $BfVolumes[$VolNum]
$BuildVolID = $UserVol.'Volume ID'
$VolName = $UserVol.'Volume Name'

Write-Host "Volume name: $VolName `n" -ForegroundColor Yellow

$ListFlv = Invoke-RestMethod -Uri https://ORD.servers.api.rackspacecloud.com/v2/$CloudAccountNum//flavors -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$Flavors = $ListFlv.flavors 

#Create Hashtable of Flavors and number the list 
$FlvNum = 0
$WinFlavors = @()
foreach ($Flv in $Flavors) 
         {    
                $item2 = New-Object PSObject
                $item2 | Add-Member -MemberType NoteProperty -Name "Flavor Number" -Value $FlvNum
                $item2 | Add-Member -MemberType NoteProperty -Name "Flavor ID" -Value $Flv.Id
                $item2 | Add-Member -MemberType NoteProperty -Name "Flavor Name" -Value $Flv.Name
                $WinFlavors += $item2
                $FLvNum += 1
         }
          

     
$WinFlavors | ft

#Request user input to pick the Flavor they want to use
$FlvNum = Read-Host "Enter number of Flavour Number you would like to use"
$UserFlv = $WinFlavors[$FlvNum]
$BuildFlv = $UserFlv.'Flavor ID'
$Flvname = $UserFlv.'Flavor Name'

Write-Host "Flavour: $Flvname " -ForegroundColor Yellow

#Request user input for Server name
$SrvName = Read-Host "Enter server Name"

Write-Host "`n"
Write-Host "You have chosen to build a server called: $SrvName `n" -ForegroundColor Yellow
Write-Host "Image name: $VolName `n" -ForegroundColor Yellow
Write-Host "Flavour: $Flvname " -ForegroundColor Yellow

#provide warning and opt out before building
if (-not $force) {
    if((Read-Host "Warning, this script is about to create the server do you want to proceeed (Y/N)") -notlike "y*") {exit} }




###################################################################################################################
#  7 - Create a an existing cloned boot from volume disk
###################################################################################################################

#Create JSON object for the API request. This example takes a powershell object and converts it to JSON
#These are required variables to create a Boot from volume server.  Update the fields by using commmands above to see available images, flavors etc
$obj = @{
    server = @{
        "name" = "$SrvName";
        "flavorRef" = "$BuildFlv";
        "imageRef" = "";
        "block_device_mapping_v2" = @(
                    @{
                    "boot_index" = "0";
                    "uuid" = "$BuildVolID";
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

#Create a Boot From volume server using exisiting cloned BFV image  
$CreateBFVServer = Invoke-RestMethod -Uri "https://ORD.servers.api.rackspacecloud.com/v2/$CloudAccountNum/servers" -Method Post -Headers @{"X-Auth-Token"=$token} -ContentType application/json -Body $JSON


Write-Host "Building Server " -ForegroundColor Green
$AdminPass = $CreateBFVServer.server.adminPass
Write-Host "Admin Password: $AdminPass " -ForegroundColor Green