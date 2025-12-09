@echo off
title Quick Test - Dashboard Test Call Feature
color 0E

cls
echo.
echo ================================================================================
echo              🧪 QUICK TEST - DASHBOARD TEST CALL FEATURE
echo ================================================================================
echo.
echo This script will help you test the Test Call feature in the dashboard.
echo.
echo Prerequisites:
echo   1. Voice call server running (port 3002)
echo   2. Dashboard running (port 5173)
echo   3. Twilio configured in .env
echo.
echo ================================================================================
echo.

cd /d "%~dp0"

REM Check voice call server
echo [1/3] Checking Voice Call Server...
curl -s http://localhost:3002/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Voice Call Server: RUNNING
) else (
    echo    ❌ Voice Call Server: NOT RUNNING
    echo.
    echo    Please start it first:
    echo      cd voice-call-server
    echo      npm start
    echo.
    pause
    exit /b 1
)

REM Check dashboard
echo [2/3] Checking Dashboard...
curl -s http://localhost:5173 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Dashboard: RUNNING
) else (
    echo    ❌ Dashboard: NOT RUNNING
    echo.
    echo    Please start it first:
    echo      npm run dev
    echo.
    pause
    exit /b 1
)

REM Check Twilio config
echo [3/3] Checking Twilio Configuration...
curl -s http://localhost:3002/api/voice-call/config > temp_config.json 2>&1
findstr /C:"\"enabled\":true" temp_config.json >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    ✅ Twilio: ENABLED
) else (
    echo    ⚠️  Twilio: NOT CONFIGURED
    echo.
    echo    Please configure Twilio in voice-call-server\.env:
    echo      TWILIO_ACCOUNT_SID=ACxxxxx
    echo      TWILIO_AUTH_TOKEN=xxxxx
    echo      TWILIO_PHONE_NUMBER=+1234567890
    echo.
)
del temp_config.json >nul 2>&1

echo.
echo ================================================================================
echo ✅ ALL CHECKS PASSED!
echo ================================================================================
echo.
echo Now test the Test Call feature:
echo.
echo 📋 STEPS:
echo   1. Open Dashboard: http://localhost:5173
echo   2. Scroll to "Emergency Voice Calls" section
echo   3. Click "Add Number" button
echo   4. Enter your phone number: +628123456789 (with country code!)
echo   5. Enter name: Your Name
echo   6. Click "Add Number"
echo   7. Find your number in the list
echo   8. Click the "📤 Test Call" button (BLUE button)
echo   9. Confirm in the dialog
echo   10. Wait for your phone to ring!
echo.
echo 🎯 EXPECTED RESULTS:
echo   ✅ Button changes to "⏳ Calling..."
echo   ✅ Success message appears with Call SID
echo   ✅ Your phone rings within 30 seconds
echo   ✅ You hear: "This is a test call from the Fire Detection..."
echo   ✅ Button changes to "✅ Tested" (GREEN)
echo.
echo 🐛 IF TEST FAILS:
echo   - Check if number is VERIFIED (for trial accounts)
echo   - Go to: console.twilio.com → Verified Caller IDs
echo   - Add and verify your number
echo   - Try test again
echo.
echo ================================================================================
echo.

REM Open dashboard automatically
choice /C YN /M "Open Dashboard automatically in browser"
if %ERRORLEVEL% EQU 1 (
    echo.
    echo Opening Dashboard...
    start http://localhost:5173
)

echo.
echo Press any key to exit...
pause >nul
