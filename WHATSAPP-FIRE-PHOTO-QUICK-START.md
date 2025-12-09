# 🚀 Quick Start: WhatsApp Fire Photo Notification

## Setup Cepat (10 Menit)

### Step 1: Install Dependencies (2 menit)

```bash
# Proxy Server
cd D:\webdevprojek\IotCobwengdev\proxy-server
npm install

# WhatsApp Server  
cd D:\webdevprojek\IotCobwengdev\whatsapp-server
npm install

# Python Dependencies
cd D:\zakaiot
pip install requests opencv-python ultralytics pillow google-generativeai paho-mqtt
```

### Step 2: Konfigurasi Recipients (1 menit)

```bash
cd D:\webdevprojek\IotCobwengdev\whatsapp-server

# Buat recipients.json
echo [{"phoneNumber": "628123456789", "name": "Your Name"}] > recipients.json

# Ganti 628123456789 dengan nomor WhatsApp Anda (format: 628xxxxxxxxxx)
```

### Step 3: Start Services (2 menit)

**Terminal 1 - Proxy Server:**
```bash
cd D:\webdevprojek\IotCobwengdev\proxy-server
npm start
```

**Terminal 2 - WhatsApp Server:**
```bash
cd D:\webdevprojek\IotCobwengdev\whatsapp-server
npm start
```

**Terminal 3 - Connect WhatsApp:**
```bash
curl -X POST http://localhost:3001/api/whatsapp/connect \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"628123456789\", \"method\": \"pairing\"}"

# Ganti 628123456789 dengan nomor Anda
# Copy pairing code yang muncul
# Buka WhatsApp → Settings → Linked Devices → Link with phone number
# Masukkan pairing code
# Tunggu sampai connected
```

### Step 4: Test Fire Detection (5 menit)

**Option A: Test dengan Dummy Image**
```bash
cd D:\zakaiot
python fire_whatsapp_helper.py
```

Expected output:
```
🧪 Testing WhatsApp Fire Photo Sender...
============================================================
📤 Sending test fire photo to WhatsApp...
============================================================
✅ SUCCESS: Photo sent successfully! ID: fire_1730553045_abc123

📱 Check WhatsApp! Recipients should receive:
   - Photo dengan bounding box merah
   - Caption lengkap dengan data deteksi
   - Gemini verification badge
============================================================
```

**Option B: Test dengan Real Fire Detection**
```bash
# Pastikan ESP32-CAM running di 10.148.218.219
cd D:\zakaiot
python fire_detect_esp32_whatsapp.py
```

---

## ✅ Checklist Verifikasi

Setelah setup, pastikan semua ini berfungsi:

### 1. Proxy Server (Port 8080)
```bash
# Test health check
curl http://localhost:8080/health

# Expected response:
{
  "status": "ok",
  "mqtt": "connected",
  "clients": 0,
  "fireDetections": 0
}
```

### 2. WhatsApp Server (Port 3001)
```bash
# Check status
curl http://localhost:3001/api/whatsapp/status

# Expected response:
{
  "connected": true,
  "status": "connected",
  "phone": "628123456789",
  "recipients": 1,
  "mqttConnected": true
}
```

### 3. MQTT Broker
```bash
# Subscribe untuk monitor
mosquitto_sub -h localhost -p 1883 -u zakaria -P zaks123 -t "lab/zaks/#" -v

# Expected: See messages saat fire detection trigger
```

### 4. WhatsApp Notification
- [ ] Nomor WhatsApp sudah connected
- [ ] Recipients.json berisi nomor yang benar
- [ ] Test script berhasil kirim foto
- [ ] WhatsApp menerima foto + caption lengkap

---

## 📱 Contoh Notifikasi WhatsApp

Ketika fire detected, recipients akan menerima:

**[FOTO: ESP32-CAM frame dengan bounding box merah]**

```
🔥 DETEKSI API DENGAN BUKTI FOTO!

⚠️ PERINGATAN: API TERDETEKSI

📊 Tingkat Keyakinan:
🎯 YOLO Detection: 89.5%
🤖 Gemini AI Verification: 92.3% ✅
💭 AI Analysis: Flame pattern detected with high temperature signature

📷 Sumber:
📍 Camera: esp32cam_lab
🌐 IP Address: 10.148.218.219
🤖 Model: yolov8n

📐 Lokasi Api di Frame:
• X: 245 - 389
• Y: 156 - 298
• Size: 144×142px

⏰ Waktu Deteksi:
Sabtu, 2 November 2024, 17:30:45

⚠️ TINDAKAN YANG HARUS DILAKUKAN:
1️⃣ Periksa lokasi kamera SEGERA
2️⃣ Pastikan tidak ada asap atau api
3️⃣ Hubungi petugas keamanan jika perlu
4️⃣ Evakuasi jika situasi berbahaya

🆔 Detection ID: fire_1730553045234_abc123
```

