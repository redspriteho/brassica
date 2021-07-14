; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Brassica"
!define PRODUCT_VERSION "0.0.2"
!define PRODUCT_WEB_SITE "https://github.com/bradrn/brassica"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\brassica-gui.exe"
!define PRODUCT_DIR_REGKEY_CMD "Software\Microsoft\Windows\CurrentVersion\App Paths\brassica.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE ".\LICENSE"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\brassica-gui.exe"
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION CreateDesktopShortCut
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "brassica-setup-${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES\Brassica"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  File "bin\brassica.exe"
  File "bin\brassica-gui.exe"
  CreateDirectory "$SMPROGRAMS\Brassica"
  CreateShortCut "$SMPROGRAMS\Brassica\Brassica.lnk" "$INSTDIR\brassica-gui.exe"
  File "bin\D3Dcompiler_47.dll"
  SetOutPath "$INSTDIR\iconengines"
  File "bin\iconengines\qsvgicon.dll"
  SetOutPath "$INSTDIR\imageformats"
  File "bin\imageformats\qgif.dll"
  File "bin\imageformats\qicns.dll"
  File "bin\imageformats\qico.dll"
  File "bin\imageformats\qjpeg.dll"
  File "bin\imageformats\qsvg.dll"
  File "bin\imageformats\qtga.dll"
  File "bin\imageformats\qtiff.dll"
  File "bin\imageformats\qwbmp.dll"
  File "bin\imageformats\qwebp.dll"
  SetOutPath "$INSTDIR"
  File "bin\libEGL.dll"
  File "bin\libgcc_s_seh-1.dll"
  File "bin\libGLESv2.dll"
  File "bin\libstdc++-6.dll"
  File "bin\libwinpthread-1.dll"
  File "bin\opengl32sw.dll"
  SetOutPath "$INSTDIR\platforms"
  File "bin\platforms\qwindows.dll"
  SetOutPath "$INSTDIR"
  File "bin\Qt5Core.dll"
  File "bin\Qt5Gui.dll"
  File "bin\Qt5Svg.dll"
  File "bin\Qt5Widgets.dll"
  SetOutPath "$INSTDIR\styles"
  File "bin\styles\qwindowsvistastyle.dll"
  SetOutPath "$INSTDIR\translations"
  File "bin\translations\qt_ar.qm"
  File "bin\translations\qt_bg.qm"
  File "bin\translations\qt_ca.qm"
  File "bin\translations\qt_cs.qm"
  File "bin\translations\qt_da.qm"
  File "bin\translations\qt_de.qm"
  File "bin\translations\qt_en.qm"
  File "bin\translations\qt_es.qm"
  File "bin\translations\qt_fi.qm"
  File "bin\translations\qt_fr.qm"
  File "bin\translations\qt_gd.qm"
  File "bin\translations\qt_he.qm"
  File "bin\translations\qt_hu.qm"
  File "bin\translations\qt_it.qm"
  File "bin\translations\qt_ja.qm"
  File "bin\translations\qt_ko.qm"
  File "bin\translations\qt_lv.qm"
  File "bin\translations\qt_pl.qm"
  File "bin\translations\qt_ru.qm"
  File "bin\translations\qt_sk.qm"
  File "bin\translations\qt_tr.qm"
  File "bin\translations\qt_uk.qm"
  File "bin\translations\qt_zh_TW.qm"
SectionEnd

Function CreateDesktopShortCut
  CreateShortCut "$DESKTOP\Brassica.lnk" "$INSTDIR\brassica-gui.exe"
FunctionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\brassica-gui.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY_CMD}" "" "$INSTDIR\brassica.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\brassica-gui.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "Brassica was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove Brassica and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\translations\qt_zh_TW.qm"
  Delete "$INSTDIR\translations\qt_uk.qm"
  Delete "$INSTDIR\translations\qt_tr.qm"
  Delete "$INSTDIR\translations\qt_sk.qm"
  Delete "$INSTDIR\translations\qt_ru.qm"
  Delete "$INSTDIR\translations\qt_pl.qm"
  Delete "$INSTDIR\translations\qt_lv.qm"
  Delete "$INSTDIR\translations\qt_ko.qm"
  Delete "$INSTDIR\translations\qt_ja.qm"
  Delete "$INSTDIR\translations\qt_it.qm"
  Delete "$INSTDIR\translations\qt_hu.qm"
  Delete "$INSTDIR\translations\qt_he.qm"
  Delete "$INSTDIR\translations\qt_gd.qm"
  Delete "$INSTDIR\translations\qt_fr.qm"
  Delete "$INSTDIR\translations\qt_fi.qm"
  Delete "$INSTDIR\translations\qt_es.qm"
  Delete "$INSTDIR\translations\qt_en.qm"
  Delete "$INSTDIR\translations\qt_de.qm"
  Delete "$INSTDIR\translations\qt_da.qm"
  Delete "$INSTDIR\translations\qt_cs.qm"
  Delete "$INSTDIR\translations\qt_ca.qm"
  Delete "$INSTDIR\translations\qt_bg.qm"
  Delete "$INSTDIR\translations\qt_ar.qm"
  Delete "$INSTDIR\styles\qwindowsvistastyle.dll"
  Delete "$INSTDIR\Qt5Widgets.dll"
  Delete "$INSTDIR\Qt5Svg.dll"
  Delete "$INSTDIR\Qt5Gui.dll"
  Delete "$INSTDIR\Qt5Core.dll"
  Delete "$INSTDIR\platforms\qwindows.dll"
  Delete "$INSTDIR\opengl32sw.dll"
  Delete "$INSTDIR\libwinpthread-1.dll"
  Delete "$INSTDIR\libstdc++-6.dll"
  Delete "$INSTDIR\libGLESv2.dll"
  Delete "$INSTDIR\libgcc_s_seh-1.dll"
  Delete "$INSTDIR\libEGL.dll"
  Delete "$INSTDIR\imageformats\qwebp.dll"
  Delete "$INSTDIR\imageformats\qwbmp.dll"
  Delete "$INSTDIR\imageformats\qtiff.dll"
  Delete "$INSTDIR\imageformats\qtga.dll"
  Delete "$INSTDIR\imageformats\qsvg.dll"
  Delete "$INSTDIR\imageformats\qjpeg.dll"
  Delete "$INSTDIR\imageformats\qico.dll"
  Delete "$INSTDIR\imageformats\qicns.dll"
  Delete "$INSTDIR\imageformats\qgif.dll"
  Delete "$INSTDIR\iconengines\qsvgicon.dll"
  Delete "$INSTDIR\D3Dcompiler_47.dll"
  Delete "$INSTDIR\brassica-gui.exe"
  Delete "$INSTDIR\brassica.exe"

  Delete "$DESKTOP\Brassica.lnk"
  Delete "$SMPROGRAMS\Brassica\Brassica.lnk"

  RMDir "$SMPROGRAMS\Brassica"
  RMDir "$INSTDIR\translations"
  RMDir "$INSTDIR\styles"
  RMDir "$INSTDIR\platforms"
  RMDir "$INSTDIR\imageformats"
  RMDir "$INSTDIR\iconengines"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY_CMD}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd