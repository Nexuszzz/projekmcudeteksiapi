@echo off
chcp 65001 >nul
cls
color 0A
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     🚀 DEPLOY FIRE DETECTION SYSTEM TO EC2                    ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Target IP: 3.27.11.106
echo Status: Ready to Deploy
echo.
timeout /t 2 >nul

:MENU
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                 🎯 DEPLOYMENT MENU                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo   [1] 📖 Baca Panduan Lengkap
echo   [2] 🔍 Cek Prerequisites
echo   [3] 📦 Prepare Files untuk Upload
echo   [4] 🌐 Connect ke EC2 (PuTTY)
echo   [5] 📤 Upload Files (WinSCP)
echo   [6] ⚡ Deploy Command Reference
echo   [7] 🧪 Test Deployment
echo   [8] ❌ Exit
echo.
set /p choice="Pilih menu [1-8]: "

if "%choice%"=="1" goto GUIDE
if "%choice%"=="2" goto CHECK
if "%choice%"=="3" goto PREPARE
if "%choice%"=="4" goto CONNECT
if "%choice%"=="5" goto UPLOAD
if "%choice%"=="6" goto COMMANDS
if "%choice%"=="7" goto TEST
if "%choice%"=="8" goto EXIT
goto MENU

:GUIDE
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                 📖 PANDUAN LENGKAP                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo File panduan: DEPLOY-TO-3.27.11.106.md
echo.
echo Opening in default text editor...
start notepad.exe "DEPLOY-TO-3.27.11.106.md"
timeout /t 2 >nul
pause
goto MENU

:CHECK
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              🔍 CHECKING PREREQUISITES                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check Node.js
echo [1/5] Checking Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    node --version
    echo ✅ Node.js installed
) else (
    echo ❌ Node.js NOT installed
)
echo.

REM Check npm
echo [2/5] Checking npm...
where npm >nul 2>&1
if %errorlevel% equ 0 (
    npm --version
    echo ✅ npm installed
) else (
    echo ❌ npm NOT installed
)
echo.

REM Check PuTTY
echo [3/5] Checking PuTTY...
if exist "C:\Program Files\PuTTY\putty.exe" (
    echo ✅ PuTTY installed
) else if exist "C:\Program Files (x86)\PuTTY\putty.exe" (
    echo ✅ PuTTY installed
) else (
    echo ❌ PuTTY NOT found
    echo    Download: https://www.putty.org/
)
echo.

REM Check WinSCP
echo [4/5] Checking WinSCP...
if exist "C:\Program Files\WinSCP\WinSCP.exe" (
    echo ✅ WinSCP installed
) else if exist "C:\Program Files (x86)\WinSCP\WinSCP.exe" (
    echo ✅ WinSCP installed
) else (
    echo ❌ WinSCP NOT found
    echo    Download: https://winscp.net/
)
echo.

