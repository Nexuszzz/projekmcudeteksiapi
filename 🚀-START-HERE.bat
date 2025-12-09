@echo off
chcp 65001 >nul
cls
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                              ║
echo ║              🔥 FIRE DETECTION SYSTEM - QUICK START 🔥                      ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo.
echo    This is the MAIN LAUNCHER for your fire detection system.
echo    All services will start automatically with verification.
echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo.

timeout /t 2 >nul

REM Just call the complete script
call "%~dp0START-ALL-SERVICES.bat"