---

## 🔧 Troubleshooting Cepat

### Problem: "Connection error: Cannot reach proxy server"
```bash
# Check proxy server running
curl http://localhost:8080/health

# Jika error, restart proxy:
cd D:\webdevprojek\IotCobwengdev\proxy-server
npm start
```

### Problem: WhatsApp tidak terconnect
```bash
# Check status
curl http://localhost:3001/api/whatsapp/status

# Jika disconnected, delete session dan reconnect:
curl -X POST http://localhost:3001/api/whatsapp/delete-session
curl -X POST http://localhost:3001/api/whatsapp/connect \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"628xxx\", \"method\": \"pairing\"}"
```

### Problem: Photo tidak terkirim
```bash
# Check folder uploads ada
dir D:\webdevprojek\IotCobwengdev\proxy-server\uploads\fire-detections

# Check MQTT message published
mosquitto_sub -h localhost -p 1883 -u zakaria -P zaks123 -t "lab/zaks/fire_photo" -v

# Check WhatsApp server logs
# Lihat terminal WhatsApp server, should show:
# "📸 Handling fire detection with photo..."
# "✅ Fire photo alert sent to..."
```

### Problem: "Cooldown active"
```python
# Normal behavior untuk prevent spam
# Wait 60 seconds antara notifications
# Atau edit cooldown di fire_whatsapp_helper.py:
# self.cooldown = 10  # Change to 10 seconds for testing
```

---

## 📝 Integration dengan Existing Scripts

### Tambahkan ke Fire Detection Script Anda:

```python
# 1. Import helper
from fire_whatsapp_helper import send_fire_photo_to_whatsapp

# 2. Dalam detection loop, tambahkan:
if fire_detected:
    # ... existing YOLO detection code ...
    
    # Send to WhatsApp
    success, msg = send_fire_photo_to_whatsapp(
        frame=frame,
        confidence=conf,
        bbox=bbox.tolist(),
        camera_ip="10.148.218.219",
        camera_id="esp32cam_lab"
    )
    
    if success:
        print(f"✅ WhatsApp: {msg}")
    else:
        print(f"❌ WhatsApp: {msg}")
```

### Scripts Yang Bisa Langsung Digunakan:

1. **fire_detect_esp32_whatsapp.py** - Complete integration (recommended)
2. **fire_whatsapp_helper.py** - Library helper untuk scripts lain
3. Atau edit existing scripts Anda: `fire_detect_esp32_ultimate.py`, dll

---

## 🎯 Next Steps

Setelah berhasil setup:

1. **Test dengan API Real:**
   - Gunakan lighter untuk trigger detection
   - Verify WhatsApp notification received
   - Check foto quality acceptable

2. **Configure Multiple Recipients:**
   ```json
   [
     {"phoneNumber": "628xxx", "name": "Admin"},
     {"phoneNumber": "628yyy", "name": "Security"},
     {"phoneNumber": "628zzz", "name": "Manager"}
   ]
   ```

3. **Tune Detection Parameters:**
   - Adjust `CONFIDENCE_THRESHOLD` di script
   - Adjust `WHATSAPP_COOLDOWN` sesuai kebutuhan
   - Enable Gemini AI verification jika ada API key

4. **Production Deployment:**
   - Setup auto-start services (systemd/PM2)
   - Configure firewall rules
   - Setup monitoring dan logging
   - Backup recipients.json dan auth_info/

---

## 📚 Documentation Reference

- **Full Integration Guide:** `WHATSAPP-FIRE-PHOTO-INTEGRATION.md`
- **API Reference:** See proxy-server README
- **Troubleshooting:** See documentation folder
- **Code Examples:** `fire_detect_esp32_whatsapp.py`

---

## ✨ Features Summary

✅ **Implemented:**
- Real-time fire photo upload
- WhatsApp notification dengan foto
- Detailed caption dengan metadata
- MQTT integration
- Cooldown mechanism
- Multi-recipient support
- Gemini AI verification (optional)
- Web dashboard sync
- Auto-cleanup old photos

🎉 **Ready to Use!** Sistem sudah fully functional dan production-ready!
