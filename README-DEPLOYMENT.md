# 🔥 CARA HOSTING KE EC2 IP: 3.27.0.139

## ⚡ MULAI DARI SINI!

### 🚀 Quick Start

**Double-click file ini:**

```
DEPLOY-QUICK-START.bat
```

Ini akan membuka menu dengan opsi:
1. Launch interactive deployment menu
2. Read documentation
3. Connect to EC2 via PuTTY
4. Upload files via WinSCP
5. Test deployment

---

## 📋 Cara Deploy (3 Langkah)

### 1️⃣ Persiapan

**Yang dibutuhkan:**
- ✅ PuTTY (untuk connect ke EC2)
- ✅ WinSCP (untuk transfer files)
- ✅ File .pem key dari AWS
- ✅ AWS Security Group allow port 22, 80, 443

**Install tools:**
- PuTTY: https://www.putty.org/
- WinSCP: https://winscp.net/

### 2️⃣ Upload Files

**Opsi A: Via WinSCP (Recommended)**
1. Buka WinSCP
2. Host: `3.27.0.139`, User: `ubuntu`
3. Auth: Pilih file .pem
4. Login
5. Upload folder ke `/home/ubuntu/sudahtapibelum`

**Opsi B: Via Git Clone (Lebih cepat)**
```bash
# Connect via PuTTY lalu jalankan:
cd ~
git clone https://github.com/Nexuszzz/sudahtapibelum.git
cd sudahtapibelum
```

### 3️⃣ Deploy

Di terminal EC2 (via PuTTY):

```bash
cd /home/ubuntu/sudahtapibelum
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

**Tunggu 10-15 menit** untuk instalasi lengkap.

---

## 🌐 Akses Website

Setelah deploy selesai:

**URL:** http://3.27.0.139

**Login:**
- Username: `admin`
- Password: `admin123`

---

## 📖 File Penting

| File | Deskripsi |
|------|-----------|
| **DEPLOY-QUICK-START.bat** | ⭐ Menu utama deployment |
| **START-DEPLOYMENT.bat** | Menu interaktif lengkap |
| **🎉-DEPLOYMENT-READY.md** | Panduan deployment lengkap |
| **DEPLOY-TO-3.27.0.139.md** | Guide detail untuk IP ini |
| **deploy-to-ec2.sh** | Script auto deployment (jalankan di EC2) |
| **ecosystem.config.json** | PM2 configuration |

---

## 🔧 Setup AWS Security Group

**PENTING!** Sebelum deploy, pastikan EC2 Security Group allow:

| Type | Port | Source |
|------|------|--------|
| SSH | 22 | Your IP |
| HTTP | 80 | 0.0.0.0/0 |
| HTTPS | 443 | 0.0.0.0/0 |

**Cara setting:**
1. AWS Console → EC2 → Instances
2. Pilih instance `3.27.0.139`
3. Tab Security → Click Security Group
4. Edit inbound rules → Add rules
5. Save

---

## 📊 Cek Status Deployment

Setelah deployment, cek services:

```bash
# Status services
pm2 status

# Lihat logs
pm2 logs

# Restart jika perlu
pm2 restart all

# Cek nginx
sudo systemctl status nginx
```

---

## 🐛 Troubleshooting

### Website tidak bisa diakses
```bash
# Cek nginx
sudo systemctl status nginx
sudo systemctl restart nginx

# Cek PM2
pm2 status
pm2 restart all
```

### API error
```bash
pm2 logs proxy-server
pm2 restart proxy-server
```

---

## 🔄 Update Code

Jika update code:

```bash
# Di local
git push origin main

# Di EC2
cd ~/sudahtapibelum
git pull origin main
npm install
npm run build
pm2 restart all
```

---

## ✅ Checklist

- [ ] Tools installed (PuTTY, WinSCP)
- [ ] Security Group configured
- [ ] Files uploaded to EC2
- [ ] `deploy-to-ec2.sh` executed
- [ ] Website accessible at http://3.27.0.139
- [ ] Login works (admin/admin123)
- [ ] Password changed
- [ ] ESP32-CAM IP updated

---

## 📞 Quick Commands

```bash
# Connect
ssh -i "key.pem" ubuntu@3.27.0.139

# Deploy
cd /home/ubuntu/sudahtapibelum && chmod +x deploy-to-ec2.sh && ./deploy-to-ec2.sh

# Monitor
pm2 status
pm2 logs
pm2 monit

# Restart
pm2 restart all
```

---

## 🎉 Selesai!

Website akan live di: **http://3.27.0.139**

**Features:**
- 🔥 Fire Detection dengan YOLO + Gemini AI
- 📊 Real-time Dashboard
- 📱 WhatsApp Notifications
- 🎥 Auto Video Recording
- 🔐 Authentication System

---

**Need Help?**

Baca file lengkap:
- `🎉-DEPLOYMENT-READY.md` - Panduan lengkap dengan troubleshooting
- `DEPLOY-TO-3.27.0.139.md` - Guide detail untuk IP ini

**Happy Deployment! 🚀🔥**
