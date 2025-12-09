# 🔥 Fire Detection di EC2 - Complete Guide

## 📋 Overview

Untuk menjalankan fire detection di EC2, ada 2 komponen utama:
1. **ESP32-CAM** - Tetap di lokasi (rumah/kantor) untuk streaming video
2. **Python Script** - Jalan di EC2 untuk processing & detection

---

## 🎯 Arsitektur Sistem

```
┌─────────────────┐
│   ESP32-CAM     │ ◄─── Di rumah/lokasi
│  (192.168.1.x)  │
└────────┬────────┘
         │ WiFi
         │
┌────────▼────────┐
│  Router + Port  │
│   Forwarding    │ ◄─── Port 8080 → ESP32:80
└────────┬────────┘
         │ Internet
         │
    ┌────▼──────┐
    │ Internet  │
    └────┬──────┘
         │
┌────────▼─────────────────┐
│    AWS EC2 Instance      │
│                          │
│  ┌──────────────────┐   │
│  │ Python Script    │   │ ◄─── Akses ESP32 via public IP
│  │ Fire Detection   │   │
│  └──────────────────┘   │
│                          │
│  ┌──────────────────┐   │
│  │ Node.js Server   │   │
│  │ Web Dashboard    │   │
│  └──────────────────┘   │
└──────────────────────────┘
         │
    ┌────▼──────┐
    │  Users    │ ◄─── Akses dashboard via browser
    └───────────┘
```

---

## 🚀 Step-by-Step Setup

### **Step 1: Setup ESP32-CAM untuk Public Access**

#### Opsi A: Port Forwarding (Permanent, Free)

1. **Cari IP lokal ESP32-CAM:**
   - Buka router → DHCP Client List
   - Atau gunakan IP Scanner
   - Contoh: `192.168.1.100`

2. **Cari Public IP rumah Anda:**
   ```bash
   # Buka browser
   https://whatismyipaddress.com/
   # Atau di terminal
   curl ifconfig.me
   ```

3. **Setup Port Forwarding di Router:**
   - Login router (biasanya 192.168.1.1)
   - Menu: Advanced → Port Forwarding
   - Tambah rule:
     ```
     Service Name:  ESP32-CAM
     External Port: 8080
     Internal IP:   192.168.1.100  (IP ESP32 Anda)
     Internal Port: 80
     Protocol:      TCP
     ```
   - Save & Restart router

4. **Test dari internet:**
   ```
   http://YOUR_PUBLIC_IP:8080/stream
   ```
   ✅ Jika muncul video = berhasil!

**Script helper tersedia:** `setup-esp32-public-access.sh`

---

#### Opsi B: Ngrok (Easy, untuk Testing)

```bash
# Di komputer yang satu jaringan dengan ESP32

# Download Ngrok: https://ngrok.com/download

# Jalankan
ngrok http http://192.168.1.100:80

# Copy HTTPS URL yang muncul
# Example: https://abc123.ngrok.io
```

**Kelebihan:** Super mudah, built-in HTTPS
**Kekurangan:** URL berubah tiap restart (kecuali paid plan)

---

### **Step 2: Upload Model YOLO ke EC2**

Model fire detection perlu di-upload ke EC2.

#### Via PowerShell (Windows):

```powershell
# Edit file upload-model-to-ec2.ps1
# Ganti:
# - YOUR_EC2_PUBLIC_IP → IP EC2 Anda
# - YOUR_KEY.pem → Path ke file .pem Anda

# Jalankan
.\upload-model-to-ec2.ps1
```

#### Via WinSCP (GUI):

1. Download WinSCP: https://winscp.net/
2. Login:
   - Host: Your EC2 IP
   - Username: ubuntu
   - Private key: Your .ppk file
3. Upload file:
   - Local: `D:\zakaiot\fire_yolov8s_ultra_best.pt`
   - Remote: `/home/ubuntu/sudahtapibelum/python_scripts/`

---

### **Step 3: Configure Environment di EC2**

SSH ke EC2 via PuTTY, lalu:

```bash
# Masuk ke directory
cd ~/sudahtapibelum/python_scripts

# Copy template .env
cp .env.production .env

# Edit .env
nano .env
```

**Update values berikut:**

```env
# Ganti YOUR_EC2_PUBLIC_IP dengan IP EC2 Anda
UPLOAD_API=http://YOUR_EC2_PUBLIC_IP:8080/api/video/upload
WEB_LOG_WS_URL=ws://YOUR_EC2_PUBLIC_IP:8080/ws
PROXY_SERVER_URL=http://YOUR_EC2_PUBLIC_IP:8080
WEB_API_URL=http://YOUR_EC2_PUBLIC_IP:8080/api/fire-detection

# Ganti dengan URL ESP32 Anda
# Jika pakai port forwarding:
ESP32_CAM_STREAM=http://YOUR_HOME_PUBLIC_IP:8080/stream

# Jika pakai Ngrok:
# ESP32_CAM_STREAM=https://abc123.ngrok.io/stream

# IP lokal ESP32 (untuk MQTT)
ESP32_CAM_IP=192.168.1.100
```

