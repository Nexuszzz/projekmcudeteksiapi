#!/bin/bash

# 📤 Upload Model YOLO ke EC2
# Jalankan di komputer lokal (Git Bash atau WSL)

echo "============================================"
echo "📤 Upload YOLO Model to EC2"
echo "============================================"
echo ""

# Warna
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Konfigurasi
EC2_IP="YOUR_EC2_PUBLIC_IP"  # Ganti dengan IP EC2 Anda
PEM_FILE="YOUR_KEY.pem"       # Ganti dengan path ke file .pem Anda
LOCAL_MODEL_PATH="D:/zakaiot/fire_yolov8s_ultra_best.pt"
EC2_DEST_PATH="/home/ubuntu/sudahtapibelum/python_scripts/"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "   EC2 IP: $EC2_IP"
echo "   PEM File: $PEM_FILE"
echo "   Model: $LOCAL_MODEL_PATH"
echo ""

# Check if PEM file exists
if [ ! -f "$PEM_FILE" ]; then
    echo -e "${RED}❌ PEM file not found: $PEM_FILE${NC}"
    echo "   Please update PEM_FILE in this script"
    exit 1
fi

# Check if model exists
if [ ! -f "$LOCAL_MODEL_PATH" ]; then
    echo -e "${RED}❌ Model file not found: $LOCAL_MODEL_PATH${NC}"
    echo "   Please update LOCAL_MODEL_PATH in this script"
    exit 1
fi

# Upload model
echo -e "${YELLOW}📤 Uploading model to EC2...${NC}"
scp -i "$PEM_FILE" "$LOCAL_MODEL_PATH" "ubuntu@$EC2_IP:$EC2_DEST_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Model uploaded successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo "   1. SSH to EC2: ssh -i $PEM_FILE ubuntu@$EC2_IP"
    echo "   2. Verify model: ls -lh $EC2_DEST_PATH"
    echo "   3. Start fire detection: pm2 start fire_detect_record_ultimate.py --interpreter python3"
else
    echo ""
    echo -e "${RED}❌ Upload failed!${NC}"
    echo "   Please check your EC2 IP and PEM file"
    exit 1
fi

echo ""
echo "============================================"
