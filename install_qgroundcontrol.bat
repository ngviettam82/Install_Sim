@echo off
REM ========================================
REM Install QGroundControl
REM ========================================

echo Installing QGroundControl...
echo.

REM Set installation directory
set "INSTALL_DIR=%~dp0..\QGroundControl"
set "QGC_URL=https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-installer.exe"
set "QGC_INSTALLER=%TEMP%\QGroundControl-installer.exe"

REM Check if QGroundControl is already installed
if exist "%INSTALL_DIR%\QGroundControl.exe" (
    echo QGroundControl is already installed at: %INSTALL_DIR%
    goto :create_launcher
)

REM Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Downloading QGroundControl...
echo URL: %QGC_URL%
echo.

REM Download using PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%QGC_URL%' -OutFile '%QGC_INSTALLER%'}"

if %errorLevel% neq 0 (
    echo ERROR: Failed to download QGroundControl!
    echo.
    echo Please download manually from:
    echo https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html
    exit /b 1
)

echo.
echo Running installer silently...
echo This may take several minutes...
echo.

REM Run the installer silently
REM /S = silent mode
REM /D = installation directory
"%QGC_INSTALLER%" /S /D="%INSTALL_DIR%"

if %errorLevel% neq 0 (
    echo ERROR: QGroundControl installation failed!
    echo Exit code: %errorLevel%
    exit /b 1
)

REM Clean up installer
if exist "%QGC_INSTALLER%" del "%QGC_INSTALLER%"

echo Installation completed successfully!

:create_launcher
REM Create launcher batch file in root directory
set "LAUNCHER=%~dp0..\qgc.bat"
if not exist "%LAUNCHER%" (
    echo Creating QGroundControl launcher...
    (
        echo @echo off
        echo REM Launch QGroundControl
        echo.
        echo REM Try common installation locations
        echo if exist "C:\Program Files ^(x86^)\QGroundControl\QGroundControl.exe" ^(
        echo     start "" "C:\Program Files ^(x86^)\QGroundControl\QGroundControl.exe"
        echo     exit /b 0
        echo ^)
        echo.
        echo if exist "%ProgramFiles%\QGroundControl\QGroundControl.exe" ^(
        echo     start "" "%ProgramFiles%\QGroundControl\QGroundControl.exe"
        echo     exit /b 0
        echo ^)
        echo.
        echo if exist "%USERPROFILE%\Desktop\QGroundControl.exe" ^(
        echo     start "" "%USERPROFILE%\Desktop\QGroundControl.exe"
        echo     exit /b 0
        echo ^)
        echo.
        echo echo ERROR: QGroundControl executable not found!
        echo echo Please update the path in this script.
        echo pause
    ) > "%LAUNCHER%"
)

echo.
echo ========================================
echo QGroundControl Installation Complete
echo ========================================
echo.
echo Launcher created: qgc.bat
echo.

REM Only pause if script is run directly (not called from another script)
if "%1"=="" (
    echo Press any key to continue...
    pause >nul
)

exit /b 0
