@echo off
title Fire Detection System - Complete Setup
color 0A
echo.
echo ========================================================================
echo    FIRE DETECTION SYSTEM - COMPLETE SETUP
echo ========================================================================
echo.

REM Check if in correct directory
if not exist "proxy-server" (
    echo [ERROR] proxy-server folder not found!
    echo Please run this script from IotCobwengdev root directory
    pause
    exit /b 1
)

if not exist "src" (
    echo [ERROR] src folder not found!
    echo Please run this script from IotCobwengdev root directory
    pause
    exit /b 1
)

echo [1/4] Installing Proxy Server dependencies...
cd proxy-server
call npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install proxy-server dependencies
    pause
    exit /b 1
)
echo [OK] Proxy Server ready
echo.

echo [2/4] Installing Web Dashboard dependencies...
cd ..
call npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install web dashboard dependencies
    pause
    exit /b 1
)
echo [OK] Web Dashboard ready
echo.

echo [3/4] Checking Python environment...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Python not found in PATH
    echo Please install Python 3.11+ and required packages manually:
    echo   pip install opencv-python ultralytics requests paho-mqtt
) else (
    echo [OK] Python detected
)
echo.

echo [4/4] Setup complete!
echo.
echo ========================================================================
echo    READY TO START
echo ========================================================================
echo.
echo Start services in this order:
echo.
echo   1. Proxy Server:    start-proxy.bat
echo   2. Web Dashboard:   start-dashboard.bat
echo   3. Fire Detection:  cd d:\zakaiot ^&^& python fire_detect_esp32_ultimate.py
echo.
echo ========================================================================
echo.
pause
