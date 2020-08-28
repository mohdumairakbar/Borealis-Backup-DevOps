Nginx Controller Helm Chart
Commands
# Get the ingress controller chart from ACR repo and assign ACRPull IAM role to SPNaksinfrapoc SP.
•	helm chart pull brseuwacrd01.azurecr.io/helmcharts/nginx-ingress:base
•	helm chart export brseuwacrd01.azurecr.io/helmcharts/nginx-ingress:base \ --destination ./
•	cd nginx-ingress/
Nginx Ingress Controller
Commands
# Create a namespace for your ingress resources
•	kubectl create namespace ingress-ns
# Use Helm to deploy an NGINX ingress controller with customized values 
•	helm install nginx-ingress . --values customised_values.yaml \
--namespace ingress-ns \
-f internal-ingress.yaml \
--set controller.replicaCount=2 \
--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=Linux
# When the Kubernetes load balancer service is created for the NGINX ingress controller, your internal IP address is assigned.
•	kubectl get service -l app=nginx-ingress --namespace ingress-ns

Run demo applications
Commands
# Run two application in cluster to check ingress controller in action using kubectl apply..
•	kubectl apply -f aks-helloworld.yaml --namespace ingress-ns
•	kubectl apply -f ingress-demo.yaml --namespace ingress-ns

Create an ingress route
Commands
# Create a ingress resource to route traffic of both application.
•	kubectl apply -f hello-world-ingress.yaml

Test the ingress controller
Commands
 # Test this internal only functionality using  pod by attaching terminal session to it.
•	kubectl run -it --rm aks-ingress-test --image=debian --namespace ingress-ns
# Install curl in the pod using apt-get:
•	apt-get update && apt-get install -y curl
•	curl -L http://10.49.0.250
•	curl -L http://10.49.0.250//hello-world-two
