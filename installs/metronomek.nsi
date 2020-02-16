; PRODUCT_VERSION is there
; !include "NSIS.definitions.nsh"

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Metronomek"
!define PRODUCT_PUBLISHER "Metronomek"
!define PRODUCT_WEB_SITE "https://metronomek.sourceforge.io"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\metronomek.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "images\pack.ico"
!define MUI_UNICON "images\pack.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"
!define MUI_LANGDLL_ALLLANGUAGES

; Image
!define MUI_HEADERIMAGE
; !define MUI_WELCOMEFINISHPAGE_BITMAP "picts\logo-left.bmp"
!define MUI_HEADERIMAGE_BITMAP "images\logo.bmp"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "LICENSE"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\metronomek.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Polish"


; Reserve files
!insertmacro MUI_RESERVEFILE_LANGDLL

; MUI end ------

Name "Metronomek"
OutFile "Metronomek-Windows-Installer.exe"
InstallDir "$PROGRAMFILES\Metronomek"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show


Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "MainGroup" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  SetOverwrite try
  File "metronomek.exe"
  CreateDirectory "$SMPROGRAMS\Metronomek"
  CreateShortCut "$SMPROGRAMS\Metronomek\Metronomek.lnk" "$INSTDIR\metronomek.exe"
  CreateShortCut "$DESKTOP\Metronomek.lnk" "$INSTDIR\metronomek.exe"

  File "*.dll"

  File "LICENSE"

  SetOutPath "$INSTDIR\bearer"
    File "bearer\*.dll"

  SetOutPath "$INSTDIR\imageformats"
    File "imageformats\*.dll"

  SetOutPath "$INSTDIR\platforms"
    File "platforms\qwindows.dll"

  SetOutPath "$INSTDIR\qmltooling"
    File "qmltooling\*.dll"

  SetOutPath "$INSTDIR\audio"
    File "audio\*.dll"

  SetOutPath "$INSTDIR\mediaservice"
    File "mediaservice\*.dll"

  SetOutPath "$INSTDIR"
;    File /r "Qt"
    File /r /x "*.qmlc" "QtGraphicalEffects"
;    File /r /x "*.qmlc" "QtQml"
    File /r /x "*.qmlc" "QtQuick"
    File /r /x "*.qmlc" "QtQuick.2"


  SetOutPath "$INSTDIR\Sounds"
    File "Sounds\*.raw48-16"

;   SetOutPath "$INSTDIR\Images"
;     File "picts\*.ico"
;     File "picts\*.png"

  SetOutPath "$INSTDIR\translations"
    File "translations\*.qm"

SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\Metronomek\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\Metronomek\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\metronomek.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\metronomek.exe"
;   WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


  LangString UninstallMess ${LANG_ENGLISH} "Do You really want to remove $(^Name) and all its components?"
  LangString UninstallMess ${LANG_POLISH} "Czy rzeczywiście chcesz usunąć program Metronomek i jego składniki?"

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
   MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(UninstallMess)" IDYES +2
   Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\metronomek.exe"

  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\Sounds\*.*"
  Delete "$INSTDIR\LICENSE"
;   Delete "$INSTDIR\Images\*.*"
  Delete "$INSTDIR\translations\*.*"
  Delete "$INSTDIR\platforms\*.*"
  Delete "$INSTDIR\bearer\*.*"
  Delete "$INSTDIR\imageformats\*.*"
  Delete "$INSTDIR\qmltooling\*.*"
  Delete "$INSTDIR\audio\*.*"
  Delete "$INSTDIR\mediaservice\*.*"

  Delete "$SMPROGRAMS\Metronomek\Uninstall.lnk"
  Delete "$SMPROGRAMS\Metronomek\Website.lnk"
  Delete "$DESKTOP\Metronomek.lnk"
  Delete "$SMPROGRAMS\Metronomek\Metronomek.lnk"

  RMDir "$SMPROGRAMS\Metronomek"
  RMDir "$INSTDIR\Sounds"
;   RMDir "$INSTDIR\Images"
  RMDir "$INSTDIR\translations"
  RMDir "$INSTDIR\platforms"
  RMDir "$INSTDIR\bearer"
  RMDir "$INSTDIR\imageformats"
  RMDir "$INSTDIR\qmltooling"
  RMDir "$INSTDIR\audio"
  RMDir "$INSTDIR\mediaservice"
;  RMDir  /r "$INSTDIR\Qt"
  RMDir  /r "$INSTDIR\QtGraphicalEffects"
;  RMDir  /r "$INSTDIR\QtQml"
  RMDir  /r "$INSTDIR\QtQuick"
  RMDir  /r "$INSTDIR\QtQuick.2"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
