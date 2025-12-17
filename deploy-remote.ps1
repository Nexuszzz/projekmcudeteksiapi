#!/usr/bin/env pwsh

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " 🚀 DEPLOY VIA REMOTE SSH" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$EC2IP = "3.27.11.106"
$EC2User = "ubuntu"
$RepoURL = "https://github.com/Nexuszzz/sudahtapibelum.git"

Write-Host "Target: $EC2User@$EC2IP" -ForegroundColor Yellow
Write-Host ""

# Push latest code
Write-Host "[1/3] Pushing latest code to GitHub..." -ForegroundColor Yellow
git add .
$commitMsg = "Deploy to EC2 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMsg
git push origin master
Write-Host "  Done!" -ForegroundColor Green
Write-Host ""

# Create deployment script
Write-Host "[2/3] Creating deployment commands..." -ForegroundColor Yellow

$deployScript = @'
#!/bin/bash
echo "============================================"
echo "Starting deployment..."
echo "============================================"
echo ""

cd ~

if [ -d "sudahtapibelum" ]; then
    echo "Repository exists, updating..."
    cd sudahtapibelum
    git pull origin master
else
    echo "Cloning repository..."
    git clone https://github.com/Nexuszzz/sudahtapibelum.git
    cd sudahtapibelum
fi

echo ""
echo "Making script executable..."
chmod +x deploy-to-ec2.sh

echo ""
echo "Running deployment..."
./deploy-to-ec2.sh
'@

# Save to temp file
$scriptFile = "$env:TEMP\deploy-remote.sh"
$deployScript | Out-File -FilePath $scriptFile -Encoding UTF8 -NoNewline
Write-Host "  Script created!" -ForegroundColor Green
Write-Host ""

# Show available keys
Write-Host "[3/3] Testing SSH keys..." -ForegroundColor Yellow
Write-Host ""

$keyPath = "C:\Users\NAUFAL\Downloads"
$ppkFiles = Get-ChildItem "$keyPath\*.ppk" -ErrorAction SilentlyContinue

Write-Host "I found these .ppk files:" -ForegroundColor Cyan
foreach ($file in $ppkFiles) {
    Write-Host "  - $($file.Name)" -ForegroundColor White
}
Write-Host ""

Write-Host "============================================" -ForegroundColor Yellow
Write-Host " MANUAL DEPLOYMENT REQUIRED" -ForegroundColor Yellow  
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Since we need .ppk to .pem conversion, here's what to do:" -ForegroundColor White
Write-Host ""

# Option 1: Use PuTTY
Write-Host "OPTION 1: Use PuTTY (Recommended)" -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "1. Locate PuTTY.exe on your system" -ForegroundColor White
Write-Host "   (Check: C:\Program Files\PuTTY\putty.exe)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open PuTTY and configure:" -ForegroundColor White
Write-Host "   - Host Name: $EC2IP" -ForegroundColor Gray
Write-Host "   - Port: 22" -ForegroundColor Gray
Write-Host "   - Connection > SSH > Auth > Private key: $keyPath\sismod.ppk" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Click Open and login as: $EC2User" -ForegroundColor White
Write-Host ""
Write-Host "4. Copy and paste these commands:" -ForegroundColor White
Write-Host ""
Write-Host "cd ~" -ForegroundColor Yellow
Write-Host "git clone $RepoURL" -ForegroundColor Yellow
Write-Host "cd sudahtapibelum" -ForegroundColor Yellow
Write-Host "chmod +x deploy-to-ec2.sh" -ForegroundColor Yellow
Write-Host "./deploy-to-ec2.sh" -ForegroundColor Yellow
Write-Host ""
Write-Host ""

# Option 2: Convert key
Write-Host "OPTION 2: Convert .ppk to .pem" -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "1. Open PuTTYgen (comes with PuTTY)" -ForegroundColor White
Write-Host ""
Write-Host "2. Click 'Load' and select:" -ForegroundColor White
Write-Host "   $keyPath\sismod.ppk" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Menu: Conversions > Export OpenSSH key" -ForegroundColor White
Write-Host ""
Write-Host "4. Save as:" -ForegroundColor White
Write-Host "   $keyPath\sismod.pem" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Then run this PowerShell script:" -ForegroundColor White
Write-Host "   .\deploy-with-pem.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host ""

# Option 3: Use VS Code Remote SSH
Write-Host "OPTION 3: Use VS Code Remote SSH Extension" -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "1. Install 'Remote - SSH' extension in VS Code" -ForegroundColor White
Write-Host ""
Write-Host "2. Press F1 and type: Remote-SSH: Connect to Host" -ForegroundColor White
Write-Host ""
Write-Host "3. Enter: $EC2User@$EC2IP" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Select .ppk key file when prompted" -ForegroundColor White
Write-Host ""
Write-Host "5. Open terminal in VS Code and run:" -ForegroundColor White
Write-Host "   cd ~" -ForegroundColor Yellow
Write-Host "   git clone $RepoURL" -ForegroundColor Yellow
Write-Host "   cd sudahtapibelum" -ForegroundColor Yellow
Write-Host "   chmod +x deploy-to-ec2.sh" -ForegroundColor Yellow
Write-Host "   ./deploy-to-ec2.sh" -ForegroundColor Yellow
Write-Host ""

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " QUICK COMMANDS (Copy these)" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
$quickCmd = "cd ~ && git clone $RepoURL && cd sudahtapibelum && chmod +x deploy-to-ec2.sh && ./deploy-to-ec2.sh"
Write-Host $quickCmd -ForegroundColor Cyan
Write-Host ""
Write-Host ""
Write-Host "After deployment, access:" -ForegroundColor Yellow
Write-Host "http://$EC2IP" -ForegroundColor White
Write-Host "Login: admin / admin123" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
