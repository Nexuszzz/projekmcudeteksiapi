@echo off
title Fire Detection - All Services
color 0E

echo.
echo ========================================================================
echo    FIRE DETECTION SYSTEM - STARTING ALL SERVICES
echo ========================================================================
echo.

REM Open Proxy Server in new window
echo [1/3] Starting Proxy Server (Backend + MQTT)...
start "Fire Detection - Proxy Server" cmd /k "cd proxy-server && npm start"
timeout /t 3 /nobreak >nul
echo [OK] Proxy Server started on http://localhost:8080
echo.

REM Open Web Dashboard in new window
echo [2/3] Starting Web Dashboard (Frontend)...
start "Fire Detection - Web Dashboard" cmd /k "npm run dev"
timeout /t 3 /nobreak >nul
echo [OK] Web Dashboard starting on http://localhost:5173
echo.

REM Instructions for Python
echo [3/3] Python Fire Detection Script
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
echo   [Proxy Server]  http://localhost:8080/health
echo   [Web Dashboard] http://localhost:5173
echo   [Fire Gallery]  http://localhost:5173/#/ (Dashboard tab)
echo   [Live Stream]   http://localhost:5173/#/live-stream
echo.
echo To stop all services: Close all terminal windows or press Ctrl+C
echo.
echo ========================================================================
echo.
pause
