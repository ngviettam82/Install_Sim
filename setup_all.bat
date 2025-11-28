@echo off
REM ========================================
REM Complete Setup Script for PX4 Development Environment
REM ========================================
REM This script will:
REM 1. Install WSL with Ubuntu 22.04
REM 2. Clone and install PX4 Autopilot
REM 3. Build PX4 SITL
REM 4. Install GroundController-CTUAV
REM ========================================

REM Disable Quick Edit mode for current console to prevent click-pause issue (ensure extended flags are set)
powershell -NoProfile -Command "$code = '[DllImport(\"kernel32.dll\", SetLastError=true)] public static extern IntPtr GetStdHandle(int h); [DllImport(\"kernel32.dll\", SetLastError=true)] public static extern bool GetConsoleMode(IntPtr h, out uint m); [DllImport(\"kernel32.dll\", SetLastError=true)] public static extern bool SetConsoleMode(IntPtr h, uint m);'; $t = Add-Type -MemberDefinition $code -Name 'W' -Namespace 'C' -PassThru; $h = $t::GetStdHandle(-10); $m = 0; if ($t::GetConsoleMode($h, [ref]$m)) { $m = ($m -bor 0x0080) -band (-bnot 0x0040); $null = $t::SetConsoleMode($h, $m) }" >nul 2>&1

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

echo [1/5] Installing WSL with Ubuntu 22.04...
call "%~dp0install_wsl.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: WSL installation failed!
    pause
    exit /b 1
)
echo WSL installation completed successfully!
echo.

echo.
echo [2/5] Setting up PX4 Autopilot in WSL...
call "%~dp0setup_px4_in_wsl.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: PX4 setup failed!
    pause
    exit /b 1
)
echo PX4 setup completed successfully!
echo.

echo.
echo [3/5] Building PX4 SITL...
call "%~dp0build_px4.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: PX4 build failed!
    pause
    exit /b 1
)
echo PX4 build completed successfully!
echo.

echo.
echo [4/5] Installing GroundController-CTUAV...
call "%~dp0install_groundcontroller.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: GroundController-CTUAV installation failed!
    pause
    exit /b 1
)
echo GroundController-CTUAV installation completed successfully!
echo.

echo.
echo [5/5] Configuring AirSim Settings...
call "%~dp0setup_settings.bat" auto
if %errorLevel% neq 0 (
    echo ERROR: Settings configuration failed!
    pause
    exit /b 1
)
echo Settings configuration completed successfully!
echo.

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Press any key to close this window...
pause >nul
exit /b 0
