#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"
$versionnumber = "0.1"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\azavd\azavd.bicep"
New-AzTemplateSpec -Name "az-tempspec-avd" -Version "$versionnumber" -ResourceGroupName "$resourcegroup" -Location "$location" -TemplateFile ".\templatespec\azavd\azavd.json"
