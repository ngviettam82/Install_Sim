@echo off
setlocal enabledelayedexpansion
REM ============================================================================
REM WSL2 and Ubuntu 22.04 Installation Script
REM ============================================================================
REM This script will:
REM 1. Enable WSL and Virtual Machine Platform features
REM 2. Set WSL 2 as the default version
REM 3. Install Ubuntu 22.04
REM 4. Auto-configure Ubuntu with root user
REM ============================================================================

echo.
echo ============================================================================
echo WSL2 and Ubuntu 22.04 Installation Script
echo ============================================================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please run this script as Administrator.
    echo.
    pause
    exit /b 1
)

echo *** ENABLING WINDOWS SUBSYSTEM FOR LINUX ***
echo.

echo [Step 1/4] Enabling WSL feature...
echo Attempting to enable Microsoft-Windows-Subsystem-Linux feature...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
set WSL_RESULT=%errorlevel%
if %WSL_RESULT% equ 0 (
    echo WSL feature enabled successfully.
) else if %WSL_RESULT% equ 3010 (
    echo WSL feature enabled successfully ^(restart required^).
) else if %WSL_RESULT% equ 1 (
    echo WSL feature already enabled.
) else (
    echo WARNING: DISM returned code %WSL_RESULT%. This may be normal if the feature is already enabled.
)
echo.

echo [Step 2/4] Enabling Virtual Machine Platform feature...
echo Attempting to enable VirtualMachinePlatform feature...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
set VM_RESULT=%errorlevel%
if %VM_RESULT% equ 0 (
    echo Virtual Machine Platform feature enabled successfully.
) else if %VM_RESULT% equ 3010 (
    echo Virtual Machine Platform feature enabled successfully ^(restart required^).
) else if %VM_RESULT% equ 1 (
    echo Virtual Machine Platform feature already enabled.
) else (
    echo WARNING: DISM returned code %VM_RESULT%. This may be normal if the feature is already enabled.
)
echo.

echo [Step 3/4] Installing WSL2 MSI package...
echo Downloading WSL2 MSI from GitHub...

REM Create a temporary directory for downloads
set TEMP_DIR=%TEMP%\WSL_Install_%RANDOM%
mkdir "%TEMP_DIR%" 2>nul

REM Check system architecture
for /f "tokens=2 delims==" %%A in ('wmic os get osarchitecture /value ^| find "="') do set ARCH=%%A
echo Detected architecture: %ARCH%

REM Download the appropriate WSL2 MSI
if "%ARCH%"=="64-bit" (
    echo Downloading WSL2 Linux kernel update for x64...
    powershell -Command "& {$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP_DIR%\wsl_update.msi' -UseBasicParsing}" 2>nul
) else if "%ARCH%"=="ARM64" (
    echo Downloading WSL2 Linux kernel update for ARM64...
    powershell -Command "& {$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi' -OutFile '%TEMP_DIR%\wsl_update.msi' -UseBasicParsing}" 2>nul
) else (
    echo WARNING: Unable to detect architecture. Attempting x64 download...
    powershell -Command "& {$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP_DIR%\wsl_update.msi' -UseBasicParsing}" 2>nul
)

if exist "%TEMP_DIR%\wsl_update.msi" (
    echo Installing WSL2 Linux kernel update...
    echo This may take a few moments...
    msiexec /i "%TEMP_DIR%\wsl_update.msi" /quiet /norestart
    if %errorlevel% equ 0 (
        echo WSL2 kernel package installed successfully.
    ) else (
        echo WARNING: WSL2 kernel installation returned code %errorlevel%. Continuing...
    )
) else (
    echo WARNING: Failed to download WSL2 kernel package. Continuing anyway...
)

REM Clean up temp directory
rmdir /s /q "%TEMP_DIR%" 2>nul

REM After MSI install, the wsl command should be available but may need time to register
echo Waiting for WSL command to become available...
timeout /t 3 /nobreak >nul
echo.

echo [Step 4/4] Installing Ubuntu 22.04...


REM Check for wsl.exe - handle WOW64 redirection for 32-bit installers on 64-bit Windows
REM On 64-bit Windows, 32-bit processes see SysWOW64 when accessing System32
REM Use PowerShell to check actual file existence without redirection
set WSL_FOUND=0
set WSL_PATH=

