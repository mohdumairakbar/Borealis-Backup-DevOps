 $AKS_RESOURCE_GROUP="BRS-EUW-RSG-D-SPOKE-AKS-UDR"
 $AKS_CLUSTER_NAME= "BRS-EUW-D-AKS-UPOC-CLUSTER"
 $DOTNETCORE_NAMESPACE="dotnetcore-ns"  
 $DEVOPS_GROUP= "BRS-EUW-GRP-D-DEVOPS"
 $DOTNETCORE_DEV_GROUP="BRS-EUW-GRP-D-DEVELOPER"
 $THIRD_PARTY_GROUP="BRS-EUW-GRP-D-THIRDPARTY"
 


# Get the AKS ClusterID
$AKS_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query id -o tsv)

az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin

# Create Groups for developers
$DOTNETAPPDEV_ID=$(az ad group create --display-name $DOTNETCORE_DEV_GROUP --mail-nickname $DOTNETCORE_DEV_GROUP --query objectId -o tsv)
echo $DOTNETAPPDEV_ID
#68693837-37cd-4c75-84f3-f001140eadb0

# Assign role to pull kubeconfig from AKS Cluster
az role assignment create --assignee $DOTNETAPPDEV_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID

# Create Groups for Devops users
$admingroupid=$(az ad group create --display-name $DEVOPS_GROUP --mail-nickname $DEVOPS_GROUP --query objectId -o tsv)
echo $admingroupid
 
# Assign role to pull kubeconfig from AKS Cluster
az role assignment create --assignee $admingroupid --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID 

# Create Group for Thirdparty
$THIRD_PARTY_ID=$(az ad group create --display-name $THIRD_PARTY_GROUP --mail-nickname $THIRD_PARTY_GROUP --query objectId -o tsv)
#echo $THIRD_PARTY_ID

# Assign role to pull kubeconfig from AKS Cluster
az role assignment create --assignee $THIRD_PARTY_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID
