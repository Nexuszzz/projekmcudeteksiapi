@echo off
cls
color 0B
title Fire Detection - Separated Services (RECOMMENDED!)

echo.
echo ================================================================================
echo            FIRE DETECTION SYSTEM - SEPARATED ARCHITECTURE
echo ================================================================================
echo.
echo This script starts ALL services with SEPARATED architecture:
echo.
echo   Port 8080: Proxy Server (Backend + MQTT)
echo   Port 3001: WhatsApp Server (Baileys messaging ONLY)
echo   Port 3002: Voice Call Server (Twilio calls ONLY)  [NEW!]
echo   Port 5173: Dashboard (Frontend)
echo.
echo Benefits:
echo   * No port conflicts
echo   * Clear separation (WhatsApp vs Voice Call)
echo   * Easier debugging (separate logs)
echo   * Independent restart
echo.
echo ================================================================================
echo.

timeout /t 2 >nul

call "%~dp0START-SEPARATED-SERVICES.bat"
