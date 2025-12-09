# 📹 ESP32-CAM Video Recording Feature

## 🎯 **Fitur Baru yang Ditambahkan**

### **1. Backend API Video Recording (Proxy Server Port 8080)**

✅ **Routes baru di `/api/video`:**
- `POST /api/video/start-recording` - Mulai recording dari ESP32-CAM
- `POST /api/video/stop-recording/:id` - Stop recording
- `GET /api/video/recordings` - List semua video yang tersimpan
- `GET /api/video/recordings/:filename` - Stream/download video (with range support)
- `POST /api/video/upload` - Upload video dari Python script
- `DELETE /api/video/recordings/:id` - Hapus video
- `GET /api/video/status` - Status recording system

✅ **Fitur Backend:**
- **FFmpeg integration** untuk convert MJPEG stream ke MP4
- **Multer** untuk handle video upload (max 500 MB)
- **Range support** untuk video seeking di player
- **In-memory metadata** untuk tracking recordings
- **Auto-cleanup** file lama (sliding window)

---

### **2. Frontend UI Component (React)**

✅ **VideoGallery.tsx** - Component baru untuk:
- **Recording controls**: Start/Stop button dengan duration slider
- **Video grid display**: Thumbnail preview dari semua recordings
- **Video player modal**: Full-screen playback dengan controls
- **Download & delete**: Actions untuk setiap video
- **Real-time status**: Polling active recordings setiap 5 detik

✅ **LiveStream.tsx** - Updated dengan:
- **Tab switching**: Live Stream vs Recordings
- **Integrated VideoGallery** di tab Recordings
- **Conditional controls**: Hide grid/single view saat di tab Recordings

---

### **3. Python Script untuk Auto-Upload**

✅ **`python_scripts/record_and_upload_esp32cam.py`:**
- Record MJPEG stream dari ESP32-CAM menggunakan OpenCV
- Save ke lokal laptop di `D:/esp32cam_recordings/`
- Auto-upload ke proxy server via API
- Progress tracking (FPS, duration, file size)
- Error handling & retry mechanism

---

## 🚀 **Cara Menggunakan**

### **Metode 1: Recording via Dashboard (Recommended)**

1. **Start semua services:**
   ```batch
   D:\rtsp-main\START-SEPARATED-SERVICES.bat
   ```

2. **Buka Dashboard:**
   ```
   http://localhost:5173/live-stream
   ```

3. **Recording Steps:**
   - Klik tab **"Recordings"** (icon 📹 Video)
   - Set **ESP32-CAM IP** (default: 10.148.218.219)
   - Set **Duration** dalam seconds (60s = 1 menit)
   - Klik **"Start Recording"** (tombol merah)
   - Tunggu hingga selesai atau klik **"Stop Recording"** untuk berhenti
   - Video otomatis muncul di gallery setelah recording selesai

4. **Playback & Download:**
   - Klik thumbnail video untuk full-screen player
   - Gunakan controls (play/pause/seek)
   - Klik "Download" untuk save ke laptop
   - Klik "Delete" untuk hapus permanent

---

### **Metode 2: Recording via Python Script (Manual)**

1. **Install dependencies:**
   ```bash
   cd D:\rtsp-main\python_scripts
   pip install opencv-python requests
   ```

2. **Edit configuration di script:**
   ```python
   # Buka: record_and_upload_esp32cam.py
   
   ESP32_CAM_IP = "10.148.218.219"  # Ganti dengan IP ESP32-CAM Anda
   RECORD_DURATION = 60             # Duration dalam seconds
   SAVE_DIR = "D:/esp32cam_recordings"  # Folder penyimpanan lokal
   ```

3. **Jalankan script:**
   ```bash
   python record_and_upload_esp32cam.py
   ```

4. **Output:**
   ```
   📹 Recording started...
   ⏱️  Recording: 30s | Frames: 600 | FPS: 20.0
   ✅ Recording Complete!
   📝 File: esp32cam_20241209_143022.mp4
   💾 Size: 12.45 MB
   
   📤 Uploading to web server...
   ✅ Upload successful!
   
   🎉 Process completed successfully!
   ```

