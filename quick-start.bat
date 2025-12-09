@echo off
echo ========================================
echo IoT Fire Detection Dashboard
echo Quick Start Setup Script
echo ========================================
echo.

echo Step 1: Copying environment configuration...
if exist env-configured.txt (
    copy /Y env-configured.txt .env
    echo [OK] Frontend .env created
) else (
    echo [ERROR] env-configured.txt not found!
    pause
    exit /b 1
)

if exist proxy-server\env-configured.txt (
    copy /Y proxy-server\env-configured.txt proxy-server\.env
    echo [OK] Proxy .env created
) else (
    echo [ERROR] proxy-server\env-configured.txt not found!
    pause
    exit /b 1
)

echo.
echo Step 2: Installing dependencies...
echo This may take a few minutes...
echo.

echo Installing frontend dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Frontend npm install failed!
    pause
    exit /b 1
)

echo.
echo Installing proxy server dependencies...
cd proxy-server
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Proxy npm install failed!
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo To start the application:
echo.
echo 1. Start Proxy Server:
echo    cd proxy-server
echo    npm start
echo.
echo 2. Start Dashboard (in new terminal):
echo    npm run dev
echo.
echo 3. Open browser: http://localhost:3000
echo.
echo See SETUP-INSTRUCTIONS.md for detailed guide
echo ========================================
pause
