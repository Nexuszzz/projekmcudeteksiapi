@echo off
chcp 65001 >nul
cls
color 0B
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                                                                   ║
echo ║         🔥 FIRE DETECTION SYSTEM - EC2 DEPLOYMENT 🔥             ║
echo ║                                                                   ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo ┌───────────────────────────────────────────────────────────────────┐
echo │                   DEPLOYMENT INFORMATION                          │
echo └───────────────────────────────────────────────────────────────────┘
echo.
echo   🌐 Target EC2 IP: 3.27.0.139
echo   👤 Username: ubuntu
echo   🔑 Auth: .pem key file
echo   📦 Repository: github.com/Nexuszzz/sudahtapibelum
echo.
timeout /t 2 >nul

echo ┌───────────────────────────────────────────────────────────────────┐
echo │                      DEPLOYMENT OPTIONS                           │
echo └───────────────────────────────────────────────────────────────────┘
echo.
echo   [1] 🚀 QUICK DEPLOY - Launch Interactive Menu
echo.
echo   [2] 📖 Read Full Documentation
echo.
echo   [3] ⚡ Open PuTTY to EC2
echo.
echo   [4] 📤 Open WinSCP for File Transfer
echo.
echo   [5] 🧪 Test Deployment (Open Website)
echo.
echo   [6] ❌ Exit
echo.
set /p choice="Select option [1-6]: "

if "%choice%"=="1" goto QUICK_DEPLOY
if "%choice%"=="2" goto DOCS
if "%choice%"=="3" goto PUTTY
if "%choice%"=="4" goto WINSCP
if "%choice%"=="5" goto TEST
if "%choice%"=="6" goto EXIT

:QUICK_DEPLOY
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   🚀 LAUNCHING DEPLOYMENT MENU                    ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
timeout /t 1 >nul
start "" "%~dp0START-DEPLOYMENT.bat"
goto END

:DOCS
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   📖 OPENING DOCUMENTATION                        ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo Opening files:
echo   • 🎉-DEPLOYMENT-READY.md
echo   • DEPLOY-TO-3.27.0.139.md
echo.
timeout /t 1 >nul
start notepad.exe "%~dp0🎉-DEPLOYMENT-READY.md"
timeout /t 1 >nul
start notepad.exe "%~dp0DEPLOY-TO-3.27.0.139.md"
goto END

:PUTTY
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   🌐 CONNECTING TO EC2                            ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo Connection Details:
echo   • Host: 3.27.0.139
echo   • Port: 22
echo   • User: ubuntu
echo.
echo Opening PuTTY...
echo.
if exist "C:\Program Files\PuTTY\putty.exe" (
    start "" "C:\Program Files\PuTTY\putty.exe" -ssh ubuntu@3.27.0.139
    echo ✅ PuTTY launched!
) else if exist "C:\Program Files (x86)\PuTTY\putty.exe" (
    start "" "C:\Program Files (x86)\PuTTY\putty.exe" -ssh ubuntu@3.27.0.139
    echo ✅ PuTTY launched!
) else (
    echo ❌ PuTTY not found!
    echo.
    echo Download from: https://www.putty.org/
)
echo.
timeout /t 3 >nul
goto END

:WINSCP
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   📤 OPENING WINSCP                               ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo File Transfer Details:
echo   • Protocol: SFTP
echo   • Host: 3.27.0.139
echo   • Port: 22
echo   • User: ubuntu
echo   • Remote dir: /home/ubuntu/sudahtapibelum
echo.
echo Opening WinSCP...
echo.
if exist "C:\Program Files\WinSCP\WinSCP.exe" (
    start "" "C:\Program Files\WinSCP\WinSCP.exe"
    echo ✅ WinSCP launched!
) else if exist "C:\Program Files (x86)\WinSCP\WinSCP.exe" (
    start "" "C:\Program Files (x86)\WinSCP\WinSCP.exe"
    echo ✅ WinSCP launched!
) else (
    echo ❌ WinSCP not found!
    echo.
    echo Download from: https://winscp.net/
)
echo.
timeout /t 3 >nul
goto END

:TEST
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   🧪 TESTING DEPLOYMENT                           ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo Opening website: http://3.27.0.139
echo.
timeout /t 1 >nul
start http://3.27.0.139
echo.
echo ┌───────────────────────────────────────────────────────────────────┐
echo │                      LOGIN CREDENTIALS                            │
echo └───────────────────────────────────────────────────────────────────┘
echo.
echo   👤 Username: admin
echo   🔑 Password: admin123
echo.
echo ┌───────────────────────────────────────────────────────────────────┐
echo │                      TESTING CHECKLIST                            │
echo └───────────────────────────────────────────────────────────────────┘
echo.
echo   [ ] Website loads successfully
echo   [ ] Login works with admin/admin123
echo   [ ] Dashboard displays correctly
echo   [ ] Navigation menu functions
echo   [ ] Real-time data updates
echo   [ ] Fire detection status visible
echo.
pause
goto END

:EXIT
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                   👋 EXITING DEPLOYMENT TOOL                      ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
timeout /t 1 >nul
exit

:END
echo.
echo ┌───────────────────────────────────────────────────────────────────┐
echo │                      QUICK COMMANDS                               │
echo └───────────────────────────────────────────────────────────────────┘
echo.
echo   Connect to EC2:
echo     ssh -i "key.pem" ubuntu@3.27.0.139
echo.
echo   Deploy on EC2:
echo     cd /home/ubuntu/sudahtapibelum
echo     chmod +x deploy-to-ec2.sh
echo     ./deploy-to-ec2.sh
echo.
echo   Check services:
echo     pm2 status
echo     pm2 logs
echo.
echo   Website: http://3.27.0.139
echo.
pause
cls
goto :EOF
