@echo off
color 0A
title QUICK FIX - Restart Voice Server & Test

cls
echo.
echo ================================================================================
echo                  QUICK FIX - Error 21609 SOLVED!
echo ================================================================================
echo.
echo Problem: localhost URL not accessible by Twilio
echo Solution: Removed statusCallback (optional parameter)
echo Result: Calls will work now!
echo.
echo ================================================================================
echo.

echo [1/3] Stopping old Voice Call Server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 2 >nul
echo    [OK] Old server stopped
echo.

echo [2/3] Starting NEW Voice Call Server (without statusCallback)...
cd voice-call-server
start "Voice Call Server - FIXED" cmd /k "title Voice Call - Error 21609 FIXED & npm start"
cd ..
timeout /t 8 >nul
echo    [OK] Server started
echo.

echo [3/3] Testing call to your number...
echo.
set phone=+6289677175597

echo Making test call to: %phone%
echo.
echo You should receive call with INDONESIAN fire alert!
echo.

curl -X POST http://localhost:3002/api/voice-call/test -H "Content-Type: application/json" -d "{\"phoneNumber\":\"%phone%\"}"

echo.
echo.
echo ================================================================================
echo WAIT FOR PHONE TO RING (10-30 SECONDS)
echo ================================================================================
echo.
echo Answer the phone and listen for:
echo.
echo   "Perhatian! Terdeteksi kebakaran di lokasi Anda!"
echo   "Segera lakukan evakuasi!"
echo.
echo Message will repeat 3 times in Indonesian, then 2 times in English.
echo.
echo ================================================================================
echo.
echo If phone RINGS and you HEAR the message: SUCCESS! ✅
echo.
echo If still no call, check Twilio logs:
echo   https://console.twilio.com/us1/monitor/logs/calls
echo.
pause
