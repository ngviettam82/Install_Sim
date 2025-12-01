@echo off
REM ========================================
REM PX4 Development Environment Uninstaller
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo PX4 Development Environment Uninstaller
echo ========================================
echo.


echo Uninstalling PX4 Development Environment...
echo.

REM Check if WSL is installed
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    echo [1/3] Terminating WSL Ubuntu-22.04 distribution...
    wsl --terminate Ubuntu-22.04 >nul 2>&1
    echo Done.
    echo.

    echo [2/3] Unregistering WSL Ubuntu-22.04 distribution...
    wsl --unregister Ubuntu-22.04 >nul 2>&1
    echo Done.
    echo.

    echo [3/3] Uninstalling WSL...
    wsl --uninstall >nul 2>&1
    echo Done.
    echo.
) else (
    echo WSL is not installed, skipping WSL uninstallation.
    echo.
)

echo Uninstalling GroundController...
if exist "C:\Program Files\GroundController\GroundController-Uninstall.exe" (
    echo Running GroundController uninstaller...
    start /wait "" "C:\Program Files\GroundController\GroundController-Uninstall.exe" /S >nul 2>&1
    echo GroundController uninstalled.
) else (
    echo WARNING: GroundController uninstaller not found at C:\Program Files\GroundController\GroundController-Uninstall.exe
    echo You may need to uninstall GroundController manually.
)

echo.
echo ========================================
echo Uninstallation Complete!
echo ========================================


exit /b 0
