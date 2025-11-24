@echo off
REM ========================================
REM PX4 Development Environment Packager
REM ========================================
REM This script creates a compressed package of all project files

setlocal enabledelayedexpansion

echo.
echo ========================================
echo PX4 Development Environment Packager
echo ========================================
echo.

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo ERROR: 7-Zip is not installed!
    echo Please install 7-Zip from: https://www.7-zip.org/
    echo.
    pause
    exit /b 1
)

REM Create output directory
set OUTPUT_DIR=%cd%\Package
if exist "%OUTPUT_DIR%" (
    echo Removing existing package directory...
    rmdir /s /q "%OUTPUT_DIR%"
)

mkdir "%OUTPUT_DIR%"
echo Created package directory: %OUTPUT_DIR%

REM Copy all necessary files
echo.
echo Copying project files...

copy "setup_all.bat" "%OUTPUT_DIR%\" >nul
copy "install_wsl.bat" "%OUTPUT_DIR%\" >nul
copy "install_groundcontroller.bat" "%OUTPUT_DIR%\" >nul
copy "build_px4.bat" "%OUTPUT_DIR%\" >nul
copy "px4s.bat" "%OUTPUT_DIR%\" >nul
copy "setup_settings.bat" "%OUTPUT_DIR%\" >nul

copy "setup_px4_in_wsl.ps1" "%OUTPUT_DIR%\" >nul
copy "build_px4.ps1" "%OUTPUT_DIR%\" >nul
copy "setup_settings.ps1" "%OUTPUT_DIR%\" >nul

copy "GroundController-installer.exe" "%OUTPUT_DIR%\" >nul 2>&1
copy "README.md" "%OUTPUT_DIR%\" >nul
copy ".gitignore" "%OUTPUT_DIR%\" >nul

echo Files copied successfully!

REM Create the archive
echo.
echo Creating compressed archive...

set ARCHIVE_NAME=PX4_Development_Setup.7z

"C:\Program Files\7-Zip\7z.exe" a -r "%cd%\%ARCHIVE_NAME%" "%OUTPUT_DIR%\*" >nul

if %errorlevel% equ 0 (
    echo Archive created successfully: %ARCHIVE_NAME%
    echo Location: %cd%\%ARCHIVE_NAME%
    echo.
    
    REM Clean up temporary directory
    rmdir /s /q "%OUTPUT_DIR%"
    echo.
    echo Packager completed successfully!
    echo.
    echo To distribute: Share %ARCHIVE_NAME%
    echo To extract: Use 7-Zip or Windows built-in extraction
    echo.
) else (
    echo ERROR: Failed to create archive!
    pause
    exit /b 1
)

echo.
pause
exit /b 0
