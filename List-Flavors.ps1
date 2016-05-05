<#
    .SYNOPSIS
    List all Cloud Server Flavors 
    
    .DESCRIPTION
    List all Cloud Server Flavors and creates a numbered menu for user selection. 
    
    .NOTES
    Author: Bob Larkin
    Date: 05/05/2016
    Version: 1.0


#>

$ListFlv = Invoke-RestMethod -Uri https://ORD.servers.api.rackspacecloud.com/v2/$CloudAccountNum//flavors -Method Get -Headers @{"X-Auth-Token"=$token} -ContentType application/json
$Flavors = $ListFlv.flavors 


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

$FlvNum = Read-Host "Enter number of Flavour Number you would like to use"
$UserFlv = $WinFlavors[$FlvNum]
$BuildFlv = $UserFlv.'Flavor ID'
$Flvname = $UserFlv.'Flavor Name'

Write-Host "Flavour: $Flvname " -ForegroundColor Yellow
