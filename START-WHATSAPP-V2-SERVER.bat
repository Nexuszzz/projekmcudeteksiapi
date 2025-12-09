@echo off
REM ====================================================
REM START WHATSAPP V2 GO API SERVER
REM ====================================================
REM 
REM This script starts the go-whatsapp-web-multidevice API server
REM Make sure you have Go installed and the repository cloned
REM
REM Repository: https://github.com/aldinokemal/go-whatsapp-web-multidevice
REM
REM ====================================================

echo.
echo ========================================
echo  WHATSAPP V2 GO API SERVER STARTER
echo ========================================
echo.

REM Check if go is installed
where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Go is not installed!
    echo.
    echo Please install Go from: https://go.dev/dl/
    echo.
    pause
    exit /b 1
)

echo [OK] Go is installed
go version
echo.

REM Define the go-whatsapp directory path
set "GO_WA_DIR=..\go-whatsapp-web-multidevice"

REM Check if directory exists
if not exist "%GO_WA_DIR%" (
    echo [WARNING] go-whatsapp-web-multidevice not found!
    echo.
    echo Expected location: %GO_WA_DIR%
    echo.
    echo Do you want to clone it now? (Y/N)
    set /p CLONE_CHOICE=Choice: 
    
    if /i "%CLONE_CHOICE%"=="Y" (
        echo.
        echo Cloning repository...
        git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice "%GO_WA_DIR%"
        
        if %ERRORLEVEL% NEQ 0 (
            echo [ERROR] Failed to clone repository!
            pause
            exit /b 1
        )
        
        echo [OK] Repository cloned successfully
    ) else (
        echo.
        echo Please clone manually:
        echo   git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice
        echo.
        pause
        exit /b 1
    )
)

echo [OK] Directory found: %GO_WA_DIR%
echo.

REM Change to go-whatsapp directory
cd "%GO_WA_DIR%"

REM Check if dependencies are installed
if not exist "go.sum" (
    echo Installing Go dependencies...
    go mod download
    
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to download dependencies!
        pause
        exit /b 1
    )
    
    echo [OK] Dependencies installed
    echo.
)

REM Check if built binary exists
if not exist "whatsapp-api.exe" (
    echo Building application...
    go build -o whatsapp-api.exe
    
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Build failed!
        pause
        exit /b 1
    )
    
    echo [OK] Build successful
    echo.
)

echo ========================================
echo  STARTING WHATSAPP V2 API SERVER
echo ========================================
echo.
echo API will be available at:
echo   - http://localhost:3000
echo.
echo Endpoints:
echo   - GET  /app/devices
echo   - GET  /app/login?device=628xxx
echo   - POST /send/message
echo   - POST /send/image
echo   - POST /send/location
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

REM Run the server
go run main.go

REM If server exits
echo.
echo Server stopped.
pause
