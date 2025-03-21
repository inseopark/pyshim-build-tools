@ECHO OFF
PUSHD %~dp0
rem path should be below 80 character
rem add component https://docs.microsoft.com/ko-kr/visualstudio/install/workload-and-component-ids?view=vs-2017
rem python 3.6.3 have some minor point that windows sdk not found properly
rem see https://bugs.python.org/issue354333, sdk 15063 is happy with most cases
rem thus  ...VCTools;includeRecommended not to be used
rem Microsoft.VisualStudio.Component.VC.Tools.x86.x64 is requred package but added explicitly.
rem Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools is optional (not requred for python)
rem Microsoft.Net.Component.4.7.2.TargetingPack is optional (not requred for python)
rem ======================================================
rem edition
rem Visual Studio 2022 Professional : vs_professional.exe https://aka.ms/vs/17/release/vs_professional.exe
rem Visual Studio 2022 Community    : vs_community.exe    https://aka.ms/vs/17/release/vs_community.exe 
rem Visual Studio 2022 Build Tools  : vs_buildtools.exe   https://aka.ms/vs/17/release/vs_buildtools.exe

SET "_THIS_FILE_=%~nx0"
:CheckOpts
if "%~1" EQU "-h" goto HELP

SETLOCAL
rem prepare vs_BuildTools.exe from aka 
rem f
SET "VS_VERSION=17"
SET "VS_ADD_LANG=en-US ko-KR"
rem Supported language pack can be added above
rem see https://docs.microsoft.com/ko-kr/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2017#list-of-language-locales

:CheckOpts
if "%~1" EQU "-h" goto Help
if "%~1" EQU "--compress" (set _CMD_COMPRESS_=1) && shift && goto CheckOpts
if "%~1" EQU "-p" (set _GET_PRODUCT_=%~2) && shift && shift && goto CheckOpts

IF NOT DEFINED _GET_PRODUCT_ (SET _GET_PRODUCT_=buildtools)

SET VS_DOWNLOADER_EXE=

IF /i "%_GET_PRODUCT_%" equ "buildtools" (
   ECHO [%_THIS_FILE_%] buildtools requested ...
   SET VS_DOWNLOADER_EXE=vs_BuildTools.exe
)

IF /i "%_GET_PRODUCT_%" equ "community" (
   ECHO [%_THIS_FILE_%] community requested ...
   SET VS_DOWNLOADER_EXE=vs_Community.exe
)

::IF /i "%_GET_PRODUCT_%" equ "express" (
::   ECHO [%_THIS_FILE_%] express requested ...
::   SET VS_DOWNLOADER_EXE=vs_WDExpress.exe
::)

IF /i "%_GET_PRODUCT_%" equ "professional" (
   ECHO [%_THIS_FILE_%] professional requested ...
   SET VS_DOWNLOADER_EXE=vs_Professional.exe
)

IF NOT DEFINED VS_DOWNLOADER_EXE (
   ECHO [%_THIS_FILE_%] product NOT specified... see usage
   ECHO.
   ENDLOCAL & GOTO help
)
@echo this is vs layout generator for Visual Studio 2022
SET "DOWNLOAD_URL=https://aka.ms/vs/%VS_VERSION%/release/%VS_DOWNLOADER_EXE%"
rem we should use noprofile because conda inject into powershell but
rem when Document folder is redirected to network drive, very slow speed, unusable case happens
ECHO [%_THIS_FILE_%] language to be added [%VS_ADD_LANG%]
IF NOT EXIST "%VS_DOWNLOADER_EXE%" (
    ECHO [%_THIS_FILE_%] Seems %VS_DOWNLOADER_EXE% missing, trying to get tools ...
    powershell -nop -nol -c "Invoke-WebRequest -Uri %DOWNLOAD_URL% -OutFile %VS_DOWNLOADER_EXE%"
)
rem https://stackoverflow.com/questions/1706892/how-do-i-retrieve-the-version-of-a-file-from-a-batch-file-on-windows-vista
FOR /F "usebackq" %%F IN (`powershell -nop -nol -c ^(Get-Item "%VS_DOWNLOADER_EXE%"^).VersionInfo.FileVersion`) DO (SET TMP_VS_TOOL_VERSION=%%F)
ECHO [%_THIS_FILE_%] vs setup file version: %TMP_VS_TOOL_VERSION%

IF NOT EXIST "%~dp0..\lout" MKDIR "%~dp0..\lout"
ECHO "layout_%_GET_PRODUCT_%: v%TMP_VS_TOOL_VERSION%" > %~dp0..\lout\layout_%_GET_PRODUCT_%_v%TMP_VS_TOOL_VERSION%

:BUILDTOOLS
IF /i "%_GET_PRODUCT_%" equ "buildtools" (
  ECHO "%_GET_PRODUCT_% downloading started... "
  %VS_DOWNLOADER_EXE% --layout  %~dp0..\lout\%_GET_PRODUCT_%v%VS_VERSION% ^
  --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended ^
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
REM  --add Microsoft.VisualStudio.Component.VC.140 ^
  --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 ^
  --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools ^
  --add Microsoft.Net.Component.4.7.2.TargetingPack ^
  --lang en-US ko-KR
)
 
IF /i "%_GET_PRODUCT_%" equ "community" (
  ECHO "%_GET_PRODUCT_% downloading started... " 
  %VS_DOWNLOADER_EXE% --layout %~dp0..\lout\%_GET_PRODUCT_%_v%VS_VERSION% ^
  --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --add Microsoft.VisualStudio.Workload.ManagedDesktop ^
  --add Microsoft.Net.Component.4.8.TargetingPack ^
  --add Microsoft.VisualStudio.Workload.Python ^
  --add Component.VisualStudio.GitHub.Copilot ^
  --lang %VS_ADD_LANG%
)

IF /i "%_GET_PRODUCT_%" equ "professional" (
  ECHO "%_GET_PRODUCT_% downloading started... " 
  %VS_DOWNLOADER_EXE% --layout %~dp0..\lout\%_GET_PRODUCT_%_v%VS_VERSION% ^
  --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --add Microsoft.VisualStudio.Workload.ManagedDesktop ^
  --add Microsoft.Net.Component.4.8.TargetingPack ^
  --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools ^
  --add Microsoft.VisualStudio.Component.IntelliCode ^
  --add Component.Dotfuscator ^
  --add Microsoft.VisualStudio.Workload.Python ^
  --add Component.VisualStudio.GitHub.Copilot ^
  --add Microsoft.VisualStudio.Component.VC.140 ^
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
  --add Microsoft.VisualStudio.Component.VC.14.41.17.11.x86.x64 ^
  --lang %VS_ADD_LANG%
)

ENDLOCAL & SET "VS_BUILDTOOLS_LAYOUT_V17=%~dp0..\lout\%_GET_PRODUCT_%_v%VS_VERSION%" 

ECHO [%_THIS_FILE_%] Job completed .. && EXIT /B %ERROLEVEL%

:Help
ECHO Usage:
ECHO %_THIS_FILE_% [-h] -p [community^|buildtools^|professional] --compress
ECHO.
ECHO.   --p [community^|buildtools^|professional] downloading product type, default is buildtools
ECHO.   --compress          Generating zip file, 7-Zip required
echo    -h                  Show usage
ECHO.
ECHO This file is to generate layout of vs_build_tools
ECHO You can install VS Build Tools 2022 using command like below inside layout folder
ECHO $^> vs_BuildTools.exe --wait --passive --nocache --noUpdateInstaller --noWeb ^^
ECHO. --nickname "Buildv17" --installPath "c:\opt\vsbuild\v17" 

SET _THIS_FILE_=
