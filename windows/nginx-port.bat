@echo off
setlocal enabledelayedexpansion

set PORT=%~1
set ROOTNGINX=%~2
set ROOTDIR=C:\gajahweb
set UTILSDIR=%~dp0
set TEMPLATE=%UTILSDIR%..\baseconfig\windows\nginx.conf.template
set OUTPUT=%ROOTDIR%\nginx\conf\nginx.conf

:: Default values for new parameters
if "%PHP_PORT%"=="" set PHP_PORT=9000
if "%LOG_DIR%"=="" set LOG_DIR=%ROOTDIR%\nginx\logs
if "%TEMP_DIR%"=="" set TEMP_DIR=%ROOTDIR%\nginx\temp

echo Membuat config Nginx dengan port %PORT% dan root %ROOTNGINX% ...
echo Template: %TEMPLATE%

if not exist "%ROOTDIR%\nginx\conf" mkdir "%ROOTDIR%\nginx\conf"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

"%UTILSDIR%bin\sed.exe" "%TEMPLATE%" "%OUTPUT%" --replace __PORT__ %PORT% --replace __ROOT__ %ROOTNGINX% --replace __PHP_PORT__ %PHP_PORT% --replace __LOG_DIR__ %LOG_DIR% --replace __TEMP_DIR__ %TEMP_DIR%

echo Selesai! nginx.conf digenerate.
endlocal
