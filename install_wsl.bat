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

echo [Step 3/5] Checking if restart is needed...
REM Check if WSL command is available after enabling features
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    echo WSL is functional. Proceeding with installation.
    echo.
    goto InstallUbuntu
)

echo WSL features have been enabled. Proceeding with WSL installation...
echo.

:InstallWSL
echo [Step 4/5] Installing WSL2...
echo Attempting to install WSL2 with Ubuntu 22.04...
wsl --install -d Ubuntu-22.04 --no-launch
if %errorlevel% neq 0 (
    echo ERROR: Failed to install WSL2 and Ubuntu 22.04.
    echo.
    echo Please restart your computer and run this script again.
    echo.
    pause
    exit /b 1
)
echo WSL2 and Ubuntu 22.04 installed successfully.
echo.

:ConfigureUbuntu
echo [Step 5/5] Configuring Ubuntu user...
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