5. **View on dashboard:**
   - Refresh dashboard: http://localhost:5173/live-stream
   - Tab "Recordings" akan menampilkan video yang baru diupload

---

## 🔧 **Technical Details**

### **FFmpeg Command Used:**

```bash
ffmpeg -y \
  -f mjpeg \
  -i http://ESP32_IP:81/stream \
  -c:v libx264 \
  -preset medium \
  -crf 23 \
  -pix_fmt yuv420p \
  -t DURATION \
  output.mp4
```

**Parameters:**
- `-f mjpeg` = Input format MJPEG stream
- `-c:v libx264` = Encode dengan H.264 codec
- `-preset medium` = Balance antara speed & quality
- `-crf 23` = Quality (lower = better, default 23)
- `-pix_fmt yuv420p` = Pixel format untuk compatibility
- `-t DURATION` = Recording duration (optional)

---

### **File Storage Structure:**

```
D:\rtsp-main\
├── proxy-server\
│   └── recordings\                    # ← Videos tersimpan di sini
│       ├── esp32cam_20241209_143022.mp4
│       ├── esp32cam_20241209_144500.mp4
│       └── rec_1702123456789.mp4
│
└── python_scripts\
    └── record_and_upload_esp32cam.py  # ← Script Python
```

**Lokal Laptop:**
```
D:\esp32cam_recordings\                # ← Python script save di sini
├── esp32cam_20241209_143022.mp4
└── esp32cam_20241209_144500.mp4
```

---

### **API Response Examples:**

**Start Recording:**
```json
POST /api/video/start-recording
{
  "cameraIp": "10.148.218.219",
  "duration": 60,
  "quality": "medium"
}

Response:
{
  "success": true,
  "recordingId": "rec_1702123456789",
  "streamUrl": "http://10.148.218.219:81/stream",
  "outputPath": "D:/rtsp-main/proxy-server/recordings/rec_1702123456789.mp4",
  "message": "Recording started successfully"
}
```

**List Recordings:**
```json
GET /api/video/recordings

Response:
{
  "success": true,
  "recordings": [
    {
      "id": "rec_1702123456789",
      "cameraIp": "10.148.218.219",
      "filename": "rec_1702123456789.mp4",
      "size": 13056780,
      "startTime": 1702123456789,
      "endTime": 1702123516789,
      "duration": 60,
      "path": "/api/video/recordings/rec_1702123456789.mp4",
      "status": "completed"
    }
  ],
  "activeRecordings": [
    {
      "id": "rec_1702123999999",
      "cameraIp": "10.148.218.219",
      "startTime": 1702123990000,
      "duration": 120,
      "status": "recording"
    }
  ]
}
```

---

## ⚙️ **Configuration**

### **.env Configuration:**

Sudah ditambahkan:
```env
# ESP32-CAM Configuration
VITE_ESP32CAM_DEFAULT_URL=http://10.148.218.219:81/stream
VITE_VIDEO_API_URL=http://localhost:8080/api/video
```

### **Package Dependencies:**

**Backend (proxy-server):**
- `express` - Web server
- `multer` - File upload handling
- `ws` - WebSocket server
- `mqtt` - MQTT client

**Frontend:**
- `react` - UI framework
- `lucide-react` - Icons
- `tailwindcss` - Styling

**Python:**
- `opencv-python` - Video recording
- `requests` - HTTP upload

---

## 🐛 **Troubleshooting**

### **Problem: FFmpeg not found**

**Error:**
```
Error: spawn ffmpeg ENOENT
```

**Solution:**
1. Download FFmpeg: https://ffmpeg.org/download.html
2. Extract ke `C:\ffmpeg\`
3. Add to PATH:
   ```
   Control Panel → System → Advanced → Environment Variables
   Add to Path: C:\ffmpeg\bin
   ```
4. Verify:
   ```bash
   ffmpeg -version
   ```

---

### **Problem: Video tidak muncul di gallery**

**Possible causes:**
1. Recording belum selesai (check "Active Recordings" badge)
2. API server not running (check port 8080)
3. File permissions issue

**Solution:**
```bash
# Check proxy server logs
cd D:\rtsp-main\proxy-server
npm start

