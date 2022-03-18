$acr="[ACR]"
$username="[ACR User]"
$password="[ACR Password]"

$HostName = [System.Net.DNS]::GetHostByName($Null).HostName

try {

    az acr login -n $acr -u $username -p $password

    docker pull [your images]

    Write-Host "Pulling the base images are complete!"

    $message = "<h2>Pulliing the base images are successfully on $($HostName)</h2><br/>"
    $lines = docker images
    ForEach($line in $lines){
      $message = $message + $line + "<br/>"
    }
    
    $JSONBody = [PSCustomObject][Ordered]@{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "Pull images on build agents job status - $($HostName) Success!"
        "themeColor" = '0078D7'
        "title"      = "Pull images on build agents job status - $($HostName) Success!"
        "text"       = $message
    }
    # Restart-Computer
}
catch {

    $ErrorMessage = $_
    $message = "<h2>An error occurred on $($HostName):$($ErrorMessage)</h2>"

    $JSONBody = [PSCustomObject][Ordered]@{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "Pull images on build agents job status - $($HostName) Error!"
        "themeColor" = '0078D7'
        "title"      = "Pull images on build agents job status - $($HostName) Error!"
        "text"       = $message
    }
    
}

$MSTeamsChannelURI = "[Webhook]"

$MSTeamsMessageBody = ConvertTo-Json $JSONBody -Depth 100

$parameters = @{
    "URI"         = $MSTeamsChannelURI
    "Method"      = 'POST'
    "Body"        = $MSTeamsMessageBody
    "ContentType" = 'application/json'
}

Invoke-RestMethod @parameters
