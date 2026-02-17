# Configure error handling
$ErrorActionPreference = "Continue"

Write-Host "Setting Git proxy to http://127.0.0.1:7890..." -ForegroundColor Cyan
git config http.proxy http://127.0.0.1:7890

Write-Host "Running photo sync script..." -ForegroundColor Cyan
try {
    # Assuming this script is in tools/, and sync_photos.ps1 is also in tools/
    & "$PSScriptRoot\sync_photos.ps1"
} catch {
    Write-Error "Photo sync failed: $_"
    exit 1
}

Write-Host "Checking for changes..." -ForegroundColor Cyan
git add .
$status = git status --porcelain
if ($status) {
    Write-Host "Committing changes..." -ForegroundColor Green
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    git commit -m "Auto-update photos: $date"
} else {
    Write-Host "No changes to commit." -ForegroundColor Yellow
}

Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "----------------------------------------" -ForegroundColor Green
    Write-Host "SUCCESS! Website updated." -ForegroundColor Green
    Write-Host "Visit: https://huruzun.github.io/memory/" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Green
} else {
    Write-Host "----------------------------------------" -ForegroundColor Red
    Write-Host "PUSH FAILED. Please check your network connection." -ForegroundColor Red
    Write-Host "Ensure your proxy is running." -ForegroundColor Red
    Write-Host "----------------------------------------" -ForegroundColor Red
    exit 1
}
