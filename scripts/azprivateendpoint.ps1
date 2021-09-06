#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\privateendpoint\privateendpoint.bicep"

