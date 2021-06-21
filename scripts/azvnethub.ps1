#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"
$versionnumber = "0.4"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\azvnethub\azvnethub.bicep"
New-AzTemplateSpec -Name "az-tempspec-vnethub" -Version "$versionnumber" -ResourceGroupName "$resourcegroup" -Location "$location" -TemplateFile ".\templatespec\azvnethub\azvnethub.json"
