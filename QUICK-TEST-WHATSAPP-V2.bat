@echo off
title WhatsApp V2 - Quick Test & Verification
color 0E

cls
echo.
echo ================================================================================
echo      WHATSAPP V2 - QUICK TEST ^& VERIFICATION
echo ================================================================================
echo.

cd /d "%~dp0"

echo [Step 1/5] Checking if WhatsApp V2 server is installed...
echo.

if not exist "D:\go-whatsapp-web-multidevice\src\server.exe" (
    echo    [ERROR] Server not found!
    echo.
    echo    Please run setup first:
    echo    1. git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice.git D:\go-whatsapp-web-multidevice
    echo    2. cd D:\go-whatsapp-web-multidevice\src
    echo    3. go mod download
    echo    4. go build -o server.exe main.go
    echo.
    echo    Or run: START-WHATSAPP-V2-SERVER.bat (it will auto-compile)
    echo.
    pause
    exit /b 1
)

echo    [OK] Server found at: D:\go-whatsapp-web-multidevice\src\server.exe
echo.

echo [Step 2/5] Checking if port 3000 is available...
echo.

netstat -ano | findstr :3000 | findstr LISTENING >nul 2>&1
if %errorlevel% equ 0 (
    echo    [INFO] Port 3000 is already in use - Good! Server might be running.
) else (
    echo    [INFO] Port 3000 is free - Server needs to be started.
    echo.
    echo    Starting server now...
    cd /d "D:\go-whatsapp-web-multidevice\src"
    start "WhatsApp V2 Server" cmd /k "title WhatsApp V2 Server & server.exe rest"
    cd /d "%~dp0"
    echo.
    echo    Waiting 8 seconds for server to start...
    timeout /t 8 /nobreak >nul
)
echo.

echo [Step 3/5] Testing API endpoint /app/devices...
echo.

curl -s http://localhost:3000/app/devices 2>nul | findstr "SUCCESS" >nul
if %errorlevel% equ 0 (
    echo    [OK] Server is responding!
    echo.
    echo    Response:
    curl -s http://localhost:3000/app/devices 2>nul
    echo.
) else (
    echo    [ERROR] Server is not responding!
    echo.
    echo    Possible issues:
    echo    1. Server not started yet (wait a bit longer)
    echo    2. Server crashed (check server window for errors)
    echo    3. Port 3000 blocked by firewall
    echo    4. Go not installed or server not compiled
    echo.
    echo    Trying one more time in 5 seconds...
    timeout /t 5 /nobreak >nul
    curl -s http://localhost:3000/app/devices 2>nul | findstr "SUCCESS" >nul
    if %errorlevel% equ 0 (
        echo    [OK] Server responded on second try!
    ) else (
        echo    [ERROR] Still not responding. Check server window.
        pause
        exit /b 1
    )
)

echo [Step 4/5] Testing QR code generation endpoint...
echo.

curl -s http://localhost:3000/app/login 2>nul | findstr "qr_link" >nul
if %errorlevel% equ 0 (
    echo    [OK] QR code generation working!
    echo.
    echo    Sample response:
    curl -s http://localhost:3000/app/login 2>nul
    echo.
) else (
    echo    [WARNING] QR generation returned unexpected response
    echo.
    echo    Response:
    curl -s http://localhost:3000/app/login 2>nul
    echo.
)

echo [Step 5/5] Testing dashboard connection...
echo.

curl -s http://localhost:5173 2>nul >nul
if %errorlevel% equ 0 (
    echo    [OK] Dashboard is running at http://localhost:5173
) else (
    echo    [INFO] Dashboard is not running
    echo.
    echo    Start dashboard with:
    echo    npm run dev
)
echo.

echo ================================================================================
echo [SUCCESS] ALL TESTS COMPLETED!
echo ================================================================================
echo.
echo Summary:
echo ================================================================================
echo.
echo    Server Status:     RUNNING
echo    Port:              3000
echo    API Endpoint:      http://localhost:3000
echo    Dashboard:         http://localhost:5173
echo.
echo ================================================================================
echo NEXT STEPS:
echo ================================================================================
echo.
echo 1. Open browser: http://localhost:5173/whatsappv2
echo 2. Input phone number: 6287847529293 (format: 62xxx)
echo 3. Click: "Generate QR Code"
echo 4. QR code will appear in 2-3 seconds
echo 5. Scan with WhatsApp on your phone
echo 6. Done! Device connected
echo.
echo ================================================================================
echo USEFUL COMMANDS:
echo ================================================================================
echo.
echo Test server manually:
echo    curl http://localhost:3000/app/devices
echo.
echo Generate QR code manually:
echo    curl http://localhost:3000/app/login
echo.
echo View logs:
echo    Check "WhatsApp V2 Server" window
echo.
echo Restart server:
echo    1. Close server window (Ctrl+C)
echo    2. Run: START-WHATSAPP-V2-SERVER.bat
echo.
echo ================================================================================
echo.

echo Opening dashboard in 5 seconds...
timeout /t 5 /nobreak >nul

start http://localhost:5173/whatsappv2

echo.
echo Dashboard opened in browser!
echo.
pause