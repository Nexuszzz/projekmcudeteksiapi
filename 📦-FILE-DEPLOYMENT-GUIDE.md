# 📦 DAFTAR FILE DEPLOYMENT

## ✅ File-file yang Sudah Dibuat untuk Deployment

### 🎯 File Utama (MULAI DARI SINI!)

1. **DEPLOY-QUICK-START.bat** ⭐⭐⭐
   - **Fungsi:** Menu utama deployment dengan pilihan cepat
   - **Kapan digunakan:** PERTAMA KALI sebelum deploy
   - **Features:**
     - Launch interactive menu
     - Open documentation
     - Open PuTTY untuk connect
     - Open WinSCP untuk upload
     - Test deployment
   - **Cara pakai:** Double-click aja!

2. **START-DEPLOYMENT.bat** ⭐⭐
   - **Fungsi:** Menu interaktif lengkap dengan 8 opsi
   - **Kapan digunakan:** Untuk guide step-by-step deployment
   - **Features:**
     - Cek prerequisites (Node.js, PuTTY, WinSCP)
     - Guide prepare files
     - Auto-open PuTTY & WinSCP
     - Command reference untuk deploy
     - Testing tools
   - **Cara pakai:** Dipanggil dari DEPLOY-QUICK-START.bat atau run manual

3. **DEPLOY-NOW.bat**
   - **Fungsi:** Script deployment sederhana (versi lama)
   - **Kapan digunakan:** Alternatif jika mau simple
   - **Cara pakai:** Double-click

---

### 📖 Dokumentasi Lengkap

1. **README-DEPLOYMENT.md** ⭐⭐⭐
   - **Fungsi:** Quick reference untuk deployment
   - **Isi:**
     - 3 langkah deploy
     - Quick commands
     - Checklist
     - Troubleshooting singkat
   - **Baca:** Sebelum deploy untuk overview

2. **🎉-DEPLOYMENT-READY.md** ⭐⭐⭐
   - **Fungsi:** Panduan lengkap deployment dengan detail
   - **Isi:**
     - Step-by-step deployment
     - Monitoring & management
     - Troubleshooting detail
     - Update code workflow
     - Checklist lengkap
   - **Baca:** Untuk panduan detail

3. **DEPLOY-TO-3.27.0.139.md** ⭐⭐
   - **Fungsi:** Panduan spesifik untuk IP 3.27.0.139
   - **Isi:**
     - Quick start 5 langkah
     - AWS Security Group setup
     - Monitoring commands
     - Troubleshooting
     - ESP32-CAM configuration
   - **Baca:** Untuk detail teknis IP ini

4. **🚀-DEPLOY-EC2-GUIDE.md**
   - **Fungsi:** Guide umum deployment EC2
   - **Isi:** Panduan deployment umum untuk EC2

5. **QUICK-START-EC2.md**
   - **Fungsi:** Quick start 10 menit deployment
   - **Isi:** Panduan cepat deployment

---

### 🔧 Script Deployment (Dijalankan di EC2)

1. **deploy-to-ec2.sh** ⭐⭐⭐
   - **Fungsi:** Auto deployment script untuk EC2
   - **Dijalankan di:** EC2 server (via PuTTY)
   - **Yang dilakukan:**
     - Install Node.js 18.x
     - Install Python 3 + pip
     - Install PM2 (process manager)
     - Install Nginx (web server)
     - Clone/pull repository
     - Install dependencies (npm + pip)
     - Build React frontend
     - Configure Nginx
     - Start services dengan PM2
     - Setup firewall (UFW)
     - Auto-start on boot
   - **Cara jalankan:**
     ```bash
     cd /home/ubuntu/sudahtapibelum
     chmod +x deploy-to-ec2.sh
     ./deploy-to-ec2.sh
     ```
   - **Waktu:** 10-15 menit

2. **ecosystem.config.json**
   - **Fungsi:** PM2 configuration untuk manage services
   - **Services yang diatur:**
     - proxy-server (Express backend)
     - whatsapp-server (WhatsApp integration)
     - voice-call-server (Twilio voice calls)
   - **Digunakan oleh:** PM2 saat `pm2 start ecosystem.config.json`

3. **requirements.txt**
   - **Fungsi:** List Python dependencies
   - **Packages:**
     - opencv-python (computer vision)
     - ultralytics (YOLO)
     - google-generativeai (Gemini AI)
     - paho-mqtt (MQTT client)
     - requests
     - python-dotenv
   - **Digunakan:** `pip3 install -r requirements.txt`

---

### 📁 File Konfigurasi

1. **python_scripts/.env.production**
   - **Fungsi:** Production environment variables
   - **Berisi:**
     - Gemini API key
     - EC2 URLs
     - ESP32-CAM config
     - MQTT settings

2. **proxy-server/.env** (akan dibuat di EC2)
   - **Fungsi:** Backend environment variables
   - **Berisi:**
     - PORT=8080
     - JWT_SECRET (auto-generated)
     - MQTT_BROKER
     - WHATSAPP_API_URL

---

## 🎯 Workflow Deployment

### Step 1: Persiapan (Di Windows)

```
1. Double-click: DEPLOY-QUICK-START.bat
2. Pilih opsi [2] untuk baca dokumentasi
3. Pilih opsi [1] untuk launch interactive menu
```

### Step 2: Upload Files

**Opsi A: Git Clone (Recommended)**
```bash
# Di EC2 via PuTTY:
cd ~
git clone https://github.com/Nexuszzz/sudahtapibelum.git
cd sudahtapibelum
```

