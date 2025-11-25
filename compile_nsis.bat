@echo off
REM ========================================
REM PX4 NSIS Installer Packager (64-bit)
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo PX4 NSIS Installer Packager (64-bit)
echo ========================================
echo.

REM Try to find NSIS installation - prefer 64-bit Bin folder
set NSIS_PATH=C:\Program Files (x86)\NSIS
set MAKENSIS=

REM Check for 64-bit makensis in Bin\makensis.exe
if exist "!NSIS_PATH!\Bin\makensis.exe" (
    set MAKENSIS="!NSIS_PATH!\Bin\makensis.exe"
    echo Found 64-bit NSIS compiler
) else if exist "!NSIS_PATH!\makensis.exe" (
    set MAKENSIS="!NSIS_PATH!\makensis.exe"
    echo Found standard NSIS compiler
)

if "!MAKENSIS!"=="" (
    echo ERROR: NSIS is not installed at: !NSIS_PATH!
    echo.
    echo Please install NSIS from: https://nsis.sourceforge.io/Download
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

echo Found NSIS at: !NSIS_PATH!
echo Using compiler: !MAKENSIS!
echo.

REM Compile the installer as 64-bit
echo Compiling 64-bit NSIS installer...
!MAKENSIS! /INPUTCHARSET UTF8 "PX4_Installer.nsi"

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