Save: `Ctrl+X` → `Y` → `Enter`

---

### **Step 4: Deploy ke EC2**

```bash
# Jalankan deployment script
cd ~
./deploy-to-ec2.sh
```

Script akan otomatis:
- ✅ Install dependencies (Python, Node.js, PM2, Nginx)
- ✅ Clone repository dari GitHub
- ✅ Build frontend
- ✅ Setup services
- ✅ Start dengan PM2

---

### **Step 5: Start Fire Detection**

```bash
# Start Python fire detection
cd ~/sudahtapibelum/python_scripts
pm2 start fire_detect_record_ultimate.py --name fire-detection --interpreter python3

# Monitor logs
pm2 logs fire-detection

# Check status
pm2 status
```

**Expected output:**
```
✅ Connected to ESP32-CAM: http://YOUR_IP:8080/stream
✅ Fire detection system started
✅ WebSocket connected to dashboard
```

---

## 📊 Monitoring & Maintenance

### Check Service Status:
```bash
pm2 status
```

### View Logs:
```bash
# Fire detection logs
pm2 logs fire-detection

# Proxy server logs
pm2 logs proxy-server

# All logs
pm2 logs
```

### Restart Services:
```bash
# Restart fire detection only
pm2 restart fire-detection

# Restart all
pm2 restart all
```

### Check Resources:
```bash
# CPU & Memory monitoring
pm2 monit

# Disk usage
df -h

# Free memory
free -h
```

---

## 🔧 Troubleshooting

### 1. ESP32 tidak bisa diakses dari EC2

**Cek:**
```bash
# Di EC2, test akses ESP32
curl http://YOUR_HOME_IP:8080/stream
```

**Solusi:**
- ✓ Pastikan port forwarding sudah benar
- ✓ Cek firewall router
- ✓ Pastikan ESP32 masih online
- ✓ Test dari browser dulu: http://YOUR_PUBLIC_IP:8080/stream

---

### 2. Python script error "Model not found"

**Solusi:**
```bash
# Check model file
ls -lh ~/sudahtapibelum/python_scripts/*.pt

# Jika tidak ada, upload ulang
# Gunakan script: upload-model-to-ec2.ps1
```

---

### 3. WebSocket connection failed

**Solusi:**
```bash
# Check proxy server
pm2 logs proxy-server

# Restart proxy server
pm2 restart proxy-server

# Check port 8080
netstat -tulpn | grep 8080
```

---

### 4. Out of memory

**Solusi:**
```bash
# Check memory
free -h

# Restart services
pm2 restart all

# Consider upgrading EC2 instance type
```

---

## 📝 Update Code dari GitHub

Setelah push code baru:

```bash
cd ~/sudahtapibelum
git pull origin main
npm run build
pm2 restart all
```

Atau gunakan script:
```bash
./update-server.sh
```

---

## 💾 Backup Data

```bash
# Manual backup
./backup-data.sh

# Scheduled backup (crontab)
crontab -e
# Add: 0 2 * * * /home/ubuntu/sudahtapibelum/backup-data.sh
```

---

## 🎯 Quick Reference

### Files Created:

| File | Purpose |
|------|---------|
| `PYTHON-SCRIPT-EC2-SETUP.md` | Detailed Python setup guide |
| `.env.production` | Environment template for EC2 |
| `upload-model-to-ec2.ps1` | PowerShell script upload model |
| `upload-model-to-ec2.sh` | Bash script upload model |
| `setup-esp32-public-access.sh` | Port forwarding guide |
| `deploy-to-ec2.sh` | Auto deployment script |
| `update-server.sh` | Update code script |
| `backup-data.sh` | Backup data script |

---

## 🔐 Security Checklist

- [ ] Ganti default admin password
- [ ] Update JWT_SECRET di .env
- [ ] Enable UFW firewall
- [ ] Setup SSL certificate (optional)
- [ ] Add password protection to ESP32
- [ ] Restrict SSH to your IP only
- [ ] Regular backups enabled

---

## 📞 Need Help?

1. **Check logs first:**
   ```bash
   pm2 logs fire-detection
   pm2 logs proxy-server
   ```

2. **Check system:**
   ```bash
   pm2 status
   free -h
   df -h
   ```

3. **Restart everything:**
   ```bash
   pm2 restart all
   sudo systemctl restart nginx
   ```

---

## ✅ Final Checklist

Sebelum production:

- [ ] ESP32-CAM accessible dari internet
- [ ] Model YOLO sudah di-upload ke EC2
- [ ] .env sudah dikonfigurasi dengan benar
- [ ] PM2 services running (fire-detection + proxy-server)
- [ ] Nginx serving frontend di port 80
- [ ] Dashboard accessible: http://YOUR_EC2_IP
- [ ] Fire detection berfungsi dengan baik
- [ ] Recording tersimpan di server
- [ ] WhatsApp notification working (optional)

---

**🎉 Selamat! Fire Detection System sudah live di cloud!**

Access dashboard: `http://YOUR_EC2_PUBLIC_IP`
