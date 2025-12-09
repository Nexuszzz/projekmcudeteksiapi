# 🚀 WhatsApp V2 Integration - Complete Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Usage Guide](#usage-guide)
6. [MQTT Integration](#mqtt-integration)
7. [API Reference](#api-reference)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

**WhatsApp V2** adalah integrasi baru yang menggunakan **go-whatsapp-web-multidevice** API server (Go + Whatsmeow). Ini adalah upgrade dari WhatsApp Baileys yang lama dengan fitur-fitur berikut:

### ✨ Keunggulan vs WhatsApp Baileys (OLD)

| Feature | WhatsApp V1 (Baileys) | WhatsApp V2 (Go) |
|---------|----------------------|------------------|
| Multi-Device | ❌ No | ✅ Yes |
| Stability | ⚠️ Moderate | ✅ High |
| Performance | 🐌 Slow | ⚡ Fast |
| Message Types | 3 types | 📦 6+ types |
| Group Support | ⚠️ Limited | ✅ Full |
| API Quality | 🔧 DIY | 📚 Well-documented |

### 🔥 Fitur Utama

- ✅ **Multi-Device Support** - Kelola beberapa nomor WhatsApp sekaligus
- ✅ **Rich Message Types** - Text, Image, File, Video, Location, Contact
- ✅ **MQTT Auto-Send** - Fire detection → WhatsApp otomatis
- ✅ **Smart Cooldown** - Prevent spam dengan mekanisme cooldown
- ✅ **Real-time Photos** - Kirim foto fire detection dengan bounding box
- ✅ **Group Broadcasting** - Broadcast ke multiple groups
- ✅ **QR Code Login** - Easy device pairing
- ✅ **RESTful API** - Clean & well-structured API

---

## 📦 Prerequisites

### 1. Go WhatsApp API Server

Download dan install dari GitHub:
```bash
git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice
cd go-whatsapp-web-multidevice
```

### 2. Go Language (1.19+)

Download dari: https://go.dev/dl/

```bash
# Verify installation
go version
```

### 3. Dependencies

Project ini sudah include semua dependencies yang diperlukan di `package.json`.

---

## 🔧 Installation

### Step 1: Clone & Install Dependencies

```bash
# Already done if you have the project
cd IotCobwengdev-backup-20251103-203857
npm install
```

### Step 2: Setup Go WhatsApp API Server

```bash
# Navigate to go-whatsapp directory
cd go-whatsapp-web-multidevice

# Install dependencies
go mod download

# Build the project
go build -o whatsapp-api

# Run the server (Windows)
whatsapp-api.exe

# Run the server (Linux/Mac)
./whatsapp-api
```

Server akan berjalan di `http://localhost:3000`

### Step 3: Configure Environment

Edit file `.env`:
```env
# WhatsApp V2 Configuration
VITE_WHATSAPP_V2_API_URL=http://localhost:3000
VITE_WHATSAPP_V2_API_KEY=
VITE_WHATSAPP_V2_DEFAULT_DEVICE=628123456789
```

### Step 4: Start Development Server

```bash
# Terminal 1: Proxy Server (MQTT WebSocket)
npm run dev:proxy

# Terminal 2: Frontend
npm run dev

# Terminal 3: Go WhatsApp API
cd go-whatsapp-web-multidevice
go run main.go
```

---

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `VITE_WHATSAPP_V2_API_URL` | Base URL untuk Go API | `http://localhost:3000` | ✅ Yes |
| `VITE_WHATSAPP_V2_API_KEY` | API Key (jika diperlukan) | - | ❌ No |
| `VITE_WHATSAPP_V2_DEFAULT_DEVICE` | Nomor device default | `628xxx` | ❌ No |

### Go API Configuration

File `config.yaml` di go-whatsapp-web-multidevice:

```yaml
app:
  port: 3000
  debug: true
  webhook: http://localhost:5173/webhook

database:
  type: sqlite
  path: ./whatsapp.db

whatsapp:
  autoReconnect: true
  syncHistory: false
```

---

## 📱 Usage Guide

### 1. Device Manager

#### Add New Device

1. Buka halaman **WhatsApp V2** (`http://localhost:5173/whatsappv2`)
2. Di panel **Device Manager**, masukkan nomor WhatsApp:
   ```
   628123456789
   ```
3. Klik **"Generate QR Code"**
4. Scan QR Code dengan WhatsApp di HP Anda:
   - WhatsApp → Settings → Linked Devices → Link a Device
5. Tunggu hingga status menjadi **"Connected"** ✅

#### Manage Existing Devices

- **View Devices**: Semua device muncul di panel kanan
- **Reconnect**: Klik tombol "Reconnect" jika terputus
- **Logout**: Klik "Logout" untuk disconnect device
- **Status**: Green = Connected, Red = Disconnected

---

### 2. Message Center

#### Add Recipients

1. Di panel **Message Center**, klik **"Add"**
2. Masukkan nomor penerima:
   ```
   628123456789
   ```
3. Masukkan nama (optional):
   ```
   Emergency Contact 1
   ```
4. Klik **"Add"**

Recipients akan tersimpan di localStorage dan otomatis reload.

#### Send Text Message

1. Pilih tab **"Text"**
2. Ketik pesan di text area
3. Klik **"Send to N Recipients"**
4. Tunggu konfirmasi: `✅ Berhasil: 3 | ❌ Gagal: 0`

**Format Teks:**
- **Bold**: `*bold text*`
- **Italic**: `_italic text_`
- **Monospace**: `` `code` ``

#### Send Image

1. Pilih tab **"Image"**
2. Klik **"Select Image"** dan pilih file (max 5MB)
3. Tambahkan caption (optional)
4. Klik **"Send Image to N Recipients"**

**Supported formats:** JPG, PNG, GIF, WEBP

#### Send Location

1. Pilih tab **"Location"**
2. Masukkan koordinat:
   ```
   Latitude: -6.2088
   Longitude: 106.8456
   Address: Fire Detection Location
   ```
3. Klik **"Send Location to N Recipients"**

---

### 3. MQTT Integration

#### Enable Auto-Send

1. Di panel **MQTT Integration**, pastikan:
   - ✅ WhatsApp Connected (hijau)
   - ✅ MQTT Connected (hijau)
   - ✅ Minimal 1 recipient di Message Center

2. Klik tombol **"Enable"** di kanan atas

3. Status berubah menjadi **"Enabled"** (hijau) ✅

#### Configure Settings

**Alert Cooldown:**
- Default: 60 seconds
- Range: 10-300 seconds
- Fungsi: Minimum waktu antara alerts (prevent spam)

**Send Images:**
- ON: Kirim foto fire detection dengan caption
- OFF: Hanya kirim text alert

**Send Location:**
- ON: Kirim GPS coordinates sensor
- OFF: Tidak kirim lokasi

**Location Settings (jika enabled):**
```
Latitude: -6.2088
Longitude: 106.8456
Address: Fire Detection Sensor - Building A
```

#### How It Works

```
┌────────────┐    MQTT Topic        ┌──────────────┐    REST API     ┌──────────────┐
│ ESP32/IoT  ├─────────────────────>│ Proxy Server ├───────────────>│ WhatsApp V2  │
│  Sensors   │ lab/zaks/fire_photo  │  (Node.js)   │  /send/image   │  Go API      │
└────────────┘                       └──────────────┘                 └──────────────┘
                                             │                                │
                                             │ Parse & Forward                │
                                             ▼                                ▼
                                      ┌──────────────┐               ┌──────────────┐
                                      │ MQTT Bridge  │               │  Recipients  │
                                      │  Service     │               │  (WhatsApp)  │
                                      └──────────────┘               └──────────────┘
```

**Supported MQTT Topics:**

| Topic | Action | Message Type |
|-------|--------|--------------|
| `lab/zaks/alert` | Fire alert detected | Text + Sensor data |
| `lab/zaks/fire_photo` | Fire with image | Image + Caption |
| `lab/zaks/event` | Critical event | Text notification |
| `lab/zaks/log` | Sensor telemetry | Conditional alert |

---

## 📡 API Reference

### Base URL
```
http://localhost:3000
```

### Authentication

Jika API key diaktifkan:
```http
Authorization: Bearer YOUR_API_KEY
```

### Endpoints

#### 1. Get Devices
```http
GET /app/devices
```

**Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "devices": [
      {
        "device": "628123456789",
        "name": "My Device",
        "is_connected": true,
        "jid": "628123456789@s.whatsapp.net"
      }
    ]
  }
}
```

#### 2. Login (Generate QR)
```http
GET /app/login?device=628123456789
```

**Response:**
```json
{
  "code": 200,
  "data": {
    "qr_code": "data:image/png;base64,iVBORw0KG...",
    "timeout": 60
  }
}
```

#### 3. Send Text Message
```http
POST /send/message
Content-Type: application/json

