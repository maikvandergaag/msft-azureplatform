#Login to the correct azure subscription
Login-AzAccount

bicep build ".\policies\corporate_initiative\initiative.bicep"
$tempFile = ".\policies\corporate_initiative\initiative.json"
$mgId = "mgid"

New-AzManagementGroupDeployment -Name "DeployInitiative" -ManagementGroupId $mgId -TemplateFile $tempFile -Location "WestEurope"