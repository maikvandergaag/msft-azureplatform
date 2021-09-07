#Login to the correct azure subscription
Login-AzAccount

$resourcegroup = "gaag-rg-templates";
$location = "westeurope"
$versionnumber = "0.2"

New-AzResourceGroup -Name $resourcegroup -Location $location -Force


bicep build ".\templatespec\securedwebapp\securedwebapp.bicep"
New-AzTemplateSpec -Name "az-tempspec-securedwebapp" -Version "$versionnumber" -ResourceGroupName "$resourcegroup" -Location "$location" -TemplateFile ".\templatespec\securedwebapp\securedwebapp.json"
