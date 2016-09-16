
<#
    .SYNOPSIS
    Create a Rackspace cloud server
    
    .DESCRIPTION
    Create a Rackspace cloud server.  Provides menu to pick flavor, image and Server name
    
    If you update your profile C:\Users\%username%\Documents\WindowsPowerShell and add a variable like the one below;

    $PoshAPIAccounts = "C:\Users\%username%\Documents\CloudAccounts1.csv"

    You can then create the correpsonding csv file to store your credentials so you can use this instead of inputing these each time. I have just shown example of how this would look below

    CloudUsername,CloudAPIKey,Region,TenantId %username%,gi89746emy5eut66fc59412qaraea93t,ORD,987654

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

#List available images
$ListImg = Invoke-RestMethod -Uri https://$Region.servers.api.rackspacecloud.com/v2/$CloudAccountNum/images/detail -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$AllImages  | ConvertTo-Json -Depth 6 
$ImgList = $ListImg.images | Select-Object ID,name

#Create Hashtable of Images and number the list 
$Num = 0
$Winimages = @()
foreach ($img in $ImgList) 

            {
                
                $item = New-Object PSObject 
                $item | Add-Member -MemberType NoteProperty -Name "Number" -Value $Num
                $item | Add-Member -MemberType NoteProperty -Name "Image ID" -Value $img.ID
                $item | Add-Member -MemberType NoteProperty -Name "Image Name" -Value $img.name
                $Winimages +=$item
                $Num += 1

            }

 
 $Winimages | ft

#Request user input to pick the image they want to use
$ImgNum = Read-Host "Enter number of Image you would like to use"
$Userimg = $Winimages[$ImgNum]
$Buildimg = $Userimg.'Image ID'
$ImgName = $Userimg.'Image Name'

Write-Host "Image name: $ImgName `n" -ForegroundColor Yellow

$ListFlv = Invoke-RestMethod -Uri https://$Region.servers.api.rackspacecloud.com/v2/$CloudAccountNum//flavors -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
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
Write-Host "Image name: $ImgName `n" -ForegroundColor Yellow
Write-Host "Flavour: $Flvname " -ForegroundColor Yellow

#provide warning and opt out before building
if (-not $force) {
    if((Read-Host "Warning, this script is about to create the server do you want to proceeed (Y/N)") -notlike "y*") {exit} }


# create the Server using details provided. The below we create the JSON object first then pass this as a variable to the API request 
$obj = @{
        server = @{
            "name" = "$SrvName";
            "flavorRef" = "$BuildFlv";
            "imageRef" = "$Buildimg";
            }           

       
};  


$JSON = $obj | ConvertTo-Json -Depth 10
$JSON

$CreateServer = Invoke-RestMethod -Uri https://$Region.servers.api.rackspacecloud.com/v2/$CloudAccountNum/servers -Method Post -Headers @{"X-Auth-Token"=$token} -ContentType application/json -Body $JSON
  
Write-Host "Building Server " -ForegroundColor Green
$AdminPass = $CreateServer.server.adminPass
Write-Host "Admin Password: $AdminPass " -ForegroundColor Green
