 $AKS_RESOURCE_GROUP="BRS-EUW-RSG-D-SPOKE-AKS"
 $AKS_CLUSTER_NAME= "BRS-EUW-D-AKS-POC-CLUSTER"
 $ADMIN_GROUP= "BRS-EUW-GRP-D-AKSADMIN"
 $DEVOPS_SPN= "SPNDevopsApps"
 $DOTNETCORE_NAMESPACE="dotnetcore-ns"  
 $DOTNETCORE_DEV_GROUP="BRS-EUW-GRP-D-AKSDOTNETCORE"

# Get the AKS ClusterID
 $AKS_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query id -o tsv)

# Create Groups for admin users
 $admingroupid=$(az ad group create --display-name $ADMIN_GROUP --mail-nickname $ADMIN_GROUP --query objectId -o tsv)
 echo $admingroupid
2cda7e34-08f4-4cfb-bbc4-8b676425f557

 az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin
#Assigned admin user to the group.
# Create Rolebindings so that respective groups get admin access to Kubernetes  cluster
 kubectl create clusterrolebinding aad-cluster-admin --clusterrole=cluster-admin --group=$admingroupid 

# Create Groups for dotnet application developers
 $DOTNETAPPDEV_ID=$(az ad group create --display-name $DOTNETCORE_DEV_GROUP --mail-nickname $DOTNETCORE_DEV_GROUP --query objectId -o tsv)
 echo $DOTNETAPPDEV_ID
68693837-37cd-4c75-84f3-f001140eadb0
# Assign role to pull kubeconfig from AKS Cluster
 az role assignment create --assignee $DOTNETAPPDEV_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID



# Create Kubernetes Role to allow only read access to Pods and their logs 
 kubectl create ns $DOTNETCORE_NAMESPACE  
 kubectl apply -f DeveloperRole.yaml -n $DOTNETCORE_NAMESPACE

# Create Rolebindings so that respective groups get Read access to Kubernetes pods inside their own namespace only
 kubectl create rolebinding developer-dotnet-binding --role=developerrole --group=$DOTNETAPPDEV_ID -n $DOTNETCORE_NAMESPACE  

# Create Service Principal for DevOpsApps
 $SP_PASSWD=$(az ad sp create-for-rbac --name http://$DEVOPS_SPN --role "Azure Kubernetes Service Cluster User Role" --scopes $AKS_ID --query password --output tsv)
 $CLIENT_ID=$(az ad sp show --id http://$DEVOPS_SPN --query appId --output tsv)
 $TENANT_ID=$(az ad sp show --id http://$DEVOPS_SPN --query appOwnerTenantId --output tsv)

# Create DevOps Role in Kubernetes --Note (remove the delete permission from this role)
 kubectl apply -f DevOpsRole.yaml -n $DOTNETCORE_NAMESPACE

# Create RoleBindings for DevOps
 kubectl create rolebinding devops-dotnet-binding --role=developerrole --user=$CLIENT_ID -n $DOTNETCORE_NAMESPACE 

# Login with devops user id to chek the permission in required namespace
 az login --service-principal -u cbdbfc46-30f3-4614-beb5-0dfe8cc3a05b -p XLA6BL3lB.vUc21pU.LT5esSqzI1~1de1Y --tenant ce5330fc-da76-4db0-8b83-9dfdd963f09a
 az login --service-principal -u $CLIENT_ID -p $SP_PASSWD --tenant  $TENANT_ID

 echo $CLIENT_ID
cbdbfc46-30f3-4614-beb5-0dfe8cc3a05b
 echo $TENANT_ID
ce5330fc-da76-4db0-8b83-9dfdd963f09a
 echo $SP_PASSWD
XLA6BL3lB.vUc21pU.LT5esSqzI1~1de1Y
#
#To check role & rolebinding
 kubectl get role  -n dotnetcore-ns
 kubectl get rolebinding  -n dotnetcore-ns


