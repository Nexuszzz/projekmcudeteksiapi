@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 🧪 WHATSAPP PHOTO SENDING - COMPLETE TEST
echo ============================================================
echo.

echo 📋 PRE-TEST CHECKLIST:
echo.
echo 1. Proxy Server Status...
curl.exe -s http://localhost:8080/health >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ Proxy server running on port 8080
) else (
    echo    ❌ Proxy server NOT running!
    echo    Run: START_SERVERS.bat
    pause
    exit /b 1
)

echo.
echo 2. WhatsApp Server Status...
curl.exe -s http://localhost:3001/api/whatsapp/status >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ WhatsApp server running on port 3001
) else (
    echo    ❌ WhatsApp server NOT running!
    echo    Run: RESTART_WHATSAPP_SERVER.bat
    pause
    exit /b 1
)

echo.
echo 3. WhatsApp Connection Status...
curl.exe -s http://localhost:3001/api/whatsapp/status -o "%TEMP%\wa_status.json" 2>nul
findstr /C:"connected" "%TEMP%\wa_status.json" >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ WhatsApp authenticated and connected
) else (
    echo    ❌ WhatsApp NOT connected!
    echo    Scan QR code or use pairing code
    pause
    exit /b 1
)

echo.
echo 4. Recipients Configuration...
curl.exe -s http://localhost:3001/api/whatsapp/recipients -o "%TEMP%\recipients.json" 2>nul
findstr /C:"phoneNumber" "%TEMP%\recipients.json" >nul 2>&1
if %errorlevel%==0 (
    for /f %%i in ('findstr /C:"phoneNumber" "%TEMP%\recipients.json" ^| find /c /v ""') do set recipient_count=%%i
    echo    ✅ Recipients configured: %recipient_count% numbers
) else (
    echo    ❌ No recipients configured!
    echo    Run: ADD_RECIPIENT.bat
    pause
    exit /b 1
)

echo.
echo 5. Fire Detection Helper...
if exist "d:\zakaiot\fire_whatsapp_helper.py" (
    echo    ✅ fire_whatsapp_helper.py found
) else (
    echo    ❌ fire_whatsapp_helper.py NOT found!
    pause
    exit /b 1
)

echo.
echo 6. Upload Directory...
if exist "proxy-server\uploads\fire-detections\" (
    echo    ✅ Upload directory exists
    dir /b /a-d "proxy-server\uploads\fire-detections\*.jpg" 2>nul | find /c /v "" >"%TEMP%\file_count.txt"
    set /p file_count=<"%TEMP%\file_count.txt"
    echo    📁 Current photos: %file_count% files
) else (
    echo    ⚠️  Upload directory will be created automatically
)

echo.
echo ============================================================
echo ✅ ALL CHECKS PASSED - SYSTEM READY FOR TESTING!
echo ============================================================
echo.
echo 📝 TESTING INSTRUCTIONS:
echo.
echo 1. Run fire detection script:
echo    cd d:\zakaiot
echo    python fire_detect_esp32_ultimate.py
echo.
echo 2. Enter your ESP32-CAM IP address when prompted
echo.
echo 3. Show fire source (lighter/candle) to camera
echo.
echo 4. Wait for detection (5-10 seconds):
echo    Console: "📱 SENDING FIRE DETECTION TO WHATSAPP..."
echo    Console: "✅ WhatsApp: Photo sent successfully!"
echo.
echo 5. Check WhatsApp Server console window for:
echo    📸 Handling fire detection with photo...
echo    ✅ Found photo at [path strategy]
echo    📤 Sending photo to [recipient]...
echo    ✅ Fire photo alert sent to [recipient]
echo.
echo 6. Check your WhatsApp phone:
echo    📱 Should receive message WITH PHOTO
echo    🖼️  Photo shows bounding box around fire
echo    📄 Caption includes YOLO + Gemini scores
echo.
echo ============================================================
echo.
echo 🔍 MONITORING TIPS:
echo.
echo - Watch WhatsApp server console for path resolution logs
echo - Check which strategy found the photo (fullPath/relative/HTTP)
echo - Verify photo size in bytes is logged
echo - Cooldown is 60 seconds between notifications
echo.
echo ============================================================
echo.
echo 📊 POST-TEST VERIFICATION:
echo.
echo After testing, verify:
echo [ ] WhatsApp received message WITH PHOTO (not just text)
echo [ ] Photo shows red bounding box around fire
echo [ ] Photo has timestamp overlay
echo [ ] Caption shows YOLO and Gemini scores
echo [ ] Web dashboard also received the detection
echo [ ] WhatsApp server console shows successful send
echo.
echo ============================================================
echo.

choice /C YN /M "Ready to start fire detection test"
if errorlevel 2 exit /b

echo.
echo 🚀 Starting fire detection script...
echo.

cd /d d:\zakaiot
python fire_detect_esp32_ultimate.py

pause
