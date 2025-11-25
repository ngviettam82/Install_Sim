@echo off
REM ========================================
REM Install GroundController-CTUAV
REM ========================================

setlocal enabledelayedexpansion

echo Installing GroundController-CTUAV...
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

set "GC_INSTALLER=!SCRIPT_DIR!GroundController-installer.exe"

REM Check if installer exists
if not exist "!GC_INSTALLER!" (
    echo ERROR: GroundController-installer.exe not found!
    echo Expected location: !GC_INSTALLER!
    exit /b 1
)

echo.
echo IMPORTANT: Check for any prompted window for driver installation!
echo.
echo Running installer silently...
echo This may take several minutes...
echo.

REM Run the installer silently and wait for it to complete
start /wait "" "!GC_INSTALLER!" /S

REM Wait for installation to complete
timeout /t 3 /nobreak >nul

echo Installation completed successfully!

echo.
echo ========================================
echo GroundController-CTUAV Installation Complete
echo ========================================
echo.

REM Only pause if script is run directly (not called from another script)
if "%1"=="" (
    echo Press any key to continue...
    pause >nul
)

exit /b 0
