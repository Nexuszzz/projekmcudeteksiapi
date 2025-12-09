@echo off
echo ========================================
echo ESP32-CAM STREAM - FINAL TEST
echo ========================================
echo.
echo [FIXES APPLIED]
echo 1. Removed crossOrigin attribute (CORS fix)
echo 2. Added detailed console logging
echo 3. Fixed duplicate 'now' variable declaration
echo 4. Added useCallback dependency
echo.
echo Status: NO COMPILATION ERRORS
echo.
echo ========================================
echo TESTING INSTRUCTIONS
echo ========================================
echo.
echo Step 1: Verify Dashboard is Running
echo ----------------------------------------
echo Check terminal running start-fire-detection-complete.bat
echo Should see: "VITE ready in XXXms"
echo              "Local: http://localhost:5173"
echo.

echo Step 2: Dashboard Page Opened
echo ----------------------------------------
echo Browser should open to: http://localhost:5173/#/live-stream
echo Page title: "ESP32-CAM Live Stream"
echo.
timeout /t 2 > nul

echo Step 3: Open Developer Console
echo ----------------------------------------
echo In browser: Press F12
echo Go to "Console" tab
echo.

echo Step 4: Click GREEN "Start" Button
echo ----------------------------------------
echo Location: Top-right area of stream container
echo Text: "Start" with play icon
echo.

echo Step 5: Watch Console for Logs
echo ----------------------------------------
echo Expected logs (in order):
echo.
echo   [OK] Starting ESP32-CAM stream: http://10.148.218.219:81/stream
echo   [OK] streamRef exists: true
echo   [OK] Config enabled: true
echo   [OK] Stream URL set to img.src
echo   [OK] Stream frame loaded successfully at [TIME]
echo   [OK] Frame count: 1
echo   [OK] Stream URL: http://10.148.218.219:81/stream
echo   [OK] Stream frame loaded successfully at [TIME]
echo   [OK] Frame count: 2
echo   (continues incrementing...)
echo.

echo Step 6: Verify Stream Display
echo ----------------------------------------
echo Check for:
echo   [OK] Video stream visible in black container
echo   [OK] "LIVE" indicator (red dot) in top-right corner
echo   [OK] FPS counter in bottom-left: "15-20 FPS"
echo   [OK] Frame counter in bottom-right: "Frame 1, 2, 3..."
echo   [OK] No "Stream Error" overlay
echo   [OK] Button changed to red "Stop"
echo.

echo ========================================
echo TROUBLESHOOTING
echo ========================================
echo.
echo IF STREAM DOES NOT APPEAR:
echo ----------------------------------------
echo.
echo 1. Check Console for Errors
echo    - Look for red error messages
echo    - Common errors:
echo      * "Failed to load resource" - ESP32-CAM offline
echo      * "CORS policy" - Should NOT appear (we fixed this)
echo      * "Stream error occurred" - Check retry logs
echo.
echo 2. Check Network Tab
echo    - Press F12 - Go to "Network" tab
echo    - Filter: "stream"
echo    - Click "Start" button
echo    - Look for request to: http://10.148.218.219:81/stream
echo    - Status should be: 200 OK
echo    - Type should be: image/jpeg
echo    - If 0 or (failed): ESP32-CAM not accessible
echo.
echo 3. Verify ESP32-CAM Online
echo    - Open new tab: http://10.148.218.219:81/stream
echo    - Stream should appear directly in browser
echo    - If NOT: Check ESP32-CAM power and WiFi
echo.
echo 4. Check Settings
echo    - In dashboard, click Settings (gear icon)
echo    - Verify URL: http://10.148.218.219:81/stream
echo    - Auto Reconnect: ON
echo    - Reconnect Delay: 3000ms
echo    - Click "Test" button to verify URL
echo.
echo ========================================
echo RESULTS TO REPORT
echo ========================================
echo.
echo Please report the following:
echo.
echo [1] Console Logs:
echo     - Screenshot of console showing logs
echo     - Copy ALL log messages
echo.
echo [2] Network Tab:
echo     - Screenshot showing /stream request
echo     - Status code (200, 404, 0, etc)
echo     - Response headers
echo.
echo [3] Stream Status:
echo     - Does stream appear? YES / NO
echo     - Does "LIVE" indicator show? YES / NO
echo     - Does FPS counter update? YES / NO
echo     - Frame count increasing? YES / NO
echo.
echo [4] Errors:
echo     - Any red errors in console?
echo     - Error overlay in stream container?
echo     - Error message text?
echo.
echo ========================================
echo.

echo Opening dashboard now...
start http://localhost:5173/#/live-stream

echo.
echo Press any key when ready to continue testing...
pause > nul

echo.
echo ========================================
echo ADVANCED DEBUG COMMANDS
echo ========================================
echo.
echo Run these in Browser Console (F12) if needed:
echo.
echo // Check if image element exists
echo document.querySelector("img[alt*='ESP32']")
echo.
echo // Check image src
echo document.querySelector("img[alt*='ESP32']")?.src
echo.
echo // Check image loaded
echo document.querySelector("img[alt*='ESP32']")?.complete
echo.
echo // Check image size
echo document.querySelector("img[alt*='ESP32']")?.naturalWidth
echo document.querySelector("img[alt*='ESP32']")?.naturalHeight
echo.
echo // Test fetch to ESP32-CAM
echo fetch('http://10.148.218.219:81/stream', {mode: 'no-cors'})
echo   .then(r =^> console.log('Fetch OK:', r))
echo   .catch(e =^> console.error('Fetch failed:', e))
echo.
echo ========================================
echo.

echo Press any key to exit...
pause > nul
