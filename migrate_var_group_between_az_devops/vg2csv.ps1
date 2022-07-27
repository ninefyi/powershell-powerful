$AzureDevOpsURL = "https://dev.azure.com/"

$PAT = Read-Host "Enter your personal access token "

$OrganizationURL = Read-Host "Enter your project organization "

$AzureDevOpsURL = $AzureDevOpsURL + $OrganizationURL

$Project = Read-Host "$($AzureDevOpsURL)>Enter your project "

az devops configure -d organization="$($AzureDevOpsURL)" project="$($Project)"

$json = az pipelines variable-group list

$currentLocation = Get-Location

$groups = $json | ConvertFrom-Json

$CSVFolder = "$($currentLocation)/$($Project)"

if (!(Test-Path $CSVFolder))
{
    New-Item -itemType Directory -Path $currentLocation -Name $Project -Force
}

foreach ($group in $groups)
{
    $CSVFile = "$($CSVFolder)/$($group.name).csv"

    if (Test-Path $CSVFile) 
    {
        Remove-Item $CSVFile
    }

    foreach ($variables in $group.variables)
    {

        foreach ($property in $variables.psobject.properties)
        {
            $VarObject =[pscustomobject]@{
                'Variable' = $property.Name
                'Value' = $property.Value.value
            }
            $VarObject | Export-CSV $CSVFile -Append -NoTypeInformation -Force
        }

    }
}
