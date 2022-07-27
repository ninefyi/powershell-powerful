$AzureDevOpsURL = "https://dev.azure.com/"

$OrganizationURL = Read-Host "Enter your destination project organization "

$Project = Read-Host "Enter your destination project "

$Folder = Read-Host "Enter your source folder "

$PAT = Read-Host "Enter your personal access token "

$AzureDevOpsURL = $AzureDevOpsURL + $OrganizationURL

az devops configure -d organization="$($AzureDevOpsURL)" project="$($Project)"

$ProjectId = az devops project show -p "$($Project)" --query "id" -o tsv

$currentLocation = Get-Location

$currentFolderPath = "$($currentLocation)\\$Folder"

Write-Host "Connecting to $($currentFolderPath)"

$CSVFiles = Get-ChildItem -Path $currentFolderPath -Filter *.csv

Write-Host "CSV Files found: " $CSVFiles.Count

$orgUrl = $AzureDevOpsURL

$queryString = "api-version=7.1-preview.2"

$createVariableGroupsUrl = "$($orgUrl)/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$header = @{authorization = "Basic $token"}

$no = 1

foreach ($CSVFile in $CSVFiles) {

    $GroupName = $CSVFile.Name.Replace(".csv", "")

    Write-Host "$($no). $($GroupName):"

    $GroupIdForDelete = az pipelines variable-group list --query "[?name=='$($GroupName)'].{objectId:id}" -o tsv
    if($GroupIdForDelete){
        Write-Host "Deleting variable group $($GroupName)"
        $output = az pipelines variable-group delete --group-id "$($GroupIdForDelete)" --yes
    }

    Write-Host "Importing from $($CSVFile.FullName)."
    $variables = @{}
    Import-Csv $CSVFile.FullName | ForEach-Object {
        $variables["$($_.Variable)"] = @{"value" = "$($_.Value)"}
    }
    $varaibleGroupJSON = @{
        name = "$($GroupName)"
        type = "Vsts"
        variableGroupProjectReferences = @(
            @{ 
                name = "$($GroupName)"
                projectReference = @{
                    id = "$($ProjectId)"
                    name = "$($Project)"
                } 
            }
        )
        variables = $variables
    } | ConvertTo-Json -Depth 4
    $response = Invoke-RestMethod -Uri $createVariableGroupsUrl -Method Post -ContentType "application/json" -Headers $header -Body ($varaibleGroupJSON )
    Write-Host "$($GroupName) created."
    $no = $no + 1
}
Write-Host "Done."