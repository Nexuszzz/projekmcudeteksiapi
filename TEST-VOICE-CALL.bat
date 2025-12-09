@echo off
echo ================================================================================
echo 🧪 TEST EMERGENCY VOICE CALL FEATURE
echo ================================================================================
echo.

echo [1/5] Checking if backend server is running...
netstat -ano | findstr ":3001" >nul
if %errorlevel% neq 0 (
    echo ❌ Backend server NOT running on port 3001!
    echo.
    echo Please start backend first:
    echo   cd whatsapp-server
    echo   npm start
    echo.
    pause
    exit /b 1
)
echo ✅ Backend server is running
echo.

echo [2/5] Checking Twilio configuration...
curl -s http://localhost:3001/api/voice-call/config > config.json
findstr /C:"\"enabled\":true" config.json >nul
if %errorlevel% neq 0 (
    echo ❌ Twilio NOT enabled!
    echo.
    echo Please check .env file has Twilio credentials:
    echo   TWILIO_ACCOUNT_SID=...
    echo   TWILIO_AUTH_TOKEN=...
    echo   TWILIO_PHONE_NUMBER=...
    echo.
    echo Then restart backend server.
    pause
    del config.json
    exit /b 1
)
echo ✅ Twilio is enabled
del config.json
echo.

echo [3/5] Current emergency numbers:
curl -s http://localhost:3001/api/voice-call/numbers
echo.
echo.

echo [4/5] Do you want to add a test number? (Y/N)
set /p add_test="Enter Y to add test number, N to skip: "
if /i "%add_test%"=="Y" (
    echo.
    set /p test_phone="Enter phone number (with country code, e.g., +628123456789): "
    set /p test_name="Enter name (e.g., Test User): "
    
    echo.
    echo Adding test number...
    curl -X POST http://localhost:3001/api/voice-call/numbers -H "Content-Type: application/json" -d "{\"phoneNumber\": \"!test_phone!\", \"name\": \"!test_name!\"}"
    echo.
    echo.
)

echo [5/5] Do you want to make a TEST CALL? (Y/N)
set /p make_call="⚠️  This will call the number! Enter Y to proceed: "
if /i "%make_call%"=="Y" (
    set /p call_phone="Enter phone number to call (with +): "
    
    echo.
    echo 📞 Making test call to !call_phone!...
    curl -X POST http://localhost:3001/api/voice-call/test -H "Content-Type: application/json" -d "{\"phoneNumber\": \"!call_phone!\"}"
    echo.
    echo.
    echo ✅ Test call initiated! Check the phone for incoming call.
    echo.
)

echo ================================================================================
echo 🎉 TEST COMPLETE!
echo ================================================================================
echo.
echo Next steps:
echo 1. Open dashboard: http://localhost:5173
echo 2. Go to WhatsApp Integration page
echo 3. Test add number via UI
echo 4. Trigger fire detection to test automatic calls
echo.
pause
