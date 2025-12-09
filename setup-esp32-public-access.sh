#!/bin/bash

# 🔥 Setup ESP32-CAM Access via Port Forwarding
# Panduan untuk setup port forwarding di router

echo "============================================"
echo "🌐 ESP32-CAM Public Access Setup Guide"
echo "============================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}📋 What you need:${NC}"
echo "   ✓ ESP32-CAM running and connected to WiFi"
echo "   ✓ Access to your router admin panel"
echo "   ✓ Your home's public IP address"
echo ""

# Get ESP32 local IP
echo -e "${YELLOW}1️⃣  Find your ESP32-CAM local IP:${NC}"
echo "   Option 1: Check your router's DHCP client list"
echo "   Option 2: Use IP scanner (Advanced IP Scanner, Angry IP Scanner)"
echo "   Option 3: Check ESP32 serial monitor when it boots"
echo ""
echo "   Example: 192.168.1.100"
echo ""

# Get public IP
echo -e "${YELLOW}2️⃣  Find your home's public IP:${NC}"
echo "   Visit: https://whatismyipaddress.com/"
echo "   Or run: curl ifconfig.me"
echo ""
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null)
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "   ${GREEN}Your public IP: $PUBLIC_IP${NC}"
else
    echo "   Your public IP: (check website above)"
fi
echo ""

# Router setup
echo -e "${YELLOW}3️⃣  Setup Port Forwarding in Router:${NC}"
echo ""
echo "   A. Login to router admin panel:"
echo "      - Common addresses: 192.168.1.1 or 192.168.0.1"
echo "      - Default credentials (check router sticker)"
echo ""
echo "   B. Find Port Forwarding / Virtual Server menu:"
echo "      - Usually under: Advanced → NAT → Port Forwarding"
echo "      - Or: Security → Port Forwarding"
echo ""
echo "   C. Add new rule:"
echo "      ┌─────────────────────────────────────────┐"
echo "      │ Service Name:    ESP32-CAM              │"
echo "      │ External Port:   8080                   │"
echo "      │ Internal IP:     192.168.1.100          │"
echo "      │ Internal Port:   80                     │"
echo "      │ Protocol:        TCP                    │"
echo "      │ Status:          Enabled                │"
echo "      └─────────────────────────────────────────┘"
echo ""
echo "   D. Save and restart router (if needed)"
echo ""

# Test access
echo -e "${YELLOW}4️⃣  Test ESP32-CAM access:${NC}"
echo ""
echo "   From LOCAL network:"
echo -e "   ${CYAN}http://192.168.1.100/stream${NC}"
echo ""
echo "   From INTERNET (anywhere):"
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "   ${GREEN}http://$PUBLIC_IP:8080/stream${NC}"
else
    echo "   http://YOUR_PUBLIC_IP:8080/stream"
fi
echo ""
echo "   ✓ If you see video stream = SUCCESS! ✅"
echo ""

# Security warning
echo -e "${RED}⚠️  SECURITY WARNING:${NC}"
echo "   - Your ESP32 is now accessible from internet"
echo "   - Add password protection to ESP32 web server"
echo "   - Consider using VPN for secure access"
echo "   - Or use Ngrok for temporary/testing access"
echo ""

# Alternative: Ngrok
echo -e "${YELLOW}5️⃣  Alternative: Use Ngrok (easier for testing)${NC}"
echo ""
echo "   A. Download Ngrok: https://ngrok.com/download"
echo ""
echo "   B. Run on computer in same network as ESP32:"
echo -e "      ${CYAN}ngrok http http://192.168.1.100:80${NC}"
echo ""
echo "   C. Copy the HTTPS URL (e.g., https://abc123.ngrok.io)"
echo ""
echo "   D. Use in EC2:"
echo -e "      ${CYAN}ESP32_CAM_STREAM=https://abc123.ngrok.io/stream${NC}"
echo ""
echo "   ⚠️  Note: Free Ngrok URL changes on restart"
echo ""

# EC2 Configuration
echo -e "${YELLOW}6️⃣  Configure EC2 Environment:${NC}"
echo ""
echo "   Edit .env file in EC2:"
echo -e "   ${CYAN}nano ~/sudahtapibelum/python_scripts/.env${NC}"
echo ""
echo "   Add/Update:"
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "   ${GREEN}ESP32_CAM_STREAM=http://$PUBLIC_IP:8080/stream${NC}"
else
    echo "   ESP32_CAM_STREAM=http://YOUR_PUBLIC_IP:8080/stream"
fi
echo "   ESP32_CAM_IP=192.168.1.100"
echo ""
echo "   Save (Ctrl+X, Y, Enter)"
echo ""

# Final test
echo -e "${YELLOW}7️⃣  Test Fire Detection:${NC}"
echo ""
echo "   Start fire detection on EC2:"
echo -e "   ${CYAN}cd ~/sudahtapibelum/python_scripts${NC}"
echo -e "   ${CYAN}pm2 start fire_detect_record_ultimate.py --name fire-detection --interpreter python3${NC}"
echo ""
echo "   Monitor logs:"
echo -e "   ${CYAN}pm2 logs fire-detection${NC}"
echo ""
echo "   You should see: ✅ Connected to ESP32-CAM stream"
echo ""

echo "============================================"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "============================================"
echo ""
echo -e "${CYAN}📝 Summary:${NC}"
echo "   1. Port forward 8080 → ESP32 IP:80"
if [ ! -z "$PUBLIC_IP" ]; then
    echo "   2. Access: http://$PUBLIC_IP:8080/stream"
else
    echo "   2. Access: http://YOUR_PUBLIC_IP:8080/stream"
fi
echo "   3. Configure EC2 .env with stream URL"
echo "   4. Start PM2 fire detection service"
echo ""
