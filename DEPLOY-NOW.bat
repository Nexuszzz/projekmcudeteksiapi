@echo off
echo ====================================
echo 🚀 Deploy to EC2: 3.27.0.139
echo ====================================
echo.

REM Set EC2 details
set EC2_IP=3.27.0.139
set EC2_USER=ubuntu
set PPK_FILE=C:\Users\NAUFAL\Downloads\sismod.ppk

echo 📋 Deployment Configuration:
echo    EC2 IP: %EC2_IP%
echo    User: %EC2_USER%
echo    Key: %PPK_FILE%
echo.

echo 📦 Step 1: Push code to GitHub...
git add .
git commit -m "Ready for EC2 deployment to %EC2_IP%"
git push origin master

echo.
echo ✅ Code pushed to GitHub!
echo.
echo 📝 Next Steps:
echo.
echo 1. Open PuTTY
echo 2. Host Name: %EC2_USER%@%EC2_IP%
echo 3. Connection → SSH → Auth → Browse: %PPK_FILE%
echo 4. Click Open
echo.
echo 5. In EC2 terminal, run:
echo    cd ~
echo    git clone https://github.com/Nexuszzz/sudahtapibelum.git
echo    cd sudahtapibelum
echo    chmod +x deploy-to-ec2.sh
echo    ./deploy-to-ec2.sh
echo.
echo ====================================
pause
