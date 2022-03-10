$HostName = [System.Net.DNS]::GetHostByName($Null).HostName

try {

    $c_drive = Get-Volume -DriveLetter C
    $before_size_in_gb = [Math]::Round($c_drive.SizeRemaining / 1GB, 2)

    Invoke-Command -ScriptBlock { docker builder prune -a -f }
    Invoke-Command -ScriptBlock { wsl --shutdown }
    Invoke-Command -ScriptBlock { DISKPART /s diskpart.txt }

    $c_drive = Get-Volume -DriveLetter C
    $end_size_in_gb = [Math]::Round($c_drive.SizeRemaining / 1GB, 2)

    Write-Host "Cleanup complete!"

    $message = "<h2>Cleanup successfully on C drive of $($HostName)</h2><br/>Free space before clean up: $($before_size_in_gb) GB<br/>Free space after clean up: $($end_size_in_gb) GB"
    
    $JSONBody = [PSCustomObject][Ordered]@{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "Cleanup build agents job status - $($HostName) Success!"
        "themeColor" = '0078D7'
        "title"      = "Cleanup build agents job status - $($HostName) Success!"
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
        "summary"    = "Cleanup build agents job status - $($HostName) Error!"
        "themeColor" = '0078D7'
        "title"      = "Cleanup build agents job status - $($HostName) Error!"
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

Write-Host "Rebooting in 10 secs"
Start-Sleep -s 10