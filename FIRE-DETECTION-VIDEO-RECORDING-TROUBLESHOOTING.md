# 🔥 Fire Detection Video Recording - Troubleshooting

## ❌ MASALAH: Video Tidak Tersimpan Meskipun Api Terdeteksi

### 📋 Checklist Diagnosa

#### 1️⃣ **Apakah YOLO Mendeteksi Api?**
Cek terminal output saat running script:
```
Detections: 123 | Verified: 0
```
- ✅ Jika `Detections > 0` → YOLO bekerja
- ❌ Jika `Detections: 0` → YOLO tidak detect api

#### 2️⃣ **Apakah Gemini AI Memverifikasi?**
Cek log di terminal:
```
✅ Fire VERIFIED! Gemini: 0.85 - High confidence fire detected
❌ Fire REJECTED: 0.12 - Not a fire
```
- ✅ Jika ada "Fire VERIFIED" → Recording akan mulai
- ❌ Jika semua "Fire REJECTED" → Tidak akan record

#### 3️⃣ **Apakah Recording Dimulai?**
Cek log:
```
🎬 Recording started: fire_20251209_143055.mp4 (30s)
```
- ✅ Jika muncul → Video sedang direcord
- ❌ Jika tidak muncul → Check kenapa tidak trigger

#### 4️⃣ **Apakah Recording Selesai?**
Cek log setelah 30 detik:
```
✅ Recording complete: fire_20251209_143055.mp4 (30.1s, 12.34MB, 600 frames)
```

#### 5️⃣ **Apakah Upload Berhasil?**
Cek log upload:
```
📤 Uploading: fire_20251209_143055.mp4
✅ Upload successful: fire_20251209_143055.mp4
```

---

## 🛠️ PERBAIKAN YANG SUDAH DILAKUKAN

### ✅ **Fix 1: Model Loading Error**
**Problem:**
```
❌ Error: name 'model' is not defined
```

**Solution:**
Ditambahkan loading YOLO model:
```python
model = YOLO(MODEL_PATH)
print(f"✅ YOLO model loaded successfully!")
```

### ✅ **Fix 2: Fallback Recording Mode**
**Problem:**
- Recording **HANYA** dimulai setelah Gemini verify
- Jika Gemini gagal/timeout → **TIDAK ADA RECORDING**

**Solution:**
Ditambahkan fallback mode dengan 2 cara trigger recording:

#### **Mode 1: Gemini Verification (Primary)**
```python
if result["status"] == "verified":  # Gemini says it's fire
    video_recorder.start_recording(frame, det_info)
```
- Threshold: `GEMINI_SCORE_THRESHOLD = 0.40`
- Cooldown: `GEMINI_COOLDOWN = 1.0` detik (dikurangi dari 2.0)

#### **Mode 2: High-Confidence YOLO (Fallback)**
```python
if conf >= FALLBACK_CONF_THRESHOLD:  # YOLO confidence ≥ 60%
    video_recorder.start_recording(frame, det_info)
```
- Threshold: `FALLBACK_CONF_THRESHOLD = 0.60` (60% confidence)
- Aktif ketika: Gemini tidak tersedia ATAU gagal verify

**Benefits:**
- ✅ Lebih reliable - tidak bergantung 100% pada Gemini
- ✅ Tetap record meskipun Gemini API down
- ✅ Confidence 60% sudah cukup tinggi untuk fire detection

---

## 🔍 CARA DIAGNOSA KENAPA TIDAK RECORD

### **Scenario 1: YOLO Tidak Detect Sama Sekali**
**Gejala:**
```
Detections: 0 | Verified: 0
```

**Penyebab:**
1. Tidak ada api di frame
2. Api terlalu kecil (< MIN_AREA = 150 pixel)
3. Confidence terlalu rendah (< 0.25)

**Solusi:**
- Pastikan ada api yang jelas di kamera
- Dekatkan kamera ke sumber api
- Turunkan `CONF_THRESHOLD` jadi 0.15:
  ```python
  CONF_THRESHOLD = 0.15  # More sensitive
  ```

---

### **Scenario 2: YOLO Detect Tapi Gemini Reject Semua**
**Gejala:**
```
Detections: 45 | Verified: 0
❌ Fire REJECTED: 0.12 - Not a fire
❌ Fire REJECTED: 0.08 - Looks like light reflection
```

**Penyebab:**
- False positive dari YOLO (bukan api)
- Gemini terlalu strict (threshold 0.40)

**Solusi:**
- Pastikan benar-benar ada api (bukan LED/lampu/refleksi)
- Turunkan Gemini threshold:
  ```python
  GEMINI_SCORE_THRESHOLD = 0.30  # Less strict
  ```
