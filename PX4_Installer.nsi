; PX4 Development Environment Installer
; NSIS Installer Script - Standalone Automatic Setup

!include "MUI2.nsh"
!include "x64.nsh"

; Basic Settings
Name "PX4 Development Environment Setup"
OutFile "Setup.exe"
; Use folder next to Setup.exe - will be set dynamically in .onInit
InstallDir "$EXEDIR\PX4_Setup_Temp"

; Request administrator privileges
RequestExecutionLevel admin

; MUI Settings - No directory page, just welcome and install
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

; Set install directory to be next to the Setup.exe
Function .onInit
  StrCpy $INSTDIR "$EXEDIR\PX4_Setup_Temp"
FunctionEnd

; Installer Sections
Section "PX4 Development Environment" SecInstall
  SetOutPath "$INSTDIR"
  
  ; Copy all batch files
  File "setup_all.bat"
  File "install_wsl.bat"
  File "install_groundcontroller.bat"
  File "build_px4.bat"
  File "px4s.bat"
  File "setup_settings.bat"
  File "setup_px4_in_wsl.bat"
  
  ; Copy all PowerShell scripts
  File "setup_px4_in_wsl.ps1"
  File "build_px4.ps1"
  File "setup_settings.ps1"
  
  ; Copy GroundController installer
  File "GroundController-installer.exe"
  
  ; Copy README
  File "README.md"
  
  ; Copy cleanup script
  File "cleanup.bat"
  
SectionEnd

; Function to run setup after installation
Function .onInstSuccess
  ; Automatically launch setup_all.bat after installation completes
  MessageBox MB_YESNO "Installation complete.$\n$\nThe setup wizard will now configure PX4 and install all required components.$\n$\nThis may take some time. Continue?" IDNO NoSetup
  ; Run setup_all.bat via cmd.exe with /k to keep window open
  ExecWait 'cmd.exe /k "$INSTDIR\setup_all.bat"'
  
  ; Launch cleanup script with delay to allow all processes to release
  ; Pass EXEDIR as parameter for the cleanup script
  Exec 'cmd.exe /c start "" /b "$INSTDIR\cleanup.bat" "$EXEDIR"'
  
  NoSetup:
FunctionEnd
