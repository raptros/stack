REM TODO: move this logic into release.hs
REM Note: STACK_ROOT, TMP, and TEMP must be set to short paths otherwise this is unlikely to work
setlocal
set RELEASE_SCRIPT=%APPDATA%\local\bin\stack-release-script.exe
if exist %RELEASE_SCRIPT% del %RELEASE_SCRIPT%
set BUILD_DIR=%CD%
cd %~dp0
stack --install-ghc install
if errorlevel 1 exit /b
cd %BUILD_DIR%
REM @@@ add --certificate-name?
REM @@@ release
%RELEASE_SCRIPT% --no-test-haddocks --arch=x86_64 %1 %2 %3 %4 %5 %6 %7 %8 %9 release
if errorlevel 1 exit /b
REM @@@ change back to reease
%RELEASE_SCRIPT% --no-test-haddocks --arch=i386 %1 %2 %3 %4 %5 %6 %7 %8 %9 upload
if errorlevel 1 exit /b
