@echo off
chcp 65001 >nul
title Fire Detection System - Complete Startup
color 0B

cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                              ║
echo ║          🔥 FIRE DETECTION SYSTEM - COMPLETE STARTUP v2.0 🔥                ║
echo ║                                                                              ║
echo ║              Dengan Emergency Voice Call Feature (Twilio)                   ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Starting ALL required services:
echo.
echo   [1/4] Proxy Server (Backend + MQTT)     - Port 8080
echo   [2/4] WhatsApp Server (Alerts + Calls)  - Port 3001  ⭐ NEW!
echo   [3/4] Dashboard Frontend (Web UI)       - Port 5173
echo   [4/4] Python Fire Detection Script      - Manual start
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo.

REM Change to script directory
cd /d "%~dp0"

REM Kill old processes if any
echo 🔄 Checking for existing processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING 2^>nul') do (
    echo    → Stopping old Proxy Server (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING 2^>nul') do (
    echo    → Stopping old WhatsApp Server (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING 2^>nul') do (
    echo    → Stopping old Dashboard (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 2 >nul
echo    ✅ Ready to start fresh
echo.

echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo [1/4] Starting Proxy Server...
echo ═══════════════════════════════════════════════════════════════════════════════
cd proxy-server
start "🌐 Proxy Server (8080)" cmd /k "title Proxy Server ^& echo ╔══════════════════════════════════════════════════════════╗ ^& echo ║          PROXY SERVER - Backend + MQTT (Port 8080)      ║ ^& echo ╚══════════════════════════════════════════════════════════╝ ^& npm start"
cd ..
timeout /t 3 /nobreak >nul
echo    ✅ Proxy Server starting at http://localhost:8080
echo.

echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo [2/4] Starting WhatsApp Server (with Voice Call Feature)...
echo ═══════════════════════════════════════════════════════════════════════════════
cd whatsapp-server

REM Check if Twilio configured
findstr "TWILIO_ACCOUNT_SID" .env >nul 2>&1
if %errorlevel% neq 0 (
    echo    ⚠️  WARNING: Twilio credentials not found in .env
    echo    Voice Call feature will be DISABLED
    echo.
    echo    To enable Voice Calls:
    echo      1. Add Twilio credentials to whatsapp-server\.env
    echo      2. Restart this server
    echo.
) else (
    echo    ✅ Twilio credentials detected - Voice Call ENABLED
)

start "📱 WhatsApp Server (3001)" cmd /k "title WhatsApp ^& Twilio Server ^& echo ╔══════════════════════════════════════════════════════════╗ ^& echo ║      WHATSAPP + VOICE CALL SERVER (Port 3001)           ║ ^& echo ║      - WhatsApp Notifications (Baileys)                 ║ ^& echo ║      - Emergency Voice Calls (Twilio)                   ║ ^& echo ╚══════════════════════════════════════════════════════════╝ ^& npm start"
cd ..
timeout /t 3 /nobreak >nul
echo    ✅ WhatsApp Server starting at http://localhost:3001
echo.

echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo [3/4] Starting Dashboard Frontend...
echo ═══════════════════════════════════════════════════════════════════════════════
start "🖥️ Dashboard (5173)" cmd /k "title Dashboard Frontend ^& echo ╔══════════════════════════════════════════════════════════╗ ^& echo ║           DASHBOARD FRONTEND (Port 5173)                 ║ ^& echo ╚══════════════════════════════════════════════════════════╝ ^& npm run dev"
timeout /t 5 /nobreak >nul
echo    ✅ Dashboard starting at http://localhost:5173
echo.

echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo [4/4] Python Fire Detection Script
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo    ⚠️  MANUAL STEP: Open NEW terminal and run:
echo.
echo       cd d:\zakaiot
echo       python fire_detect_esp32_ultimate.py
echo.
echo    Then enter your ESP32-CAM IP address (e.g., 10.148.218.219)
echo.

timeout /t 3 >nul

echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo ✅ ALL SERVICES STARTED SUCCESSFULLY!
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo 📡 Service URLs:
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo    Proxy Server:     http://localhost:8080/health
echo    WhatsApp Server:  http://localhost:3001/api/whatsapp/status
echo    Voice Call API:   http://localhost:3001/api/voice-call/config
echo    Dashboard:        http://localhost:5173
echo.

REM Verify services
echo ═══════════════════════════════════════════════════════════════════════════════
echo 🔍 Verifying Services (wait 8 seconds)...
echo ═══════════════════════════════════════════════════════════════════════════════
timeout /t 8 /nobreak >nul
echo.

echo [Proxy Server Health Check]
curl -s http://localhost:8080/health 2>nul
if %errorlevel% equ 0 (
    echo    ✅ Proxy Server: RUNNING
) else (
    echo    ❌ Proxy Server: NOT RESPONDING
)
echo.

echo [WhatsApp Server Status]
curl -s http://localhost:3001/api/whatsapp/status 2>nul | findstr "status" >nul
if %errorlevel% equ 0 (
    echo    ✅ WhatsApp Server: RUNNING
) else (
    echo    ❌ WhatsApp Server: NOT RESPONDING
)
echo.

echo [Voice Call Status]
curl -s http://localhost:3001/api/voice-call/config 2>nul | findstr "enabled" >nul
if %errorlevel% equ 0 (
    curl -s http://localhost:3001/api/voice-call/config | findstr "\"enabled\":true" >nul
    if !errorlevel! equ 0 (
        echo    ✅ Voice Call Feature: ENABLED (Twilio configured)
    ) else (
        echo    ⚠️  Voice Call Feature: DISABLED (Twilio not configured)
    )
) else (
    echo    ❌ Voice Call API: NOT RESPONDING
)
echo.

echo ═══════════════════════════════════════════════════════════════════════════════
echo 📋 NEXT STEPS:
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo 1️⃣  Open Dashboard: http://localhost:5173
echo.
echo 2️⃣  Configure WhatsApp (if not connected):
echo       → Go to WhatsApp Settings
echo       → Generate Pairing Code
echo       → Enter code in WhatsApp app
echo.
echo 3️⃣  Add WhatsApp Recipients:
echo       → Go to WhatsApp Integration page
echo       → Add phone numbers for alerts
echo.
echo 4️⃣  Add Emergency Call Numbers (NEW!):
echo       → Scroll to "Emergency Voice Calls" section
echo       → Click "Add Number"
echo       → Enter phone number with country code (e.g., +628123456789)
echo       → Add name (e.g., "Security Team")
echo.
echo 5️⃣  Start Fire Detection:
echo       cd d:\zakaiot
echo       python fire_detect_esp32_ultimate.py
echo.
echo 6️⃣  Test the system with fire detection!
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo 🚨 ALERT FLOW:
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo    Fire Detected → Gemini AI Verification
echo         ↓
echo    ✅ Confirmed Fire
echo         ↓
echo    ┌─────────────────────────┬──────────────────────────────┐
echo    │                         │                              │
echo    ↓                         ↓                              ↓
echo    📱 WhatsApp Message      📞 Emergency Voice Calls      🚨 ESP32 Buzzer
echo    (Photo + Details)        (Twilio - Automatic)          (MQTT Alert)
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo 💡 TIPS:
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo    • Keep ALL terminal windows open (don't close them!)
echo    • Monitor each window for logs and errors
echo    • WhatsApp must be connected for alerts to work
echo    • Voice calls require Twilio credentials in .env
echo    • Press F12 in browser to see debug logs
echo    • Press Ctrl+C in any window to stop that service
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo 📞 Voice Call Feature:
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo    Status: Check http://localhost:3001/api/voice-call/config
echo.
echo    If DISABLED:
echo      1. Edit whatsapp-server\.env
echo      2. Add Twilio credentials:
echo         TWILIO_ACCOUNT_SID=AC...
echo         TWILIO_AUTH_TOKEN=...
echo         TWILIO_PHONE_NUMBER=+1...
echo      3. Restart WhatsApp Server window
echo.
echo    Cooldowns:
echo      • WhatsApp: 60 seconds
echo      • Voice Call: 120 seconds (2 minutes)
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo.
echo Press any key to exit this launcher...
echo (Services will continue running in background windows)
echo.
pause >nul
