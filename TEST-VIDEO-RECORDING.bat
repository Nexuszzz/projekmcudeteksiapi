@echo off
title ESP32-CAM Video Recording Test
color 0E

echo.
echo ================================================================================
echo    ESP32-CAM VIDEO RECORDING TEST
echo ================================================================================
echo.
echo This script tests the video recording feature end-to-end.
echo.
echo Prerequisites:
echo   [1] All services running (START-SEPARATED-SERVICES.bat)
echo   [2] ESP32-CAM connected and streaming
echo   [3] FFmpeg installed (check: ffmpeg -version)
echo.
echo ================================================================================
echo.

REM Change to script directory
cd /d "%~dp0"

echo [1/5] Testing API Endpoint...
curl -s http://localhost:8080/api/video/status >nul 2>&1
if errorlevel 1 (
    echo    [FAIL] Proxy server not running on port 8080
    echo.
    echo    Solution: Run START-SEPARATED-SERVICES.bat first
    echo.
    pause
    exit /b 1
) else (
    echo    [OK] Proxy server is running
)
echo.

echo [2/5] Checking FFmpeg installation...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo    [FAIL] FFmpeg not found in PATH
    echo.
    echo    Solution:
    echo      1. Download: https://ffmpeg.org/download.html
    echo      2. Extract to C:\ffmpeg\
    echo      3. Add to PATH: C:\ffmpeg\bin
    echo.
    pause
    exit /b 1
) else (
    echo    [OK] FFmpeg is installed
)
echo.

echo [3/5] Checking ESP32-CAM IP...
set /p ESP32_IP="Enter ESP32-CAM IP (default: 10.148.218.219): "
if "%ESP32_IP%"=="" set ESP32_IP=10.148.218.219

echo    Testing: http://%ESP32_IP%:81/stream
curl -s --max-time 5 "http://%ESP32_IP%:81/stream" >nul 2>&1
if errorlevel 1 (
    echo    [FAIL] Cannot connect to ESP32-CAM
    echo.
    echo    Troubleshooting:
    echo      - Check ESP32-CAM is powered on
    echo      - Verify IP address is correct
    echo      - Test in browser: http://%ESP32_IP%:81/stream
    echo.
    pause
    exit /b 1
) else (
    echo    [OK] ESP32-CAM is accessible
)
echo.

echo [4/5] Testing API Recording Start...
echo    Starting 10-second test recording...
curl -X POST "http://localhost:8080/api/video/start-recording" ^
     -H "Content-Type: application/json" ^
     -d "{\"cameraIp\":\"%ESP32_IP%\",\"duration\":10,\"quality\":\"medium\"}" ^
     -s -o test_response.json

findstr /C:"success" test_response.json >nul
if errorlevel 1 (
    echo    [FAIL] Recording start failed
    type test_response.json
    del test_response.json
    pause
    exit /b 1
) else (
    echo    [OK] Recording started successfully
)
del test_response.json
echo.

echo [5/5] Waiting for recording to complete (15 seconds)...
timeout /t 15 /nobreak >nul
echo    [OK] Recording should be complete
echo.

echo ================================================================================
echo Testing Complete!
echo ================================================================================
echo.
echo Next steps:
echo   1. Open dashboard: http://localhost:5173/live-stream
echo   2. Click "Recordings" tab
echo   3. You should see the 10-second test video
echo   4. Click to play and verify quality
echo.
echo If video appears and plays correctly: SUCCESS! Feature working.
echo.
pause
