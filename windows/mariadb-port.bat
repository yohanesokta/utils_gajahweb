@echo off
setlocal enabledelayedexpansion

set PORT=%~1
set ROOTDIR=C:\gajahweb
set UTILSDIR=%~dp0
set TEMPLATE=%UTILSDIR%..\baseconfig\windows\mariadb.conf.template
set OUTPUT=%ROOTDIR%\mariadb\data\my.ini

if not exist "%ROOTDIR%\mariadb\data" mkdir "%ROOTDIR%\mariadb\data"

"%UTILSDIR%bin\sed.exe" "%TEMPLATE%" "%OUTPUT%" --replace __PORT__ %PORT%

echo Selesai! my.ini digenerate pakai port %PORT%.
endlocal
