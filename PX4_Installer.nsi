; PX4 Development Environment Installer
; NSIS Installer Script - Standalone Automatic Setup
; Use Bin\makensis.exe to compile as 64-bit (avoids WOW64 redirection)

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
  
SectionEnd

; Function to run setup after installation
Function .onInstSuccess
  ; Silently run setup without prompting - no message box
  
  ; Temporarily disable Quick Edit for consoles created during setup so accidental clicks do not pause execution
  ReadRegDWORD $0 HKCU "Console" "QuickEdit"
  StrCpy $1 1
  IfErrors 0 +2
    StrCpy $1 0
  WriteRegDWORD HKCU "Console" "QuickEdit" 0
  
  ; Use Sysnative to run 64-bit cmd.exe from 32-bit installer
  ; This ensures wsl.exe in System32 is accessible
  IfFileExists "$WINDIR\Sysnative\cmd.exe" 0 +4
    ExecWait '"$WINDIR\Sysnative\cmd.exe" /c "$INSTDIR\setup_all.bat"'
    Goto RestoreQuickEdit
  ; Fallback to regular cmd if Sysnative doesn't exist (already 64-bit)
  ExecWait 'cmd.exe /c "$INSTDIR\setup_all.bat"'
  
  RestoreQuickEdit:
  
  ; Restore original Quick Edit registry state
  StrCmp $1 0 0 +3
    DeleteRegValue HKCU "Console" "QuickEdit"
    Goto DoneQuickEditRestore
  WriteRegDWORD HKCU "Console" "QuickEdit" $0
  DoneQuickEditRestore:
  
  DoneSetup:
  ; Delete temp folder after setup completes
  SetOutPath "$EXEDIR"
  RMDir /r "$INSTDIR"
FunctionEnd
