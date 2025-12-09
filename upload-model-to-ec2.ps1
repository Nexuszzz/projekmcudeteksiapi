# 📤 Upload Model YOLO ke EC2 (PowerShell Version)
# Jalankan di PowerShell di komputer lokal

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📤 Upload YOLO Model to EC2" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Konfigurasi
$EC2_IP = "YOUR_EC2_PUBLIC_IP"  # Ganti dengan IP EC2 Anda
$PEM_FILE = "YOUR_KEY.pem"      # Ganti dengan path ke file .pem Anda
$LOCAL_MODEL_PATH = "D:\zakaiot\fire_yolov8s_ultra_best.pt"
$EC2_DEST_PATH = "/home/ubuntu/sudahtapibelum/python_scripts/"

Write-Host "📋 Configuration:" -ForegroundColor Yellow
Write-Host "   EC2 IP: $EC2_IP"
Write-Host "   PEM File: $PEM_FILE"
Write-Host "   Model: $LOCAL_MODEL_PATH"
Write-Host ""

# Check if model exists
if (-Not (Test-Path $LOCAL_MODEL_PATH)) {
    Write-Host "❌ Model file not found: $LOCAL_MODEL_PATH" -ForegroundColor Red
    Write-Host "   Please update LOCAL_MODEL_PATH in this script" -ForegroundColor Red
    exit 1
}

# Check if PEM file exists
if (-Not (Test-Path $PEM_FILE)) {
    Write-Host "❌ PEM file not found: $PEM_FILE" -ForegroundColor Red
    Write-Host "   Please update PEM_FILE in this script" -ForegroundColor Red
    exit 1
}

# Upload using WinSCP or PSCP
Write-Host "📤 Uploading model to EC2..." -ForegroundColor Yellow
Write-Host ""

# Check if pscp is available (from PuTTY)
$pscpPath = "C:\Program Files\PuTTY\pscp.exe"
if (Test-Path $pscpPath) {
    Write-Host "Using PSCP (PuTTY)..." -ForegroundColor Cyan
    & $pscpPath -i $PEM_FILE $LOCAL_MODEL_PATH "ubuntu@${EC2_IP}:${EC2_DEST_PATH}"
} else {
    Write-Host "⚠️  PSCP not found. Please use one of these methods:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Method 1: Install PuTTY (includes PSCP)" -ForegroundColor Cyan
    Write-Host "   Download: https://www.putty.org/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Method 2: Use WinSCP (GUI)" -ForegroundColor Cyan
    Write-Host "   Download: https://winscp.net/" -ForegroundColor Cyan
    Write-Host "   Then manually upload: $LOCAL_MODEL_PATH" -ForegroundColor Cyan
    Write-Host "   To: ubuntu@${EC2_IP}:${EC2_DEST_PATH}" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Method 3: Use Git Bash with SCP" -ForegroundColor Cyan
    Write-Host "   Run: scp -i `"$PEM_FILE`" `"$LOCAL_MODEL_PATH`" ubuntu@${EC2_IP}:${EC2_DEST_PATH}" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Model uploaded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Yellow
    Write-Host "   1. SSH to EC2 using PuTTY" -ForegroundColor Cyan
    Write-Host "   2. Verify model: ls -lh $EC2_DEST_PATH" -ForegroundColor Cyan
    Write-Host "   3. Start fire detection: pm2 start fire_detect_record_ultimate.py --interpreter python3" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Upload failed!" -ForegroundColor Red
    Write-Host "   Please check your EC2 IP and PEM file" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
