@echo off
setlocal enabledelayedexpansion

set PORT=%~1
set ROOTDIR=C:\gajahweb
set UTILSDIR=%ROOTDIR%\data\flutter_assets\utils
set TEMPLATE=%UTILSDIR%\baseconfig\windows\mariadb.conf.template
set OUTPUT=%ROOTDIR%\mariadb\data\my.ini

%UTILSDIR%\windows\bin\sed.exe %TEMPLATE% %OUTPUT% --replace __PORT__ %PORT%

echo Selesai! nginx.conf digenerate pakai port %PORT%.
endlocal
