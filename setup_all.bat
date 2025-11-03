@echo off
REM ========================================
REM Complete Setup Script for PX4 Development Environment
REM ========================================
REM This script will:
REM 1. Install WSL with Ubuntu 22.04
REM 2. Clone and install PX4 Autopilot
REM 3. Build PX4 SITL
REM 4. Install QGroundControl
REM ========================================

echo ========================================
echo PX4 Development Environment Setup
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [1/4] Installing WSL with Ubuntu 22.04...
call "%~dp0install_wsl.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: WSL installation failed!
    pause
    exit /b 1
)
echo WSL installation completed successfully!
echo.

echo.
echo [2/4] Setting up PX4 Autopilot in WSL...
call "%~dp0setup_px4_in_wsl.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: PX4 setup failed!
    pause
    exit /b 1
)
echo PX4 setup completed successfully!
echo.

echo.
echo [3/4] Building PX4 SITL...
call "%~dp0build_px4.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: PX4 build failed!
    pause
    exit /b 1
)
echo PX4 build completed successfully!
echo.

echo.
echo [4/4] Installing QGroundControl...
call "%~dp0install_qgroundcontrol.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: QGroundControl installation failed!
    pause
    exit /b 1
)
echo QGroundControl installation completed successfully!
echo.

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo You can now:
echo   - Run PX4 SITL: px4s.bat
echo   - Run QGroundControl: qgc.bat
echo.
pause
