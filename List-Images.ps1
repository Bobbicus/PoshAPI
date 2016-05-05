<#
    .SYNOPSIS
    List all Cloud Server images 
    
    .DESCRIPTION
    List all Cloud Server images and creates a numbered menu for user selection. 
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>

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