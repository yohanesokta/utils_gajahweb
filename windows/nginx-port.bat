@echo off
setlocal enabledelayedexpansion

set PORT=%~1
set ROOTNGINX=%~2
set ROOTDIR=C:\gajahweb
set UTILSDIR=%~dp0
set TEMPLATE=%UTILSDIR%..\baseconfig\windows\nginx.conf.template
set OUTPUT=%ROOTDIR%\nginx\conf\nginx.conf

echo Membuat config Nginx dengan port %PORT% dan root %ROOTNGINX% ...
echo Template: %TEMPLATE%

if not exist "%ROOTDIR%\nginx\conf" mkdir "%ROOTDIR%\nginx\conf"

"%UTILSDIR%bin\sed.exe" "%TEMPLATE%" "%OUTPUT%" --replace __PORT__ %PORT% --replace __ROOT__ %ROOTNGINX%

echo Selesai! nginx.conf digenerate.
endlocal
