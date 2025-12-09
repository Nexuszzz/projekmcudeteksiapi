@echo off
title Voice Call Server - Starting...

echo.
echo ========================================================================
echo 🚀 VOICE CALL SERVER - STARTUP SCRIPT
echo ========================================================================
echo.
echo This script will:
echo   1. Check prerequisites
echo   2. Kill any existing voice-call-server
echo   3. Start fresh voice-call-server
echo   4. Monitor for errors
echo.
echo ========================================================================
echo.

REM Navigate to project root
cd /d "%~dp0"

echo 📁 Current directory: %CD%
echo.

REM ============================================================================
REM Step 1: Check Prerequisites
REM ============================================================================

echo 🔍 STEP 1: Checking prerequisites...
echo.

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found!
    echo    Please install Node.js from: https://nodejs.org
    pause
    exit /b 1
)
echo ✅ Node.js: 
node --version

REM Check npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm not found!
    pause
    exit /b 1
)
echo ✅ npm: 
npm --version

echo.

REM Check folder exists
if not exist "voice-call-server" (
    echo ❌ voice-call-server folder not found!
    echo    Current directory: %CD%
    pause
    exit /b 1
)
echo ✅ voice-call-server folder exists

REM Check server.js exists
if not exist "voice-call-server\server.js" (
    echo ❌ server.js not found!
    pause
    exit /b 1
)
echo ✅ server.js exists

REM Check .env
if not exist "voice-call-server\.env" (
    echo ⚠️  .env not found - creating from .env.example...
    if exist "voice-call-server\.env.example" (
        copy "voice-call-server\.env.example" "voice-call-server\.env" >nul
        echo ✅ .env created from .env.example
        echo.
        echo ⚠️  IMPORTANT: Edit voice-call-server\.env with your Twilio credentials!
        echo    Then run this script again.
        echo.
        notepad "voice-call-server\.env"
        pause
        exit /b 0
    ) else (
        echo ❌ .env.example not found!
        pause
        exit /b 1
    )
) else (
    echo ✅ .env exists
)

REM Check node_modules
if not exist "voice-call-server\node_modules" (
    echo ⚠️  node_modules not found
    echo 📦 Installing dependencies...
    cd voice-call-server
    call npm install
    if %errorlevel% neq 0 (
        echo ❌ npm install failed!
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo ✅ Dependencies installed
) else (
    echo ✅ node_modules exists
)

echo.

REM ============================================================================
REM Step 2: Kill Existing Server
REM ============================================================================

echo 🔍 STEP 2: Checking for existing server on port 3002...
echo.

netstat -ano | findstr ":3002" >nul
if %errorlevel%==0 (
    echo ⚠️  Port 3002 is IN USE
    echo 🔪 Killing existing process...
    
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3002" ^| findstr "LISTENING"') do (
        echo    Killing PID: %%a
        taskkill /F /PID %%a >nul 2>&1
    )
    
    timeout /t 2 /nobreak >nul
    echo ✅ Old process killed
) else (
    echo ✅ Port 3002 is available
)

echo.

REM ============================================================================
REM Step 3: Start Server
REM ============================================================================

echo 🚀 STEP 3: Starting voice-call-server...
echo.
echo ⏳ Starting server on port 3002...
echo 📝 Watch for errors below:
echo.
echo ========================================================================
echo.

cd voice-call-server
node server.js

REM If we get here, server stopped
echo.
echo ========================================================================
echo.
echo ⚠️  Server stopped!
echo.
pause
