# 🔄 Migrasi dari Baileys + Twilio ke Go-WhatsApp (GOWA)

## 📋 Ringkasan Perubahan

Sistem Fire Detection telah dimigrasi dari:
- ❌ **Baileys** (Node.js WhatsApp library) → ✅ **Go-WhatsApp** (Golang REST API)
- ❌ **Twilio** (Voice Call service) → ✅ **Dihapus** (tidak diperlukan)

## 🆕 Stack Baru

### Go-WhatsApp (GOWA)
- **Repository**: https://github.com/aldinokemal/go-whatsapp-web-multidevice
- **Port Default**: 3000
- **Bahasa**: Golang 1.24+
- **Features**:
  - QR Code & Pairing Code authentication
  - REST API yang lengkap
  - MCP (Model Context Protocol) support
  - Webhook dengan HMAC security
  - Auto-reconnect
  - Lower memory footprint (~50MB vs ~150MB Baileys)

## 📁 File yang Berubah

### Dihapus:
```
❌ whatsapp-server/           (Baileys-based)
❌ voice-call-server/         (Twilio-based)
❌ VoiceCallManager.tsx       (Twilio UI component)
```

### Ditambah:
```
✅ fire_gowa_helper.py        (Python helper untuk GOWA)
✅ START-GOWA-SERVER.bat      (Launcher untuk GOWA)
✅ start-gowa-server.ps1      (PowerShell launcher)
✅ START-FIRE-DETECTION-GOWA.bat (Combined launcher)
```

### Dimodifikasi:
```
📝 WhatsAppIntegration.tsx    (Frontend component - full rewrite)
📝 api.config.ts              (API configuration - GOWA endpoints)
📝 proxy-server/server.js     (Proxy routes untuk GOWA)
```

## 🚀 Cara Menjalankan

### 1. Start GOWA Server
```bash
# Option A: Windows Batch
START-GOWA-SERVER.bat

# Option B: PowerShell
.\start-gowa-server.ps1

# Option C: Manual (di folder go-whatsapp-web-multidevice/src)
go run . rest --port 3000 --debug
```

### 2. Start Proxy Server
```bash
cd proxy-server
npm start
```

### 3. Start Frontend
```bash
npm run dev
```

### 4. Atau Gunakan Combined Launcher
```bash
START-FIRE-DETECTION-GOWA.bat
```

## 🔗 API Endpoints

### GOWA API (port 3000)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/app/login` | GET | Login dengan QR Code |
| `/app/login-with-code?phone=628xxx` | GET | Login dengan Pairing Code |
| `/app/logout` | GET | Logout |
| `/app/reconnect` | GET | Reconnect |
| `/app/devices` | GET | List connected devices |
| `/send/message` | POST | Kirim pesan teks |
| `/send/image` | POST | Kirim gambar |
| `/send/file` | POST | Kirim file |
| `/send/video` | POST | Kirim video |
| `/user/info` | GET | Info user |
| `/chat/list` | GET | List chat |

### Proxy Routes (port 8080)
Semua GOWA endpoints tersedia via proxy:
- `http://localhost:8080/gowa/*`
- `https://api.latom.flx.web.id/gowa/*` (production)

## ⚙️ Konfigurasi

### Environment Variables
```env
# GOWA Configuration
GOWA_API_URL=http://localhost:3000
GOWA_PORT=3000

# atau via proxy
VITE_GOWA_API_URL=http://localhost:8080/gowa
```

### GOWA .env (go-whatsapp-web-multidevice/src/.env)
```env
APP_PORT=3000
APP_DEBUG=true
APP_OS=FireDetectionSystem
WHATSAPP_AUTO_MARK_READ=true
WHATSAPP_AUTO_DOWNLOAD_MEDIA=true
```

## 🐍 Python Integration

### Menggunakan GOWA Helper
```python
from fire_gowa_helper import send_fire_alert, check_gowa_connection

# Cek koneksi
connected, msg = check_gowa_connection()
print(f"Connected: {connected}, Message: {msg}")

# Kirim alert
success, msg = send_fire_alert(
    frame=opencv_frame,
    confidence=0.85,
    gemini_verified=True,
    gemini_score=0.90,
    camera_id="ESP32-CAM",
    camera_ip="192.168.1.100"
)
```

### Backward Compatibility
```python
# Fungsi lama masih tersedia
from fire_gowa_helper import send_fire_photo_to_whatsapp
```

## 📱 Frontend Usage

### WhatsApp Integration Component
Komponen `WhatsAppIntegration.tsx` sudah diupdate untuk:
1. Menggunakan GOWA API endpoints
2. Support QR Code dan Pairing Code
3. Menyimpan recipients di localStorage
4. Dynamic API URL (tidak hardcoded)

## 🔒 Security

### Tidak Ada Hardcoded URLs
Semua URL dikonfigurasi via:
1. Environment variables
2. Runtime detection di `api.config.ts`
3. Proxy server untuk production

### GOWA Webhook Security
GOWA mendukung HMAC-SHA256 signed webhooks:
```env
WHATSAPP_WEBHOOK=http://your-webhook.com/handler
WHATSAPP_WEBHOOK_SECRET=your-secret-key
```

## 🎯 Keuntungan Migrasi

| Aspek | Baileys | GOWA |
|-------|---------|------|
| Memory | ~150MB+ | ~50MB |
| Startup | 2-5s | <1s |
| Language | Node.js | Golang |
| Binary | 100MB+ (node_modules) | 15MB (single binary) |
| Concurrency | Event Loop | Goroutines |
| MCP Support | ❌ | ✅ |
| Maintenance | Active | Active |

## 📋 Checklist Deployment

- [ ] Install Go 1.24+ atau download binary
- [ ] Install FFmpeg (untuk media processing)
- [ ] Copy `.env` ke `go-whatsapp-web-multidevice/src/`
- [ ] Update proxy-server environment
- [ ] Test connection locally
- [ ] Deploy ke VPS

## ❓ Troubleshooting

### GOWA Server tidak bisa start
```bash
# Pastikan Go terinstall
go version

# Atau download binary dari releases
https://github.com/aldinokemal/go-whatsapp-web-multidevice/releases
```

### Connection Error
```bash
# Cek apakah GOWA running
curl http://localhost:3000/app/devices
```

### QR Code tidak muncul
- Pastikan tidak ada session lama
- Coba logout dulu: `GET /app/logout`
- Restart GOWA server

---

**Migrasi ini menghapus dependency pada Baileys dan Twilio, menyederhanakan stack, dan meningkatkan performa sistem.**
