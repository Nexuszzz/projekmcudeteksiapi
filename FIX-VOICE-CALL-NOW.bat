@echo off
cls
color 0A
echo ================================================================================
echo 🚀 QUICK FIX: Emergency Voice Call Feature
echo ================================================================================
echo.
echo ⚠️  PROBLEM DETECTED:
echo     Backend server is running OLD code without voice call endpoints!
echo.
echo 🔧 SOLUTION:
echo     We need to RESTART backend server with the NEW code.
echo.
echo This script will:
echo   1. Stop old backend process
echo   2. Verify Twilio credentials in .env
echo   3. Start NEW backend with voice call feature
echo.
echo ⏱️  This will take ~10 seconds
echo.
pause
echo.

echo ================================================================================
echo [1/4] Stopping old backend process...
echo ================================================================================
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001" ^| findstr "LISTENING"') do (
    echo Found process: %%a
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel!==0 (
        echo ✅ Process %%a stopped
    ) else (
        echo ⚠️  Failed to stop %%a ^(might already be stopped^)
    )
)
timeout /t 2 >nul
echo.

echo ================================================================================
echo [2/4] Verifying environment...
echo ================================================================================
cd whatsapp-server
if not exist ".env" (
    echo ❌ ERROR: .env file not found!
    echo Creating from .env.example...
    copy .env.example .env >nul
)

findstr "TWILIO_ACCOUNT_SID" .env >nul
if %errorlevel% neq 0 (
    echo ⚠️  Twilio credentials missing, adding now...
    call add-twilio-config.bat >nul
)
echo ✅ Configuration ready
echo.

echo ================================================================================
echo [3/4] Starting backend server...
echo ================================================================================
echo.
echo ⚠️  NEW WINDOW will open with server logs
echo ⚠️  DO NOT CLOSE that window!
echo.
timeout /t 2
start "WhatsApp Server - Voice Call Enabled" cmd /k "npm start"
echo ✅ Server starting in new window...
echo.
timeout /t 5
echo.

echo ================================================================================
echo [4/4] Verifying server is working...
echo ================================================================================
timeout /t 3
echo.
echo Testing API endpoints...
curl -s http://localhost:3001/api/voice-call/config
echo.
echo.

echo ================================================================================
echo 🎉 DONE!
echo ================================================================================
echo.
echo Next steps:
echo   1. Check the NEW window - should show "✅ Twilio Voice Call initialized"
echo   2. Refresh your browser (F5) on http://localhost:5173
echo   3. Try adding emergency number again
echo   4. Check browser console (F12) for any errors
echo.
echo If still not working:
echo   - Press F12 in browser
echo   - Go to Console tab  
echo   - Try add number again
echo   - Copy any error messages
echo.
pause
