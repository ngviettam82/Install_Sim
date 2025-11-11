@echo off
REM ========================================
REM Settings Configuration Script for AirSim
REM ========================================
REM This script calls the PowerShell setup script

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_settings.ps1" %1

exit /b %errorLevel%
