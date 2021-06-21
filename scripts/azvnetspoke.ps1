#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"
$versionnumber = "0.2"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\azvnetspoke\azvnetspoke.bicep"
New-AzTemplateSpec -Name "az-tempspec-vnetspoke" -Version "$versionnumber" -ResourceGroupName "$resourcegroup" -Location "$location" -TemplateFile ".\templatespec\azvnetspoke\azvnetspoke.json"
