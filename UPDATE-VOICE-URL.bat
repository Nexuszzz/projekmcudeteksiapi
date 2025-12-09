@echo off
color 0E
title Update Voice URL to TwiML Bin

cls
echo.
echo ================================================================================
echo              SETUP TWILIO TWIML BIN - Indonesian Fire Alert
echo ================================================================================
echo.
echo Current problem: localhost URL not accessible by Twilio
echo Solution: Use Twilio TwiML Bins (FREE hosting for TwiML)
echo.
echo ================================================================================
echo STEP 1: Create TwiML Bin
echo ================================================================================
echo.
echo 1. Open browser and go to:
echo    https://console.twilio.com/us1/develop/runtime/twiml-bins
echo.

pause

echo.
echo 2. Click: "Create new TwiML Bin" (red + button)
echo.

pause

echo.
echo 3. Enter Friendly Name:
echo    Fire Alert Indonesian
echo.

pause

echo.
echo 4. Copy and paste this TwiML code:
echo.
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Response^>
echo     ^<Say voice="Polly.Joanna" language="id-ID" loop="3"^>
echo         Perhatian! Terdeteksi kebakaran di lokasi Anda.
echo         Segera lakukan evakuasi.
echo         Ini adalah panggilan darurat otomatis dari sistem deteksi kebakaran.
echo     ^</Say^>
echo     ^<Pause length="1"/^>
echo     ^<Say voice="Polly.Joanna" language="en-US" loop="2"^>
echo         Warning! Fire detected at your location.
echo         Please evacuate immediately.
echo         This is an automated emergency call from fire detection system.
echo     ^</Say^>
echo ^</Response^>
echo.

pause

echo.
echo 5. Click: "Create"
echo.
echo 6. COPY the URL that appears!
echo    It looks like: https://handler.twilio.com/twiml/EH...
echo.

pause

echo.
echo ================================================================================
echo STEP 2: Update .env File
echo ================================================================================
echo.

set /p twiml_url="Paste your TwiML Bin URL here: "

echo.
echo Updating voice-call-server\.env file...
echo.

cd voice-call-server

REM Backup old .env
copy .env .env.backup >nul 2>&1

REM Update TWILIO_VOICE_URL
powershell -Command "(Get-Content .env) -replace 'TWILIO_VOICE_URL=.*', 'TWILIO_VOICE_URL=%twiml_url%' | Set-Content .env"

echo [OK] .env file updated!
echo.
echo TWILIO_VOICE_URL=%twiml_url%
echo.

cd ..

pause

echo.
echo ================================================================================
echo STEP 3: Restart Voice Call Server
echo ================================================================================
echo.

echo Stopping old server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 2 >nul

echo Starting new server with TwiML Bin URL...
cd voice-call-server
start "Voice Call Server - TwiML Bin" cmd /k "title Voice Call Server - Indonesian Message & npm start"
cd ..
timeout /t 8 >nul

echo [OK] Server restarted
echo.

echo ================================================================================
echo STEP 4: TEST CALL NOW!
echo ================================================================================
echo.

set /p test_phone="Enter phone number to test (with +62): "

echo.
echo Making test call to %test_phone%...
echo.

curl -X POST http://localhost:3002/api/voice-call/test -H "Content-Type: application/json" -d "{\"phoneNumber\":\"%test_phone%\"}"

echo.
echo.
echo ================================================================================
echo RESULT:
echo ================================================================================
echo.
echo If you see "success": true:
echo   - Phone will ring in 10-30 seconds
echo   - Answer and hear INDONESIAN fire alert!
echo   - Message repeats 3x in Indonesian, 2x in English
echo.
echo If still error, check:
echo   1. TwiML Bin URL correct in .env
echo   2. Destination number verified in Twilio
echo   3. Twilio phone number correct
echo.
pause
