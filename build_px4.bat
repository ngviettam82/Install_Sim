@echo off
REM ========================================
REM Build PX4 SITL for the first time
REM ========================================

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

set "PS_SCRIPT=!SCRIPT_DIR!build_px4.ps1"

REM Check if PowerShell script exists
if not exist "!PS_SCRIPT!" (
    echo ERROR: build_px4.ps1 not found!
    echo Expected location: !PS_SCRIPT!
    pause
    exit /b 1
)

echo Running PowerShell script: !PS_SCRIPT!
powershell -ExecutionPolicy Bypass -NoProfile -File "!PS_SCRIPT!" "%1"

if %errorLevel% neq 0 (
    echo.
    echo ERROR: PX4 build failed with exit code %errorLevel%
    echo.
    pause
    exit /b %errorLevel%
)

exit /b 0
