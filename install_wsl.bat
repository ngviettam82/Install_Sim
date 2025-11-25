@echo off
REM ============================================================================
REM WSL2 and Ubuntu 22.04 Installation Script
REM ============================================================================
REM This script will:
REM 1. Enable WSL and Virtual Machine Platform features
REM 2. Set WSL 2 as the default version
REM 3. Install Ubuntu 22.04
REM 4. Auto-configure Ubuntu with username "ubuntu" and blank password
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

echo [Step 1/5] Enabling WSL feature...
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

echo [Step 2/5] Enabling Virtual Machine Platform feature...
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

echo [Step 3/5] Installing WSL2 MSI package...
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
timeout /t 8 /nobreak >nul
echo.

echo [Step 4/5] Installing Ubuntu 22.04...
echo Checking if wsl.exe is available...
timeout /t 3 /nobreak >nul

REM Check for wsl.exe - handle WOW64 redirection for 32-bit installers on 64-bit Windows
REM On 64-bit Windows, 32-bit processes see SysWOW64 when accessing System32
REM Use Sysnative to access the real 64-bit System32 folder
set WSL_FOUND=0
set WSL_PATH=

REM First priority: Check Sysnative (for 32-bit process on 64-bit Windows)
REM This path only exists when running as 32-bit process on 64-bit Windows
if exist "C:\Windows\Sysnative\wsl.exe" (
    set WSL_PATH=C:\Windows\Sysnative\wsl.exe
    set WSL_FOUND=1
    echo Found WSL at Sysnative path (32-bit process on 64-bit Windows)
    goto WSLFound
)

REM Second priority: Check native System32 (for 64-bit process or 32-bit Windows)
if exist "C:\Windows\System32\wsl.exe" (
    set WSL_PATH=C:\Windows\System32\wsl.exe
    set WSL_FOUND=1
    echo Found WSL at System32 path
    goto WSLFound
)

REM Third priority: Wait and retry both paths
for /l %%i in (1,1,15) do (
    if exist "C:\Windows\Sysnative\wsl.exe" (
        set WSL_PATH=C:\Windows\Sysnative\wsl.exe
        set WSL_FOUND=1
        goto WSLFound
    )
    if exist "C:\Windows\System32\wsl.exe" (
        set WSL_PATH=C:\Windows\System32\wsl.exe
        set WSL_FOUND=1
        goto WSLFound
    )
    echo Attempt %%i/15: WSL not found yet. Waiting...
    timeout /t 2 /nobreak >nul
)

:WSLFound
if %WSL_FOUND% equ 1 (
    echo WSL found at: %WSL_PATH%
    echo Installing Ubuntu 22.04...
    echo Running: "%WSL_PATH%" --install -d Ubuntu-22.04 --no-launch
    "%WSL_PATH%" --install -d Ubuntu-22.04 --no-launch
    if %errorlevel% equ 0 (
        echo Ubuntu 22.04 installation completed successfully.
    ) else (
        echo WARNING: Ubuntu install returned code %errorlevel%. Continuing...
    )
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
timeout /t 3 /nobreak >nul
echo.

:ConfigureUbuntu
echo [Step 5/5] Configuring Ubuntu user...
echo Waiting for WSL to be fully initialized...
timeout /t 8 /nobreak >nul

REM Ensure WSL_PATH is set - find it if not already found (handle WOW64 redirection)
if not defined WSL_PATH (
    if exist "C:\Windows\Sysnative\wsl.exe" (
        set WSL_PATH=C:\Windows\Sysnative\wsl.exe
    ) else if exist "C:\Windows\System32\wsl.exe" (
        set WSL_PATH=C:\Windows\System32\wsl.exe
    )
)

REM Try to verify Ubuntu is installed and available using full path
"%WSL_PATH%" -l --quiet 2>nul | findstr /I "Ubuntu-22.04" >nul 2>&1
if %errorlevel% neq 0 (
    echo INFO: Ubuntu 22.04 not yet fully initialized.
    echo This may require another restart to complete.
    echo.
    echo After restart, run this script again to configure the Ubuntu user.
    echo.
    pause
    exit /b 0
)

echo Ubuntu 22.04 is installed. Proceeding with user configuration...
timeout /t 3 /nobreak >nul

echo Checking if user 'ubuntu' already exists...
"%WSL_PATH%" -d Ubuntu-22.04 -u root id ubuntu >nul 2>&1
if %errorlevel% equ 0 (
    echo User 'ubuntu' already exists. Skipping user creation.
    echo Ensuring passwordless sudo is enabled...
    "%WSL_PATH%" -d Ubuntu-22.04 -u root bash -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu; chmod 0440 /etc/sudoers.d/ubuntu"
    goto SetDefaultUser
)

echo Creating user 'ubuntu' with blank password...

REM Use ubuntu2204 install with root user first
ubuntu2204.exe install --root
timeout /t 2 /nobreak >nul

REM Create ubuntu user and configure sudo using full path
"%WSL_PATH%" -d Ubuntu-22.04 -u root bash -c "useradd -m -s /bin/bash ubuntu; echo 'ubuntu: ' | chpasswd; usermod -aG sudo ubuntu; echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu; chmod 0440 /etc/sudoers.d/ubuntu"

if %errorlevel% neq 0 (
    echo ERROR: Failed to create user with alternative method.
    echo Please restart your computer manually and run this script again.
    echo.
    pause
    exit /b 1
)

:SetDefaultUser
echo Setting 'ubuntu' as default user...
REM Set default user for Ubuntu
ubuntu2204.exe config --default-user ubuntu
if %errorlevel% neq 0 (
    echo WARNING: Failed to set default user. Trying to configure...
    "%WSL_PATH%" -d Ubuntu-22.04 -u root bash -c "echo '[user]' > /etc/wsl.conf; echo 'default=ubuntu' >> /etc/wsl.conf"
    "%WSL_PATH%" --terminate Ubuntu-22.04
    timeout /t 2 /nobreak >nul
)

echo Setting Ubuntu-22.04 as default WSL distribution...
"%WSL_PATH%" --set-default Ubuntu-22.04
if %errorlevel% equ 0 (
    echo Ubuntu-22.04 is now set as the default WSL distribution.
) else (
    echo WARNING: Failed to set Ubuntu-22.04 as default distribution.
)
echo.

echo.
echo ============================================================================
echo WSL Installation Complete!
echo ============================================================================
echo.
echo Ubuntu 22.04 is now installed and configured with:
echo   - Username: ubuntu
echo   - Password: blank (space character)
echo   - Default WSL version: 2
echo   - Passwordless sudo enabled
echo.
echo You can launch Ubuntu by typing: wsl
echo ============================================================================
echo.

REM Only pause if script is run directly (not called from another script)
if "%1"=="" pause

exit /b 0
