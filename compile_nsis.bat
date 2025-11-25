@echo off
REM ========================================
REM PX4 NSIS Installer Packager
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo PX4 NSIS Installer Packager
echo ========================================
echo.

REM Try to find NSIS installation
set NSIS_PATH=C:\Program Files (x86)\NSIS
set MAKENSIS="!NSIS_PATH!\makensis.exe"

if not exist !MAKENSIS! (
    echo ERROR: NSIS is not installed at: !NSIS_PATH!
    echo.
    echo Please install NSIS from: https://nsis.sourceforge.io/Download
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

echo Found NSIS at: !NSIS_PATH!
echo.

REM Compile the installer
echo Compiling NSIS installer...
!MAKENSIS! "PX4_Installer.nsi"

if %errorlevel% neq 0 (
    echo ERROR: Failed to compile NSIS installer!
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo NSIS Installer compiled successfully!
echo ========================================
echo.
echo Output file: Setup.exe
echo Location: %cd%\Setup.exe
echo.
echo The installer is ready to distribute!
echo.
pause
exit /b 0