- **ATAU** pakai fallback mode (sudah aktif):
  ```python
  FALLBACK_RECORD_ENABLED = True
  FALLBACK_CONF_THRESHOLD = 0.60
  ```

---

### **Scenario 3: Verified Tapi Tidak Record**
**Gejala:**
```
✅ Fire VERIFIED! Gemini: 0.85
(tapi tidak ada "🎬 Recording started")
```

**Penyebab:**
- Recording masih cooldown (60 detik sejak recording terakhir)

**Cek Code:**
```python
RECORD_COOLDOWN = 60  # 60 detik
```

**Solusi:**
- Tunggu 60 detik
- ATAU kurangi cooldown:
  ```python
  RECORD_COOLDOWN = 10  # 10 detik saja
  ```

---

### **Scenario 4: Recording Started Tapi File Tidak Ada**
**Gejala:**
```
🎬 Recording started: fire_20251209_143055.mp4
✅ Recording complete: fire_20251209_143055.mp4 (30.1s)
(tapi file tidak ada di D:\fire_recordings)
```

**Penyebab:**
- Path tidak valid
- Permission error
- Disk penuh

**Solusi:**
Cek error di log:
```python
⚠️  Frame write error: [error message]
```

Ganti path:
```python
RECORD_SAVE_DIR = "D:/fire_recordings"  # Pastikan folder exist
```

---

### **Scenario 5: File Ada Tapi Tidak Upload**
**Gejala:**
```
✅ Recording complete: fire_20251209_143055.mp4
(tapi tidak ada "📤 Uploading")
```

**Penyebab:**
- Auto-upload disabled

**Cek:**
```python
AUTO_UPLOAD_AFTER_RECORD = True  # Harus True
```

**Upload manual:**
```python
UPLOAD_API = "http://localhost:8080/api/video/upload"
```

Cek apakah proxy-server running:
```cmd
netstat -ano | findstr ":8080"
```

---

## 📊 MONITORING TIPS

### **Real-time Monitoring**

1. **Terminal Output:**
   ```
   Detections: 123 | Verified: 5
   ✅ Fire VERIFIED! Gemini: 0.85
   🎬 Recording started: fire_20251209_143055.mp4 (30s)
   🔴 RECORDING  ← Status di OpenCV window
   ✅ Recording complete: fire_20251209_143055.mp4 (30.1s, 12.34MB, 600 frames)
   📤 Uploading: fire_20251209_143055.mp4
   ✅ Upload successful
   ```

