# 🚀 Panduan Deploy ke AWS EC2 dengan PuTTY

## 📋 Persiapan Sebelum Deploy

### 1. Yang Harus Disiapkan di AWS:
- ✅ Instance EC2 sudah running (Ubuntu 20.04/22.04 recommended)
- ✅ Security Group sudah dikonfigurasi:
  - **Port 22** (SSH) - untuk PuTTY
  - **Port 80** (HTTP) - untuk web
  - **Port 443** (HTTPS) - untuk SSL (opsional)
  - **Port 8080** - untuk proxy server
  - **Port 5000** - untuk Python scripts
  - **Port 1883** - untuk MQTT (jika digunakan)
- ✅ Elastic IP (recommended agar IP tidak berubah)
- ✅ File `.pem` key pair sudah diunduh

### 2. Convert .pem ke .ppk untuk PuTTY:
1. Download **PuTTYgen** (https://www.putty.org/)
2. Buka PuTTYgen
3. Click **Load** → pilih file `.pem` Anda
4. Click **Save private key** → simpan sebagai `.ppk`

---

## 🔧 Step 1: Connect ke EC2 dengan PuTTY

### Cara Connect:
1. Buka **PuTTY**
2. Masukkan:
   - **Host Name:** `ubuntu@YOUR_EC2_PUBLIC_IP`
   - **Port:** `22`
3. Di sidebar kiri: **Connection → SSH → Auth**
4. Browse dan pilih file `.ppk` Anda
5. Kembali ke **Session** → Save session (beri nama, misal: "MyEC2")
6. Click **Open**

✅ Jika berhasil, Anda akan masuk ke terminal EC2!

---

## 📦 Step 2: Install Dependencies di EC2

Jalankan script ini di terminal EC2:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python 3 dan pip
sudo apt install -y python3 python3-pip

# Install PM2 (untuk keep server running 24/7)
sudo npm install -g pm2

# Install Git (untuk clone project)
sudo apt install -y git

# Install Nginx (sebagai reverse proxy)
sudo apt install -y nginx

# Verify installations
node -v
npm -v
python3 --version
pm2 -v
```

---

## 📂 Step 3: Upload Project ke EC2

### Opsi A: Upload via GitHub (RECOMMENDED)

1. **Push project ke GitHub:**
   ```bash
   # Di komputer lokal (PowerShell)
   cd d:\rtsp-main
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Clone di EC2:**
   ```bash
   # Di EC2 terminal
   cd ~
   git clone https://github.com/Nexuszzz/sudahtapibelum.git
   cd sudahtapibelum
   ```

### Opsi B: Upload via WinSCP

1. Download **WinSCP** (https://winscp.net/)
2. Login dengan:
   - **Protocol:** SFTP
   - **Host:** Your EC2 Public IP
   - **Username:** ubuntu
   - **Private key:** Your `.ppk` file
3. Drag & drop folder `rtsp-main` ke `/home/ubuntu/`

---

## 🔨 Step 4: Setup Project di EC2

```bash
cd ~/sudahtapibelum  # atau ~/rtsp-main

# Install Node.js dependencies
npm install
cd proxy-server
npm install
cd ..

# Install Python dependencies
cd python_scripts
pip3 install -r requirements.txt
cd ..

# Build React frontend
npm run build
```

---

## ⚙️ Step 5: Setup Environment Variables

```bash
# Buat file .env untuk proxy server
cd ~/sudahtapibelum/proxy-server
nano .env
```

Isi dengan:
```env
PORT=8080
NODE_ENV=production
JWT_SECRET=YOUR_SUPER_SECRET_KEY_HERE_CHANGE_THIS
MQTT_BROKER=mqtt://localhost:1883
WHATSAPP_API_URL=http://localhost:3001
```

Tekan `Ctrl+X` → `Y` → `Enter` untuk save.

---

## 🚀 Step 6: Start Services dengan PM2

### 1. Start Proxy Server:
```bash
cd ~/sudahtapibelum/proxy-server
pm2 start server.js --name "proxy-server"
```

### 2. Start Python Fire Detection:
```bash
cd ~/sudahtapibelum/python_scripts
pm2 start fire_detect_record_ultimate.py --name "fire-detection" --interpreter python3
```

### 3. Save PM2 configuration:
```bash
pm2 save
pm2 startup
# Copy dan jalankan command yang muncul
```

### 4. Monitor services:
```bash
pm2 status
pm2 logs
pm2 monit
```

---

## 🌐 Step 7: Setup Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/fire-detection
```

Isi dengan:
```nginx
server {
    listen 80;
    server_name YOUR_EC2_PUBLIC_IP;  # Atau domain Anda

    # Serve React frontend
    location / {
        root /home/ubuntu/sudahtapibelum/dist;
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Proxy WebSocket
    location /socket.io/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
    }
}
```

Enable dan restart Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/fire-detection /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl restart nginx
```

---

## 🔥 Step 8: Test Deployment

1. **Akses web:** `http://YOUR_EC2_PUBLIC_IP`
2. **Test login:** Login dengan `admin` / `admin123`
3. **Check logs:**
   ```bash
   pm2 logs proxy-server
   pm2 logs fire-detection
   ```

---

## 📊 Monitoring & Maintenance

### PM2 Commands:
```bash
pm2 status              # Lihat status semua services
pm2 restart all         # Restart semua services
pm2 stop all            # Stop semua services
pm2 logs                # Lihat logs real-time
pm2 monit              # Monitor CPU/Memory usage
pm2 delete all          # Hapus semua services
```

### Update Code:
```bash
cd ~/sudahtapibelum
git pull origin main
npm run build
pm2 restart all
```

---

## 🛡️ Security Checklist

- [ ] Ganti password default admin
- [ ] Update `JWT_SECRET` di `.env`
- [ ] Setup firewall:
  ```bash
  sudo ufw allow 22
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw enable
  ```
- [ ] Nonaktifkan password login SSH (gunakan key saja)
- [ ] Setup SSL dengan Let's Encrypt (opsional)

---

## 🔧 Troubleshooting

### Port sudah digunakan:
```bash
sudo lsof -i :8080
sudo kill -9 <PID>
pm2 restart proxy-server
```

### Service tidak jalan:
```bash
pm2 logs <service-name>
pm2 describe <service-name>
```

### Nginx error:
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

---

## 📞 Support

Jika ada masalah:
1. Check PM2 logs: `pm2 logs`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Restart services: `pm2 restart all`

---

**🎉 Selamat! Web Anda sudah live di EC2!**

Akses: `http://YOUR_EC2_PUBLIC_IP`