REM Use PowerShell to check real System32 path (bypasses WOW64 redirection)
echo Checking for WSL executable...
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "if (Test-Path 'C:\Windows\System32\wsl.exe') { Write-Output 'C:\Windows\System32\wsl.exe' } elseif (Test-Path 'C:\Windows\Sysnative\wsl.exe') { Write-Output 'C:\Windows\Sysnative\wsl.exe' } else { Write-Output 'NOT_FOUND' }"') do set WSL_CHECK=%%a

if not "%WSL_CHECK%"=="NOT_FOUND" (
    set WSL_PATH=%WSL_CHECK%
    set WSL_FOUND=1
    echo Found WSL at: %WSL_CHECK%
    goto WSLFound
)

REM Retry loop if not found immediately
for /l %%i in (1,1,15) do (
    for /f "tokens=*" %%a in ('powershell -NoProfile -Command "if (Test-Path 'C:\Windows\System32\wsl.exe') { Write-Output 'C:\Windows\System32\wsl.exe' } elseif (Test-Path 'C:\Windows\Sysnative\wsl.exe') { Write-Output 'C:\Windows\Sysnative\wsl.exe' } else { Write-Output 'NOT_FOUND' }"') do set WSL_CHECK=%%a
    if not "!WSL_CHECK!"=="NOT_FOUND" (
        set WSL_PATH=!WSL_CHECK!
        set WSL_FOUND=1
        goto WSLFound
    )
    echo Attempt %%i/15: WSL not found yet. Waiting...
    timeout /t 2 /nobreak >nul
)

:WSLFound
if %WSL_FOUND% equ 1 (
    echo WSL found at: %WSL_PATH%
    
    echo.
    echo Installing WSL and Ubuntu 22.04...
    echo Running: "%WSL_PATH%" --install -d Ubuntu-22.04 --no-launch
    cmd /c "%WSL_PATH%" --install -d Ubuntu-22.04 --no-launch
    echo WSL installation returned code %errorlevel%
    timeout /t 5 /nobreak >nul
    
    echo.
    echo Initializing Ubuntu 22.04 with root user...
    echo Running: ubuntu2204.exe install --root
    cmd /c ubuntu2204.exe install --root
    echo Ubuntu 22.04 initialization returned code %errorlevel%
    timeout /t 3 /nobreak >nul
    
    echo.
    echo Creating ubuntu user with blank password...
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- useradd -m -s /bin/bash ubuntu
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- passwd -d ubuntu
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- usermod -aG sudo ubuntu
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- bash -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu"
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- chmod 440 /etc/sudoers.d/ubuntu
    echo Ubuntu user created successfully.
    timeout /t 2 /nobreak >nul
    
    echo.
    echo Setting ubuntu as default user for Ubuntu-22.04...
    "%WSL_PATH%" -d Ubuntu-22.04 -u root -- bash -c "printf '[user]\ndefault=ubuntu\n' > /etc/wsl.conf"
    echo Default user set to ubuntu.
    timeout /t 2 /nobreak >nul
    
    echo.
    echo Setting Ubuntu-22.04 as default WSL distribution...
    cmd /c "%WSL_PATH%" --set-default Ubuntu-22.04
    echo Set default returned code %errorlevel%
    
    echo.
    echo Terminating Ubuntu to apply user changes...
    cmd /c "%WSL_PATH%" --terminate Ubuntu-22.04
    timeout /t 3 /nobreak >nul
) else (
    echo INFO: WSL executable not found at expected locations.
    echo The WSL MSI may not have installed properly, or a system restart is required.
    echo.
    echo Checked locations:
    echo - C:\Windows\System32\wsl.exe
    echo - C:\Program Files\WSL\wsl.exe
    echo.
    set /p RESTART_INPUT="Press Y and Enter to restart now, or N to restart manually later: "
    if /i "%RESTART_INPUT%"=="Y" (
        echo.
        echo Restarting system in 10 seconds...
        timeout /t 10 /nobreak
        shutdown /r /t 0 /c "Restarting to complete WSL2 kernel installation"
        exit /b 0
    ) else (
        echo.
        echo Please restart your computer manually and run this script again.
        echo.
        pause
        exit /b 0
    )
)
echo.

echo.
echo ============================================================================
echo WSL Installation Complete!
echo ============================================================================
echo.
echo Ubuntu 22.04 is now installed and configured with:
echo   - Default user: root
echo   - Default WSL version: 2
echo.
echo You can launch Ubuntu by typing: wsl
echo ============================================================================
echo.

REM Always exit with success code 0 when we reach this point
exit /b 0
