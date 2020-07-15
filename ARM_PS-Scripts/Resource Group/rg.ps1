$rgname="BRS-EUW-RSG-D-AKS"
$location="westeurope"
try
{

#######-----Resource Group Creation Template-----#######
echo "Creating Resource Group"
New-AzResourceGroup -Name $rgname -Location $location
echo "Resource Group Created Successfully"
}
catch
{	
    Write-Host "An error occurred:"
    Write-Host $_
}