**Opsi B: WinSCP**
```
1. DEPLOY-QUICK-START.bat → [4] Open WinSCP
2. Login: 3.27.0.139, ubuntu, .pem key
3. Upload folder ke: /home/ubuntu/sudahtapibelum
```

### Step 3: Deploy (Di EC2)

```bash
cd /home/ubuntu/sudahtapibelum
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

### Step 4: Test

```
1. DEPLOY-QUICK-START.bat → [5] Test Deployment
2. Atau buka browser: http://3.27.0.139
3. Login: admin / admin123
```

---

## 📊 Struktur Setelah Deploy

```
/home/ubuntu/sudahtapibelum/
├── src/                      # React source
├── proxy-server/            # Express backend
│   ├── server.js
│   ├── .env                 # Auto-generated
│   └── routes/
├── python_scripts/          # Python fire detection
│   ├── fire_detect_record_ultimate.py
│   ├── .env.production
│   └── requirements.txt
├── dist/                    # Built React (nginx serves this)
├── node_modules/           # Node dependencies
├── deploy-to-ec2.sh        # Deployment script
├── ecosystem.config.json   # PM2 config
└── package.json
```

---

## 🔄 Update Workflow

### Update Code dari Local

```bash
# 1. Di local Windows
cd d:\rtsp-main
git add .
git commit -m "Update features"
git push origin main

# 2. Di EC2 via PuTTY
cd ~/sudahtapibelum
git pull origin main
npm install              # Install new dependencies
npm run build            # Rebuild frontend
pm2 restart all          # Restart services
```

---

## 📱 Services Management

### PM2 Commands

```bash
# Status
pm2 status

# Logs (real-time)
pm2 logs
pm2 logs proxy-server
pm2 logs fire-detection

# Restart
pm2 restart all
pm2 restart proxy-server

# Monitor CPU/Memory
pm2 monit

# Stop
pm2 stop all
pm2 delete all
```

### Nginx Commands

```bash
# Status
sudo systemctl status nginx

# Test config
sudo nginx -t

# Restart
sudo systemctl restart nginx

# Reload (no downtime)
sudo systemctl reload nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 🐛 Troubleshooting

### Website tidak bisa diakses

**Cek 1: Security Group**
```
AWS Console → EC2 → Security Group
Pastikan port 80 allow 0.0.0.0/0
```

**Cek 2: Nginx**
```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl restart nginx
```

**Cek 3: Firewall**
```bash
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443
```

### API Error 404/500

**Cek proxy-server:**
```bash
pm2 logs proxy-server --lines 50
pm2 restart proxy-server
curl http://localhost:8080/api/health
```

### Fire Detection Tidak Jalan

**Cek Python service:**
```bash
pm2 logs fire-detection --lines 50
pm2 restart fire-detection

# Test Python
cd ~/sudahtapibelum/python_scripts
python3 fire_detect_record_ultimate.py
```

**Cek dependencies:**
```bash
pip3 list | grep -E "opencv|ultralytics|google"
```

---

## ✅ Checklist Lengkap

### Pre-Deployment
- [ ] PuTTY installed
- [ ] WinSCP installed  
- [ ] File .pem key tersedia
- [ ] AWS Security Group allow port 22, 80, 443
- [ ] Code sudah di-push ke GitHub

### Deployment
- [ ] Files sudah di EC2
- [ ] `deploy-to-ec2.sh` berhasil dijalankan
- [ ] Node.js, Python, PM2, Nginx installed
- [ ] Dependencies installed
- [ ] Frontend built (dist/ folder ada)
- [ ] Nginx configured
- [ ] PM2 services running
- [ ] Firewall configured

### Testing
- [ ] Website accessible (http://3.27.0.139)
- [ ] Login works (admin/admin123)
- [ ] Dashboard loads
- [ ] Navigation works
- [ ] Real-time data updates
- [ ] API calls work
- [ ] Fire detection status visible

### Post-Deployment
- [ ] Password admin diganti
- [ ] ESP32-CAM IP updated
- [ ] Auto-start enabled (`pm2 save`, `pm2 startup`)
- [ ] Monitoring setup (optional: CloudWatch)
- [ ] Backup script configured (optional)

---

## 📞 Quick Reference

### Connect to EC2
```bash
ssh -i "path/to/key.pem" ubuntu@3.27.0.139
```

### One-line Deploy
```bash
cd /home/ubuntu/sudahtapibelum && chmod +x deploy-to-ec2.sh && ./deploy-to-ec2.sh
```

### Check Everything
```bash
pm2 status && sudo systemctl status nginx && df -h && free -h
```

### Restart Everything
```bash
pm2 restart all && sudo systemctl restart nginx
```

---

## 🎉 Summary

**File yang HARUS dijalankan:**
1. ⭐ **DEPLOY-QUICK-START.bat** (di Windows)
2. ⭐ **deploy-to-ec2.sh** (di EC2)

**File yang HARUS dibaca:**
1. ⭐ **README-DEPLOYMENT.md** (quick guide)
2. ⭐ **🎉-DEPLOYMENT-READY.md** (complete guide)

**Result:**
- Website live di: http://3.27.0.139
- Login: admin/admin123
- Services: PM2 manages all
- Web server: Nginx
- Auto-start: Enabled

---

**Happy Deployment! 🚀🔥**

Jika ada pertanyaan, cek dokumentasi lengkap atau lihat logs:
```bash
pm2 logs
```
