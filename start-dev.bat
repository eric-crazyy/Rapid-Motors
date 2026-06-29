@echo off
title Rapid Motors - Dev Environment Startup
cls

:: 0. AUTOMATIC ENV FILE CREATION & INTERACTIVE CONFIGURATION
if not exist ".env" (
    if exist ".env.example" (
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
    ) else (
        echo ============================================================
        echo [ERROR] Neither .env nor .env.example found!
        echo Please ensure .env.example exists in the root folder.
        echo ============================================================
        pause
        exit /b 1
    )
)

:: 1. BACKEND DEPENDENCY CHECK
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
if /I "%comp_choice%"=="no" (
    echo Exiting program...
    timeout /t 2 >nul
    exit
)
echo Invalid input! Please type 'yes' or 'no'.
echo.
goto LOOP_VENDOR

:RUN_COMPOSER
echo.
echo Running composer install... Please wait...
cmd /c composer install --no-scripts --no-autoloader
if %ERRORLEVEL% neq 0 (
    echo Composer install failed.
    pause
    exit /b 1
)

echo.
echo Generating fast development autoloader...
cmd /c composer dump-autoload
echo.
goto CHECK_FRONTEND


:CHECK_FRONTEND
:: 2. FRONTEND DEPENDENCY CHECK
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
if /I "%npm_choice%"=="no" (
    echo Exiting program...
    timeout /t 2 >nul
    exit
)
echo Invalid input! Please type 'yes' or 'no'.
echo.
goto LOOP_NODE

:RUN_NPM
echo.
echo Running npm install... Please wait...
cmd /c npm install --legacy-peer-deps
echo.
goto CHECK_APP_KEY


:CHECK_APP_KEY
:: 3. APP KEY GENERATION CHECK
findstr /C:"APP_KEY=base64:" .env >nul
if %ERRORLEVEL% neq 0 (
    echo ============================================================
    echo [INFO] Application encryption key is missing. Generating key...
    echo ============================================================
    cmd /c php artisan key:generate
    echo.
)
goto CHECK_DATABASE


:CHECK_DATABASE
:: 4. DYNAMIC DATABASE CONNECTION & AUTO-CREATION (Reads directly from .env)
echo Checking database connection using .env configuration...
php -r "$t=file_get_contents('.env'); preg_match('/^\s*DB_PORT\s*=\s*(.*)/m', $t, $po); preg_match('/^\s*DB_USERNAME\s*=\s*(.*)/m', $t, $us); preg_match('/^\s*DB_PASSWORD\s*=\s*(.*)/m', $t, $pa); preg_match('/^\s*DB_DATABASE\s*=\s*(.*)/m', $t, $da); $port=trim($po[1]??'3306'); $user=trim($us[1]??'root'); $pass=trim($pa[1]??''); $db=trim($da[1]??'laravel'); try { $p = new PDO('mysql:host=127.0.0.1;port='.$port, $user, $pass); $p->exec('CREATE DATABASE IF NOT EXISTS '.$db); echo 'OK'; } catch(Exception $e) { echo 'ERROR'; }" > %TEMP%\dbcheck.txt 2>nul
find "OK" %TEMP%\dbcheck.txt >nul 2>&1

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Could not connect to MySQL! 
    echo Please make sure your SQL server is running with the credentials specified in your .env file.
    echo ============================================================
    echo.
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
echo.

:: Launch Backend
start "Rapid Motors - Backend (Laravel)" cmd /k "php artisan migrate:fresh --seed && php artisan serve --port=8000"

:: Launch Frontend
start "Rapid Motors - Frontend (Vue/Vite)" cmd /k "npm run dev"

exit