@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 📱 CONNECT WHATSAPP - QUICK GUIDE
echo ============================================================
echo.

echo Current Status:
curl -s http://localhost:3001/api/whatsapp/status | findstr "connected"
echo.

echo ============================================================
echo 🔧 HOW TO CONNECT WHATSAPP
echo ============================================================
echo.

echo OPTION 1: SCAN QR CODE (RECOMMENDED)
echo =====================================
echo.
echo 1. Open dashboard in browser:
echo    http://localhost:5173
echo.
echo 2. Click "WhatsApp Settings" in sidebar
echo.
echo 3. Click "Generate QR Code" button
echo.
echo 4. Scan QR code with your phone:
echo    - Open WhatsApp on your phone
echo    - Go to Settings ^> Linked Devices
echo    - Click "Link a Device"
echo    - Scan the QR code shown on screen
echo.
echo 5. Wait for connection (~5 seconds)
echo.
echo ============================================================
echo.
echo OPTION 2: PAIRING CODE
echo =====================================
echo.
echo 1. Open dashboard: http://localhost:5173
echo.
echo 2. Enter your phone number (format: 6281225995024)
echo.
echo 3. Click "Generate Pairing Code"
echo.
echo 4. Enter 8-digit code in WhatsApp:
echo    - Open WhatsApp ^> Settings ^> Linked Devices
echo    - Click "Link a Device"
echo    - Choose "Link with phone number"
echo    - Enter the 8-digit code
echo.
echo ============================================================
echo.

echo 🌐 Opening dashboard in browser...
timeout /t 2 >nul
start http://localhost:5173

echo.
echo ⏳ Waiting for you to scan QR code...
echo    (This window will auto-check connection every 5 seconds)
echo.

:check_loop
timeout /t 5 >nul

curl -s http://localhost:3001/api/whatsapp/status > %TEMP%\wa_status.json 2>nul
findstr /C:"\"connected\":true" %TEMP%\wa_status.json >nul 2>&1

if %errorlevel%==0 (
    echo.
    echo ============================================================
    echo ✅ WHATSAPP CONNECTED SUCCESSFULLY!
    echo ============================================================
    echo.
    
    curl -s http://localhost:3001/api/whatsapp/status
    
    echo.
    echo ============================================================
    echo 🎉 READY TO TEST FIRE DETECTION!
    echo ============================================================
    echo.
    echo Next steps:
    echo 1. Open NEW terminal window
    echo 2. Run: cd d:\zakaiot
    echo 3. Run: python fire_detect_esp32_ultimate.py
    echo 4. Test with fire (lighter/candle)
    echo.
    echo 📋 MONITOR THESE WINDOWS:
    echo.
    echo Window 1: Proxy Server
    echo   - Watch for: "Fire photo published to MQTT"
    echo.
    echo Window 2: WhatsApp Server
    echo   - Watch for: "📸 Handling fire detection with photo..."
    echo   - Watch for: "✅ Fire photo alert sent to..."
    echo.
    echo Window 3: Python Fire Detection
    echo   - Watch for: "📱 SENDING FIRE DETECTION TO WHATSAPP..."
    echo   - Watch for: "✅ WhatsApp: Photo sent successfully!"
    echo.
    echo Window 4: Your WhatsApp Phone
    echo   - Should receive: MESSAGE WITH PHOTO! 📸
    echo.
    echo ============================================================
    echo.
    goto end
)

echo Still waiting... (Status: disconnected)
echo Press Ctrl+C to cancel, or wait for connection...
goto check_loop

:end
pause
