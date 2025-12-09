@echo off
echo ========================================================================
echo 🔧 FIX VOICE CALL SERVER - Diagnostic and Restart
echo ========================================================================
echo.

REM Check if voice-call-server is running
echo 🔍 Checking if voice-call-server is running on port 3002...
netstat -ano | findstr ":3002" >nul
if %errorlevel%==0 (
    echo ✅ Port 3002 is in use
    echo.
    echo 🔍 Finding process using port 3002...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3002" ^| findstr "LISTENING"') do (
        echo    PID: %%a
        echo.
        echo ⚠️  Killing old voice-call-server process...
        taskkill /F /PID %%a >nul 2>&1
        if errorlevel 1 (
            echo    ❌ Failed to kill process
        ) else (
            echo    ✅ Process killed successfully
        )
    )
) else (
    echo ❌ Port 3002 is not in use - voice-call-server not running
)

echo.
echo ========================================================================
echo 🚀 Starting Voice Call Server
echo ========================================================================
echo.

REM Check if voice-call-server folder exists
if not exist "voice-call-server" (
    echo ❌ ERROR: voice-call-server folder not found!
    echo.
    echo Current directory: %CD%
    echo.
    echo Please ensure you're in the correct directory:
    echo d:\IotCobwengdev-backup-20251103-203857
    echo.
    pause
    exit /b 1
)

REM Check if .env exists
if not exist "voice-call-server\.env" (
    echo ⚠️  WARNING: .env file not found in voice-call-server!
    echo.
    echo Creating .env from .env.example...
    if exist "voice-call-server\.env.example" (
        copy "voice-call-server\.env.example" "voice-call-server\.env"
        echo ✅ .env created
        echo.
        echo ⚠️  IMPORTANT: Edit voice-call-server\.env with your Twilio credentials!
        echo.
    ) else (
        echo ❌ .env.example not found!
        echo.
        echo Creating blank .env...
        (
            echo TWILIO_ACCOUNT_SID=your_account_sid_here
            echo TWILIO_AUTH_TOKEN=your_auth_token_here
            echo TWILIO_PHONE_NUMBER=+1234567890
            echo PORT=3002
        ) > "voice-call-server\.env"
        echo ✅ Blank .env created
        echo.
        echo ⚠️  IMPORTANT: Edit voice-call-server\.env with your Twilio credentials!
        echo.
    )
    pause
)

REM Check if node_modules exists
if not exist "voice-call-server\node_modules" (
    echo ⚠️  node_modules not found. Installing dependencies...
    cd voice-call-server
    call npm install
    cd ..
    echo.
)

REM Start voice-call-server
echo 📞 Starting voice-call-server on port 3002...
echo.
start "🎙️ Voice Call Server" cmd /k "cd voice-call-server && npm start"

REM Wait for server to start
echo ⏳ Waiting for server to start (5 seconds)...
timeout /t 5 /nobreak >nul

REM Check if server started successfully
echo.
echo 🔍 Verifying server started...
netstat -ano | findstr ":3002" >nul
if %errorlevel%==0 (
    echo ✅ Voice Call Server is running on port 3002!
    echo.
    echo ========================================================================
    echo ✅ SERVER READY
    echo ========================================================================
    echo.
    echo 📞 Voice Call API: http://localhost:3002/api/voice-call
    echo 🏥 Health Check: http://localhost:3002/health
    echo.
    echo Next steps:
    echo 1. Open dashboard: http://localhost:5173
    echo 2. Refresh the page (Ctrl+R or F5)
    echo 3. Check "Emergency Voice Calls" section
    echo 4. Error should be gone!
    echo.
    echo To test server manually:
    echo    curl http://localhost:3002/health
    echo.
) else (
    echo ❌ Server failed to start on port 3002
    echo.
    echo 🔍 Possible issues:
    echo    1. Check voice-call-server terminal for errors
    echo    2. Verify .env file has correct Twilio credentials
    echo    3. Check if another process is using port 3002
    echo    4. Ensure npm and node are installed
    echo.
    echo 📝 Check the server terminal window for error details
    echo.
)

echo ========================================================================
echo.
pause
