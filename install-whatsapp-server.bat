@echo off
echo ========================================
echo INSTALLING WHATSAPP BAILEYS SERVER
echo ========================================
echo.

cd whatsapp-server

echo Step 1: Installing dependencies...
call npm install

echo.
echo ========================================
echo INSTALLATION COMPLETE!
echo ========================================
echo.
echo To start the server, run:
echo   start-whatsapp-server.bat
echo.
pause
