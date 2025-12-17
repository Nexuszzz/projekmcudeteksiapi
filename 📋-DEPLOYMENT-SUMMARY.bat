@echo off
chcp 65001 >nul
cls
color 0A

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║     ✅ DEPLOYMENT FILES CREATED SUCCESSFULLY! ✅              ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo 📦 FILES CREATED FOR DEPLOYMENT TO EC2 IP: 3.27.11.106
echo ════════════════════════════════════════════════════════════════
echo.
echo.
echo 🎯 MAIN FILES (START HERE):
echo ════════════════════════════════════════════════════════════════
echo.
echo    ⭐⭐⭐ DEPLOY-QUICK-START.bat
echo         └─ Interactive menu untuk mulai deployment
echo.
echo    ⭐⭐⭐ START-DEPLOYMENT.bat
echo         └─ Menu lengkap dengan 8 opsi
echo.
echo    ⭐⭐⭐ deploy-to-ec2.sh
echo         └─ Auto-deployment script (run di EC2)
echo.
echo.
echo 📖 DOCUMENTATION FILES:
echo ════════════════════════════════════════════════════════════════
echo.
echo    📄 🎯-MULAI-DARI-SINI.txt
echo    📄 README-DEPLOYMENT.md
echo    📄 🎉-DEPLOYMENT-READY.md
echo    📄 DEPLOY-TO-3.27.11.106.md
echo    📄 📦-FILE-DEPLOYMENT-GUIDE.md
echo    📄 🚀-DEPLOY-EC2-GUIDE.md
echo.
echo.
echo 🔧 CONFIGURATION FILES:
echo ════════════════════════════════════════════════════════════════
echo.
echo    ⚙️  ecosystem.config.json
echo    ⚙️  requirements.txt
echo    ⚙️  python_scripts/.env.production
echo.
echo.
timeout /t 3 >nul

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  🚀 HOW TO DEPLOY (QUICK)                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo STEP 1: Read the Guide
echo ════════════════════════════════════════════════════════════════
echo.
echo    Double-click: 🎯-MULAI-DARI-SINI.txt
echo    (Contains complete deployment steps)
echo.
timeout /t 2 >nul
echo.
echo STEP 2: Run Deployment Tool
echo ════════════════════════════════════════════════════════════════
echo.
echo    Double-click: DEPLOY-QUICK-START.bat
echo    (Interactive menu for deployment)
echo.
timeout /t 2 >nul
echo.
echo STEP 3: Upload to EC2
echo ════════════════════════════════════════════════════════════════
echo.
echo    Option A: Git Clone (Recommended)
echo      cd ~
echo      git clone https://github.com/Nexuszzz/sudahtapibelum.git
echo.
echo    Option B: WinSCP
echo      Use DEPLOY-QUICK-START.bat menu [4]
echo.
timeout /t 2 >nul
echo.
echo STEP 4: Deploy on EC2
echo ════════════════════════════════════════════════════════════════
echo.
echo    cd /home/ubuntu/sudahtapibelum
echo    chmod +x deploy-to-ec2.sh
echo    ./deploy-to-ec2.sh
echo.
timeout /t 2 >nul
echo.
echo STEP 5: Test Website
echo ════════════════════════════════════════════════════════════════
echo.
echo    URL: http://3.27.11.106
echo    Login: admin / admin123
echo.
echo.
timeout /t 3 >nul

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  ⚙️  AWS SECURITY GROUP                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo ⚠️  IMPORTANT: Configure Security Group BEFORE deployment!
echo ════════════════════════════════════════════════════════════════
echo.
echo    1. AWS Console → EC2 → Instances
echo    2. Select instance: 3.27.11.106
echo    3. Security tab → Edit inbound rules
echo    4. Add these rules:
echo.
echo       ┌──────────────┬────────┬──────────────┐
echo       │ Type         │ Port   │ Source       │
echo       ├──────────────┼────────┼──────────────┤
echo       │ SSH          │ 22     │ My IP        │
echo       │ HTTP         │ 80     │ 0.0.0.0/0    │
echo       │ HTTPS        │ 443    │ 0.0.0.0/0    │
echo       └──────────────┴────────┴──────────────┘
echo.
echo    5. Save rules
echo.
echo.
pause

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  ✅ CHECKLIST                                  ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo PRE-DEPLOYMENT:
echo ════════════════════════════════════════════════════════════════
echo.
echo    [ ] PuTTY installed
echo    [ ] WinSCP installed (optional)
echo    [ ] .pem key file available
echo    [ ] AWS Security Group configured
echo    [ ] Code pushed to GitHub
echo.
echo.
echo DEPLOYMENT:
echo ════════════════════════════════════════════════════════════════
echo.
echo    [ ] Files uploaded to EC2
echo    [ ] deploy-to-ec2.sh executed
echo    [ ] All services running (PM2)
echo    [ ] Nginx configured
echo.
echo.
echo TESTING:
echo ════════════════════════════════════════════════════════════════
echo.
echo    [ ] Website accessible (http://3.27.11.106)
echo    [ ] Login works (admin/admin123)
echo    [ ] Dashboard loads correctly
echo    [ ] Real-time data updates
echo.
echo.
echo POST-DEPLOYMENT:
echo ════════════════════════════════════════════════════════════════
echo.
echo    [ ] Admin password changed
echo    [ ] ESP32-CAM IP updated
echo    [ ] Auto-start enabled
echo.
echo.
pause

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  🎉 READY TO DEPLOY!                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo 📚 NEXT STEPS:
echo ════════════════════════════════════════════════════════════════
echo.
echo    1. Read: 🎯-MULAI-DARI-SINI.txt
echo.
echo    2. Run: DEPLOY-QUICK-START.bat
echo.
echo    3. Follow the interactive menus
echo.
echo    4. Deploy to: http://3.27.11.106
echo.
echo.
echo 🎯 RESULT:
echo ════════════════════════════════════════════════════════════════
echo.
echo    ✅ Fire Detection System LIVE
echo    ✅ Real-time Dashboard
echo    ✅ WhatsApp Integration
echo    ✅ Auto Video Recording
echo    ✅ Authentication System
echo.
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo    🌐 Website: http://3.27.11.106
echo    🔑 Login: admin / admin123
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo.
echo    Would you like to start deployment now? [Y/N]
echo.
set /p start="Enter your choice: "

if /i "%start%"=="Y" goto START_DEPLOY
if /i "%start%"=="y" goto START_DEPLOY
goto END

:START_DEPLOY
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              🚀 LAUNCHING DEPLOYMENT TOOL...                   ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
timeout /t 2 >nul
start "" "%~dp0DEPLOY-QUICK-START.bat"
start notepad.exe "%~dp0🎯-MULAI-DARI-SINI.txt"
echo.
echo ✅ Deployment tool launched!
echo ✅ Guide opened in Notepad
echo.
timeout /t 3 >nul
goto END

:END
echo.
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo    Thank you! Happy deploying! 🚀🔥
echo.
echo    For help, read: 🎉-DEPLOYMENT-READY.md
echo.
echo ════════════════════════════════════════════════════════════════
echo.
timeout /t 3 >nul
exit
