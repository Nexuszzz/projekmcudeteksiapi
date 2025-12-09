@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 🔧 COMPLETE SYSTEM RESTART - FIX MQTT ISSUE
echo ============================================================
echo.

echo 🎯 ROOT CAUSE IDENTIFIED:
echo    Proxy server NOT publishing to MQTT properly
echo    WhatsApp server NOT receiving fire_photo messages
echo.
echo 📋 SOLUTION:
echo    1. Restart Proxy Server with proper MQTT connection
echo    2. Restart WhatsApp Server with bug fix
echo    3. Test fire detection with monitoring
echo.
echo ============================================================
echo.

pause

echo.
echo 🔄 STEP 1: KILLING OLD PROCESSES...
echo.

echo Killing processes on port 8080 (Proxy Server)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    echo    Killing PID %%a
    taskkill /F /PID %%a >nul 2>&1
)

echo Killing processes on port 3001 (WhatsApp Server)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING') do (
    echo    Killing PID %%a
    taskkill /F /PID %%a >nul 2>&1
)

timeout /t 2 >nul

echo.
echo ✅ Old processes killed
echo.

echo ============================================================
echo 🚀 STEP 2: STARTING PROXY SERVER
echo ============================================================
echo.

cd /d "%~dp0proxy-server"

echo Starting in background...
start "Proxy Server" cmd /k "npm start"

timeout /t 5 >nul

echo.
echo Checking Proxy Server...
curl -s http://localhost:8080/health
echo.

echo.
echo ============================================================
echo 🚀 STEP 3: STARTING WHATSAPP SERVER
echo ============================================================
echo.

cd /d "%~dp0whatsapp-server"

echo Starting in background...
start "WhatsApp Server" cmd /k "npm start"

timeout /t 5 >nul

echo.
echo Checking WhatsApp Server...
curl -s http://localhost:3001/api/whatsapp/status
echo.

echo.
echo ============================================================
echo ✅ SYSTEM RESTART COMPLETE
echo ============================================================
echo.
echo 📋 NEXT STEPS:
echo.
echo 1. Check Proxy Server window for:
echo    ✅ "Connected to MQTT broker"
echo    ✅ "Subscribed to: lab/zaks/#"
echo.
echo 2. Check WhatsApp Server window for:
echo    ✅ "WhatsApp Connected Successfully!"
echo    ✅ "Subscribed to topics: lab/zaks/fire_photo"
echo.
echo 3. Run fire detection:
echo    cd d:\zakaiot
echo    python fire_detect_esp32_ultimate.py
echo.
echo 4. Test with fire and monitor BOTH server windows
echo.
echo 5. Proxy Server should show:
echo    🔥 Fire detection logged: fire_xxx
echo    ✅ Fire photo published to MQTT topic: lab/zaks/fire_photo
echo.
echo 6. WhatsApp Server should show:
echo    📸 Handling fire detection with photo...
echo    ✅ Found photo at...
echo    ✅ Fire photo alert sent to...
echo.
echo ============================================================
echo.

pause
