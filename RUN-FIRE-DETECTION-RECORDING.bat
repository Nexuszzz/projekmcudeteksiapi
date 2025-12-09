@echo off
title Fire Detection + Auto Recording + Web Logging
color 0E

echo.
echo ================================================================================
echo    FIRE DETECTION + AUTO VIDEO RECORDING + WEB LOGGING
echo ================================================================================
echo.
echo Features:
echo   [1] Real-time fire detection (YOLO + Gemini AI)
echo   [2] Auto-record video when fire detected (30s clips)
echo   [3] Save to laptop: D:/fire_recordings/
echo   [4] Auto-upload to web server
echo   [5] Real-time logs on dashboard
echo   [6] MQTT alerts to ESP32 DevKit
echo.
echo Prerequisites:
echo   - All services running (START-SEPARATED-SERVICES.bat)
echo   - ESP32-CAM connected and streaming
echo   - YOLO model in D:/zakaiot/
echo.
echo ================================================================================
echo.

REM Change to script directory
cd /d "%~dp0\python_scripts"

echo [1/3] Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    echo    [FAIL] Python not found in PATH
    pause
    exit /b 1
)
echo    [OK] Python available

echo.
echo [2/3] Checking required packages...
python -c "import cv2, ultralytics, requests, websocket, numpy" >nul 2>&1
if errorlevel 1 (
    echo    [FAIL] Missing packages
    echo.
    echo    Installing required packages...
    pip install opencv-python ultralytics requests websocket-client numpy paho-mqtt python-dotenv
)
echo    [OK] All packages available

echo.
echo [3/3] Checking YOLO model...
if exist "D:\zakaiot\fire_yolov8s_ultra_best.pt" (
    echo    [OK] Model found: fire_yolov8s_ultra_best.pt
) else if exist "D:\zakaiot\fire_training\fire_yolov8n_best.pt" (
    echo    [OK] Model found: fire_yolov8n_best.pt
) else (
    echo    [FAIL] YOLO model not found in D:\zakaiot\
    echo.
    echo    Please ensure fire detection model exists:
    echo      - D:\zakaiot\fire_yolov8s_ultra_best.pt
    echo      OR
    echo      - D:\zakaiot\fire_training\fire_yolov8n_best.pt
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================================================
echo Starting Fire Detection System...
echo ================================================================================
echo.
echo Configuration:
echo   ESP32-CAM IP: 10.148.218.219 (edit in .env to change)
echo   Recording Dir: D:/fire_recordings/
echo   Clip Duration: 30 seconds
echo   Web Logs: ws://localhost:8080/ws
echo.
echo Press Ctrl+C to stop
echo.
echo ================================================================================
echo.

REM Run the script
python fire_detect_record_ultimate.py

pause
