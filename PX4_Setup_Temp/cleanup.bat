@echo off
REM This script deletes the setup temp folder after installation
REM Called with a delay to allow all processes to exit
REM Parameter 1: Parent directory path (e.g., C:\Users\ADMIN\Desktop\Sim Launcher)

setlocal enabledelayedexpansion

REM Get the base directory from parameter or calculate it
if "%~1"=="" (
    REM If no parameter, calculate parent directory
    set "BASE_DIR=%~dp0.."
) else (
    REM Use the provided parameter
    set "BASE_DIR=%~1"
)

REM Wait 5 seconds to ensure all processes are released
timeout /t 5 /nobreak >nul

REM Delete the temp folder and all contents
if exist "!BASE_DIR!\PX4_Setup_Temp" (
    rmdir /s /q "!BASE_DIR!\PX4_Setup_Temp" 2>nul
    if exist "!BASE_DIR!\PX4_Setup_Temp" (
        REM If still exists, try again with more delay
        timeout /t 3 /nobreak >nul
        rmdir /s /q "!BASE_DIR!\PX4_Setup_Temp" 2>nul
    )
)

exit /b 0
