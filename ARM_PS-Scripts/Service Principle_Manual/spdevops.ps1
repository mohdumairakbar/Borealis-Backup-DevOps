try
{
	# creating service principal for devops

	az ad sp create-for-rbac -n "spdevops" --skip-assignment

	# Service Principal for devops created

}
catch
{	
    Write-Host "An error occurred:"
    Write-Host $_
}