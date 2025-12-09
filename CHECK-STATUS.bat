@echo off
echo ================================================================================
echo 🔍 DIAGNOSTIC: Emergency Voice Call Feature Status
echo ================================================================================
echo.

echo [1] Checking Backend Server (port 3001)...
netstat -ano | findstr ":3001" >nul
if %errorlevel% neq 0 (
    echo ❌ Backend server NOT running!
    echo.
    echo SOLUTION: Start backend server
    echo   cd whatsapp-server
    echo   npm start
    echo.
    goto :end
) else (
    echo ✅ Backend server is running
)
echo.

echo [2] Checking Twilio Configuration...
curl -s http://localhost:3001/api/voice-call/config
echo.
echo.

echo [3] Checking Emergency Numbers...
curl -s http://localhost:3001/api/voice-call/numbers
echo.
echo.

echo [4] Testing Add Number API (dry run)...
echo This will NOT actually add a number, just test the endpoint.
curl -s -X POST http://localhost:3001/api/voice-call/numbers ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\": \"+62811111111\", \"name\": \"Test\"}"
echo.
echo.

echo ================================================================================
echo 📋 ANALYSIS:
echo ================================================================================
echo.
echo Look at the responses above:
echo.
echo ✅ If config shows "enabled": true → Twilio is configured correctly
echo ❌ If config shows "enabled": false → Need to restart backend with .env credentials
echo.
echo ✅ If POST returns "success": true → API works, frontend issue
echo ❌ If POST returns error → Backend issue
echo.
echo Common issues:
echo 1. Backend not restarted after adding .env credentials
echo 2. CORS blocking frontend requests
echo 3. Frontend button disabled (check browser console F12)
echo.

:end
pause