REM Check deployment script
echo [5/5] Checking deployment script...
if exist "deploy-to-ec2.sh" (
    echo ✅ deploy-to-ec2.sh found
) else (
    echo ❌ deploy-to-ec2.sh NOT found
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
pause
goto MENU

:PREPARE
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              📦 PREPARING FILES FOR UPLOAD                     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Folder yang HARUS di-upload:
echo.
echo ✅ src/                    (React source code)
echo ✅ proxy-server/          (Express backend)
echo ✅ python_scripts/        (Fire detection)
echo ✅ public/                (Static assets)
echo ✅ *.json                 (package.json, ecosystem.config.json)
echo ✅ *.sh                   (deployment scripts)
echo ✅ *.md                   (documentation)
echo ✅ index.html
echo ✅ vite.config.ts
echo ✅ tsconfig.json
echo.
echo Folder yang TIDAK perlu di-upload:
echo.
echo ❌ node_modules/          (akan di-install di server)
echo ❌ dist/                  (akan di-build di server)
echo ❌ recordings/            (hasil rekaman)
echo ❌ .git/                  (gunakan git clone di server)
echo ❌ fire_detect_recordings/ (hasil deteksi)
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo 💡 TIP: Gunakan WinSCP untuk upload files
echo    atau git clone langsung di server!
echo.
pause
goto MENU

:CONNECT
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              🌐 CONNECT TO EC2 VIA PUTTY                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo LANGKAH-LANGKAH:
echo.
echo 1. Buka PuTTY
echo.
echo 2. Isi konfigurasi:
echo    • Host Name: 3.27.11.106
echo    • Port: 22
echo    • Connection Type: SSH
echo.
echo 3. Setup Authentication:
echo    • Sidebar: Connection → SSH → Auth
echo    • Private key file: Browse dan pilih file .pem
echo.
echo 4. (Opsional) Save Session:
echo    • Kembali ke Session
echo    • Saved Sessions: ketik "FireDetection-EC2"
echo    • Klik Save
echo.
echo 5. Klik "Open"
echo.
echo 6. Login:
echo    • login as: ubuntu
echo    • Jika ada security alert, klik "Yes"
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo Opening PuTTY...
echo.

REM Try to open PuTTY
if exist "C:\Program Files\PuTTY\putty.exe" (
    start "" "C:\Program Files\PuTTY\putty.exe" -ssh ubuntu@3.27.11.106
) else if exist "C:\Program Files (x86)\PuTTY\putty.exe" (
    start "" "C:\Program Files (x86)\PuTTY\putty.exe" -ssh ubuntu@3.27.11.106
) else (
    echo ❌ PuTTY not found!
    echo    Please install from: https://www.putty.org/
)
echo.
pause
goto MENU

:UPLOAD
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              📤 UPLOAD FILES VIA WINSCP                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo LANGKAH-LANGKAH:
echo.
echo 1. Buka WinSCP
echo.
echo 2. New Site - Isi konfigurasi:
echo    • File protocol: SFTP
echo    • Host name: 3.27.11.106
echo    • Port number: 22
echo    • User name: ubuntu
echo.
echo 3. Setup Authentication:
echo    • Klik "Advanced..."
echo    • SSH → Authentication
echo    • Private key file: Browse .pem file
echo    • Klik OK
echo.
echo 4. Klik "Login"
echo.
echo 5. Transfer Files:
echo    • Left panel: d:\rtsp-main
echo    • Right panel: /home/ubuntu/
echo    • Drag folder ke kanan atau:
echo      - Klik kanan folder rtsp-main
echo      - Upload
echo      - Remote directory: /home/ubuntu/sudahtapibelum
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo 💡 ALTERNATIF: Clone dari GitHub
echo.
echo Di EC2 (via PuTTY):
echo   cd ~
echo   git clone https://github.com/Nexuszzz/sudahtapibelum.git
echo   cd sudahtapibelum
echo.
echo Opening WinSCP...
echo.

REM Try to open WinSCP
if exist "C:\Program Files\WinSCP\WinSCP.exe" (
    start "" "C:\Program Files\WinSCP\WinSCP.exe"
) else if exist "C:\Program Files (x86)\WinSCP\WinSCP.exe" (
    start "" "C:\Program Files (x86)\WinSCP\WinSCP.exe"
) else (
    echo ❌ WinSCP not found!
    echo    Please install from: https://winscp.net/
)
echo.
pause
goto MENU

:COMMANDS
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║           ⚡ DEPLOYMENT COMMANDS (RUN IN PUTTY)                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │ STEP 1: Navigate to Project Directory                         │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo   cd /home/ubuntu/sudahtapibelum
echo.
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │ STEP 2: Make Script Executable                                │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo   chmod +x deploy-to-ec2.sh
echo.
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │ STEP 3: Run Deployment Script                                 │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo   ./deploy-to-ec2.sh
echo.
echo   ⏱️  This will take 10-15 minutes
echo   ✅ Script will install: Node.js, Python, PM2, Nginx
echo   ✅ Build frontend and start services
echo.
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │ STEP 4: Verify Deployment                                     │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo   pm2 status
echo   sudo systemctl status nginx
echo.
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo 📋 QUICK COPY (paste di PuTTY dengan klik kanan):
echo.
echo cd /home/ubuntu/sudahtapibelum ^&^& chmod +x deploy-to-ec2.sh ^&^& ./deploy-to-ec2.sh
echo.
echo ════════════════════════════════════════════════════════════════
echo.
pause
goto MENU

:TEST
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              🧪 TESTING DEPLOYMENT                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Opening website in browser...
echo.
echo URL: http://3.27.11.106
echo.
timeout /t 2 >nul
start http://3.27.11.106
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo 🔑 LOGIN CREDENTIALS:
echo.
echo    Username: admin
echo    Password: admin123
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo ✅ CHECKLIST TESTING:
echo.
echo    [ ] Website terbuka (tidak error)
echo    [ ] Login berhasil dengan admin/admin123
echo    [ ] Dashboard muncul dengan benar
echo    [ ] Menu navigasi berfungsi
echo    [ ] Real-time data muncul
echo    [ ] Fire detection status terlihat
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo 🐛 JIKA ADA MASALAH:
echo.
echo Di PuTTY, jalankan:
echo    pm2 logs           (lihat error logs)
echo    pm2 status         (cek service running)
echo    pm2 restart all    (restart semua service)
echo.
pause
goto MENU

:EXIT
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              ✅ DEPLOYMENT HELPER                              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo 📚 RESOURCES:
echo.
echo    • Full Guide: DEPLOY-TO-3.27.11.106.md
echo    • Deployment Script: deploy-to-ec2.sh
echo    • PM2 Config: ecosystem.config.json
echo.
echo 🌐 ACCESS:
echo.
echo    • Website: http://3.27.11.106
echo    • Login: admin / admin123
echo.
echo 📞 SUPPORT COMMANDS:
echo.
echo    • pm2 status       (service status)
echo    • pm2 logs         (view logs)
echo    • pm2 monit        (CPU/Memory)
echo    • pm2 restart all  (restart services)
echo.
echo.
echo Thank you! Happy deploying! 🚀🔥
echo.
timeout /t 3 >nul
exit
