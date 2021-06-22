#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"
$versionnumber = "0.4"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\azinternalvm\azinternalvm.bicep"
New-AzTemplateSpec -Name "az-tempspec-internalvm" -Version "$versionnumber" -ResourceGroupName "$resourcegroup" -Location "$location" -TemplateFile ".\templatespec\azinternalvm\azinternalvm.json"
