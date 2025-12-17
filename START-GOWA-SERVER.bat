@echo off
REM ============================================================
REM  Go-WhatsApp (GOWA) Server Launcher
REM  Fire Detection System - WhatsApp Integration
REM ============================================================
REM  
REM  This script starts the Go-WhatsApp REST API server
REM  GitHub: https://github.com/aldinokemal/go-whatsapp-web-multidevice
REM
REM  Requirements:
REM  - Go 1.24.0+ OR pre-built binary
REM  - FFmpeg (for media processing)
REM
REM ============================================================

echo.
echo ============================================================
echo   Go-WhatsApp (GOWA) Server Launcher
echo   Fire Detection System - WhatsApp Integration
echo ============================================================
echo.

REM Navigate to GOWA directory
cd /d "%~dp0go-whatsapp-web-multidevice\src"

IF NOT EXIST "." (
    echo [ERROR] GOWA directory not found!
    echo Please ensure go-whatsapp-web-multidevice is in the project root
    pause
    exit /b 1
)

REM Check if binary exists
IF EXIST "whatsapp.exe" (
    echo [INFO] Starting pre-built GOWA binary...
    echo.
    .\whatsapp.exe rest --port 3000 --debug
) ELSE (
    echo [INFO] No binary found, attempting to run with Go...
    echo.
    
    REM Check if Go is installed
    where go >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Go is not installed!
        echo.
        echo Please either:
        echo   1. Install Go from https://golang.org/dl/
        echo   2. Download pre-built binary from:
        echo      https://github.com/aldinokemal/go-whatsapp-web-multidevice/releases
        echo.
        pause
        exit /b 1
    )
    
    echo [INFO] Running with Go...
    go run . rest --port 3000 --debug
)

echo.
echo [INFO] GOWA Server stopped.
pause
