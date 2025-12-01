#!/usr/bin/env powershell
<#
.SYNOPSIS
Setup AirSim Settings - Updates LocalHostIp in all settings.json files with WSL IP
#>

param(
    [string]$Parameter = ""
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "AirSim Settings Configuration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory using PSScriptRoot (more reliable)
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommandPath
}
$projectDir = Split-Path -Parent $scriptDir

# New folder structure: resources/maps/prod and resources/maps/tutorials
$resourceMapsDir = Join-Path $projectDir "resources" "maps"
$mapsFolder = Join-Path $resourceMapsDir "prod"
$tutorialMapsFolder = Join-Path $resourceMapsDir "tutorials"

# Legacy folder structure fallback: Maps and Tutorial Maps
$legacyMapsFolder = Join-Path $projectDir "Maps"
$legacyTutorialMapsFolder = Join-Path $projectDir "Tutorial Maps"

Write-Host "[*] Project Directory: $projectDir" -ForegroundColor Yellow

# Determine which folder structure to use
$usingNewStructure = (Test-Path $mapsFolder) -or (Test-Path $tutorialMapsFolder)
$usingLegacyStructure = (Test-Path $legacyMapsFolder) -or (Test-Path $legacyTutorialMapsFolder)

if ($usingNewStructure) {
    Write-Host "[*] Using new folder structure" -ForegroundColor Green
    Write-Host "[*] Maps Directory: $mapsFolder" -ForegroundColor Yellow
    Write-Host "[*] Tutorial Maps Directory: $tutorialMapsFolder" -ForegroundColor Yellow
} elseif ($usingLegacyStructure) {
    Write-Host "[*] Using legacy folder structure" -ForegroundColor Yellow
    $mapsFolder = $legacyMapsFolder
    $tutorialMapsFolder = $legacyTutorialMapsFolder
    Write-Host "[*] Maps Directory: $mapsFolder" -ForegroundColor Yellow
    Write-Host "[*] Tutorial Maps Directory: $tutorialMapsFolder" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: No Maps folders found!" -ForegroundColor Red
    Write-Host "Expected new structure: $mapsFolder" -ForegroundColor Red
    Write-Host "Or legacy structure: $legacyMapsFolder" -ForegroundColor Red
    if ($Parameter -eq "") {
        pause
    }
    exit 1
}
Write-Host ""

# Get WSL IP address using the same method as setup_px4_in_wsl.ps1
Write-Host "[*] Detecting WSL IP address..." -ForegroundColor Yellow
$wslIpConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*WSL*" }
$wslIp = $wslIpConfig.IPAddress

if ($wslIp) {
    Write-Host "Found WSL IP: $wslIp" -ForegroundColor Green
} else {
    Write-Host "ERROR: Could not detect WSL IP address!" -ForegroundColor Red
    Write-Host "Make sure WSL is installed and running." -ForegroundColor Red
    if ($Parameter -eq "") {
        pause
    }
    exit 1
}
Write-Host ""

# Get all folders in Maps and Tutorial Maps directories
$mapFolders = @()

if (Test-Path $mapsFolder) {
    $mapFolders += Get-ChildItem -Path $mapsFolder -Directory
}

if (Test-Path $tutorialMapsFolder) {
    $mapFolders += Get-ChildItem -Path $tutorialMapsFolder -Directory
}

if ($mapFolders.Count -eq 0) {
    Write-Host "WARNING: No folders found in Maps or Tutorial Maps directories" -ForegroundColor Yellow
    if ($Parameter -eq "") {
        pause
    }
    exit 0
}

Write-Host "[*] Found $($mapFolders.Count) total map folder(s)" -ForegroundColor Yellow
Write-Host ""

# Process each folder
$successCount = 0
$failureCount = 0

foreach ($folder in $mapFolders) {
    $settingsJsonPath = Join-Path $folder.FullName "settings.json"
    
    Write-Host "Processing folder: $($folder.Name)" -ForegroundColor Cyan
    
    if (-not (Test-Path $settingsJsonPath)) {
        Write-Host "  [!] settings.json not found in $($folder.Name) - Skipping" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Read the settings.json file
        $jsonContent = Get-Content -Path $settingsJsonPath -Raw
        
        # Check if LocalHostIp exists in the file
        if ($jsonContent -match '"LocalHostIp"\s*:\s*"[^"]*"') {
            Write-Host "  [*] Found LocalHostIp, updating..." -ForegroundColor Blue
            
            # Replace LocalHostIp value using regex (handles indentation)
            $updatedContent = $jsonContent -replace `
                '"LocalHostIp"\s*:\s*"[^"]*"', `
                ('"LocalHostIp": "{0}"' -f $wslIp)
            
            # Write the updated content back to the file
            Set-Content -Path $settingsJsonPath -Value $updatedContent -Encoding UTF8
            
            Write-Host "  [+] Updated with WSL IP: $wslIp" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  [!] LocalHostIp not found in settings.json - Skipping" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  [x] Error updating settings.json: $_" -ForegroundColor Red
        $failureCount++
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Settings Update Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Successfully updated: $successCount file(s)" -ForegroundColor Green
if ($failureCount -gt 0) {
    Write-Host "Failed updates: $failureCount file(s)" -ForegroundColor Red
}
Write-Host ""
Write-Host "[+] Settings configuration completed successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Only pause if script is run directly (not called from another script)
if ($Parameter -eq "") {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    pause
}

exit 0
