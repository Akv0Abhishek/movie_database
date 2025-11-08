# Script to get SHA-256 fingerprint for Android App Links
# Usage: 
#   For debug keystore: .\get_sha256.ps1
#   For release keystore: .\get_sha256.ps1 -keystore "path/to/keystore.jks" -alias "your-alias"

param(
    [string]$keystore = "$env:USERPROFILE\.android\debug.keystore",
    [string]$alias = "androiddebugkey",
    [string]$storepass = "android",
    [string]$keypass = "android"
)

Write-Host "Getting SHA-256 fingerprint from keystore: $keystore" -ForegroundColor Cyan

if (-not (Test-Path $keystore)) {
    Write-Host "Error: Keystore file not found at $keystore" -ForegroundColor Red
    Write-Host "For release builds, specify the keystore path:" -ForegroundColor Yellow
    Write-Host "  .\get_sha256.ps1 -keystore `"path/to/keystore.jks`" -alias `"your-alias`" -storepass `"your-password`" -keypass `"your-password`"" -ForegroundColor Yellow
    exit 1
}

$fingerprint = keytool -list -v -keystore $keystore -alias $alias -storepass $storepass -keypass $keypass 2>&1 | Select-String -Pattern "SHA256:" | ForEach-Object { $_.Line.Trim() }

if ($fingerprint) {
    Write-Host "`nSHA-256 Fingerprint:" -ForegroundColor Green
    Write-Host $fingerprint -ForegroundColor White
    Write-Host "`nUpdate this in: public/.well-known/assetlinks.json" -ForegroundColor Yellow
} else {
    Write-Host "Error: Could not extract SHA-256 fingerprint" -ForegroundColor Red
}

