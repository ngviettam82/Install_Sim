@echo off
REM ========================================
REM PX4 Development Environment Uninstaller
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo PX4 Development Environment Uninstaller
echo ========================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo Uninstalling PX4 Development Environment...
echo.

echo [1/3] Terminating WSL Ubuntu-22.04 distribution...
wsl --terminate Ubuntu-22.04
echo Done.
echo.

echo [2/3] Unregistering WSL Ubuntu-22.04 distribution...
wsl --unregister Ubuntu-22.04
echo Done.
echo.

echo [3/3] Uninstalling WSL...
wsl --uninstall
echo Done.
echo.

echo Uninstalling GroundController...
if exist "C:\Program Files\GroundController\GroundController-Uninstall.exe" (
    echo Running GroundController uninstaller...
    start /wait "" "C:\Program Files\GroundController\GroundController-Uninstall.exe"
    echo GroundController uninstalled.
) else (
    echo WARNING: GroundController uninstaller not found at C:\Program Files\GroundController\GroundController-Uninstall.exe
    echo You may need to uninstall GroundController manually.
)

echo.
echo ========================================
echo Uninstallation Complete!
echo ========================================
echo.
pause

exit /b 0
