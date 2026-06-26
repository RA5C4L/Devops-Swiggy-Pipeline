$ip = (terraform -chdir="$PSScriptRoot/terraform" output -raw instance_public_ip 2>$null)

if (-not $ip) {
    Write-Host "Could not get IP from terraform output. Run terraform apply first."
    exit 1
}

$url = "http://$ip`:8080/login"
Write-Host "Waiting for Jenkins at $url ..."
Write-Host "(This takes 8-10 minutes. Checking every 15 seconds)"
Write-Host ""

$attempt = 1
while ($true) {
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host ""
            Write-Host "Jenkins is ready! Open: http://$ip`:8080"
            Write-Host "Login: admin / admin"
            break
        }
    } catch {
        Write-Host "[$attempt] Not ready yet... ($([int]($attempt * 0.5)) min elapsed)"
    }
    $attempt++
    Start-Sleep -Seconds 15
}
