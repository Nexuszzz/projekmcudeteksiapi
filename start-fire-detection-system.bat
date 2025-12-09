@echo off
echo ================================================================================
echo       🔥 ESP32-CAM FIRE DETECTION SYSTEM - COMPLETE STARTUP 🔥
echo ================================================================================
echo.
echo This will start ALL required services:
echo   1. Proxy Server (port 8080)
echo   2. WhatsApp Server (port 3001) - NEW! 📱
echo   3. Dashboard Frontend (port 5173)
echo.
echo ================================================================================
echo.

REM Change to script directory
cd /d "%~dp0"

echo [1/3] Starting Proxy Server...
cd proxy-server
start "Proxy Server" cmd /k "echo ================================================================================& echo     PROXY SERVER (Port 8080)& echo ================================================================================& npm start"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [2/3] Starting WhatsApp Server...
cd whatsapp-server
start "WhatsApp Server" cmd /k "echo ================================================================================& echo     WHATSAPP SERVER (Port 3001)& echo ================================================================================& npm start"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [3/3] Starting Dashboard Frontend...
start "Dashboard Frontend" cmd /k "echo ================================================================================& echo     DASHBOARD FRONTEND (Port 5173)& echo ================================================================================& npm run dev"
timeout /t 3 /nobreak >nul

echo.
echo ================================================================================
echo ✅ ALL SERVICES STARTED SUCCESSFULLY!
echo ================================================================================
echo.
echo 📡 Proxy Server:      http://localhost:8080
echo 📱 WhatsApp Server:   http://localhost:3001
echo 🖥️  Dashboard:         http://localhost:5173
echo.
echo ================================================================================
echo 📋 NEXT STEPS:
echo ================================================================================
echo.
echo 1. Open Dashboard: http://localhost:5173
echo 2. Go to WhatsApp Settings
echo 3. Generate Pairing Code and connect your WhatsApp
echo 4. Add Recipients (phone numbers)
echo 5. Start Fire Detection:
echo      cd d:\zakaiot
echo      python fire_detect_ultimate.py
echo.
echo ================================================================================
echo 💡 TIPS:
echo ================================================================================
echo.
echo - Keep all 3 terminal windows open
echo - Check WhatsApp connection status in dashboard
echo - When fire detected, photo will auto-send to WhatsApp! 📸
echo - Press Ctrl+C in any window to stop that service
echo.
echo ================================================================================
echo Press any key to exit this launcher window...
echo ================================================================================
pause >nul
