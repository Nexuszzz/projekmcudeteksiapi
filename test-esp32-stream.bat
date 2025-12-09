@echo off
echo ========================================
echo ESP32-CAM LIVE STREAM - QUICK TEST
echo ========================================
echo.

echo [1/4] Testing ESP32-CAM connectivity...
ping -n 1 10.148.218.219 > nul
if %errorlevel% == 0 (
    echo    [OK] ESP32-CAM reachable at 10.148.218.219
) else (
    echo    [FAIL] Cannot reach ESP32-CAM - check power and WiFi
    pause
    exit /b 1
)
echo.

echo [2/4] Testing stream URL in default browser...
echo    Opening: http://10.148.218.219:81/stream
start http://10.148.218.219:81/stream
timeout /t 3 > nul
echo    [OK] Browser opened - verify stream appears
echo.

echo [3/4] Starting dashboard...
echo    Opening: http://localhost:5173/#/live-stream
start http://localhost:5173/#/live-stream
timeout /t 2 > nul
echo    [OK] Dashboard opened
echo.

echo [4/4] Instructions:
echo ========================================
echo 1. In browser with ESP32 stream:
echo    - Verify stream is playing
echo    - If yes: ESP32-CAM is working [OK]
echo    - If no: Check ESP32-CAM setup
echo.
echo 2. In dashboard page:
echo    - Press F12 to open Developer Console
echo    - Click green "Start" button
echo    - Watch console for logs:
echo.
echo    Expected logs:
echo    [OK] Starting ESP32-CAM stream: http://10.148.218.219:81/stream
echo    [OK] streamRef exists: true
echo    [OK] Config enabled: true
echo    [OK] Stream URL set to img.src
echo    [OK] Stream frame loaded successfully
echo.
echo    If errors appear:
echo    - Check Network tab for failed requests
echo    - Look for CORS errors in console
echo    - Verify URL matches ESP32-CAM IP
echo.
echo 3. If stream works in browser but NOT dashboard:
echo    - Screenshot the console errors
echo    - Check Network tab status codes
echo    - Report findings
echo.
echo ========================================
echo.

echo Press any key to view detailed troubleshooting guide...
pause > nul
notepad ESP32-CAM-STREAM-DEBUG.md

echo.
echo Test complete!
pause
