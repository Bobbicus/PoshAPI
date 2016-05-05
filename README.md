# PoSh Rackspace Cloud API
A basic guide to getting started using the Rackspace API using Powershell.   This give you the starting blocks to use the resources from the developer docs and pitchfork tools to replicate these in PowerShell. 


Review queries on https://pitchfork.eco.rackspace.com/
API reference guide https://developer.rackspace.com/docs/cloud-servers/v2/developer-guide/#document-getting-started

If you update your profile C:\Users\%username%\Documents\WindowsPowerShell and add a variable like the one below;

$PoshAPIAccounts = "C:\Users\%username%\Documents\CloudAccounts1.csv"



You can then create the correpsonding csv file to store your credentials so you can use this instead of inputing these each time. I have just shown example of how this would look below

CloudUsername,CloudAPIKey,Region,TenantId
%username%,gi89746emy5eut66fc59412qaraea93t,ORD,987654

This can simply be called when authenticating in scripts;

$Creds = Import-Csv $PoshAPIAccounts
