@echo off
title Fire Detection System - ALL SERVICES (with WhatsApp V2)
color 0B

cls
echo.
echo ================================================================================
echo      FIRE DETECTION SYSTEM - ALL SERVICES (WHATSAPP V2 INCLUDED!)
echo ================================================================================
echo.
echo Starting ALL services with COMPLETE architecture:
echo.
echo   [1/6] Proxy Server (Backend + MQTT)            - Port 8080
echo   [2/6] WhatsApp Server (Baileys)                - Port 3001  (Legacy)
echo   [3/6] WhatsApp V2 Server (Go Multi-Device)     - Port 3000  (NEW!)
echo   [4/6] Voice Call Server (Twilio)               - Port 3002  (Voice Calls)
echo   [5/6] Dashboard Frontend (Web UI)              - Port 5173
echo   [6/6] Python Fire Detection Script             - Manual start
echo.
echo Benefits:
echo   * TWO WhatsApp servers: Baileys (3001) + Go Multi-Device (3000)
echo   * Choose which one to use from dashboard
echo   * More stable with Go-based WhatsApp V2
echo   * All services independent and debuggable
echo.
echo ================================================================================
echo.

REM Change to script directory
cd /d "%~dp0"

REM Kill old processes
echo Cleaning up old processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING 2^>nul') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING 2^>nul') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING 2^>nul') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002 ^| findstr LISTENING 2^>nul') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING 2^>nul') do taskkill /F /PID %%a >nul 2>&1
timeout /t 2 >nul
echo    [OK] All ports ready
echo.

REM Check if required directories exist
echo Checking prerequisites...
if not exist "proxy-server" (
    echo    [WARNING] proxy-server directory not found - will skip
)
if not exist "whatsapp-server" (
    echo    [WARNING] whatsapp-server directory not found - will skip
)
if not exist "voice-call-server" (
    echo    [WARNING] voice-call-server directory not found - will skip
)
if not exist "D:\go-whatsapp-web-multidevice\src\server.exe" (
    echo    [WARNING] WhatsApp V2 server not found - will skip
)
echo.

echo ================================================================================
echo [1/6] Starting Proxy Server...
echo ================================================================================
if exist "proxy-server" (
    cd proxy-server
    start "Proxy Server (8080)" cmd /k "title Proxy Server & npm start"
    cd ..
    timeout /t 3 /nobreak >nul
    echo    [OK] Proxy Server: http://localhost:8080
) else (
    echo    [SKIP] Proxy server directory not found
)
echo.

echo ================================================================================
echo [2/6] Starting WhatsApp Server (Baileys - Legacy)...
) else (
    echo    [SKIP] Voice call server directory not found
)
echo.

echo ================================================================================
echo [5/6] Starting Dashboard Frontend...
echo ================================================================================
if exist "package.json" (
    start "Dashboard (5173)" cmd /k "title Dashboard Frontend & npm run dev"
    timeout /t 5 /nobreak >nul
    echo    [OK] Dashboard: http://localhost:5173
) else (
    echo    [ERROR] package.json not found! Are you in the right directory?
    echo           This script should be run from the project root directory.
)
echo.

echo ================================================================================
echo [6/6] Python Fire Detection Script
echo ================================================================================
echo.
echo    [MANUAL STEP] Open NEW terminal and run:
echo.
echo       cd d:\zakaiot
echo       python fire_detect_esp32_ultimate.py
echo.

timeout /t 3 >nul

echo ================================================================================
echo [SUCCESS] SERVICE STARTUP COMPLETED!
echo ================================================================================
echo.
echo Service Architecture:
echo ================================================================================
echo.
echo    Port 8080:  Proxy Server (Backend + MQTT)
echo    Port 3000:  WhatsApp V2 Server (Go Multi-Device) [NEW!]
echo    Port 3001:  WhatsApp Server (Baileys) [Legacy]
echo    Port 3002:  Voice Call Server (Twilio)
echo    Port 5173:  Dashboard (Frontend)
echo.
echo ================================================================================
echo Verifying Services (please wait...)
echo ================================================================================
timeout /t 10 /nobreak >nul
echo.

echo [Checking Proxy Server...]
curl -s http://localhost:8080/health 2>nul | findstr "OK" >nul
if %errorlevel% equ 0 (
    echo    [OK] Proxy Server is running
) else (
    echo    [INFO] Proxy Server - check manually or may not be installed
)

echo.
echo [Checking WhatsApp V2 Server...]
curl -s http://localhost:3000/app/devices 2>nul | findstr "SUCCESS" >nul
if %errorlevel% equ 0 (
    echo    [OK] WhatsApp V2 Server is running - Ready for QR code generation!
) else (
    echo    [INFO] WhatsApp V2 Server - check manually or not installed
)

echo.
echo [Checking WhatsApp Server (Baileys)...]
curl -s http://localhost:3001/api/whatsapp/status 2>nul | findstr "status" >nul
if %errorlevel% equ 0 (
    echo    [OK] WhatsApp Server ^(Baileys^) is running
) else (
    echo    [INFO] WhatsApp Server ^(Baileys^) - check manually or not installed
)

echo.
echo [Checking Voice Call Server...]
curl -s http://localhost:3002/health 2>nul | findstr "voice-call-server" >nul
if %errorlevel% equ 0 (
    echo    [OK] Voice Call Server is running
) else (
    echo    [INFO] Voice Call Server - check manually or not installed
)

echo.
echo [Checking Dashboard...]
curl -s http://localhost:5173 2>nul >nul
if %errorlevel% equ 0 (
    echo    [OK] Dashboard is running
) else (
    echo    [INFO] Dashboard - starting up, check in a few seconds
)

echo.
echo ================================================================================
echo NEXT STEPS:
echo ================================================================================
echo.
echo 1. Open Dashboard: http://localhost:5173
echo 2. Go to WhatsApp V2 tab (NEW!)
echo 3. Click "Generate QR Code"
echo 4. Scan QR with your phone
echo 5. Start sending messages via WhatsApp V2!
echo.
echo Alternative: Use legacy WhatsApp (Baileys) on port 3001
echo.
echo ================================================================================
echo WHATSAPP V2 vs WHATSAPP (BAILEYS):
echo ================================================================================
echo.
echo WhatsApp V2 (Port 3000 - NEW!):
echo   * Built with Go (more stable)
echo   * Official WhatsApp Multi-Device protocol
echo   * Better QR code handling
echo   * Comprehensive REST API
echo   * Recommended for production
echo.
echo WhatsApp Baileys (Port 3001 - Legacy):
echo   * Built with Node.js
echo   * Community-maintained
echo   * Good for development
echo.
echo You can use BOTH simultaneously!
echo.
echo ================================================================================
echo IMPORTANT NOTES:
echo ================================================================================
echo.
echo * DO NOT CLOSE any terminal windows that opened
echo * Each service runs in its own window for easier debugging
echo * WhatsApp V2 window: "WhatsApp V2 Server - Go Multi-Device"
echo * You can minimize windows but don't close them
echo * Check each window for logs and error messages
echo * WhatsApp V2 route: http://localhost:5173/whatsappv2
echo.
echo ================================================================================
echo.
pause