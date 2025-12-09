@echo off
title Fire Detection - All Services (FIXED)
color 0E

echo.
echo ========================================================================
echo    FIRE DETECTION SYSTEM - STARTING ALL SERVICES (FIXED VERSION)
echo ========================================================================
echo.
echo This version includes WhatsApp Server + Voice Call Feature!
echo.

REM Change to script directory
cd /d "%~dp0"

REM Open Proxy Server in new window
echo [1/4] Starting Proxy Server (Backend + MQTT)...
start "Fire Detection - Proxy Server" cmd /k "cd proxy-server && npm start"
timeout /t 3 /nobreak >nul
echo [OK] Proxy Server started on http://localhost:8080
echo.

REM Open WhatsApp Server (MISSING IN ORIGINAL!)
echo [2/4] Starting WhatsApp Server (Alerts + Voice Calls)...
start "Fire Detection - WhatsApp Server" cmd /k "cd whatsapp-server && npm start"
timeout /t 3 /nobreak >nul
echo [OK] WhatsApp Server started on http://localhost:3001
echo       - WhatsApp notifications: ENABLED
echo       - Emergency voice calls: Check if Twilio configured
echo.

REM Open Web Dashboard in new window
echo [3/4] Starting Web Dashboard (Frontend)...
start "Fire Detection - Web Dashboard" cmd /k "npm run dev"
timeout /t 3 /nobreak >nul
echo [OK] Web Dashboard starting on http://localhost:5173
echo.

REM Instructions for Python
echo [4/4] Python Fire Detection Script
echo.
echo *** MANUAL STEP REQUIRED ***
echo.
echo Open a new terminal and run:
echo   cd d:\zakaiot
echo   python fire_detect_esp32_ultimate.py
echo.
echo Then enter your ESP32-CAM IP address when prompted
echo Example: 10.148.218.219
echo.


echo ========================================================================
echo    ALL SERVICES STARTED
echo ========================================================================
echo.
echo Check if services are running:
echo.
echo   [Proxy Server]     http://localhost:8080/health
echo   [WhatsApp Server]  http://localhost:3001/api/whatsapp/status
echo   [Voice Call API]   http://localhost:3001/api/voice-call/config
echo   [Web Dashboard]    http://localhost:5173
echo   [Fire Gallery]     http://localhost:5173/#/ (Dashboard tab)
echo   [Live Stream]      http://localhost:5173/#/live-stream
echo   [WhatsApp Config]  http://localhost:5173/#/whatsapp
echo.
echo NEW FEATURES:
echo   [Voice Call Mgmt]  Go to WhatsApp Integration -> Emergency Voice Calls
echo.
echo To stop all services: Close all terminal windows or press Ctrl+C
echo.
echo ========================================================================
echo.
pause
