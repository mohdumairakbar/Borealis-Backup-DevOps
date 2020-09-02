# This script creates a SQL Database

# You'll need to adjust these variables accordingly

$sqlAdminUserName = 'borealisadmin'
$sqlAdminPassword = $env:SQLDBDEV
$sqlServerName = "brseuwsqldbdpoc07" # this needs to be all lower case
$resourceGroupName = "BRS-EUW-RSG-D-SPOKE-AKS" 
$sqlDatabaseName = 'EMPDB012'
$location = 'westeurope'

#Write-Host "Creating resource group $resourceGroupName"
#az group create --name $resourceGroupName --location $location

Write-Host "Creating SQL Server $sqlServerName"
az sql server create `
    --name $sqlServerName `
    --resource-group $resourceGroupName `
    --location $location  `
    --admin-user $sqlAdminUserName `
    --admin-password $sqlAdminPassword

Write-Host "Creating database $sqlDatabaseName"
az sql db create `
	--resource-group $resourceGroupName `
	--server $sqlServerName `
	--name $sqlDatabaseName `
	--service-objective S0

Write-Host "Creating firewall rule..."
az sql server firewall-rule create -g $resourceGroupName -s $sqlServerName -n "allowAzure" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
