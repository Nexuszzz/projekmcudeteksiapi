#!/bin/bash

# 🔄 Update Script - Jalankan setelah push code baru ke GitHub

echo "============================================"
echo "🔄 Updating Fire Detection System"
echo "============================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Stop services
echo -e "${YELLOW}⏸️  Stopping services...${NC}"
pm2 stop all

# Pull latest code
echo -e "${YELLOW}📥 Pulling latest code...${NC}"
cd ~/sudahtapibelum
git pull origin main

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
npm install
cd proxy-server
npm install
cd ../python_scripts
pip3 install -r requirements.txt
cd ..

# Build frontend
echo -e "${YELLOW}🔨 Building frontend...${NC}"
npm run build

# Restart services
echo -e "${YELLOW}🚀 Restarting services...${NC}"
pm2 restart all

echo ""
echo -e "${GREEN}✅ Update complete!${NC}"
echo ""
pm2 status
