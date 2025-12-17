#!/usr/bin/env pwsh
# ============================================
# 🔧 Convert PPK to PEM and Test Connection
# ============================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🔧 EC2 CONNECTION SETUP                                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$EC2IP = "3.27.11.106"
$EC2User = "ubuntu"
$KeyPath = "C:\Users\NAUFAL\Downloads"

# Check available keys
Write-Host "🔍 Searching for SSH keys..." -ForegroundColor Yellow
Write-Host ""

$pemFiles = Get-ChildItem $KeyPath -Filter "*.pem" -ErrorAction SilentlyContinue
$ppkFiles = Get-ChildItem $KeyPath -Filter "*.ppk" -ErrorAction SilentlyContinue

if ($pemFiles) {
    Write-Host "✅ Found .pem files:" -ForegroundColor Green
    $pemFiles | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor White }
    Write-Host ""
}

if ($ppkFiles) {
    Write-Host "✅ Found .ppk files:" -ForegroundColor Green
    $ppkFiles | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor White }
    Write-Host ""
}

# Ask user which key to use
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Select connection method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Use existing .pem file" -ForegroundColor White
Write-Host "  [2] Convert sismod.ppk to .pem (requires puttygen)" -ForegroundColor White
Write-Host "  [3] Use PuTTY with .ppk file" -ForegroundColor White
Write-Host "  [4] Manual SSH connection string" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice [1-4]"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Available .pem files:" -ForegroundColor Yellow
        $i = 1
        $pemFiles | ForEach-Object { 
            Write-Host "  [$i] $($_.Name)" -ForegroundColor White
            $i++
        }
        Write-Host ""
        $pemChoice = Read-Host "Select .pem file number"
        
        $selectedPem = $pemFiles[$pemChoice - 1]
        if ($selectedPem) {
            $keyFile = $selectedPem.FullName
            Write-Host ""
            Write-Host "✅ Selected: $($selectedPem.Name)" -ForegroundColor Green
            Write-Host ""
            
            # Test connection
            Write-Host "🌐 Testing connection to EC2..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Command: ssh -i `"$keyFile`" -o StrictHostKeyChecking=no $EC2User@$EC2IP `"echo 'Connection successful!'`"" -ForegroundColor Gray
            Write-Host ""
            
            try {
                $result = ssh -i "$keyFile" -o StrictHostKeyChecking=no "$EC2User@$EC2IP" "echo 'Connection successful!'"
                
                if ($result -eq "Connection successful!") {
                    Write-Host "✅ CONNECTION SUCCESSFUL!" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "🚀 Ready to deploy! Run this command:" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ".\auto-deploy-vscode.ps1 -KeyFile `"$keyFile`" -EC2IP $EC2IP -EC2User $EC2User" -ForegroundColor Cyan
                    Write-Host ""
                } else {
                    Write-Host "⚠️  Connection test returned: $result" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
                Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
                Write-Host "   1. Check AWS Security Group allows SSH (port 22)" -ForegroundColor White
                Write-Host "   2. Verify EC2 instance is running" -ForegroundColor White
                Write-Host "   3. Verify key file permissions" -ForegroundColor White
            }
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "🔧 Converting .ppk to .pem..." -ForegroundColor Yellow
        Write-Host ""
        
        # Check if puttygen exists
        $puttygenPath = "C:\Program Files\PuTTY\puttygen.exe"
        if (-not (Test-Path $puttygenPath)) {
            $puttygenPath = "C:\Program Files (x86)\PuTTY\puttygen.exe"
        }
        
        if (Test-Path $puttygenPath) {
            $ppkFile = "$KeyPath\sismod.ppk"
            $pemFile = "$KeyPath\sismod.pem"
            
            Write-Host "Converting: $ppkFile" -ForegroundColor White
            Write-Host "To: $pemFile" -ForegroundColor White
            Write-Host ""
            
            # Run puttygen to convert
            & $puttygenPath $ppkFile -O private-openssh -o $pemFile
            
            if (Test-Path $pemFile) {
                Write-Host "✅ Conversion successful!" -ForegroundColor Green
                Write-Host ""
                Write-Host "Now testing connection..." -ForegroundColor Yellow
                Write-Host ""
                
                # Test connection
                try {
                    $result = ssh -i "$pemFile" -o StrictHostKeyChecking=no "$EC2User@$EC2IP" "echo 'Connection successful!'"
                    
                    if ($result -eq "Connection successful!") {
                        Write-Host "✅ CONNECTION SUCCESSFUL!" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "🚀 Ready to deploy! Run:" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ".\auto-deploy-vscode.ps1 -KeyFile `"$pemFile`" -EC2IP $EC2IP -EC2User $EC2User" -ForegroundColor Cyan
                        Write-Host ""
                    }
                } catch {
                    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Conversion failed" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ PuTTYgen not found" -ForegroundColor Red
            Write-Host ""
            Write-Host "Manual conversion steps:" -ForegroundColor Yellow
            Write-Host "1. Open PuTTYgen" -ForegroundColor White
            Write-Host "2. Load - sismod.ppk" -ForegroundColor White
            Write-Host "3. Conversions - Export OpenSSH key" -ForegroundColor White
            Write-Host "4. Save as: $KeyPath\sismod.pem" -ForegroundColor White
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "🔧 Opening PuTTY..." -ForegroundColor Yellow
        Write-Host ""
        
        $puttyPath = "C:\Program Files\PuTTY\putty.exe"
        if (-not (Test-Path $puttyPath)) {
            $puttyPath = "C:\Program Files (x86)\PuTTY\putty.exe"
        }
        
        if (Test-Path $puttyPath) {
            $ppkFile = "$KeyPath\sismod.ppk"
            
            Write-Host "Starting PuTTY session..." -ForegroundColor White
            Write-Host "Host: $EC2User@$EC2IP" -ForegroundColor White
            Write-Host "Key: $ppkFile" -ForegroundColor White
            Write-Host ""
            
            Start-Process $puttyPath -ArgumentList "-ssh", "$EC2User@$EC2IP", "-i", $ppkFile
            
            Write-Host "✅ PuTTY opened!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📝 Run these commands in PuTTY:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "cd ~" -ForegroundColor Cyan
            Write-Host "git clone https://github.com/Nexuszzz/sudahtapibelum.git" -ForegroundColor Cyan
            Write-Host "cd sudahtapibelum" -ForegroundColor Cyan
            Write-Host "chmod +x deploy-to-ec2.sh" -ForegroundColor Cyan
            Write-Host "./deploy-to-ec2.sh" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "❌ PuTTY not found" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "📋 Manual SSH Connection Commands:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Using .pem file:" -ForegroundColor Cyan
        Write-Host "ssh -i `"C:\Users\NAUFAL\Downloads\sismod.pem`" $EC2User@$EC2IP" -ForegroundColor White
        Write-Host ""
        Write-Host "Or if you have the key without extension:" -ForegroundColor Cyan
        Write-Host "ssh -i `"C:\Users\NAUFAL\Downloads\sismod`" $EC2User@$EC2IP" -ForegroundColor White
        Write-Host ""
        Write-Host "Deployment commands to run after connecting:" -ForegroundColor Yellow
        Write-Host "cd ~" -ForegroundColor White
        Write-Host "git clone https://github.com/Nexuszzz/sudahtapibelum.git" -ForegroundColor White
        Write-Host "cd sudahtapibelum" -ForegroundColor White
        Write-Host "chmod +x deploy-to-ec2.sh" -ForegroundColor White
        Write-Host "./deploy-to-ec2.sh" -ForegroundColor White
        Write-Host ""
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
