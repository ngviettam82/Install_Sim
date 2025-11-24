; PX4 Development Environment Installer
; NSIS Installer Script

!include "MUI2.nsh"
!include "x64.nsh"

; Basic Settings
Name "PX4 Development Environment Setup"
OutFile "PX4_Setup.exe"
InstallDir "$PROGRAMFILES\PX4_Development"
InstallDirRegKey HKCU "Software\PX4_Development" ""

; Request administrator privileges
RequestExecutionLevel admin

; MUI Settings
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

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
  
  ; Copy all PowerShell scripts
  File "setup_px4_in_wsl.ps1"
  File "build_px4.ps1"
  File "setup_settings.ps1"
  
  ; Copy GroundController installer
  File "GroundController-installer.exe"
  
  ; Copy README
  File "README.md"
  
  ; Create registry entries
  WriteRegStr HKCU "Software\PX4_Development" "" "$INSTDIR"
  
  ; Create Start Menu shortcuts
  CreateDirectory "$SMPROGRAMS\PX4 Development"
  CreateShortCut "$SMPROGRAMS\PX4 Development\Setup PX4 Environment.lnk" "$INSTDIR\setup_all.bat" "" "$INSTDIR\setup_all.bat" 0
  CreateShortCut "$SMPROGRAMS\PX4 Development\Run PX4 SITL.lnk" "$INSTDIR\px4s.bat" "" "$INSTDIR\px4s.bat" 0
  CreateShortCut "$SMPROGRAMS\PX4 Development\Install GroundController.lnk" "$INSTDIR\install_groundcontroller.bat" "" "$INSTDIR\install_groundcontroller.bat" 0
  CreateShortCut "$SMPROGRAMS\PX4 Development\README.lnk" "$INSTDIR\README.md" "" "$INSTDIR\README.md" 0
  CreateShortCut "$SMPROGRAMS\PX4 Development\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
  
  ; Create desktop shortcut for setup
  CreateShortCut "$DESKTOP\PX4 Setup.lnk" "$INSTDIR\setup_all.bat" "" "$INSTDIR\setup_all.bat" 0
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  ; Write uninstall information to the registry
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development" "DisplayName" "PX4 Development Environment"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development" "DisplayVersion" "1.0"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development" "Publisher" "PX4 Development"
  
SectionEnd

; Uninstaller Section
Section "Uninstall"
  ; Remove files
  Delete "$INSTDIR\setup_all.bat"
  Delete "$INSTDIR\install_wsl.bat"
  Delete "$INSTDIR\install_groundcontroller.bat"
  Delete "$INSTDIR\build_px4.bat"
  Delete "$INSTDIR\px4s.bat"
  Delete "$INSTDIR\setup_settings.bat"
  Delete "$INSTDIR\setup_px4_in_wsl.ps1"
  Delete "$INSTDIR\build_px4.ps1"
  Delete "$INSTDIR\setup_settings.ps1"
  Delete "$INSTDIR\GroundController-installer.exe"
  Delete "$INSTDIR\README.md"
  Delete "$INSTDIR\Uninstall.exe"
  
  ; Remove directories
  RMDir "$INSTDIR"
  
  ; Remove Start Menu shortcuts
  RMDir /r "$SMPROGRAMS\PX4 Development"
  
  ; Remove desktop shortcut
  Delete "$DESKTOP\PX4 Setup.lnk"
  
  ; Remove registry entries
  DeleteRegKey HKCU "Software\PX4_Development"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\PX4_Development"
  
SectionEnd

; Function to run setup after installation
Function .onInstSuccess
  ; Optionally launch setup_all.bat after installation
  ; MessageBox MB_YESNO "Installation complete. Would you like to run the setup now?" IDNO NoSetup
  ; ExecShell "open" "$INSTDIR\setup_all.bat"
  ; NoSetup:
FunctionEnd