{
  "device": "628123456789",
  "phone": "6281234567890",
  "message": "Hello from Fire Detection!"
}
```

**Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "message_id": "3EB0XXXXX"
  }
}
```

#### 4. Send Image
```http
POST /send/image
Content-Type: application/json

{
  "device": "628123456789",
  "phone": "6281234567890",
  "image": "data:image/jpeg;base64,/9j/4AAQ...",
  "caption": "Fire detected at location X"
}
```

#### 5. Send Location
```http
POST /send/location
Content-Type: application/json

{
  "device": "628123456789",
  "phone": "6281234567890",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "address": "Fire Detection Location"
}
```

### Error Handling

**Error Response Format:**
```json
{
  "code": 400,
  "message": "Invalid phone number",
  "errors": ["Phone must start with country code"]
}
```

**Common Error Codes:**

| Code | Meaning |
|------|---------|
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid API key |
| 404 | Not Found - Device/endpoint not found |
| 500 | Internal Server Error |

---

## 🔧 Troubleshooting

### Problem 1: QR Code Not Generated

**Symptoms:**
- Error: "Failed to generate QR Code"
- QR tidak muncul setelah klik button

**Solutions:**

1. **Check Go API Server:**
   ```bash
   # Test if server is running
   curl http://localhost:3000/app/devices
   ```

