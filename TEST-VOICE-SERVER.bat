@echo off
echo ========================================================================
echo 🧪 TEST VOICE CALL SERVER
echo ========================================================================
echo.

echo 🔍 Step 1: Check if voice-call-server folder exists...
if exist "voice-call-server" (
    echo ✅ Folder exists
) else (
    echo ❌ Folder NOT found!
    pause
    exit /b 1
)

echo.
echo 🔍 Step 2: Check if server.js exists...
if exist "voice-call-server\server.js" (
    echo ✅ server.js exists
) else (
    echo ❌ server.js NOT found!
    pause
    exit /b 1
)

echo.
echo 🔍 Step 3: Check if .env exists...
if exist "voice-call-server\.env" (
    echo ✅ .env exists
) else (
    echo ⚠️  .env NOT found - creating from .env.example...
    if exist "voice-call-server\.env.example" (
        copy "voice-call-server\.env.example" "voice-call-server\.env"
        echo ✅ .env created
        echo ⚠️  Please edit .env with your Twilio credentials!
    ) else (
        echo ❌ .env.example NOT found!
    )
)

echo.
echo 🔍 Step 4: Check if node_modules exists...
if exist "voice-call-server\node_modules" (
    echo ✅ node_modules exists
) else (
    echo ⚠️  node_modules NOT found - installing...
    cd voice-call-server
    call npm install
    cd ..
    echo ✅ Dependencies installed
)

echo.
echo 🔍 Step 5: Check if port 3002 is available...
netstat -ano | findstr ":3002" >nul
if %errorlevel%==0 (
    echo ⚠️  Port 3002 is ALREADY IN USE!
    echo 🔍 Finding process...
    netstat -ano | findstr ":3002"
    echo.
    echo ❓ Kill existing process? (y/n)
    set /p kill=
    if /i "%kill%"=="y" (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3002" ^| findstr "LISTENING"') do (
            echo Killing PID: %%a
            taskkill /F /PID %%a
        )
        timeout /t 2 /nobreak >nul
    )
) else (
    echo ✅ Port 3002 is available
)

echo.
echo ========================================================================
echo 🚀 STARTING VOICE CALL SERVER
echo ========================================================================
echo.
echo Starting server in 3 seconds...
echo Close this window to stop the server.
echo.
timeout /t 3 /nobreak >nul

cd voice-call-server
node server.js

pause
