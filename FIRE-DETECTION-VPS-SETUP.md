# 🔥 ESP32-CAM Fire Detection - VPS Headless Mode

## Overview

Fire detection yang berjalan **langsung di VPS** tanpa perlu laptop:
- ESP32-CAM broadcast IP via MQTT
- VPS script auto-detect dan connect ke stream
- YOLO deteksi api + validasi warna
- Gemini AI verification (opsional)
- Upload foto ke Fire Gallery dashboard
- Kirim WhatsApp alert via GOWA

## ✅ Yang Sudah Tersedia di VPS

```
/home/ubuntu/rtsp-project/
├── proxy-server/
│   ├── server.js              # Backend API (fire-detection, video upload)
│   ├── uploads/
│   │   └── fire-detections/   # Foto deteksi api
│   └── recordings/            # Video recordings
├── python_scripts/
│   ├── fire_detect_vps.py     # Script deteksi (HEADLESS)
│   ├── .env                   # Konfigurasi
│   └── fire_yolov8s_ultra_best.pt  # Model (PERLU UPLOAD)
└── fire-detect.service        # Systemd service
```

## 🚀 Setup Steps

### 1. Upload YOLO Model (WAJIB!)

Model deteksi api (~21 MB) perlu diupload dari laptop:

```powershell
# Dari laptop, upload via SCP:
scp -i "your-key.pem" "D:\zekk\zakaiot\fire_yolov8s_ultra_best.pt" ubuntu@3.27.11.106:/home/ubuntu/rtsp-project/python_scripts/
```

Atau copy file ke folder ini dan commit, lalu pull di VPS.

### 2. Set Gemini API Key (Opsional)

Untuk verifikasi AI, tambahkan Gemini key:

```bash
# Edit .env di VPS
nano /home/ubuntu/rtsp-project/python_scripts/.env
```

Tambahkan:
```
GOOGLE_API_KEY=your_gemini_api_key_here
```

### 3. Test Manual Run

```bash
# SSH ke VPS
ssh ubuntu@3.27.11.106

# Test dengan stream URL langsung:
cd /home/ubuntu/rtsp-project/python_scripts
python3 fire_detect_vps.py --stream-url "http://192.168.x.x:81/stream" --camera-ip "192.168.x.x"

# Atau tunggu ESP32-CAM broadcast via MQTT:
python3 fire_detect_vps.py
```

### 4. Enable Auto-Start Service

```bash
# Copy service file
sudo cp /home/ubuntu/rtsp-project/fire-detect.service /etc/systemd/system/

# Enable dan start
sudo systemctl daemon-reload
sudo systemctl enable fire-detect
sudo systemctl start fire-detect

# Check status
sudo systemctl status fire-detect
```

## 📡 ESP32-CAM Network Access

**PENTING**: VPS perlu bisa akses stream ESP32-CAM. Ada beberapa opsi:

### Option A: Port Forwarding (Router)
1. Login ke router (192.168.1.1)
2. Port forward: External 8181 → ESP32-CAM_IP:81
3. Gunakan: `--stream-url "http://YOUR_PUBLIC_IP:8181/stream"`

### Option B: Tailscale VPN (Recommended)
1. Install Tailscale di VPS dan laptop
2. ESP32-CAM connect ke network yang sama dengan laptop
3. Akses via Tailscale IP

### Option C: ngrok Tunnel
```bash
# Di laptop yang sama network dengan ESP32
ngrok http 192.168.x.x:81
# Gunakan URL ngrok di VPS
```

### Option D: MQTT Auto Discovery
ESP32-CAM broadcast IP via MQTT topic `lab/zaks/esp32cam/ip`:
```json
{
  "ip": "192.168.1.100",
  "stream_url": "http://192.168.1.100:81/stream",
  "id": "ESP32CAM_001"
}
```

Script akan auto-detect dan connect.

## 📊 Fire Gallery & Recordings

Ketika api terdeteksi:
1. **Foto** → Upload ke `/api/fire-detection` → Muncul di Fire Gallery
2. **Alert** → MQTT topic `lab/zaks/alert`
3. **WhatsApp** → Kirim ke semua recipients via GOWA

### View Fire Gallery
```
https://latom.flx.web.id → Fire Gallery tab
```

### API Endpoints
```
GET  /api/fire-detections        - List semua deteksi
POST /api/fire-detection         - Upload foto baru
GET  /api/fire-detections/:id    - Detail satu deteksi
DELETE /api/fire-detection/:id   - Hapus deteksi
```

## 🔧 Script Options

```bash
python3 fire_detect_vps.py [OPTIONS]

Options:
  --stream-url URL    ESP32-CAM stream URL (override MQTT discovery)
  --camera-ip IP      Camera IP address
  --model PATH        Path to YOLO model file
  --conf 0.35         Detection confidence threshold (0-1)
  --no-gemini         Disable Gemini AI verification
  --no-record         Disable video recording
  --no-whatsapp       Disable WhatsApp notifications
  --debug             Enable debug output
```

## 📱 WhatsApp Recipients

Recipients diambil dari backend API `/api/recipients`.
Kelola via dashboard: Settings → WhatsApp Recipients

## 🔍 Troubleshooting

### Model Not Found
```bash
ls -la /home/ubuntu/rtsp-project/python_scripts/*.pt
# Upload model jika belum ada
```

### Can't Connect to Stream
```bash
# Test dari VPS
curl -I http://ESP32_IP:81/stream
# Jika timeout, perlu setup port forwarding/VPN
```

### Check Service Logs
```bash
sudo journalctl -u fire-detect -f
```

### Restart Service
```bash
sudo systemctl restart fire-detect
```

## 📋 File yang Perlu Upload dari Laptop

| File | Size | Location |
|------|------|----------|
| `fire_yolov8s_ultra_best.pt` | 21.5 MB | D:\zekk\zakaiot\ |

## 🔗 Related URLs

- Dashboard: https://latom.flx.web.id
- API: https://api.latom.flx.web.id
- GOWA: https://gowa2.flx.web.id
- MQTT: mqtt://3.27.11.106:1883
