@echo off
echo ========================================
echo Starting IoT Dashboard
echo ========================================
echo.
echo Make sure proxy server is running first!
echo Dashboard will be available at:
echo http://localhost:5173
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

if not exist node_modules (
    echo Installing dependencies...
    call npm install
)

if not exist .env (
    echo Creating .env file...
    copy /Y env-configured.txt .env
)

call npm run dev
