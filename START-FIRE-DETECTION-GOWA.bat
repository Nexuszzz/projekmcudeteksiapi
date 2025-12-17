@echo off
REM ============================================================
REM  Fire Detection System - Complete Server Launcher
REM  Using Go-WhatsApp (GOWA) API
REM ============================================================
REM
REM  This script starts all necessary services:
REM  1. Go-WhatsApp Server (port 3000)
REM  2. Proxy Server (port 8080)
REM  3. Frontend Dev Server (port 5173) - optional
REM
REM ============================================================

echo.
echo ============================================================
echo   Fire Detection System - Complete Server Launcher
echo   Using Go-WhatsApp (GOWA) REST API
echo ============================================================
echo.

REM Set working directory
cd /d "%~dp0"

echo [1/3] Starting Go-WhatsApp (GOWA) Server on port 3000...
start "GOWA Server" cmd /c "cd go-whatsapp-web-multidevice\src && (if exist whatsapp.exe (whatsapp.exe rest --port 3000 --debug) else (go run . rest --port 3000 --debug)) & pause"

REM Wait for GOWA to start
timeout /t 5 /nobreak >nul

echo [2/3] Starting Proxy Server on port 8080...
start "Proxy Server" cmd /c "cd proxy-server && npm start & pause"

REM Wait for proxy to start
timeout /t 3 /nobreak >nul

echo [3/3] Starting Frontend Dev Server...
start "Frontend" cmd /c "npm run dev & pause"

echo.
echo ============================================================
echo   All services starting...
echo ============================================================
echo.
echo   Services:
echo   - GOWA API:    http://localhost:3000
echo   - Proxy:       http://localhost:8080
echo   - Frontend:    http://localhost:5173
echo.
echo   Dashboard:     http://localhost:5173
echo   GOWA UI:       http://localhost:3000
echo.
echo   Press any key to open dashboard in browser...
pause >nul

start "" "http://localhost:5173"
