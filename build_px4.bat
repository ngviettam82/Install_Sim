@echo off
REM ========================================
REM Build PX4 SITL for the first time
REM ========================================
REM This batch file calls a PowerShell script for better reliability

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%build_px4.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: build_px4.ps1 not found!
    echo Expected location: %PS_SCRIPT%
    pause
    exit /b 1
)

REM Run the PowerShell script
REM Set execution policy to allow running the script, then execute it
powershell -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%" "%1"

exit /b %errorLevel%
