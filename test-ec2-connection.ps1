#!/usr/bin/env pwsh

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " EC2 Connection Setup & Test" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$EC2IP = "3.27.11.106"
$EC2User = "ubuntu"
$KeyPath = "C:\Users\NAUFAL\Downloads"

Write-Host "Searching for SSH keys in Downloads..." -ForegroundColor Yellow
Write-Host ""

# Find all .pem files
$pemFiles = Get-ChildItem "$KeyPath\*.pem" -ErrorAction SilentlyContinue
if ($pemFiles) {
    Write-Host "Found .pem files:" -ForegroundColor Green
    foreach ($file in $pemFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor White
    }
    Write-Host ""
}

# Find all .ppk files
$ppkFiles = Get-ChildItem "$KeyPath\*.ppk" -ErrorAction SilentlyContinue
if ($ppkFiles) {
    Write-Host "Found .ppk files:" -ForegroundColor Green
    foreach ($file in $ppkFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Select connection method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Test connection with .pem file" -ForegroundColor White
Write-Host "  [2] Open PuTTY with sismod.ppk" -ForegroundColor White
Write-Host "  [3] Show manual SSH commands" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice [1-3]"

if ($choice -eq "1") {
    Write-Host ""
    if ($pemFiles.Count -gt 0) {
        Write-Host "Select .pem file:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $pemFiles.Count; $i++) {
            Write-Host "  [$($i+1)] $($pemFiles[$i].Name)" -ForegroundColor White
        }
        Write-Host ""
        $pemChoice = Read-Host "Enter number"
        
        $selectedPem = $pemFiles[$pemChoice - 1]
        if ($selectedPem) {
            $keyFile = $selectedPem.FullName
            Write-Host ""
            Write-Host "Testing connection with: $($selectedPem.Name)" -ForegroundColor Yellow
            Write-Host ""
            
            # Test connection
            Write-Host "Connecting to $EC2User@$EC2IP..." -ForegroundColor Cyan
            Write-Host ""
            
            $testCmd = "echo 'Connected successfully!'; uname -a; uptime"
            ssh -i $keyFile -o "StrictHostKeyChecking=no" "$EC2User@$EC2IP" $testCmd
            
            Write-Host ""
            Write-Host "============================================" -ForegroundColor Green
            Write-Host "Connection test complete!" -ForegroundColor Green
            Write-Host "============================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Ready to deploy! Run this command:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host ".\auto-deploy-vscode.ps1 -KeyFile '$keyFile'" -ForegroundColor Cyan
            Write-Host ""
        }
    } else {
        Write-Host "No .pem files found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "You need to convert sismod.ppk to .pem:" -ForegroundColor Yellow
        Write-Host "1. Open PuTTYgen" -ForegroundColor White
        Write-Host "2. Load sismod.ppk" -ForegroundColor White
        Write-Host "3. Conversions > Export OpenSSH key" -ForegroundColor White
        Write-Host "4. Save as sismod.pem" -ForegroundColor White
    }
}
elseif ($choice -eq "2") {
    Write-Host ""
    $puttyPath = "C:\Program Files\PuTTY\putty.exe"
    if (-not (Test-Path $puttyPath)) {
        $puttyPath = "C:\Program Files (x86)\PuTTY\putty.exe"
    }
    
    if (Test-Path $puttyPath) {
        $ppkFile = "$KeyPath\sismod.ppk"
        if (Test-Path $ppkFile) {
            Write-Host "Opening PuTTY..." -ForegroundColor Yellow
            Write-Host "Host: $EC2User@$EC2IP" -ForegroundColor White
            Write-Host ""
            
            Start-Process $puttyPath -ArgumentList "-ssh","$EC2User@$EC2IP","-i",$ppkFile
            
            Write-Host "PuTTY opened!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Run these commands after connecting:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "cd ~" -ForegroundColor Cyan
            Write-Host "git clone https://github.com/Nexuszzz/sudahtapibelum.git" -ForegroundColor Cyan
            Write-Host "cd sudahtapibelum" -ForegroundColor Cyan
            Write-Host "chmod +x deploy-to-ec2.sh" -ForegroundColor Cyan
            Write-Host "./deploy-to-ec2.sh" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "sismod.ppk not found at: $ppkFile" -ForegroundColor Red
        }
    } else {
        Write-Host "PuTTY not found!" -ForegroundColor Red
        Write-Host "Download from: https://www.putty.org/" -ForegroundColor Yellow
    }
}
elseif ($choice -eq "3") {
    Write-Host ""
    Write-Host "Manual SSH Connection Commands:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If you have .pem file:" -ForegroundColor Cyan
    Write-Host 'ssh -i "C:\Users\NAUFAL\Downloads\sismod.pem" ubuntu@3.27.11.106' -ForegroundColor White
    Write-Host ""
    Write-Host "Deployment commands:" -ForegroundColor Cyan
    Write-Host "cd ~" -ForegroundColor White
    Write-Host "git clone https://github.com/Nexuszzz/sudahtapibelum.git" -ForegroundColor White
    Write-Host "cd sudahtapibelum" -ForegroundColor White
    Write-Host "chmod +x deploy-to-ec2.sh" -ForegroundColor White
    Write-Host "./deploy-to-ec2.sh" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
