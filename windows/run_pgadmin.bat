@echo off
setlocal

set "ACTION=%~1"
set "PORT=%~2"
set "PGADMIN_ROOT=%~3"

if "%ACTION%"=="" set "ACTION=run"
if "%PORT%"=="" set "PORT=5050"
if "%PGADMIN_ROOT%"=="" set "PGADMIN_ROOT=C:\gajahweb\pgadmin"

set "PGADMIN_DATA_DIR=%PGADMIN_ROOT%\data"
set "PGADMIN_VENV_DIR=%PGADMIN_ROOT%\venv"
set "PGADMIN_PYTHON_EXE=%PGADMIN_VENV_DIR%\Scripts\python.exe"
set "PGADMIN_EXE=%PGADMIN_VENV_DIR%\Scripts\pgadmin4.exe"
set "PGADMIN_CLI_EXE=%PGADMIN_VENV_DIR%\Scripts\pgadmin4-cli.exe"
set "PGADMIN_WEB_DIR=%PGADMIN_VENV_DIR%\Lib\site-packages\pgadmin4\web"
set "PYTHON_BOOTSTRAP="

if not exist "%PGADMIN_ROOT%" mkdir "%PGADMIN_ROOT%"
if not exist "%PGADMIN_DATA_DIR%" mkdir "%PGADMIN_DATA_DIR%"

for /f "delims=" %%I in ('where py 2^>nul') do if not defined PYTHON_BOOTSTRAP set "PYTHON_BOOTSTRAP=py -3"
if not defined PYTHON_BOOTSTRAP (
	for /f "delims=" %%I in ('where python 2^>nul') do if not defined PYTHON_BOOTSTRAP set "PYTHON_BOOTSTRAP=python"
)

if not defined PYTHON_BOOTSTRAP (
	echo Python not found
	exit /b 3
)

if /i "%ACTION%"=="stop" goto :stop
if /i "%ACTION%"=="install" goto :install
if /i "%ACTION%"=="update" goto :update
goto :run

:install
echo.
echo ========================================
echo pgAdmin Installation Process Started
echo ========================================
echo.
call :ensure_venv
if errorlevel 1 (
	echo.
	echo ERROR: Failed to setup virtual environment
	pause
	exit /b 1
)
call :install_package
if errorlevel 1 (
	echo.
	echo ERROR: Failed to install pgAdmin4
	pause
	exit /b 1
)
call :write_config
if errorlevel 1 (
	echo.
	echo ERROR: Failed to write configuration
	pause
	exit /b 1
)
call :restart_gajahweb
echo.
echo ========================================
echo pgAdmin installation finished successfully
echo ========================================
echo.
exit /b 0

:update
echo.
echo ========================================
echo pgAdmin Update Process Started
echo ========================================
echo.
call :ensure_venv
if errorlevel 1 (
	echo.
	echo ERROR: Failed to setup virtual environment
	pause
	exit /b 1
)
call :update_package
if errorlevel 1 (
	echo.
	echo ERROR: Failed to update pgAdmin4
	pause
	exit /b 1
)
call :write_config
if errorlevel 1 (
	echo.
	echo ERROR: Failed to write configuration
	pause
	exit /b 1
)
call :restart_gajahweb
echo.
echo ========================================
echo pgAdmin update finished successfully
echo ========================================
echo.
pause
exit /b 0

:run
if not exist "%PGADMIN_PYTHON_EXE%" (
	echo.
	echo ERROR: pgAdmin environment not found. Please install or update pgAdmin first.
	pause
	exit /b 1
)
call :write_config
if errorlevel 1 (
	echo.
	echo ERROR: Failed to write configuration
	pause
	exit /b 1
)

if not exist "%PGADMIN_EXE%" if not exist "%PGADMIN_WEB_DIR%\pgAdmin4.py" (
	echo.
	echo ERROR: pgAdmin executable/script not found.
	echo EXE: %PGADMIN_EXE%
	echo PY : %PGADMIN_WEB_DIR%\pgAdmin4.py
	echo Please install or update pgAdmin first.
	pause
	exit /b 3
)

echo.
echo ========================================
echo Starting pgAdmin 4 on port %PORT%
echo ========================================
echo EXE: %PGADMIN_EXE%
echo Config: %PGADMIN_WEB_DIR%\config_local.py
echo Data:   %PGADMIN_DATA_DIR%
echo.
if exist "%PGADMIN_EXE%" (
	start "" "%PGADMIN_EXE%"
) else (
	start "" "%PGADMIN_PYTHON_EXE%" "%PGADMIN_WEB_DIR%\pgAdmin4.py"
)

if errorlevel 1 (
	echo ERROR: Failed to start pgAdmin process
	exit /b 1
)

echo pgAdmin started in detached mode
exit /b 0

:stop
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :%PORT%') do taskkill /F /PID %%P >nul 2>&1
echo Stopped pgAdmin on port %PORT%
exit /b 0

:ensure_venv
echo Checking virtual environment at: %PGADMIN_VENV_DIR%
if not exist "%PGADMIN_PYTHON_EXE%" (
	echo.
	echo Creating virtual environment...
	%PYTHON_BOOTSTRAP% -m venv "%PGADMIN_VENV_DIR%"
	if errorlevel 1 (
		echo ERROR: Failed to create virtual environment
		exit /b 1
	)
	echo Virtual environment created successfully
)

echo.
exit /b 0

:install_package
echo.
echo Installing pgAdmin4...
"%PGADMIN_PYTHON_EXE%" -m pip install pgadmin4
if errorlevel 1 (
	echo ERROR: Failed to install pgAdmin4
	exit /b 1
)
echo pgAdmin4 installed successfully
exit /b 0

:update_package
echo.
echo Updating pgAdmin4...
"%PGADMIN_PYTHON_EXE%" -m pip install --upgrade pgadmin4
if errorlevel 1 (
	echo ERROR: Failed to update pgAdmin4
	exit /b 1
)
echo pgAdmin4 updated successfully
exit /b 0

:restart_gajahweb
echo.
echo Restarting GajahWeb app (kill process)...
taskkill /F /IM gajahweb.exe >nul 2>&1
if errorlevel 1 (
	echo gajahweb.exe is not running or could not be terminated.
) else (
	echo gajahweb.exe terminated.
)
exit /b 0

:write_config
if not exist "%PGADMIN_WEB_DIR%" (
	echo Creating config directory: %PGADMIN_WEB_DIR%
	mkdir "%PGADMIN_WEB_DIR%"
	if errorlevel 1 (
		echo ERROR: Failed to create config directory
		exit /b 1
	)
)
echo Writing pgAdmin configuration...
> "%PGADMIN_WEB_DIR%\config_local.py" (
	echo # Auto-generated by GajahWeb - do not edit manually.
	echo DATA_DIR = r'%PGADMIN_DATA_DIR%'
	echo LOG_FILE = r'%PGADMIN_ROOT%\pgadmin4.log'
	echo DEFAULT_SERVER_PORT = %PORT%
	echo DEFAULT_SERVER = '127.0.0.1'
	echo SERVER_MODE = False
	echo MASTER_PASSWORD_REQUIRED = False
	echo UPGRADE_CHECK_ENABLED = False
)
if errorlevel 1 (
	echo ERROR: Failed to write config file
	exit /b 1
)
echo Configuration written successfully to: %PGADMIN_WEB_DIR%\config_local.py
exit /b 0
endlocal
