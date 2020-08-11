 $AKS_RESOURCE_GROUP="BRS-EUW-RSG-D-SPOKE-AKS"
 $AKS_CLUSTER_NAME= "BRS-EUW-D-AKS-POC-CLUSTER"
 $ADMIN_GROUP= "BRS-EUW-GRP-D-AKSADMIN"
 $DEVOPS_SPN= "SPNDevopsApps"
 $DOTNETCORE_NAMESPACE="dotnetcore-ns"  
 $DEVOPS_GROUP= "BRS-EUW-GRP-D-DEVOPS"
 $DOTNETCORE_DEV_GROUP=" BRS-EUW-GRP-D-DEVELOPER"
 $THIRD_PARTY_GROUP="BRS-EUW-GRP-D-THIRDPARTY"
 $CLOUD_OPS_GROUP="BRS-EUW-GRP-D-CLOUDOPS"


# Get the AKS ClusterID
 $AKS_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query id -o tsv)

 az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin

# Create Groups for developers
 $DOTNETAPPDEV_ID=$(az ad group create --display-name $DOTNETCORE_DEV_GROUP --mail-nickname $DOTNETCORE_DEV_GROUP --query objectId -o tsv)
 echo $DOTNETAPPDEV_ID
68693837-37cd-4c75-84f3-f001140eadb0
# Assign role to pull kubeconfig from AKS Cluster
 az role assignment create --assignee $DOTNETAPPDEV_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID



# Create Kubernetes Role to allow access K8s resources. 
 kubectl apply -f developer-cluster-role.yaml
 kubectl apply -f developer-cluster-rolebindings.yaml

# Create Groups for Devops users
  $admingroupid=$(az ad group create --display-name $DEVOPS_GROUP --mail-nickname $DEVOPS_GROUP --query objectId -o tsv)
  echo $admingroupid
 
 # Assign role to pull kubeconfig from AKS Cluster
  az role assignment create --assignee $admingroupid --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID 
# Create Kubernetes Role to allow access K8s resources. 
 kubectl apply -f devops-cluster-role.yaml
 kubectl apply -f devops-cluster-rolebindings.yaml

# Create Group for Thirdparty
 $THIRD_PARTY_ID=$(az ad group create --display-name $THIRD_PARTY_GROUP --mail-nickname $THIRD_PARTY_GROUP --query objectId -o tsv)
 echo $THIRD_PARTY_ID

# Assign role to pull kubeconfig from AKS Cluster
 az role assignment create --assignee $THIRD_PARTY_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID
# Create Kubernetes Role to allow access on dotnetcore-ns and ingress-ns namespace resources. 
 kubectl apply -f third-party-cluster-role.yaml
 kubectl apply -f third-party-cluster-role-bindings-dotnetcore-ns.yaml
 kubectl apply -f third-party-cluster-role-bindings-ingress-ns.yaml


# Create Group for CloudOps
 $CLOUD_OPS_ID=$(az ad group create --display-name $CLOUD_OPS_GROUP --mail-nickname $CLOUD_OPS_GROUP --query objectId -o tsv)
 echo $CLOUD_OPS_ID
 0025e193-0df5-4760-a7d6-6db6ef495398
# Assign role to pull kubeconfig from AKS Cluster
 az role assignment create --assignee $CLOUD_OPS_ID --role "Contributor" --scope $AKS_ID
# Create Service Principal for DevOpsApps
 $SP_PASSWD=$(az ad sp create-for-rbac --name http://$DEVOPS_SPN --role "Azure Kubernetes Service Cluster User Role" --scopes $AKS_ID --query password --output tsv)
 $CLIENT_ID=$(az ad sp show --id http://$DEVOPS_SPN --query appId --output tsv)
 $TENANT_ID=$(az ad sp show --id http://$DEVOPS_SPN --query appOwnerTenantId --output tsv)


 echo $CLIENT_ID
cbdbfc46-30f3-4614-beb5-0dfe8cc3a05b
 echo $TENANT_ID
ce5330fc-da76-4db0-8b83-9dfdd963f09a
 echo $SP_PASSWD
XLA6BL3lB.vUc21pU.LT5esSqzI1~1de1Y
 az ad sp show --id cbdbfc46-30f3-4614-beb5-0dfe8cc3a05b
 Object ID:   f27ca348-4ea8-48e8-8188-e91a6e7a2c84
#
#To check role & rolebinding
 kubectl get role  -n dotnetcore-ns
 kubectl get rolebinding  -n dotnetcore-ns
 kubectl get clusterrolebinding  
 kubectl get clusterrole 


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
 kubectl get rolebinding  -n dotnetcore-
 
 #To add user in desired group 
$THIRD_PARTY_GROUP="BRS-EUW-GRP-D-THIRDPARTY"
	$DOTNETDEVUSER_ID = (Get-AzureRmADUser -SearchString 'Neetima').Id
	az ad group member add --group $THIRD_PARTY_GROUP --member-id $DOTNETDEVUSER_ID

# To test assigned group’s roles
	az aks get-credentials --resource-group BRS-EUW-RSG-D-SPOKE-AKS --name BRS-EUW-D-AKS-POC-CLUSTER --overwrite-existing
	kubectl auth can-i get pods -n dotnetcore-ns
	kubectl get pods –n dotnetcore-ns
	kubectl auth can-i delete pods -n dotnetcore-ns




