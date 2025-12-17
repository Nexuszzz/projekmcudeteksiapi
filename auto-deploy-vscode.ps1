#!/usr/bin/env pwsh
# ============================================
# 🚀 AUTO DEPLOY TO EC2 FROM VS CODE
# ============================================

param(
    [string]$KeyFile = "C:\Users\NAUFAL\Downloads\sismod.ppk",
    [string]$EC2IP = "3.27.11.106",
    [string]$EC2User = "ubuntu"
)

# Colors
$Green = [ConsoleColor]::Green
$Red = [ConsoleColor]::Red
$Yellow = [ConsoleColor]::Yellow
$Cyan = [ConsoleColor]::Cyan

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🚀 AUTO DEPLOYMENT TO EC2 FROM VS CODE                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuration
Write-Host "📋 Configuration:" -ForegroundColor Yellow
Write-Host "   EC2 IP: $EC2IP" -ForegroundColor White
Write-Host "   User: $EC2User" -ForegroundColor White
Write-Host "   Key File: $KeyFile" -ForegroundColor White
Write-Host ""

# Step 1: Check if key file exists
Write-Host "🔍 Step 1: Checking key file..." -ForegroundColor Yellow
if (-not (Test-Path $KeyFile)) {
    Write-Host "❌ Key file not found: $KeyFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available .pem files in Downloads:" -ForegroundColor Yellow
    Get-ChildItem "C:\Users\NAUFAL\Downloads" -Filter "*.pem" | ForEach-Object {
        Write-Host "   - $($_.Name)" -ForegroundColor White
    }
    Write-Host ""
    
    # Try to find sismod.pem
    $pemFile = "C:\Users\NAUFAL\Downloads\sismod.pem"
    if (Test-Path $pemFile) {
        Write-Host "✅ Found sismod.pem, using that instead" -ForegroundColor Green
        $KeyFile = $pemFile
    } else {
        Write-Host "⚠️  Please convert sismod.ppk to .pem format" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "How to convert .ppk to .pem:" -ForegroundColor Cyan
        Write-Host "1. Open PuTTYgen" -ForegroundColor White
        Write-Host "2. Load sismod.ppk" -ForegroundColor White
        Write-Host "3. Conversions → Export OpenSSH key" -ForegroundColor White
        Write-Host "4. Save as sismod.pem" -ForegroundColor White
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "✅ Key file found!" -ForegroundColor Green
}
Write-Host ""

# Step 2: Test EC2 connection
Write-Host "🌐 Step 2: Testing EC2 connection..." -ForegroundColor Yellow
$testConnection = Test-Connection -ComputerName $EC2IP -Count 1 -Quiet
if ($testConnection) {
    Write-Host "✅ EC2 is reachable!" -ForegroundColor Green
} else {
    Write-Host "❌ Cannot reach EC2 at $EC2IP" -ForegroundColor Red
    Write-Host "⚠️  Check your internet connection and AWS Security Group" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 3: Push code to GitHub
Write-Host "📦 Step 3: Pushing code to GitHub..." -ForegroundColor Yellow
try {
    git add .
    git commit -m "Deploy to EC2 $EC2IP - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git push origin master
    Write-Host "✅ Code pushed to GitHub!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Git push failed or nothing to commit" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Prepare deployment commands
Write-Host "🚀 Step 4: Preparing deployment commands..." -ForegroundColor Yellow
$deployCommands = @"
cd ~
if [ -d "sudahtapibelum" ]; then
    echo "📂 Repository exists, updating..."
    cd sudahtapibelum
    git pull origin master
else
    echo "📂 Cloning repository..."
    git clone https://github.com/Nexuszzz/sudahtapibelum.git
    cd sudahtapibelum
fi
echo ""
echo "🔧 Making deployment script executable..."
chmod +x deploy-to-ec2.sh
echo ""
echo "🚀 Starting deployment..."
./deploy-to-ec2.sh
"@

# Save commands to temp file
$tempFile = [System.IO.Path]::GetTempFileName()
$deployCommands | Out-File -FilePath $tempFile -Encoding UTF8
Write-Host "✅ Deployment script prepared" -ForegroundColor Green
Write-Host ""

# Step 5: Connect and deploy
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🔌 CONNECTING TO EC2 AND DEPLOYING...                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏱️  This will take 10-15 minutes..." -ForegroundColor Yellow
Write-Host "📊 You will see the deployment progress below..." -ForegroundColor Yellow
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if key is .ppk or .pem
$keyExtension = [System.IO.Path]::GetExtension($KeyFile)
if ($keyExtension -eq ".ppk") {
    Write-Host "⚠️  Detected .ppk file. You need to:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Convert to .pem using PuTTYgen" -ForegroundColor Cyan
    Write-Host "   1. Open PuTTYgen" -ForegroundColor White
    Write-Host "   2. Load → sismod.ppk" -ForegroundColor White
    Write-Host "   3. Conversions → Export OpenSSH key" -ForegroundColor White
    Write-Host "   4. Save as: C:\Users\NAUFAL\Downloads\sismod.pem" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Use PuTTY with pscp" -ForegroundColor Cyan
    Write-Host ""
    $usePutty = Read-Host "Use Option 2 (PuTTY)? [Y/N]"
    
    if ($usePutty -eq "Y" -or $usePutty -eq "y") {
        Write-Host ""
        Write-Host "🔧 Using PuTTY method..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Opening PuTTY session..." -ForegroundColor Cyan
        
        # Create PuTTY session
        $puttyPath = "C:\Program Files\PuTTY\putty.exe"
        if (-not (Test-Path $puttyPath)) {
            $puttyPath = "C:\Program Files (x86)\PuTTY\putty.exe"
        }
        
        if (Test-Path $puttyPath) {
            Write-Host ""
            Write-Host "📝 Run these commands in PuTTY:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host $deployCommands -ForegroundColor White
            Write-Host ""
            
            # Start PuTTY
            Start-Process $puttyPath -ArgumentList "-ssh", "$EC2User@$EC2IP", "-i", $KeyFile
            
            Write-Host "✅ PuTTY opened! Run the commands shown above." -ForegroundColor Green
        } else {
            Write-Host "❌ PuTTY not found" -ForegroundColor Red
        }
    } else {
        Write-Host ""
        Write-Host "❌ Please convert .ppk to .pem first" -ForegroundColor Red
        exit 1
    }
} else {
    # Use SSH directly with .pem file
    Write-Host "🔐 Using OpenSSH with .pem file..." -ForegroundColor Cyan
    Write-Host ""
    
    # Set proper permissions on key file (Windows equivalent)
    Write-Host "🔒 Setting key file permissions..." -ForegroundColor Yellow
    icacls $KeyFile /inheritance:r
    icacls $KeyFile /grant:r "$($env:USERNAME):(R)"
    Write-Host "✅ Permissions set" -ForegroundColor Green
    Write-Host ""
    
    # Execute deployment via SSH
    Write-Host "🚀 Executing deployment..." -ForegroundColor Yellow
    Write-Host ""
    
    $sshCommand = "ssh -i `"$KeyFile`" -o StrictHostKeyChecking=no $EC2User@$EC2IP `"bash -s`" < `"$tempFile`""
    Invoke-Expression $sshCommand
}

# Cleanup
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     ✅ DEPLOYMENT COMPLETE!                                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your website should be live at:" -ForegroundColor Yellow
Write-Host "   http://$EC2IP" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Login credentials:" -ForegroundColor Yellow
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "📊 Check status on EC2:" -ForegroundColor Yellow
Write-Host "   ssh -i `"$KeyFile`" $EC2User@$EC2IP" -ForegroundColor White
Write-Host "   pm2 status" -ForegroundColor White
Write-Host "   pm2 logs" -ForegroundColor White
Write-Host ""

# Open browser
$openBrowser = Read-Host "Open website in browser? [Y/N]"
if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
    Start-Process "http://$EC2IP"
}

Write-Host ""
Write-Host "🎉 Done! Happy deploying! 🔥" -ForegroundColor Green
Write-Host ""
