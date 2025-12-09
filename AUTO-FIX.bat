@echo off
REM Auto-fix script without user interaction
echo [FIX] Stopping old backend...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001" ^| findstr "LISTENING"') do taskkill /F /PID %%a >nul 2>&1
timeout /t 2 >nul

echo [FIX] Verifying .env file...
cd whatsapp-server
if not exist ".env" copy .env.example .env >nul
findstr "TWILIO_ACCOUNT_SID" .env >nul || (
    echo # Twilio Voice Call Configuration>> .env
    echo TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE>> .env
    echo TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE>> .env
    echo TWILIO_PHONE_NUMBER=+12174398497>> .env
    echo TWILIO_VOICE_URL=https://demo.twilio.com/welcome/voice/>> .env
)

echo [FIX] Starting new backend in background...
start /MIN "WhatsApp-Server" cmd /c "npm start"
timeout /t 6 >nul

echo [FIX] Testing endpoints...
curl -s http://localhost:3001/api/voice-call/config
echo.
echo.
echo [FIX] Done! Refresh browser and try again.