2. **Check CORS Settings:**
   - Pastikan `ALLOWED_ORIGINS` di go-whatsapp config include `http://localhost:5173`

3. **Delete Old Session:**
   ```bash
   # Di go-whatsapp directory
   rm -rf sessions/
   ```

4. **Restart Go API:**
   ```bash
   go run main.go
   ```

---

### Problem 2: Device Not Connecting

**Symptoms:**
- Status tetap "Disconnected" setelah scan QR
- "Connection timeout"

**Solutions:**

1. **Wait 10-30 seconds** after scanning QR (syncing messages)

2. **Check Phone Connection:**
   - HP harus terkoneksi internet
   - WhatsApp harus latest version
   - Tidak ada firewall blocking

3. **Check Multi-Device Limit:**
   - WhatsApp only allows 4 linked devices
   - Logout dari device lain jika sudah penuh

4. **Regenerate QR Code:**
   - Logout dari device
   - Delete session
   - Generate QR baru

---

### Problem 3: MQTT Integration Not Working

**Symptoms:**
- Alert tidak dikirim ke WhatsApp
- MQTT status "Disconnected"

**Solutions:**

1. **Check MQTT Status:**
   - Buka Dashboard → Lihat connection badge
   - Jika merah, cek proxy server:
   ```bash
   # Restart proxy server
   npm run dev:proxy
   ```

2. **Check Bridge Configuration:**
   - Pastikan "Enable" button di-klik (hijau)
   - Pastikan ada recipients di Message Center
   - Check cooldown tidak aktif

3. **Check Console Logs:**
   ```javascript
   // Open browser console (F12)
   // Look for errors like:
   "❌ Failed to send to 628xxx: ..."
   "⏳ Cooldown active. 45s remaining."
   ```

4. **Test Manual Send:**
   - Gunakan Message Center → Send Text
   - Jika berhasil, berarti MQTT bridge issue
   - Jika gagal, berarti WhatsApp device issue

---

### Problem 4: Images Not Sending

**Symptoms:**
- Text terkirim, tapi image tidak
- Error: "Failed to convert image"

