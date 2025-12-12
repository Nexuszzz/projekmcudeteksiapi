# 🚀 CARA DEPLOY KE EC2 IP: 3.27.0.139

## ⚡ QUICK START (5 Langkah Mudah)

### 1️⃣ Persiapan di Windows

Pastikan sudah ada:
- PuTTY (untuk connect ke EC2)
- PuTTYgen (untuk convert key jika perlu)
- WinSCP atau pscp.exe (untuk transfer file)
- File .pem key dari AWS

### 2️⃣ Connect ke EC2

```bash
# Via PuTTY:
Host: 3.27.0.139
Port: 22
Connection Type: SSH
Username: ubuntu
Auth: Pilih file .pem key Anda
```

Atau via Command Prompt (jika sudah ada OpenSSH):
```cmd
ssh -i "path\to\your-key.pem" ubuntu@3.27.0.139
```

### 3️⃣ Transfer File ke EC2

**Opsi A: Via WinSCP**
1. Buka WinSCP
2. Host name: 3.27.0.139
3. User name: ubuntu
4. Advanced → SSH → Authentication → Private key file: pilih .pem
5. Login
6. Copy seluruh folder `d:\rtsp-main` ke `/home/ubuntu/sudahtapibelum`

**Opsi B: Via Command (pscp)**
```cmd
cd d:\rtsp-main
pscp -i "your-key.pem" -r * ubuntu@3.27.0.139:/home/ubuntu/sudahtapibelum/
```

### 4️⃣ Jalankan Auto Deployment

Setelah connect ke EC2 via PuTTY:

```bash
cd /home/ubuntu/sudahtapibelum
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

Script akan otomatis:
- ✅ Install Node.js, Python, PM2, Nginx
- ✅ Install semua dependencies
- ✅ Build React frontend
- ✅ Configure Nginx untuk public access
- ✅ Start semua services dengan PM2
- ✅ Setup firewall

**Waktu estimasi: 10-15 menit**

### 5️⃣ Akses Website

Setelah deployment selesai, buka browser:

```
http://3.27.0.139
```

**Login Credentials:**
- Username: `admin`
- Password: `admin123`

---

## 🔧 Konfigurasi AWS Security Group

**PENTING!** Pastikan Security Group EC2 mengizinkan:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | Your IP / 0.0.0.0/0 |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 (untuk testing) |

Cara setting:
1. Buka AWS Console → EC2 → Instances
2. Pilih instance dengan IP 3.27.0.139
3. Tab "Security" → Click Security Group
4. "Edit inbound rules"
5. Add rules di atas
6. Save rules

---

## 📊 Monitoring & Management

### Cek Status Services

```bash
pm2 status
```

Expected output:
```
┌─────┬──────────────────┬─────────┬─────────┐
│ id  │ name             │ status  │ restart │
├─────┼──────────────────┼─────────┼─────────┤
│ 0   │ proxy-server     │ online  │ 0       │
│ 1   │ fire-detection   │ online  │ 0       │
└─────┴──────────────────┴─────────┴─────────┘
```

### Lihat Logs Real-time

```bash
# Semua services
pm2 logs

# Service tertentu
pm2 logs proxy-server
pm2 logs fire-detection
```

### Restart Service

```bash
# Restart semua
pm2 restart all

# Restart tertentu
pm2 restart proxy-server
pm2 restart fire-detection
```

### Cek Nginx

```bash
# Status
sudo systemctl status nginx

# Restart
sudo systemctl restart nginx

# Cek config
sudo nginx -t
```

---

## 🐛 Troubleshooting

### Website tidak bisa diakses

**1. Cek Security Group AWS**
```bash
# Dari local Windows, test port
telnet 3.27.0.139 80
```

**2. Cek Nginx running**
```bash
sudo systemctl status nginx
sudo nginx -t
```

**3. Cek PM2 services**
```bash
pm2 status
pm2 logs --err
```

### API error 404

**1. Cek proxy-server running**
```bash
pm2 logs proxy-server
curl http://localhost:8080/api/health
```

**2. Restart proxy-server**
```bash
pm2 restart proxy-server
```

### Fire detection tidak jalan

**1. Cek Python service**
```bash
pm2 logs fire-detection
```

**2. Cek dependencies**
```bash
cd ~/sudahtapibelum/python_scripts
pip3 list | grep -E "opencv|ultralytics|google-generativeai"
```

**3. Restart service**
```bash
pm2 restart fire-detection
```

### Port 80 sudah dipakai

```bash
# Cek proses yang pakai port 80
sudo lsof -i :80

# Kill proses jika perlu
sudo kill -9 <PID>

# Restart nginx
sudo systemctl restart nginx
```

---

## 🔄 Update Code Setelah Push Git

Jika Anda update code di local dan push ke GitHub:

```bash
# Connect ke EC2
ssh -i "your-key.pem" ubuntu@3.27.0.139

# Update code
cd ~/sudahtapibelum
git pull origin main

# Install dependencies baru (jika ada)
npm install
cd proxy-server && npm install && cd ..

# Rebuild frontend
npm run build

# Restart services
pm2 restart all
```

---

## 🔐 Keamanan

### Ganti Password Admin

1. Login ke dashboard: http://3.27.0.139
2. Masuk dengan `admin` / `admin123`
3. Pergi ke Settings → Change Password
4. Ganti dengan password yang kuat

### Setup HTTPS (Opsional tapi Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Setup SSL (perlu domain, tidak bisa dengan IP)
# Jika punya domain misal: firedetection.yourdomain.com
sudo certbot --nginx -d firedetection.yourdomain.com
```

---

## 📱 Koneksi ESP32-CAM

Update IP di code ESP32-CAM:

```cpp
// Ganti dengan IP EC2
const char* serverUrl = "http://3.27.0.139/api/esp32/capture";
```

Upload ulang code ke ESP32-CAM.

---

## ✅ Checklist Deployment

- [ ] Security Group AWS sudah di-configure (port 22, 80, 443)
- [ ] File sudah di-transfer ke EC2
- [ ] Script `deploy-to-ec2.sh` sudah dijalankan
- [ ] Website bisa diakses di http://3.27.0.139
- [ ] Login berhasil dengan admin/admin123
- [ ] PM2 services running (proxy-server, fire-detection)
- [ ] Nginx serving files dengan benar
- [ ] Password admin sudah diganti
- [ ] ESP32-CAM IP sudah diupdate

---

## 🎉 Selesai!

Website Fire Detection System sudah LIVE di:

**http://3.27.0.139**

**Default Login:**
- Username: `admin`
- Password: `admin123`

**Jangan lupa:**
1. ⚠️ Ganti password admin
2. 📱 Update IP di ESP32-CAM
3. 🔄 Setup auto-update dengan Git
4. 📊 Monitor services dengan `pm2 monit`

---

## 📞 Support Commands

```bash
# Remote connect
ssh -i "key.pem" ubuntu@3.27.0.139

# Service management
pm2 status
pm2 logs
pm2 restart all
pm2 monit

# Nginx management
sudo systemctl status nginx
sudo nginx -t
sudo systemctl restart nginx

# System monitoring
htop
df -h
free -h
```

**Happy Deployment! 🚀🔥**
