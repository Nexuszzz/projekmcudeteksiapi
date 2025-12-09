@echo off
chcp 65001 >nul
echo.
echo ============================================================
echo 🔄 RESTARTING WHATSAPP SERVER WITH PHOTO FIX
echo ============================================================
echo.

cd /d "%~dp0whatsapp-server"

echo 📁 Current directory: %CD%
echo.

echo ⚠️  CLOSING OLD WHATSAPP SERVER...
echo    Press Ctrl+C in the WhatsApp server window if running
timeout /t 3 >nul
echo.

echo 🚀 STARTING WHATSAPP SERVER...
echo.
echo ============================================================
echo 📋 WHAT TO LOOK FOR:
echo ============================================================
echo ✅ "WhatsApp Server running on http://localhost:3001"
echo ✅ "MQTT Connected"
echo ✅ "Subscribed to topics: lab/zaks/fire_photo"
echo.
echo When fire detected, you should see:
echo    📸 Handling fire detection with photo...
echo    ✅ Found photo at [fullPath/relativePath/HTTP]
echo    📤 Sending photo to [recipient]...
echo    ✅ Fire photo alert sent to [recipient]
echo.
echo ============================================================
echo.

npm start

pause
