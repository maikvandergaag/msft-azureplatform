[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Subscription', 'Managementgroup')]
    [string]$Scope,
    [Parameter(Mandatory = $true)]
    [string]$ScopeName,
    [Parameter(Mandatory = $true)]
    [string]$PolicyFolder,
    [Parameter(Mandatory = $false)]
    [string]$RoleIds
)

$policyFiles = Get-ChildItem -Path $PolicyFolder -Recurse -Filter "*.json"
foreach ($policyFile in $policyFiles) {

    Write-Output "Working on Policy: $($policyFile.Name)"

    $policyDefinitionFileContent = Get-Content -Raw -Path $PolicyFile
    $policyDefinitionFile = ConvertFrom-Json $policyDefinitionFileContent
    $policyDefinitionName = $policyDefinitionFile.properties.displayName

    $parameters = @{}
    $parameters.Add("Name", $policyDefinitionName)
    switch ($Scope) {
        "ManagementGroup" {
            $parameters.Add("ManagementGroupName", $ScopeName)
        }
        "Subscription" {
            $sub = Get-AzSubscription -SubscriptionName $ScopeName
            $parameters.Add("SubscriptionId", $sub.Id)
        }
    }

    $definition = Get-AzPolicyDefinition @parameters -ErrorAction SilentlyContinue

    $parameters.Add("Policy", $policyDefinitionFileContent)
    if ($definition) {
        Write-Output "Policy definition already exists, policy will be updated"
    }
    else {
        Write-Output "Policy does not exist"
    }

    New-AzPolicyDefinition @parameters
}
