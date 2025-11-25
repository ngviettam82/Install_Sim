#!/usr/bin/env powershell
<#
.SYNOPSIS
Build PX4 SITL (Software In The Loop)
#>

param(
    [string]$Parameter = ""
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "PX4 SITL Build Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Building PX4 SITL..." -ForegroundColor Yellow
Write-Host "This may take 10-20 minutes on first build..." -ForegroundColor Yellow
Write-Host ""

# Check if WSL is installed
Write-Host "Checking WSL status..." -ForegroundColor Yellow
wsl --status >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: WSL is not installed or not running!" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "WSL is running." -ForegroundColor Green
Write-Host ""

Write-Host "Running PX4 SITL build in WSL..." -ForegroundColor Yellow
Write-Host ""

# Create script content lines
$bashScriptLines = @(
    '#!/bin/bash',
    'set -e',
    '',
    'echo "Starting PX4 SITL build..."',
    'echo ""',
    'cd ~/PX4-Autopilot',
    'make',
    ''
)

# Join script lines with LF only
$scriptContent = $bashScriptLines -join "`n"

# Escape the script for use in WSL bash -c command
# Convert to base64 to avoid quoting issues entirely
$scriptBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$scriptB64 = [System.Convert]::ToBase64String($scriptBytes)

# Execute via WSL using base64 decoding to preserve exact byte content
wsl -d Ubuntu-22.04 -u ubuntu bash -c "echo '$scriptB64' | base64 -d | bash"

$buildResult = $LASTEXITCODE

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

if ($buildResult -ne 0) {
    Write-Host "ERROR: PX4 build failed!" -ForegroundColor Red
    Write-Host "Exit Code: $buildResult" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure you ran setup_px4_in_wsl.bat first" -ForegroundColor Yellow
    Write-Host "2. Check available disk space (PX4 build requires ~2GB)" -ForegroundColor Yellow
    Write-Host "3. Try cleaning and rebuilding: wsl -d Ubuntu-22.04 -u ubuntu bash -c 'cd ~/PX4-Autopilot && make clean'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
} else {
    Write-Host "PX4 SITL build completed successfully!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now run PX4 SITL with:" -ForegroundColor Green
    Write-Host "  wsl" -ForegroundColor Cyan
    Write-Host "  px4s" -ForegroundColor Cyan
    Write-Host ""
}

# Only pause if script is run directly (not called from another script)
if ($Parameter -eq "") {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    pause
}

exit 0
