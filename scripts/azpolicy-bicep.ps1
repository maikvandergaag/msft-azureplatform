$tempFile = "..\policies\deploy_resource_readonly_lock_on_resource_groups_based_on_tags\policy.bicep"
$mgId = "324f7296-1869-4489-b11e-912351f38ead"

New-AzManagementGroupDeployment -Name "DeployPolicy" -ManagementGroupId $mgId -TemplateFile $tempFile -Location "WestEurope"