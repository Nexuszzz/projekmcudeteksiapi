@echo off
chcp 65001 >nul
cls
echo.
echo ============================================================
echo 🔄 QUICK FIX - RESTART WHATSAPP SERVER
echo ============================================================
echo.

echo Current Status:
curl -s http://localhost:3001/api/whatsapp/status | findstr "recipientCount"
echo.

echo ⚠️  Recipients not loaded properly (recipientCount: 0)
echo.
echo Solution: Restart WhatsApp server to reload recipients.json
echo.

pause

echo.
echo Killing WhatsApp Server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)

timeout /t 2 >nul

echo Starting WhatsApp Server...
cd /d "%~dp0whatsapp-server"
start "WhatsApp Server" cmd /k "npm start"

timeout /t 5 >nul

echo.
echo Checking status...
curl -s http://localhost:3001/api/whatsapp/status

echo.
echo ============================================================
echo ✅ DONE! Check recipientCount above
echo ============================================================
echo.
echo If recipientCount is still 0, check WhatsApp Server window
echo for error messages about recipients.json file.
echo.

pause
