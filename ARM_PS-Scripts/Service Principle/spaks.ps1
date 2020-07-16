try
{
	# creating service principal for aks cluster

	az ad sp create-for-rbac -n "aksinfrademosp" --skip-assignment

	# Service Principal for aks cluster created
}
catch
{	
    Write-Host "An error occurred:"
    Write-Host $_
}