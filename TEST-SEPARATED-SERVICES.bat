@echo off
title Testing Separated Services
color 0E

echo.
echo ================================================================================
echo                   TESTING SEPARATED SERVICES
echo ================================================================================
echo.

echo [1/4] Testing Proxy Server (8080)...
curl -s http://localhost:8080/health
if %errorlevel% equ 0 (
    echo    [OK] Proxy Server is running
) else (
    echo    [ERROR] Proxy Server not responding
    echo    Start it first: cd proxy-server ^& npm start
)
echo.

echo [2/4] Testing WhatsApp Server (3001)...
curl -s http://localhost:3001/api/whatsapp/status | findstr "status" >nul
if %errorlevel% equ 0 (
    echo    [OK] WhatsApp Server is running
) else (
    echo    [ERROR] WhatsApp Server not responding
    echo    Start it first: cd whatsapp-server ^& npm start
)
echo.

echo [3/4] Testing Voice Call Server (3002)...
curl -s http://localhost:3002/health | findstr "voice-call-server" >nul
if %errorlevel% equ 0 (
    echo    [OK] Voice Call Server is running
    echo.
    echo    Checking Twilio configuration...
    curl -s http://localhost:3002/api/voice-call/config
    echo.
) else (
    echo    [ERROR] Voice Call Server not responding
    echo    Start it first: cd voice-call-server ^& npm start
)
echo.

echo [4/4] Testing Dashboard (5173)...
curl -s http://localhost:5173 >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] Dashboard is running
) else (
    echo    [ERROR] Dashboard not responding
    echo    Start it first: npm run dev
)
echo.

echo ================================================================================
echo                      TEST SUMMARY
echo ================================================================================
echo.
echo All services tested!
echo.
echo If any service shows ERROR, start it using START-SEPARATED-SERVICES.bat
echo.
echo Next: Open http://localhost:5173 and test voice call feature!
echo.
pause