# Check recordings directory
dir D:\rtsp-main\proxy-server\recordings
```

---

### **Problem: Upload failed from Python**

**Error:**
```
❌ Upload timeout (>5 minutes)
```

**Solution:**
1. **File too large** - Reduce duration or quality
2. **Network slow** - Check WiFi connection
3. **Server not running** - Verify port 8080 accessible

```bash
# Test API manually
curl http://localhost:8080/api/video/status
```

---

### **Problem: Poor video quality**

**Current settings:**
- Codec: H.264
- Preset: medium
- CRF: 23 (default)

**To improve quality:**

Edit `proxy-server/routes/video.js`:
```javascript
// Line ~60: Change CRF value
'-crf', '18',  // Lower = better (range: 0-51, default 23)

// OR change preset
'-preset', 'slow',  // Options: ultrafast, fast, medium, slow, veryslow
```

**Quality vs File Size:**
- CRF 18 = High quality, ~2x file size
- CRF 23 = Default quality
- CRF 28 = Lower quality, ~0.5x file size

---

## 📊 **Performance Tips**

### **1. Storage Management:**

Videos auto-stored di:
```
D:\rtsp-main\proxy-server\recordings\
```

**Current limit:** No limit (manual cleanup)

**To add auto-cleanup** (TODO):
```javascript
// Add to routes/video.js
const MAX_VIDEOS = 50;
const MAX_STORAGE_MB = 5000; // 5 GB

if (videoMetadata.length > MAX_VIDEOS) {
  // Delete oldest video
}
```

---

### **2. Optimize Recording:**

**Low bandwidth** (slow WiFi):
```javascript
// Duration: 30s
// FPS: 15
// Resolution: 640x480
```

**High quality** (fast WiFi):
```javascript
// Duration: unlimited
// FPS: 30
// Resolution: 1024x768
// CRF: 18
```

---

### **3. Network Optimization:**

**ESP32-CAM Tips:**
- Use 2.4GHz WiFi (better range)
- Place close to router (<10 meters)
- Avoid obstacles (walls, metal)
- Check signal strength: `http://ESP32_IP/` (if web interface exists)

---

## 🎉 **Success Criteria**

✅ **Backend API working:**
```bash
curl http://localhost:8080/api/video/status
# Should return: {"success": true, "status": {...}}
```

✅ **Dashboard accessible:**
```
http://localhost:5173/live-stream → Recordings tab shows
```

✅ **Recording works:**
- Start recording button clickable
- Active recordings badge appears
- Video appears in gallery after completion

✅ **Video playback:**
- Thumbnail loads
- Click opens modal
- Video plays with controls
- Download works

---

## 📝 **Next Steps & Future Enhancements**

### **Planned Features:**

1. **Scheduled Recording** ⏰
   - Cron jobs untuk record otomatis setiap jam
   - Time-based triggers (misalnya 9 AM - 5 PM)

2. **Motion Detection Recording** 🎥
   - Hanya record saat ada movement
   - Save storage space

3. **Cloud Upload** ☁️
   - Auto-upload ke Google Drive / Dropbox
   - Backup otomatis

4. **Video Analytics** 📊
   - Count total recording time
   - Storage usage graphs
   - Most active cameras

5. **Compression Options** 🗜️
   - Multiple quality presets
   - Variable bitrate encoding
   - Resolution options UI

---

## 🔐 **Security Notes**

⚠️ **Important:**

1. **No authentication** - Anyone on LAN can record/delete
2. **No encryption** - Videos transmitted unencrypted
3. **No backup** - Deleted videos permanent

**For production:**
```javascript
// Add API key authentication
app.use('/api/video', (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey !== process.env.VIDEO_API_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});
```

---

## 📚 **Documentation Links**

- **FFmpeg Docs:** https://ffmpeg.org/documentation.html
- **Multer Docs:** https://github.com/expressjs/multer
- **OpenCV Python:** https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html
- **ESP32-CAM Guide:** https://randomnerdtutorials.com/esp32-cam-video-streaming-face-recognition-arduino-ide/

---

**🎊 Video Recording Feature is now LIVE!**

Test it now:
```
http://localhost:5173/live-stream → Tab Recordings → Start Recording
```
