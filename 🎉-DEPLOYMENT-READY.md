# 🎉 DEPLOYMENT FILES READY!

## ✅ File yang Sudah Dibuat

### 📖 Dokumentasi
- **DEPLOY-TO-3.27.0.139.md** - Panduan lengkap deployment ke IP 3.27.0.139
- **🚀-DEPLOY-EC2-GUIDE.md** - Guide umum deployment EC2
- **QUICK-START-EC2.md** - Quick start 10 menit

### 🔧 Script Deployment
- **deploy-to-ec2.sh** - Auto deployment script untuk EC2 (jalankan di server)
- **ecosystem.config.json** - PM2 configuration untuk manage services
- **requirements.txt** - Python dependencies

### 💻 Windows Helper
- **START-DEPLOYMENT.bat** - Menu interaktif untuk deployment (BARU! ⭐)
- **DEPLOY-NOW.bat** - Script deployment sederhana

---

## 🚀 CARA DEPLOY (3 Langkah Mudah)

### Langkah 1: Jalankan START-DEPLOYMENT.bat

```cmd
cd d:\rtsp-main
START-DEPLOYMENT.bat
```

Script ini akan membuka menu interaktif dengan opsi:
1. 📖 Baca Panduan Lengkap
2. 🔍 Cek Prerequisites (Node.js, PuTTY, WinSCP)
3. 📦 Prepare Files untuk Upload
4. 🌐 Connect ke EC2 (PuTTY)
5. 📤 Upload Files (WinSCP)
6. ⚡ Deploy Command Reference
7. 🧪 Test Deployment
8. ❌ Exit

### Langkah 2: Upload Files ke EC2

**Pilih salah satu:**

**A. Via WinSCP (Recommended untuk pemula)**
1. Pilih menu [5] di START-DEPLOYMENT.bat
2. WinSCP akan terbuka otomatis
3. Login dengan:
   - Host: 3.27.0.139
   - User: ubuntu
   - Auth: file .pem Anda
4. Drag folder ke `/home/ubuntu/sudahtapibelum`

**B. Via Git Clone (Lebih cepat)**
1. Connect ke EC2 via PuTTY
2. Jalankan:
```bash
cd ~
git clone https://github.com/Nexuszzz/sudahtapibelum.git
cd sudahtapibelum
```

### Langkah 3: Deploy di EC2

Di terminal EC2 (via PuTTY), jalankan:

```bash
cd /home/ubuntu/sudahtapibelum
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

**Tunggu 10-15 menit** untuk proses instalasi lengkap.

Script akan otomatis:
- ✅ Install Node.js, Python, PM2, Nginx
- ✅ Install semua dependencies
- ✅ Build React frontend
- ✅ Configure Nginx
- ✅ Start services dengan PM2
- ✅ Setup firewall

---

## 🌐 Akses Website

Setelah deployment selesai:

**URL:** http://3.27.0.139

**Login:**
- Username: `admin`
- Password: `admin123`

---

## 🔧 PENTING: Setup AWS Security Group

Sebelum deploy, pastikan Security Group EC2 sudah allow:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | Your IP |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |

**Cara setting:**
1. AWS Console → EC2 → Instances
2. Pilih instance dengan IP 3.27.0.139
3. Tab "Security" → Click Security Group
4. "Edit inbound rules" → Add rules
5. Save rules

---

## 📊 Monitoring Setelah Deploy

### Cek Status Services
```bash
pm2 status
```

Expected output:
```
┌─────┬──────────────────┬─────────┐
│ id  │ name             │ status  │
├─────┼──────────────────┼─────────┤
│ 0   │ proxy-server     │ online  │
│ 1   │ fire-detection   │ online  │
└─────┴──────────────────┴─────────┘
```

### Lihat Logs
```bash
pm2 logs
pm2 logs proxy-server
pm2 logs fire-detection
```

### Restart Services
```bash
pm2 restart all
```

### Cek Nginx
```bash
sudo systemctl status nginx
sudo nginx -t
```

---

## 🐛 Troubleshooting

### Website tidak bisa diakses

**1. Cek Security Group AWS**
- Pastikan port 80 allow 0.0.0.0/0

**2. Cek Nginx**
```bash
sudo systemctl status nginx
sudo systemctl restart nginx
```

**3. Cek PM2**
```bash
pm2 status
pm2 logs --err
```

### API Error 404

```bash
pm2 restart proxy-server
pm2 logs proxy-server
```

### Fire Detection tidak jalan

```bash
pm2 restart fire-detection
pm2 logs fire-detection
```

---

## 🔄 Update Code

Jika update code di local:

```bash
# Di local Windows
cd d:\rtsp-main
git add .
git commit -m "Update code"
git push origin main

