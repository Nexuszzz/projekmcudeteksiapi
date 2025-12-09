@echo off
echo ================================================================================
echo 🔄 RESTARTING BACKEND SERVER WITH VOICE CALL FEATURE
echo ================================================================================
echo.

echo [1/3] Finding and stopping old backend process on port 3001...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001"') do (
    echo Killing process ID: %%a
    taskkill /F /PID %%a 2>nul
)
timeout /t 2 >nul
echo ✅ Old process stopped
echo.

echo [2/3] Verifying .env file has Twilio credentials...
cd whatsapp-server
findstr "TWILIO_ACCOUNT_SID" .env >nul
if %errorlevel% neq 0 (
    echo ❌ ERROR: .env file missing Twilio credentials!
    echo.
    echo Please run this first:
    echo   cd whatsapp-server
    echo   .\add-twilio-config.bat
    echo.
    pause
    exit /b 1
)
echo ✅ Twilio credentials found in .env
echo.

echo [3/3] Starting backend server with updated code...
echo.
echo ⚠️  IMPORTANT: Keep this window open!
echo ⚠️  This will show server logs. Press Ctrl+C to stop.
echo.
timeout /t 3
echo Starting...
echo.

npm start
