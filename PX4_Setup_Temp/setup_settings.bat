@echo off
REM ========================================
REM Settings Configuration Script for AirSim
REM ========================================

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

set "PS_SCRIPT=!SCRIPT_DIR!setup_settings.ps1"

REM Check if PowerShell script exists
if not exist "!PS_SCRIPT!" (
    echo ERROR: setup_settings.ps1 not found!
    echo Expected location: !PS_SCRIPT!
    exit /b 1
)

echo Running PowerShell script: !PS_SCRIPT!
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PS_SCRIPT!" %1

exit /b %errorLevel%
