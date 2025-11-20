@echo off
REM ========================================
REM Install GroundController-CTUAV
REM ========================================

echo Installing GroundController-CTUAV...
echo.

REM Set installation directory
set "INSTALL_DIR=C:\Program Files\GroundController"
set "GC_INSTALLER=%~dp0GroundController-installer.exe"

REM Check if installer exists
if not exist "%GC_INSTALLER%" (
    echo ERROR: GroundController-installer.exe not found!
    echo Expected location: %GC_INSTALLER%
    exit /b 1
)

REM Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo.
echo Running installer...
echo The GroundController-CTUAV installer window will appear.
echo Please follow the prompts, including the UAV driver installation.
echo This may take several minutes...
echo.

REM Run the installer and wait for it to complete
REM Note: NSIS installer may install to default location regardless of /D parameter
REM We'll use /S for silent installation and /D to try to set the directory
start /wait "" "%GC_INSTALLER%" /S /D="%INSTALL_DIR%"

REM Wait for installation to complete
timeout /t 3 /nobreak >nul

if %errorLevel% neq 0 (
    echo ERROR: GroundController-CTUAV installation failed!
    echo Exit code: %errorLevel%
    exit /b 1
)

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
