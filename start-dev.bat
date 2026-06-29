@echo off
title Rapid Motors - Dev Environment Startup
cls

:: --- 0. PRE-FLIGHT SYSTEM CHECK ---
echo Checking system requirements...

where php >nul 2>nul
if %ERRORLEVEL% neq 0 (echo [MISSING] PHP is not installed. Download here: https://windows.php.net/download/ & set ERROR_FOUND=1)

where composer >nul 2>nul
if %ERRORLEVEL% neq 0 (echo [MISSING] Composer is not installed. Download here: https://getcomposer.org/download/ & set ERROR_FOUND=1)

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (echo [MISSING] Node.js is not installed. Download here: https://nodejs.org/ & set ERROR_FOUND=1)

if "%ERROR_FOUND%"=="1" (
    echo.
    echo ============================================================
    echo Please install the missing components above and restart.
    echo ============================================================
    pause
    exit /b 1
)
echo [OK] All system requirements met.
echo.

:: --- 1. AUTOMATIC ENV FILE CREATION & INTERACTIVE CONFIGURATION ---
if exist ".env" goto CHECK_BACKEND
if not exist ".env.example" goto MISSING_EXAMPLE

echo ============================================================
echo [CONFIG] .env file is missing. Let's configure your database!
echo ============================================================
echo.

set "DB_PORT_INPUT="
set /p DB_PORT_INPUT="Enter MySQL Port [Default: 3333]: "
if "%DB_PORT_INPUT%"=="" set "DB_PORT_INPUT=3333"

set "DB_USER_INPUT="
set /p DB_USER_INPUT="Enter MySQL Username [Default: root]: "
if "%DB_USER_INPUT%"=="" set "DB_USER_INPUT=root"

set "DB_PASS_INPUT="
set /p DB_PASS_INPUT="Enter MySQL Password [If NO password, just press ENTER]: "

copy ".env.example" ".env" >nul

echo.
echo Injecting database credentials into .env...
powershell -Command "$c = GC .env; $c = $c -replace '^\s*#?\s*DB_CONNECTION=.*', 'DB_CONNECTION=mysql'; $c = $c -replace '^\s*#?\s*DB_HOST=.*', 'DB_HOST=127.0.0.1'; $c = $c -replace '^\s*#?\s*DB_PORT=.*', 'DB_PORT=%DB_PORT_INPUT%'; $c = $c -replace '^\s*#?\s*DB_DATABASE=.*', 'DB_DATABASE=rapid_motors'; $c = $c -replace '^\s*#?\s*DB_USERNAME=.*', 'DB_USERNAME=%DB_USER_INPUT%'; $c = $c -replace '^\s*#?\s*DB_PASSWORD=.*', 'DB_PASSWORD=%DB_PASS_INPUT%'; $c | Out-File -encoding ASCII .env"

echo .env file created and configured successfully.
echo.
goto CHECK_BACKEND

:MISSING_EXAMPLE
echo ============================================================
echo [ERROR] Neither .env nor .env.example found!
echo Please ensure .env.example exists in the root folder.
echo ============================================================
pause
exit /b 1

:CHECK_BACKEND
:: 2. BACKEND DEPENDENCY CHECK
if not exist "vendor" goto MISSING_VENDOR
goto CHECK_FRONTEND

:MISSING_VENDOR
echo ============================================================
echo [WARNING] Laravel backend dependencies (vendor folder) are missing!
echo ============================================================
:LOOP_VENDOR
set "comp_choice="
set /p comp_choice="Would you like to run 'composer install' now? (yes/no): "
if /I "%comp_choice%"=="yes" goto RUN_COMPOSER
if /I "%comp_choice%"=="no" exit
echo Invalid input! Please type 'yes' or 'no'.
echo.
goto LOOP_VENDOR

:RUN_COMPOSER
echo.
echo ============================================================
echo [INFO] Downloading Laravel dependencies...
echo This might take a few minutes depending on your connection.
echo ============================================================
cmd /c composer install --no-scripts --no-autoloader
if %ERRORLEVEL% neq 0 (
    echo Composer install failed.
    pause
    exit /b 1
)
echo.
echo [INFO] Generating fast development autoloader...
cmd /c composer dump-autoload
echo.
goto CHECK_FRONTEND

:CHECK_FRONTEND
:: 3. FRONTEND DEPENDENCY CHECK
if not exist "node_modules" goto MISSING_NODE
goto CHECK_APP_KEY

:MISSING_NODE
echo ============================================================
echo [WARNING] Frontend dependencies (node_modules folder) are missing!
echo ============================================================
:LOOP_NODE
set "npm_choice="
set /p npm_choice="Would you like to run 'npm install' now? (yes/no): "
if /I "%npm_choice%"=="yes" goto RUN_NPM
if /I "%npm_choice%"=="no" exit
echo Invalid input! Please type 'yes' or 'no'.
echo.
goto LOOP_NODE

:RUN_NPM
echo.
echo ============================================================
echo [INFO] Running npm install... Please wait...
echo ============================================================
cmd /c npm install --legacy-peer-deps
echo [INFO] Running npm audit fix...
cmd /c npm audit fix
echo.
goto CHECK_APP_KEY

:CHECK_APP_KEY
:: 4. APP KEY GENERATION CHECK
findstr /C:"APP_KEY=base64:" .env >nul
if %ERRORLEVEL% neq 0 (
    echo [INFO] Generating application encryption key...
    cmd /c php artisan key:generate
    echo.
)
goto CHECK_DATABASE

:CHECK_DATABASE
:: 5. DYNAMIC DATABASE CONNECTION & AUTO-CREATION
echo Checking database connection...
php -r "$t=file_get_contents('.env'); preg_match('/^\s*DB_PORT\s*=\s*(.*)/m', $t, $po); preg_match('/^\s*DB_USERNAME\s*=\s*(.*)/m', $t, $us); preg_match('/^\s*DB_PASSWORD\s*=\s*(.*)/m', $t, $pa); preg_match('/^\s*DB_DATABASE\s*=\s*(.*)/m', $t, $da); $port=trim($po[1]??'3306'); $user=trim($us[1]??'root'); $pass=trim($pa[1]??''); $db=trim($da[1]??'laravel'); try { $p = new PDO('mysql:host=127.0.0.1;port='.$port, $user, $pass); $p->exec('CREATE DATABASE IF NOT EXISTS '.$db); echo 'OK'; } catch(Exception $e) { echo 'ERROR'; }" > %TEMP%\dbcheck.txt 2>nul
find "OK" %TEMP%\dbcheck.txt >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Could not connect to MySQL! Please check your server.
    pause
    exit /b 1
)
echo Database is ready.
echo.
goto START_SERVERS

:START_SERVERS
echo ============================================================
echo Starting development servers...
echo ============================================================
start "Rapid Motors - Backend" cmd /k "php artisan migrate:fresh --seed && php artisan serve --port=8000"
start "Rapid Motors - Frontend" cmd /k "npm run dev"
exit