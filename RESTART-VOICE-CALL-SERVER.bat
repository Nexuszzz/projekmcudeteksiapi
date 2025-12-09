@echo off
color 0E
title Restart Voice Call Server

echo.
echo ================================================================================
echo              RESTARTING VOICE CALL SERVER
echo ================================================================================
echo.
echo Reason: Updated to use custom Indonesian fire alert message
echo.
echo Old: Demo Twilio voice (English only)
echo New: Custom message (Indonesian + English, loops 3x)
echo.
echo ================================================================================
echo.

echo Stopping old Voice Call Server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002 ^| findstr LISTENING 2^>nul') do (
    echo    Killing PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 2 >nul
echo    [OK] Old server stopped
echo.

echo Starting new Voice Call Server with custom fire alert...
cd voice-call-server
start "Voice Call Server (3002)" cmd /k "title Voice Call Server - Custom Fire Alert & echo ================================================ & echo   VOICE CALL SERVER with CUSTOM FIRE ALERT & echo   Port 3002 - Indonesian + English Message & echo ================================================ & npm start"
cd ..

timeout /t 5 >nul

echo.
echo ================================================================================
echo Verifying server...
echo ================================================================================
echo.
curl -s http://localhost:3002/health
echo.
echo.

echo ================================================================================
echo [SUCCESS] Voice Call Server Restarted!
echo ================================================================================
echo.
echo Changes:
echo   * Custom TwiML endpoint: /api/twilio/fire-alert-voice
echo   * Message in INDONESIAN + English
echo   * Loops 3 times for clarity
echo   * Much more clear than demo message!
echo.
echo Next: Test call to verify you can hear the message!
echo.
pause
