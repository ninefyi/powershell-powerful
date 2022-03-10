$docker_space = docker system df
$build_cache = $docker_space[$docker_space.Count-1]
$current_size = [regex]::Split($build_cache," {2,}")[$current_size.Count-1]
Write-Host $current_size