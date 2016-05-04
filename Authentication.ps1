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




$ListImg = Invoke-RestMethod -Uri https://ORD.servers.api.rackspacecloud.com/v2/$CloudAccountNum/images/detail -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
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

 
$ImgNum = Read-Host "Enter number of Image you would like to use"
$Userimg = $Winimages[$ImgNum]
$Buildimg = $Userimg.'Image ID'
$ImgName = $Userimg.'Image Name'

Write-Host "Image name: $ImgName `n" -ForegroundColor Yellow