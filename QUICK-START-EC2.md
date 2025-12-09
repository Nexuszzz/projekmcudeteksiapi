# 🚀 Quick Start - Cara Cepat Deploy ke EC2

## 📋 Checklist Persiapan

- [ ] Instance EC2 sudah running (Ubuntu 20.04/22.04)
- [ ] Security Group dikonfigurasi:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 443 (HTTPS - opsional)
- [ ] File `.pem` key pair sudah diunduh
- [ ] File `.pem` sudah diconvert ke `.ppk` (menggunakan PuTTYgen)

---

## 🎯 Langkah Cepat (10 Menit)

### 1️⃣ Connect ke EC2
- Buka **PuTTY**
- Host: `ubuntu@YOUR_EC2_IP`
- Port: `22`
- Auth: Pilih file `.ppk` Anda
- Click **Open**

### 2️⃣ Upload Script (Pilih salah satu):

**Opsi A - Via GitHub (Recommended):**
```bash
# Di lokal, push dulu ke GitHub
git add .
git commit -m "Ready for deployment"
git push origin main

# Di EC2, jalankan auto deploy
wget https://raw.githubusercontent.com/Nexuszzz/sudahtapibelum/main/deploy-to-ec2.sh
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

**Opsi B - Manual Upload dengan WinSCP:**
1. Download WinSCP
2. Login dengan IP EC2 dan file `.ppk`
3. Upload file `deploy-to-ec2.sh` ke `/home/ubuntu/`
4. Di PuTTY jalankan:
   ```bash
   chmod +x deploy-to-ec2.sh
   ./deploy-to-ec2.sh
   ```

### 3️⃣ Tunggu Script Selesai (5-10 menit)

Script akan otomatis:
- ✅ Install semua dependencies
- ✅ Clone repository
- ✅ Build frontend
- ✅ Setup environment
- ✅ Configure Nginx
- ✅ Start services dengan PM2

### 4️⃣ Akses Website

Buka browser: `http://YOUR_EC2_IP`

Login dengan:
- Username: `admin`
- Password: `admin123`

---

## 🔧 Command Penting

```bash
# Check status services
pm2 status

# Lihat logs
pm2 logs

# Restart semua services
pm2 restart all

# Monitor CPU/Memory
pm2 monit

# Update code dari GitHub
cd ~/sudahtapibelum
git pull origin main
npm run build
pm2 restart all
```

---

## 📊 Monitoring

### Check Service Status:
```bash
pm2 status
```

### View Logs:
```bash
pm2 logs proxy-server
pm2 logs fire-detection
```

### Check Nginx:
```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

---

## 🔄 Update Code (Setelah Push ke GitHub)

```bash
cd ~/sudahtapibelum
git pull origin main
npm install
npm run build
pm2 restart all
```

Atau jalankan script:
```bash
./update-server.sh
```

---

## 💾 Backup Data

```bash
./backup-data.sh
```

Backup tersimpan di: `/home/ubuntu/backups/`

---

## 🛡️ Security Tips

1. **Ganti password admin** setelah login pertama
2. **Setup SSL** untuk HTTPS (opsional tapi recommended):
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d yourdomain.com
   ```
3. **Disable password SSH**, gunakan key saja:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   sudo systemctl restart sshd
   ```

---

## 🆘 Troubleshooting

### Service tidak jalan:
```bash
pm2 logs
pm2 restart all
```

### Port conflict:
```bash
sudo lsof -i :8080
sudo kill -9 <PID>
pm2 restart all
```

### Nginx error:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

### Out of memory:
```bash
pm2 restart all
free -h
```

---

## 📞 Kontak

Jika ada masalah, check:
1. PM2 logs: `pm2 logs`
2. Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. System logs: `sudo journalctl -xe`

---

**🎉 Selamat! Website Anda sudah online!**
