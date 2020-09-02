$AKS_RESOURCE_GROUP="BRS-EUW-RSG-D-SPOKE-AKS"
$AKS_CLUSTER_NAME= "BRS-EUW-D-AKS-POC-CLUSTER"


# Create the Azure AD Server application (AKS Cluster to authenticate users in Azure AD)
#$serverApplicationId = $(az ad app list --display-name "${AKS_CLUSTER_NAME}Server" --query [].appId -o tsv)

$serverApplicationId=$(az ad app create --display-name "${AKS_CLUSTER_NAME}Server" --identifier-uris "https://${AKS_CLUSTER_NAME}Server" --query appId -o tsv)
echo $serverApplicationId

# Update the application group memebership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All

# Create a service principal for the Azure AD Server application
az ad sp create --id $serverApplicationId

##"objectId": "bfd15cf9-0160-4a5c-9486-205b6f4da8ae",
# Get the service principal secret
#lm2L8Wifq9htHNKCU_HD.-Xd9PIe6P_E0I


$serverApplicationSecret=$(az ad sp credential reset --name $serverApplicationId --credential-description "AKSPassword" --query password -o tsv)

#U8RBQZLO2kK9Ok8i4rHNC-3kYL0r8AVTjt

# Add permissions to Read directory data and Sign in and read user profile
az ad app permission add --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role
az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId
# Assigning last permission might fail. You need manually assign read only permission to server app for read all 

# Create the Azure AD Client application (Kubectl to call for user authentication)
#$clientApplicationId = $(az ad app list --display-name "${AKS_CLUSTER_NAME}Client" --query [].appId -o tsv)
#4820d48a-3877-460e-9907-0cdc3cf036b1
$clientApplicationId=$(az ad app create --display-name "${AKS_CLUSTER_NAME}Client" --native-app --reply-urls "https://${AKS_CLUSTER_NAME}Client" --query appId -o tsv)

# Create a service principal for the Azure AD Client application

az ad sp create --id $clientApplicationId

# Get the oAuth2 ID for the server app to allow the authentication flow between the two app components
# d199db3b-ff28-4eb3-86c4-d4b7525bce7f
$oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)
echo $oAuthPermissionId

# Add the permissions for the client application and server application components to use the oAuth2 communication flow
az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions $oAuthPermissionId=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId
