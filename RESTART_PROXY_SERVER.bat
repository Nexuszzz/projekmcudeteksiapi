@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 🔄 RESTARTING PROXY SERVER WITH MQTT FIX
echo ============================================================
echo.

cd /d "%~dp0proxy-server"

echo 📁 Current directory: %CD%
echo.

echo 📋 Checking .env configuration:
type .env | findstr /C:"MQTT_HOST" /C:"MQTT_PORT"
echo.

echo ⚠️  CLOSING OLD PROXY SERVER...
echo    Find and kill process on port 8080
timeout /t 2 >nul
echo.

echo 🚀 STARTING PROXY SERVER...
echo.
echo ============================================================
echo 📋 WHAT TO LOOK FOR:
echo ============================================================
echo ✅ "Proxy Server running on http://localhost:8080"
echo ✅ "Connected to MQTT broker"
echo ✅ "Subscribed to: lab/zaks/#"
echo.
echo When fire detected, you should see:
echo    🔥 Fire detection logged: fire_xxx
echo    ✅ Fire photo published to MQTT topic: lab/zaks/fire_photo
echo.
echo ============================================================
echo.

npm start

pause
