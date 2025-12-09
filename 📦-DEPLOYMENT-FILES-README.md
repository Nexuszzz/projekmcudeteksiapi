# 📦 File Deployment yang Sudah Disiapkan

## ✅ Files Created untuk EC2 Deployment:

### 1. **🚀-DEPLOY-EC2-GUIDE.md**
   - Panduan lengkap step-by-step deploy ke EC2
   - Cara install dependencies
   - Setup Nginx reverse proxy
   - Konfigurasi PM2
   - Security checklist

### 2. **QUICK-START-EC2.md**
   - Quick start guide (10 menit deploy)
   - Command penting untuk monitoring
   - Troubleshooting common issues

### 3. **deploy-to-ec2.sh**
   - Script otomatis untuk install semua
   - Upload ini ke EC2 dan jalankan
   - Otomatis setup semuanya

### 4. **ecosystem.config.json**
   - Konfigurasi PM2 untuk production
   - Auto-restart jika crash
   - Memory limit dan logging

### 5. **update-server.sh**
   - Script untuk update code dari GitHub
   - Jalankan setelah push code baru

### 6. **backup-data.sh**
   - Backup otomatis data penting
   - Keep 7 backup terakhir

### 7. **requirements.txt**
   - List Python packages yang dibutuhkan
   - Untuk install dependencies Python

---

## 🎯 Cara Deploy (Simple):

### **Opsi 1: Automatic (Recommended)**

1. **Push ke GitHub dulu:**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Connect ke EC2 via PuTTY**

3. **Jalankan auto deploy:**
   ```bash
   wget https://raw.githubusercontent.com/Nexuszzz/sudahtapibelum/main/deploy-to-ec2.sh
   chmod +x deploy-to-ec2.sh
   ./deploy-to-ec2.sh
   ```

4. **Done!** Buka `http://YOUR_EC2_IP`

---

### **Opsi 2: Manual dengan WinSCP**

1. Download WinSCP
2. Connect ke EC2 dengan file `.ppk`
3. Upload semua files ke `/home/ubuntu/`
4. Di PuTTY:
   ```bash
   chmod +x deploy-to-ec2.sh
   ./deploy-to-ec2.sh
   ```

---

## 📝 Yang Perlu Disiapkan di AWS:

### **Security Group Rules:**
```
Port 22   (SSH)    - Source: Your IP
Port 80   (HTTP)   - Source: 0.0.0.0/0
Port 443  (HTTPS)  - Source: 0.0.0.0/0
```

### **Instance Type:**
- Minimal: **t2.micro** (free tier)
- Recommended: **t2.small** atau **t3.small**

### **OS:**
- Ubuntu Server 20.04 LTS atau 22.04 LTS

---

## 🔑 Credentials:

Default login setelah deploy:
- **Username:** `admin`
- **Password:** `admin123`

⚠️ **PENTING:** Ganti password setelah login pertama!

---

## 📊 Monitoring Setelah Deploy:

```bash
# Check service status
pm2 status

# View logs
pm2 logs

# Monitor CPU/Memory
pm2 monit

# Restart all
pm2 restart all
```

---

## 🔄 Update Code di Server:

Setelah push code baru ke GitHub:

```bash
cd ~/sudahtapibelum
./update-server.sh
```

---

## 🆘 Troubleshooting:

### Service tidak jalan:
```bash
pm2 logs
pm2 describe proxy-server
pm2 describe fire-detection
```

### Check Nginx:
```bash
sudo systemctl status nginx
sudo nginx -t
```

### Restart semua:
```bash
pm2 restart all
sudo systemctl restart nginx
```

---

## 📞 Next Steps After Deploy:

1. ✅ Test login di browser
2. ✅ Test fire detection
3. ✅ Setup WhatsApp (jika diperlukan)
4. ✅ Ganti password admin
5. ✅ Setup SSL certificate (opsional)
6. ✅ Setup domain name (opsional)

---

**🎉 Semua file sudah siap! Tinggal deploy ke EC2!**

Baca: **QUICK-START-EC2.md** untuk langkah cepat
Atau: **🚀-DEPLOY-EC2-GUIDE.md** untuk panduan lengkap
