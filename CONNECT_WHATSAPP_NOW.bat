@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 📱 WHATSAPP CONNECTION - SCAN QR CODE
echo ============================================================
echo.
echo 🎯 LANGKAH MUDAH:
echo.
echo 1. Buka WhatsApp di HP Anda
echo 2. Tap menu (3 titik) → Linked Devices
echo 3. Tap "Link a Device"
echo 4. Scan QR code yang muncul di window "WhatsApp Server"
echo.
echo ⏳ Tunggu 5-10 detik setelah scan...
echo.
echo ============================================================
echo.

echo 🔄 Checking WhatsApp Server status...
echo.

curl -s http://localhost:3001/api/whatsapp/status

echo.
echo.
echo ============================================================
echo.
echo 📋 CATATAN:
echo    • Window "WhatsApp Server" harus terbuka
echo    • QR code muncul otomatis di console
echo    • Setelah scan, WhatsApp akan auto-connect
echo.
echo ============================================================
echo.

pause
