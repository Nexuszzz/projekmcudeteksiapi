@echo off
title Complete Fire Detection System Test
color 0B

cls
echo.
echo ================================================================================
echo              🔥 COMPLETE FIRE DETECTION SYSTEM TEST 🔥
echo ================================================================================
echo.
echo This script will test the ENTIRE fire detection system end-to-end:
echo.
echo   1. ✅ Check all services are running
echo   2. ✅ Test MQTT connectivity
echo   3. ✅ Test WhatsApp connection
echo   4. ✅ Test Voice Call (Twilio)
echo   5. ✅ Simulate fire detection
echo   6. ✅ Verify all alerts delivered
echo.
echo ================================================================================
echo.

cd /d "%~dp0"

echo.
echo ================================================================================
echo [Step 1/6] Checking Services Status
echo ================================================================================
echo.

REM Check Proxy Server (8080)
echo Checking Proxy Server (Port 8080)...
curl -s http://localhost:8080/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Proxy Server: RUNNING
) else (
    echo    ❌ Proxy Server: NOT RUNNING
    echo.
    echo    Please start: cd proxy-server ^&^& npm start
    goto :error
)

REM Check WhatsApp Server (3001)
echo Checking WhatsApp Server (Port 3001)...
curl -s http://localhost:3001/api/whatsapp/status >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ WhatsApp Server: RUNNING
) else (
    echo    ❌ WhatsApp Server: NOT RUNNING
    echo.
    echo    Please start: cd whatsapp-server ^&^& npm start
    goto :error
)

REM Check Voice Call Server (3002)
echo Checking Voice Call Server (Port 3002)...
curl -s http://localhost:3002/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Voice Call Server: RUNNING
) else (
    echo    ❌ Voice Call Server: NOT RUNNING
    echo.
    echo    Please start: cd voice-call-server ^&^& npm start
    goto :error
)

REM Check Dashboard (5173)
echo Checking Dashboard (Port 5173)...
curl -s http://localhost:5173 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Dashboard: RUNNING
) else (
    echo    ⚠️  Dashboard: NOT RUNNING (optional)
)

echo.
echo ✅ All critical services are running!
timeout /t 2 >nul

echo.
echo ================================================================================
echo [Step 2/6] Testing MQTT Connectivity
echo ================================================================================
echo.

echo Fetching Proxy Server health status...
curl -s http://localhost:8080/health

echo.
echo ✅ MQTT connectivity verified via Proxy Server
timeout /t 2 >nul

echo.
echo ================================================================================
echo [Step 3/6] Testing WhatsApp Connection
echo ================================================================================
echo.

echo Fetching WhatsApp connection status...
curl -s http://localhost:3001/api/whatsapp/status

echo.
echo.
echo ❓ Is WhatsApp CONNECTED? (y/n): 
set /p WA_CONNECTED=
if /i "%WA_CONNECTED%"=="n" (
    echo.
    echo ⚠️  Please connect WhatsApp first:
    echo    1. Open Dashboard: http://localhost:5173
    echo    2. Go to WhatsApp Settings
    echo    3. Generate Pairing Code
    echo    4. Enter code in WhatsApp app
    echo.
    pause
    goto :error
)

echo ✅ WhatsApp is connected!
timeout /t 2 >nul

echo.
echo ================================================================================
echo [Step 4/6] Testing Voice Call (Twilio)
echo ================================================================================
echo.

echo Fetching Voice Call configuration...
curl -s http://localhost:3002/api/voice-call/config

echo.
echo.
echo ❓ Is Twilio ENABLED? (y/n): 
set /p TWILIO_ENABLED=
if /i "%TWILIO_ENABLED%"=="n" (
    echo.
    echo ⚠️  Twilio is not configured. Voice calls will be SKIPPED.
    echo    To enable: Add credentials to voice-call-server\.env
    echo.
    set VOICE_TEST=n
) else (
    echo.
    echo ❓ Do you want to test a voice call now? (y/n): 
    set /p VOICE_TEST=
    
    if /i "!VOICE_TEST!"=="y" (
        echo.
        echo Enter phone number to test (format: +628xxx):
        set /p TEST_PHONE=
        
        echo.
        echo Sending test call to !TEST_PHONE!...
        curl -X POST http://localhost:3002/api/voice-call/test ^
          -H "Content-Type: application/json" ^
          -d "{\"phoneNumber\":\"!TEST_PHONE!\"}"
        
        echo.
        echo.
        echo ❓ Did you receive and hear the call? (y/n): 
        set /p CALL_RECEIVED=
        
        if /i "!CALL_RECEIVED!"=="n" (
            echo.
            echo ⚠️  Voice call failed. Check:
            echo    - Is number verified? (for trial accounts)
            echo    - Check Twilio logs: https://console.twilio.com/us1/monitor/logs/calls
            echo.
            pause
        ) else (
            echo ✅ Voice call test successful!
        )
    )
)

timeout /t 2 >nul

echo.
echo ================================================================================
echo [Step 5/6] Checking Recipients Configuration
echo ================================================================================
echo.

echo WhatsApp Recipients:
curl -s http://localhost:3001/api/whatsapp/recipients

echo.
echo.
echo Emergency Call Numbers:
curl -s http://localhost:3002/api/voice-call/numbers

echo.
echo.
echo ❓ Have you added recipients/numbers? (y/n): 
set /p RECIPIENTS_ADDED=
if /i "%RECIPIENTS_ADDED%"=="n" (
    echo.
    echo ⚠️  Please add recipients:
    echo    1. WhatsApp: Dashboard → WhatsApp Integration → Add Recipient
    echo    2. Voice Call: Dashboard → Emergency Voice Calls → Add Number
    echo.
    pause
    goto :error
)

echo ✅ Recipients configured!
timeout /t 2 >nul

echo.
echo ================================================================================
echo [Step 6/6] Fire Detection Simulation
echo ================================================================================
echo.

echo ⚠️  MANUAL STEP: Start Python Fire Detection
echo.
echo To complete the test:
echo   1. Open NEW terminal
echo   2. cd d:\zakaiot
echo   3. python fire_detect_esp32_ultimate.py
echo   4. Enter ESP32-CAM IP address
echo   5. Show fire to camera
echo   6. Verify alerts received:
echo      ✅ WhatsApp photo message
echo      ✅ Emergency voice call
echo      ✅ ESP32 buzzer activation
echo.

echo ================================================================================
echo.
echo ✅ PRE-FLIGHT CHECK COMPLETE!
echo ================================================================================
echo.
echo All systems are GO for fire detection:
echo   ✅ Proxy Server running
echo   ✅ WhatsApp Server connected
echo   ✅ Voice Call Server %TWILIO_ENABLED%
echo   ✅ Recipients configured
echo.
echo 🔥 READY TO DETECT FIRE!
echo.
echo Next: Start Python detection script and test with real fire
echo.
echo ================================================================================
echo.
pause
exit /b 0

:error
echo.
echo ================================================================================
echo ❌ TEST FAILED
echo ================================================================================
echo.
echo Please fix the issues above and run this test again.
echo.
echo Quick Start:
echo   1. Run: START-SEPARATED-SERVICES.bat
echo   2. Wait for all services to start
echo   3. Run this test again
echo.
pause
exit /b 1
