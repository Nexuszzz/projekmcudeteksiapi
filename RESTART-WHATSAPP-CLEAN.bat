@echo off
echo ================================================
echo  RESTART WHATSAPP SERVER (CLEAN)
echo ================================================
echo.

:: Kill WhatsApp server process
echo [1/4] Stopping WhatsApp Server...
taskkill /F /IM node.exe /FI "WINDOWTITLE eq whatsapp-server*" 2>nul
timeout /t 2 /nobreak >nul
echo      Done!
echo.

:: Delete session folder
echo [2/4] Deleting old session...
cd whatsapp-server
if exist auth_info (
    rmdir /s /q auth_info
    echo      Session deleted!
) else (
    echo      No session found (already clean)
)
echo.

:: Start WhatsApp server
echo [3/4] Starting WhatsApp Server...
start "whatsapp-server" cmd /k "npm start"
timeout /t 3 /nobreak >nul
echo      Server started!
echo.

:: Wait for server to initialize
echo [4/4] Waiting for server initialization...
timeout /t 5 /nobreak >nul
echo      Ready!
echo.

echo ================================================
echo  WHATSAPP SERVER RESTARTED (CLEAN)
echo ================================================
echo.
echo  Now you can:
echo  1. Go to http://localhost:5173 (Dashboard)
echo  2. Navigate to WhatsApp Integration page
echo  3. Enter phone number and click "Connect"
echo  4. Use pairing code or scan QR code
echo.
echo  Press any key to exit...
pause >nul
