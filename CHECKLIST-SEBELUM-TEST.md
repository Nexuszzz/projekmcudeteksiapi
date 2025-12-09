# ✅ CHECKLIST SEBELUM TEST ESP32-CAM → WHATSAPP

## 📋 QUICK CHECK (Paste di CMD)

```batch
curl http://localhost:8080/health && echo. && curl http://localhost:3001/api/whatsapp/status
```

---

## 🔍 STATUS YANG HARUS MUNCUL

### 1️⃣ Proxy Server (Port 8080)
```json
{
  "status": "ok",
  "mqtt": "connected",  ← ✅ WAJIB "connected"
  "clients": 5,
  "fireDetections": 0
}
```

**Jika Error:**
```
curl: (7) Failed to connect to localhost port 8080
```
→ **SOLUSI:** Jalankan `RESTART_ALL_SERVERS.bat`

---

### 2️⃣ WhatsApp Server (Port 3001)
```json
{
  "status": "connected",  ← ✅ WAJIB "connected" (bukan "disconnected")
  "connected": true,      ← ✅ WAJIB true
  "recipientCount": 2,    ← ✅ WAJIB > 0
  "hasSession": true
}
```

**Jika "disconnected":**
```json
{
  "status": "disconnected",  ← ❌ MASALAH!
  "connected": false
}
```
→ **SOLUSI:** 
1. Buka window "WhatsApp Server"
2. Scan QR code dengan HP
3. Tunggu 10 detik
4. Check lagi dengan curl

---

## 🚀 LANGKAH PERSIAPAN

### ✅ STEP 1: Start All Servers
```batch
cd d:\webdevprojek\IotCobwengdev
RESTART_ALL_SERVERS.bat
```

**Tunggu 10 detik**, lalu lanjut step 2.

---

### ✅ STEP 2: Connect WhatsApp

1. **Cari window:** `WhatsApp Server` (auto-open dari restart)
2. **Lihat QR code** di console
3. **Buka WhatsApp di HP** → Menu (⋮) → **Linked Devices**
4. **Tap "Link a Device"**
5. **Scan QR code**
6. **Tunggu 10 detik**

**Verify:**
```batch
curl http://localhost:3001/api/whatsapp/status
```

Harus muncul `"connected": true`

---

### ✅ STEP 3: Check ESP32-CAM

Test koneksi ke ESP32-CAM:
```batch
curl http://10.148.218.219
```

**Jika timeout:**
- Check ESP32-CAM nyala
- Check WiFi connected (LED biru nyala)
- Check IP address benar
- Ping ESP32-CAM: `ping 10.148.218.219`

---

### ✅ STEP 4: Prepare Fire Source

Siapkan:
- 🔥 Korek api / lighter
- 🕯️ Lilin
- 📍 Posisi depan kamera ESP32-CAM (jarak 20-50cm)

---

## 🎯 READY TO TEST!

Jika semua checklist ✅, jalankan:

```batch
cd d:\zakaiot
python fire_detect_esp32_ultimate.py
```

Input:
```
Masukkan IP ESP32-CAM: 10.148.218.219
```

**Dekatkan api** → Tunggu deteksi → **Check WhatsApp HP!**

---

## 🪟 MONITOR 3 WINDOWS

### Window 1: Python Console
```
🔥 FIRE DETECTED! conf=0.89
✅ Gemini Verified: REAL FIRE
📱 SENDING FIRE DETECTION TO WHATSAPP...
✅ WhatsApp: Photo sent successfully!
```

### Window 2: Proxy Server
```
🔥 Fire detection logged: fire_xxx
✅ Fire photo published to MQTT topic: lab/zaks/fire_photo
```

### Window 3: WhatsApp Server
```
📸 Handling fire detection with photo...
✅ Fire photo alert sent to zal
✅ Fire photo alert sent to 6287847529293
```

---

## ❌ TROUBLESHOOTING CEPAT

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `curl: (7) Failed to connect port 8080` | Proxy Server mati | `RESTART_ALL_SERVERS.bat` |
| `"status": "disconnected"` | WhatsApp belum connected | Scan QR code |
| `"recipientCount": 0` | Recipients kosong | `FIX_RECIPIENTS.bat` atau `ADD_RECIPIENT.bat` |
| `Connection timeout ESP32` | ESP32-CAM offline | Restart ESP32-CAM |
| `"Cannot reach proxy server"` | Proxy mati | `RESTART_ALL_SERVERS.bat` |

---

## 📊 ALUR SINGKAT

```
ESP32-CAM (stream) 
    ↓
Python (detect)
    ↓ upload photo
Proxy Server (save + MQTT publish)
    ↓ MQTT message
WhatsApp Server (receive + send)
    ↓ Baileys API
WhatsApp Recipients (receive message + photo)
```

---

## ✅ FINAL CHECK

Paste ini di CMD:

```batch
@echo off
echo.
echo Checking Proxy Server...
curl -s http://localhost:8080/health
echo.
echo.
echo Checking WhatsApp Server...
curl -s http://localhost:3001/api/whatsapp/status
echo.
echo.
echo Checking ESP32-CAM...
curl -s -I http://10.148.218.219 | findstr "HTTP"
echo.
echo.
echo ============================================
echo If all checks PASS, you are READY TO TEST!
echo ============================================
pause
```

**Jika semua ✅ → SIAP TEST! 🔥📸📱**

---

**Updated:** November 3, 2025  
**Status:** Production Ready ✅
