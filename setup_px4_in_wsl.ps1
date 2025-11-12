#!/usr/bin/env powershell
<#
.SYNOPSIS
Setup PX4 Autopilot in WSL Ubuntu 22.04
#>

param(
    [string]$Parameter = ""
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "PX4 Autopilot Setup Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed
Write-Host "Checking WSL status..." -ForegroundColor Yellow
wsl --status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: WSL is not installed or not running!" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "WSL is running." -ForegroundColor Green
Write-Host ""

# Auto-detect WSL IP address from network adapter
Write-Host "Detecting WSL IP address..." -ForegroundColor Yellow
$wslIpConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*WSL*" }
$wslIp = $wslIpConfig.IPAddress

if ($wslIp) {
    Write-Host "Found WSL IP: $wslIp" -ForegroundColor Green
} else {
    Write-Host "WARNING: Could not auto-detect WSL IP address" -ForegroundColor Yellow
    Write-Host "You may need to set PX4_SIM_HOST_ADDR manually" -ForegroundColor Yellow
    $wslIp = "172.20.128.1"  # Default fallback
    Write-Host "Using fallback IP: $wslIp" -ForegroundColor Yellow
}
Write-Host ""

# Create and run the setup script in WSL
Write-Host "Creating PX4 setup script in WSL..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Running setup in WSL..." -ForegroundColor Yellow
Write-Host ""

# Create script content with explicit Unix line endings (LF only)
$bashScriptLines = @(
    '#!/bin/bash',
    'set -e',
    '',
    'echo "========================================="',
    'echo "PX4 Autopilot Setup Script"',
    'echo "========================================="',
    'echo ""',
    '',
    'echo "[1/7] Updating system packages..."',
    'sudo apt-get update -y',
    'sudo apt-get upgrade -y',
    '',
    'echo "[2/7] Installing essential tools..."',
    'sudo apt-get install -y git wget curl build-essential cmake ninja-build python3-pip python3-dev',
    '',
    'echo "[3/7] Cloning/Updating PX4-Autopilot repository..."',
    'if [ -d ~/PX4-Autopilot ]; then',
    '    cd ~/PX4-Autopilot',
    '    git fetch --all',
    '    git pull',
    'else',
    '    cd ~',
    '    git clone https://github.com/ngviettam82/PX4-Autopilot.git --recursive',
    'fi',
    '',
    'echo "[4/7] Running PX4 dependency installation..."',
    'cd ~/PX4-Autopilot',
    'bash ./Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools',
    '',
    'echo "[5/7] Installing Python dependencies..."',
    'pip3 install --user -r Tools/setup/requirements.txt',
    '',
    'echo "[6/7] Setting up px4s alias..."',
    'if ! grep -q "alias px4s=" ~/.bashrc; then',
    '    cat >> ~/.bashrc << ALIASEOF',
    "alias px4s='cd ~/PX4-Autopilot && make px4_sitl none_iris'",
    'ALIASEOF',
    'fi',
    '',
    'echo "[7/7] Adding PX4_SIM_HOST_ADDR export..."',
    'if ! grep -q "export PX4_SIM_HOST_ADDR=" ~/.bashrc; then',
    '    echo "export PX4_SIM_HOST_ADDR=WSLIP_PLACEHOLDER" >> ~/.bashrc',
    '    echo "Added PX4_SIM_HOST_ADDR=WSLIP_PLACEHOLDER"',
    'else',
    '    echo "PX4_SIM_HOST_ADDR already configured in ~/.bashrc"',
    'fi',
    '',
    'echo "[8/8] Applying px4-rc.mavlink configuration..."',
    'RC_FILE=~/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/px4-rc.mavlink',
    'if [ -f "$RC_FILE" ]; then',
    '    sed -i "14s/$/ -p/" "$RC_FILE"',
    '    echo "Modified px4-rc.mavlink file (added -p flag to line 14)"',
    '    echo "mavlink start -x -u 14600 -o 14560 -f -p -t WSLIP_PLACEHOLDER" >> "$RC_FILE"',
    '    echo "mavlink stream -u 14600 -s MANUAL_CONTROL -r 20" >> "$RC_FILE"',
    '    echo "Added mavlink start command and stream command to end of px4-rc.mavlink"',
    'else',
    '    echo "Warning: px4-rc.mavlink file not found"',
    'fi',
    'echo ""',
    'echo "========================================="',
    'echo "PX4 Setup Complete!"',
    'echo "PX4_SIM_HOST_ADDR will be available in new terminal sessions"',
    'echo "========================================="'
)

# Join script lines with LF only
$scriptContent = $bashScriptLines -join "`n"

# Replace the IP placeholder with the actual WSL IP address
$scriptContent = $scriptContent -replace "WSLIP_PLACEHOLDER", $wslIp

# Escape the script for use in WSL bash -c command
# Convert to base64 to avoid quoting issues entirely
$scriptBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$scriptB64 = [System.Convert]::ToBase64String($scriptBytes)

# Execute via WSL using base64 decoding to preserve exact byte content
wsl -d Ubuntu-22.04 -u ubuntu bash -c "echo '$scriptB64' | base64 -d | bash"

$setupResult = $LASTEXITCODE

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

if ($setupResult -ne 0) {
    Write-Host "ERROR: PX4 setup failed!" -ForegroundColor Red
    Write-Host "Exit Code: $setupResult" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure sudo is enabled in WSL" -ForegroundColor Yellow
    Write-Host "2. Check internet connection" -ForegroundColor Yellow
    Write-Host "3. Try running: wsl -d Ubuntu-22.04 -u root bash -c `"sudo -l`"" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
} else {
    Write-Host "PX4 Autopilot setup completed successfully!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Only pause if script is run directly (not called from another script)
if ($Parameter -eq "") {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    pause
}

exit 0
