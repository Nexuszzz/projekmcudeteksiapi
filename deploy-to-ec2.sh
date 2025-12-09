#!/bin/bash

# 🚀 EC2 Auto Deployment Script
# Jalankan script ini setelah connect ke EC2 via PuTTY

echo "============================================"
echo "🚀 Fire Detection System - Auto Deployment"
echo "============================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Update system
echo -e "${YELLOW}📦 Step 1: Updating system...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}✅ System updated!${NC}"
echo ""

# Step 2: Install Node.js
echo -e "${YELLOW}📦 Step 2: Installing Node.js 18.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
echo -e "${GREEN}✅ Node.js installed: $(node -v)${NC}"
echo ""

# Step 3: Install Python
echo -e "${YELLOW}📦 Step 3: Installing Python 3 and pip...${NC}"
sudo apt install -y python3 python3-pip python3-venv
echo -e "${GREEN}✅ Python installed: $(python3 --version)${NC}"
echo ""

# Step 4: Install PM2
echo -e "${YELLOW}📦 Step 4: Installing PM2...${NC}"
sudo npm install -g pm2
echo -e "${GREEN}✅ PM2 installed: $(pm2 -v)${NC}"
echo ""

# Step 5: Install Nginx
echo -e "${YELLOW}📦 Step 5: Installing Nginx...${NC}"
sudo apt install -y nginx
echo -e "${GREEN}✅ Nginx installed!${NC}"
echo ""

# Step 6: Install Git
echo -e "${YELLOW}📦 Step 6: Installing Git...${NC}"
sudo apt install -y git
echo -e "${GREEN}✅ Git installed: $(git --version)${NC}"
echo ""

# Step 7: Clone repository
echo -e "${YELLOW}📂 Step 7: Cloning repository...${NC}"
cd ~
if [ -d "sudahtapibelum" ]; then
    echo -e "${YELLOW}Repository already exists, pulling latest changes...${NC}"
    cd sudahtapibelum
    git pull origin main
else
    git clone https://github.com/Nexuszzz/sudahtapibelum.git
    cd sudahtapibelum
fi
echo -e "${GREEN}✅ Repository ready!${NC}"
echo ""

# Step 8: Install Node dependencies
echo -e "${YELLOW}📦 Step 8: Installing Node.js dependencies...${NC}"
npm install
cd proxy-server
npm install
cd ..
echo -e "${GREEN}✅ Node dependencies installed!${NC}"
echo ""

# Step 9: Install Python dependencies
echo -e "${YELLOW}📦 Step 9: Installing Python dependencies...${NC}"
cd python_scripts
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt
else
    echo -e "${RED}⚠️  requirements.txt not found, installing common packages...${NC}"
    pip3 install opencv-python ultralytics google-generativeai paho-mqtt requests python-dotenv
fi
cd ..
echo -e "${GREEN}✅ Python dependencies installed!${NC}"
echo ""

# Step 10: Build frontend
echo -e "${YELLOW}🔨 Step 10: Building React frontend...${NC}"
npm run build
echo -e "${GREEN}✅ Frontend built successfully!${NC}"
echo ""

# Step 11: Setup environment file
echo -e "${YELLOW}⚙️  Step 11: Setting up environment variables...${NC}"
cd proxy-server
if [ ! -f ".env" ]; then
    cat > .env << EOF
PORT=8080
NODE_ENV=production
JWT_SECRET=$(openssl rand -hex 32)
MQTT_BROKER=mqtt://localhost:1883
WHATSAPP_API_URL=http://localhost:3001
EOF
    echo -e "${GREEN}✅ .env file created with secure JWT secret!${NC}"
else
    echo -e "${YELLOW}.env file already exists, skipping...${NC}"
fi
cd ..
echo ""

# Step 12: Configure Nginx
echo -e "${YELLOW}🌐 Step 12: Configuring Nginx...${NC}"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo tee /etc/nginx/sites-available/fire-detection > /dev/null << EOF
server {
    listen 80;
    server_name $PUBLIC_IP;

    # Serve React frontend
    location / {
        root /home/ubuntu/sudahtapibelum/dist;
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy API requests
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Proxy WebSocket
    location /socket.io/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/fire-detection /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
echo -e "${GREEN}✅ Nginx configured and running!${NC}"
echo ""

# Step 13: Start services with PM2
echo -e "${YELLOW}🚀 Step 13: Starting services with PM2...${NC}"
pm2 delete all 2>/dev/null

cd ~/sudahtapibelum/proxy-server
pm2 start server.js --name "proxy-server"

cd ~/sudahtapibelum/python_scripts
pm2 start fire_detect_record_ultimate.py --name "fire-detection" --interpreter python3

pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
echo -e "${GREEN}✅ Services started and configured to auto-start on boot!${NC}"
echo ""

# Step 14: Setup firewall
echo -e "${YELLOW}🛡️  Step 14: Configuring firewall...${NC}"
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable
echo -e "${GREEN}✅ Firewall configured!${NC}"
echo ""

# Done!
echo "============================================"
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
echo "============================================"
echo ""
echo -e "📊 Service Status:"
pm2 status
echo ""
echo -e "🌐 Your website is now live at:"
echo -e "${GREEN}http://$PUBLIC_IP${NC}"
echo ""
echo -e "📝 Useful commands:"
echo "  pm2 status          - Check service status"
echo "  pm2 logs            - View logs"
echo "  pm2 restart all     - Restart all services"
echo "  pm2 monit           - Monitor CPU/Memory"
echo ""
echo -e "🔑 Default login credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Change the admin password after first login!${NC}"
echo ""
