@echo off
echo ========================================
echo Starting MQTT Proxy Server
echo ========================================
echo.
echo Connecting to: 13.213.57.228:1883
echo WebSocket endpoint: ws://localhost:8080/ws
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

cd proxy-server

if not exist node_modules (
    echo Installing dependencies...
    call npm install
)

if not exist .env (
    echo Creating .env file...
    copy /Y env-configured.txt .env
)

call npm start