2. **Web Dashboard (http://localhost:5173/live-stream):**
   - Tab "Recordings" → Lihat uploaded videos
   - Real-time logs dari WebSocket

3. **File Explorer:**
   - `D:\fire_recordings\` → Local saved videos
   - `D:\rtsp-main\proxy-server\recordings\` → Uploaded videos

---

## ⚙️ KONFIGURASI OPTIMAL

### **Untuk Testing (Sensitive):**
```python
# Detection
CONF_THRESHOLD = 0.15           # Very sensitive
MIN_AREA = 50                    # Accept small fires

# Gemini
GEMINI_SCORE_THRESHOLD = 0.30   # Less strict
GEMINI_COOLDOWN = 0.5            # Verify more often

# Fallback
FALLBACK_RECORD_ENABLED = True
FALLBACK_CONF_THRESHOLD = 0.50  # Lower threshold

# Recording
RECORD_COOLDOWN = 5              # Record every 5 seconds
```

### **Untuk Production (Conservative):**
```python
# Detection
CONF_THRESHOLD = 0.25           # Balanced
MIN_AREA = 150                   # Ignore very small

# Gemini
GEMINI_SCORE_THRESHOLD = 0.40   # Strict verification
GEMINI_COOLDOWN = 1.0            # Balanced

# Fallback
FALLBACK_RECORD_ENABLED = True
FALLBACK_CONF_THRESHOLD = 0.60  # High confidence only

# Recording
RECORD_COOLDOWN = 60             # Prevent spam
```

---

## 🧪 TESTING STEPS

### **1. Test YOLO Detection**
```bash
cd D:\rtsp-main\python_scripts
python fire_detect_record_ultimate.py
```

Pastikan muncul:
```
✅ YOLO model loaded successfully!
✅ Stream connected!
Detections: X | Verified: Y
```

### **2. Test dengan Api Real**
- Nyalakan lilin/korek api di depan ESP32-CAM
- Harus muncul bounding box kuning (YOLO detect)
- Tunggu 1-2 detik → box jadi hijau (Gemini verify)

### **3. Test Fallback Mode**
Matikan Gemini (comment out API key):
```python
GEMINI_API_KEY = ""  # Disable Gemini
```

Detection dengan conf ≥ 60% tetap harus trigger recording.

### **4. Test Recording**
Pastikan muncul:
```
🎬 Recording started: fire_YYYYMMDD_HHMMSS.mp4 (30s)
```

Cek file:
```cmd
dir D:\fire_recordings
```

### **5. Test Upload**
Pastikan proxy-server running:
```cmd
cd D:\rtsp-main\proxy-server
npm start
```

Cek upload log:
```
📤 Uploading: fire_20251209_143055.mp4
✅ Upload successful
```

Buka dashboard:
```
http://localhost:5173/live-stream
Tab: Recordings → Should see video
```

---

## 📁 FILE LOCATIONS

### **Python Script:**
```
D:\rtsp-main\python_scripts\fire_detect_record_ultimate.py
```

### **Videos (Local):**
```
D:\fire_recordings\
fire_20251209_143055.mp4
fire_20251209_143856.mp4
```

### **Videos (Uploaded):**
```
D:\rtsp-main\proxy-server\recordings\
esp32cam_1733724655000_fire_20251209_143055.mp4
```

### **Web Dashboard:**
```
Frontend: http://localhost:5173/live-stream
Backend API: http://localhost:8080/api/video/recordings
WebSocket: ws://localhost:8080/ws
```

---

## 🚨 COMMON ERRORS

### **Error: name 'model' is not defined**
**✅ FIXED** - Model loading sudah ditambahkan

### **Error: [WinError 2] The system cannot find the file specified**
**Cause:** Path tidak valid atau folder tidak exist

**Fix:**
```python
os.makedirs(RECORD_SAVE_DIR, exist_ok=True)
```

### **Error: Connection refused**
**Cause:** Proxy-server tidak running

**Fix:**
```cmd
cd D:\rtsp-main\proxy-server
npm start
```

### **No recording despite fire detection**
**Cause:** 
1. Gemini reject semua
2. Recording cooldown aktif
3. Fallback disabled

**Fix:**
```python
FALLBACK_RECORD_ENABLED = True
FALLBACK_CONF_THRESHOLD = 0.60
```

---

## 📞 QUICK HELP

### **Check System Status:**
```bash
# 1. Python script running?
python fire_detect_record_ultimate.py

# 2. Proxy-server running?
netstat -ano | findstr ":8080"

# 3. Local videos exist?
dir D:\fire_recordings

# 4. Uploaded videos exist?
dir D:\rtsp-main\proxy-server\recordings
```

### **Force Recording (Testing):**
Turunkan semua threshold ke minimum:
```python
CONF_THRESHOLD = 0.10
GEMINI_SCORE_THRESHOLD = 0.20
FALLBACK_CONF_THRESHOLD = 0.30
RECORD_COOLDOWN = 1
```

---

## 🎯 EXPECTED BEHAVIOR

### **Normal Flow:**
1. YOLO detect api → Detections count naik
2. Kirim ke Gemini → Tunggu 1-2 detik
3. Gemini verify → "✅ Fire VERIFIED!"
4. Start recording → "🎬 Recording started"
5. Record 30 detik → "✅ Recording complete"
6. Upload ke server → "📤 Uploading" → "✅ Upload successful"
7. Cooldown 60 detik → Siap record lagi

### **Fallback Flow (Gemini Unavailable):**
1. YOLO detect api dengan conf ≥ 60%
2. Langsung start recording (skip Gemini)
3. Log: "🔥 High-confidence YOLO detection (0.85) - Starting recording"
4. Record 30 detik → Complete → Upload

---

## ✅ SUMMARY

### **Fixes Implemented:**
1. ✅ Model loading error fixed
2. ✅ Fallback recording mode added
3. ✅ Gemini cooldown reduced (2s → 1s)
4. ✅ High-confidence YOLO trigger (≥60%)

### **Current Settings:**
```python
CONF_THRESHOLD = 0.25           # YOLO detection
FALLBACK_CONF_THRESHOLD = 0.60  # YOLO-only recording
GEMINI_SCORE_THRESHOLD = 0.40   # Gemini verification
RECORD_DURATION = 30            # seconds
RECORD_COOLDOWN = 60            # seconds
```

### **Next Steps:**
1. Test dengan api real
2. Monitor terminal output
3. Check folder `D:\fire_recordings`
4. Check web dashboard recordings tab

**Jika masih tidak record, share screenshot terminal output!** 🔥
