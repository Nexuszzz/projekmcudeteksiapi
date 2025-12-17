# Go-WhatsApp (GOWA) Server Launcher
# Fire Detection System - WhatsApp Integration
#
# Run this script to start the Go-WhatsApp REST API server
# GitHub: https://github.com/aldinokemal/go-whatsapp-web-multidevice

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Go-WhatsApp (GOWA) Server Launcher" -ForegroundColor Green
Write-Host "  Fire Detection System - WhatsApp Integration" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$GOWA_PORT = if ($env:GOWA_PORT) { $env:GOWA_PORT } else { "3000" }
$GOWA_DIR = Join-Path $PSScriptRoot "go-whatsapp-web-multidevice\src"

# Check if GOWA directory exists
if (-not (Test-Path $GOWA_DIR)) {
    Write-Host "[ERROR] GOWA directory not found at: $GOWA_DIR" -ForegroundColor Red
    Write-Host "Please ensure go-whatsapp-web-multidevice is in the project root" -ForegroundColor Yellow
    exit 1
}

Set-Location $GOWA_DIR

# Check for pre-built binary
$binaryPath = Join-Path $GOWA_DIR "whatsapp.exe"
$hasBinary = Test-Path $binaryPath

# Check for Go
$hasGo = $null -ne (Get-Command go -ErrorAction SilentlyContinue)

if ($hasBinary) {
    Write-Host "[INFO] Starting pre-built GOWA binary on port $GOWA_PORT..." -ForegroundColor Green
    Write-Host ""
    & $binaryPath rest --port $GOWA_PORT --debug
}
elseif ($hasGo) {
    Write-Host "[INFO] Running GOWA with Go on port $GOWA_PORT..." -ForegroundColor Green
    Write-Host ""
    go run . rest --port $GOWA_PORT --debug
}
else {
    Write-Host "[ERROR] Neither Go nor pre-built binary found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please either:" -ForegroundColor Yellow
    Write-Host "  1. Install Go from https://golang.org/dl/" -ForegroundColor Cyan
    Write-Host "  2. Download pre-built binary from:" -ForegroundColor Cyan
    Write-Host "     https://github.com/aldinokemal/go-whatsapp-web-multidevice/releases" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[INFO] GOWA Server stopped." -ForegroundColor Yellow
