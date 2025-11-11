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

REM Check if WSL is already functional
echo [Step 1/5] Checking WSL status...
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    echo WSL is already installed and functional.
    echo Skipping feature installation.
    echo.
    goto InstallUbuntu
)

echo WSL not detected. Enabling required features...
echo.

echo [Step 2/5] Enabling WSL feature...
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

echo [Step 3/5] Enabling Virtual Machine Platform feature...
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

echo [Step 4/5] Checking if restart is needed...
REM Check if WSL command is available after enabling features
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    echo WSL is functional. No restart needed.
    echo.
    goto InstallUbuntu
)

echo A system restart is required to complete the feature installation.
echo.
set /p RESTART="Do you want to restart now? (Y/N): "
if /i "%RESTART%"=="Y" (
    echo Restarting system in 10 seconds...
    shutdown /r /t 10 /c "Restarting to complete WSL2 installation"
    exit /b 0
) else (
    echo Please restart your computer manually and run this script again.
    pause
    exit /b 0
)

:InstallUbuntu
echo Setting WSL 2 as the default version...
wsl --set-default-version 2
if %errorlevel% neq 0 (
    echo WARNING: Failed to set WSL 2 as default. You may need to update the WSL 2 kernel.
    echo Downloading WSL 2 kernel update...
    echo Please download and install from: https://aka.ms/wsl2kernel
    echo.
    echo After installing the kernel update, run this command:
    echo wsl --set-default-version 2
    echo.
)
echo.

echo Checking if Ubuntu 22.04 is already installed...
wsl -d Ubuntu-22.04 --status >nul 2>&1
if %errorlevel% equ 0 (
    echo Ubuntu 22.04 is already installed.
    echo Verifying configuration...
    goto ConfigureUbuntu
)

echo Installing Ubuntu 22.04...
wsl --install -d Ubuntu-22.04 --web-download --no-launch
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Ubuntu 22.04.
    echo.
    echo Troubleshooting tips:
    echo 1. Make sure you have restarted after enabling WSL features
    echo 2. Ensure you have an internet connection
    echo 3. Try running: wsl --update
    echo.
    pause
    exit /b 1
)
echo Ubuntu 22.04 downloaded successfully.
echo.

echo Waiting for installation to complete...
timeout /t 3 /nobreak >nul

:ConfigureUbuntu
echo Checking if user 'ubuntu' already exists...
wsl -d Ubuntu-22.04 -u root id ubuntu >nul 2>&1
if %errorlevel% equ 0 (
    echo User 'ubuntu' already exists. Skipping user creation.
    echo Ensuring passwordless sudo is enabled...
    wsl -d Ubuntu-22.04 -u root bash -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu; chmod 0440 /etc/sudoers.d/ubuntu"
    goto SetDefaultUser
)

echo Creating user 'ubuntu' with blank password...

REM Use ubuntu2204 install with root user first
ubuntu2204.exe install --root
timeout /t 2 /nobreak >nul

REM Create ubuntu user and configure sudo
wsl -d Ubuntu-22.04 -u root bash -c "useradd -m -s /bin/bash ubuntu; echo 'ubuntu: ' | chpasswd; usermod -aG sudo ubuntu; echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu; chmod 0440 /etc/sudoers.d/ubuntu"

if %errorlevel% neq 0 (
    echo ERROR: Failed to create user with alternative method.
    pause
    exit /b 1
)

:SetDefaultUser
echo Setting 'ubuntu' as default user...
REM Set default user for Ubuntu
ubuntu2204.exe config --default-user ubuntu
if %errorlevel% neq 0 (
    echo WARNING: Failed to set default user. Trying to configure...
    wsl -d Ubuntu-22.04 -u root bash -c "echo '[user]' > /etc/wsl.conf; echo 'default=ubuntu' >> /etc/wsl.conf"
    wsl --terminate Ubuntu-22.04
    timeout /t 2 /nobreak >nul
)

echo Setting Ubuntu-22.04 as default WSL distribution...
wsl --set-default Ubuntu-22.04
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