**Solutions:**

1. **Check Image Size:**
   - Max 5MB per image
   - Resize jika terlalu besar

2. **Check Image Format:**
   - Supported: JPG, PNG, GIF, WEBP
   - Convert jika format lain

3. **Check Base64 Encoding:**
   ```javascript
   // In browser console
   const img = await Utils.fileToBase64(file);
   console.log(img.substring(0, 100)); // Should start with "data:image/jpeg;base64,"
   ```

4. **Use URL Instead:**
   - Jika base64 fail, host image di server
   - Send URL instead of base64

---

### Problem 5: Rate Limiting / Spam Detected

**Symptoms:**
- Messages stopped sending after few attempts
- Error: "Too many requests"

**Solutions:**

1. **Increase Cooldown:**
   ```
   MQTT Integration → Alert Cooldown: 120 seconds
   ```

2. **Reduce Recipients:**
   - Don't send to 100+ recipients at once
   - Split into batches of 10-20

3. **Add Delays:**
   - Automatic 1-2 second delay between messages
   - Don't modify unless necessary

4. **Wait & Retry:**
   - If banned, wait 24 hours
   - Don't spam again or account might get banned permanently

---

## 🎓 Best Practices

### 1. Security

✅ **DO:**
- Keep API keys private
- Use environment variables
- Limit recipient list to trusted contacts
- Use HTTPS in production

❌ **DON'T:**
- Commit API keys to Git
- Share QR codes publicly
- Send to unknown numbers
- Use without authentication in production

### 2. Performance

✅ **DO:**
- Use cooldown to prevent spam
- Compress images before sending
- Batch messages when possible
- Monitor queue status

❌ **DON'T:**
- Send 100+ messages at once
- Send large files (>5MB)
- Disable cooldown in production
- Ignore rate limits

### 3. Reliability

✅ **DO:**
- Monitor connection status
- Auto-reconnect on disconnect
- Log all messages
- Handle errors gracefully

❌ **DON'T:**
- Assume messages always deliver
- Ignore connection status
- Skip error handling
- Delete logs immediately

---

## 📊 Monitoring & Analytics

### View Statistics

In **MQTT Integration Panel**:
- **Alerts Sent**: Total fire alerts sent this session
- **Photos Sent**: Total fire photos sent
- **Last Alert**: Timestamp of last alert

### Export Logs

```javascript
// In browser console
localStorage.getItem('whatsappv2_mqtt_config')
localStorage.getItem('whatsappv2_recipients')
```

### Clear Data

```javascript
// Clear recipients
localStorage.removeItem('whatsappv2_recipients')

// Clear config
localStorage.removeItem('whatsappv2_mqtt_config')
```

---

## 🆘 Support & Resources

### Documentation
- **Go WhatsApp API:** https://github.com/aldinokemal/go-whatsapp-web-multidevice
- **Whatsmeow Library:** https://github.com/tulir/whatsmeow
- **This Project:** See README.md

### Community
- **Issues:** Open issue di GitHub project ini
- **Discussions:** GitHub Discussions
- **Email:** support@yourproject.com

---

## 🎉 Success Criteria

Sistem berhasil jika:
- ✅ QR Code generated dalam <5 detik
- ✅ Device connected dalam <30 detik after scan
- ✅ Message delivered dalam <2 detik
- ✅ MQTT → WhatsApp latency <5 detik
- ✅ Image delivery success rate >95%
- ✅ No spam bans for 7 days continuous use

---

## 📝 Changelog

### Version 2.0.0 (Current)
- ✅ WhatsApp V2 integration with go-whatsapp-web-multidevice
- ✅ Multi-device support
- ✅ MQTT integration with auto-send
- ✅ Rich message types (text, image, location)
- ✅ Smart cooldown mechanism
- ✅ Real-time fire detection photos

### Version 1.0.0 (Legacy)
- WhatsApp Baileys integration
- Single device only
- Text messages only

---

**🎯 Status:** ✅ **READY FOR PRODUCTION**

**Author:** Your Team  
**Last Updated:** November 11, 2025  
**License:** MIT
