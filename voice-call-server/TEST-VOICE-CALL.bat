@echo off
title Test Twilio Voice Call
color 0E

echo.
echo ================================================================================
echo                   TEST TWILIO VOICE CALL FOR FIRE DETECTION
echo ================================================================================
echo.
echo This script will test the voice call functionality.
echo.

REM Check if .env exists
if not exist ".env" (
    echo ERROR: .env file not found!
    echo.
    echo Please create .env file with Twilio credentials:
    echo   TWILIO_ACCOUNT_SID=ACxxxxx
    echo   TWILIO_AUTH_TOKEN=xxxxx
    echo   TWILIO_PHONE_NUMBER=+1234567890
    echo.
    pause
    exit /b 1
)

REM Check if server is running
echo Checking if voice-call-server is running...
curl -s http://localhost:3002/health >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Voice Call Server is not running!
    echo.
    echo Please start the server first:
    echo   1. Open new terminal
    echo   2. cd d:\IotCobwengdev-backup-20251103-203857\voice-call-server
    echo   3. npm start
    echo.
    pause
    exit /b 1
)

echo OK - Server is running!
echo.

REM Get phone number
echo ================================================================================
echo PHONE NUMBER INPUT
echo ================================================================================
echo.
echo Enter phone number to test (with country code):
echo   Format: +628123456789 (Indonesia)
echo   Format: +1234567890 (USA)
echo.
set /p PHONE_NUMBER="Phone Number: "

if "%PHONE_NUMBER%"=="" (
    echo ERROR: Phone number is required!
    pause
    exit /b 1
)

echo.
echo ================================================================================
echo SENDING TEST CALL
echo ================================================================================
echo.
echo Calling: %PHONE_NUMBER%
echo.

REM Make API request to test endpoint
curl -X POST http://localhost:3002/api/voice-call/test ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\":\"%PHONE_NUMBER%\"}"

echo.
echo.
echo ================================================================================
echo TEST COMPLETE
echo ================================================================================
echo.
echo Did you receive the call and hear the message?
echo.
echo If YES:
echo   - System is working correctly!
echo   - Ready for fire detection integration
echo.
echo If NO:
echo   - Check if your number is VERIFIED (for trial accounts)
echo   - Verify at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
echo   - Check Twilio logs: https://console.twilio.com/us1/monitor/logs/calls
echo.
echo ================================================================================
echo.
pause