# Di EC2
cd ~/sudahtapibelum
git pull origin main
npm install
npm run build
pm2 restart all
```

---

## 📱 Update ESP32-CAM

Setelah deployment, update IP di code ESP32:

```cpp
// Ganti dengan IP EC2
const char* serverUrl = "http://3.27.0.139/api/esp32/capture";
```

Upload ulang code ke ESP32-CAM.

---

## ✅ Checklist Deployment

- [ ] **Pre-Deployment**
  - [ ] Security Group AWS sudah allow port 22, 80, 443
  - [ ] File .pem key tersedia
  - [ ] PuTTY & WinSCP terinstall
  - [ ] Code sudah di-push ke GitHub

- [ ] **Deployment**
  - [ ] Files sudah di-transfer ke EC2
  - [ ] Script `deploy-to-ec2.sh` berhasil dijalankan
  - [ ] PM2 services running
  - [ ] Nginx serving files

- [ ] **Testing**
  - [ ] Website bisa diakses di http://3.27.0.139
  - [ ] Login berhasil dengan admin/admin123
  - [ ] Dashboard muncul dengan benar
  - [ ] Real-time data berfungsi

- [ ] **Post-Deployment**
  - [ ] Password admin sudah diganti
  - [ ] ESP32-CAM IP sudah diupdate
  - [ ] Auto-start services enabled

---

## 📞 Quick Reference Commands

### Connect to EC2
```bash
ssh -i "key.pem" ubuntu@3.27.0.139
```

### Service Management
```bash
pm2 status
pm2 logs
pm2 restart all
pm2 monit
```

### Nginx Management
```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl restart nginx
```

### System Monitoring
```bash
htop
df -h
free -h
```

---

## 🎯 Next Steps

1. ⚡ **Jalankan START-DEPLOYMENT.bat**
   ```cmd
   cd d:\rtsp-main
   START-DEPLOYMENT.bat
   ```

2. 🌐 **Connect ke EC2 via PuTTY**
   - Menu [4] di START-DEPLOYMENT.bat

3. 📤 **Upload Files**
   - Menu [5] via WinSCP atau
   - Git clone di EC2

4. 🚀 **Deploy**
   ```bash
   ./deploy-to-ec2.sh
   ```

5. 🧪 **Test**
   - Buka http://3.27.0.139
   - Login: admin / admin123

---

## 🎉 Selesai!

Setelah semua langkah, website Fire Detection System akan LIVE di:

**http://3.27.0.139**

**Features:**
- 🔥 Real-time Fire Detection dengan YOLO + Gemini AI
- 📊 Dashboard monitoring dengan data real-time
- 📱 WhatsApp notifications
- 🎥 Auto video recording
- 🔐 Authentication system
- 📈 Telemetry & analytics

**JANGAN LUPA:**
- ⚠️ Ganti password admin setelah login
- 📱 Update IP di ESP32-CAM
- 🔒 Setup HTTPS jika punya domain

---

**Happy Deployment! 🚀🔥**

Ada pertanyaan? Cek file **DEPLOY-TO-3.27.0.139.md** untuk panduan lengkap!
