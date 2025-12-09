# 🔧 ESP32-CAM LIVE STREAM - TROUBLESHOOTING GUIDE

## ❌ PROBLEM: Stream Not Working

Jika stream tidak muncul setelah klik "Start", ikuti langkah-langkah berikut:

---

## ✅ STEP 1: Verify ESP32-CAM is Online

### Test 1: Check Power
```
✓ ESP32-CAM LED indicator harus menyala
✓ Power supply minimal 5V/2A
✓ Jangan gunakan USB port komputer (insufficient current)
```

### Test 2: Open Stream URL Directly in Browser
```
1. Copy URL: http://10.148.218.219:81/stream
2. Buka di browser baru (Chrome/Edge)
3. Jika stream muncul → ESP32-CAM OK ✅
4. Jika tidak muncul → ESP32-CAM bermasalah ❌
```

**If stream works in browser but not in dashboard:**
→ Lanjut ke Step 2

**If stream doesn't work in browser:**
→ Lanjut ke Step 3 (ESP32-CAM Setup)

---

## ✅ STEP 2: Fix Dashboard Configuration

### Option A: Use Settings Panel
```
1. Klik tombol "⚙️ Settings" (gear icon)
2. Pastikan URL benar: http://10.148.218.219:81/stream
3. Klik "Test" button → Akan buka stream di tab baru
4. Enable "Auto Reconnect" → Toggle ON
5. Set "Reconnect Delay" → 3 seconds
6. Klik "Apply & Restart"
7. Klik "▶️ Start" button (hijau)
```

### Option B: Check Browser Console
```
1. Tekan F12 (open DevTools)
2. Pilih tab "Console"
3. Klik "▶️ Start" button
4. Lihat console logs:
   ✅ "🎥 Starting ESP32-CAM stream: http://10.148.218.219:81/stream"
   ✅ "✅ Stream frame loaded successfully"
   ❌ "❌ Stream error occurred"
```

### Option C: Force Reload Page
```
1. Tekan Ctrl + Shift + R (hard reload)
2. Clear cache dan reload
3. Klik "▶️ Start" lagi
```

---

## ✅ STEP 3: ESP32-CAM Setup Verification

### Check 1: Get IP Address from Serial Monitor
```arduino
// Upload code ke ESP32-CAM
// Open Serial Monitor (115200 baud)
// Look for output:

WiFi connected
IP address: 10.148.218.219  ← Copy this!
Camera Ready! Stream URL: http://10.148.218.219:81/stream
```

### Check 2: Ping Test
```bash
# Windows Command Prompt
ping 10.148.218.219

# Expected:
Reply from 10.148.218.219: bytes=32 time=10ms TTL=128 ✅

# If timeout:
Request timed out ❌
→ ESP32-CAM not reachable (check WiFi)
```

### Check 3: WiFi Connection
```
✓ ESP32-CAM dan komputer harus di network SAMA
✓ Check SSID di Arduino code cocok dengan WiFi Anda
✓ Distance < 10 meter dari router
✓ No firewall blocking port 81
```

### Check 4: Arduino Code Verification
```cpp
// File: CameraWebServer.ino

// 1. WiFi credentials correct?
const char* ssid = "YOUR_WIFI_SSID";      // ✓ Match
const char* password = "YOUR_PASSWORD";    // ✓ Correct

// 2. Frame size appropriate?
config.frame_size = FRAMESIZE_VGA;  // 640x480 ✓ Good
// Don't use FRAMESIZE_UXGA (too large for WiFi)

// 3. JPEG quality?
config.jpeg_quality = 10;  // 0-63 (lower = better, 10 recommended)

// 4. Camera init successful?
esp_err_t err = esp_camera_init(&config);
if (err != ESP_OK) {
  Serial.printf("Camera init failed: 0x%x", err);  // ❌ Error
  return;
}

// 5. Web server started?
startCameraServer();
Serial.println("Camera Ready!");  // ✓ Should see this
```

---

## ✅ STEP 4: Network Troubleshooting

### Problem: CORS Error in Console
```
Access to Image at 'http://10.148.218.219:81/stream' from origin 'http://localhost:5173'
has been blocked by CORS policy
```

**Solution:**
MJPEG streams should NOT have CORS issues. Jika ada:
```
1. Stream langsung dari ESP32-CAM (bukan lewat proxy)
2. Pastikan URL pakai http:// (bukan https://)
3. Try disable browser security (dev mode):
   chrome.exe --disable-web-security --user-data-dir="C:/temp/chrome"
```

### Problem: High Latency / Low FPS
```
Symptoms:
- FPS < 10
- Latency > 500ms
- Stream choppy/lagging
```

**Solutions:**
```
1. Reduce quality:
   Settings → Quality Preset → "Battery Saver" (320x240)
   
2. Reduce JPEG quality in Arduino:
   config.jpeg_quality = 20;  // Lower = better quality but slower
   
3. Move closer to router
   < 5 meters ideal
   
4. Use 5GHz WiFi (if available)
   Less congestion than 2.4GHz
   
5. Reduce frame size in Arduino:
   config.frame_size = FRAMESIZE_QVGA;  // 320x240
```

### Problem: Connection Keeps Dropping
```
Symptoms:
- Stream starts then stops
- "Retrying... (1/5)" message
- Auto-reconnect triggers multiple times
```

**Solutions:**
```
1. Check ESP32-CAM overheating
   → Add heat sink or cooling fan
   
2. Insufficient power supply
   → Use 5V/2A power adapter (minimum)
   
3. Weak WiFi signal
   → Move closer to router
   → Use WiFi extender
   
4. Network congestion
   → Reduce other devices on network
   → Use dedicated IoT network
```

---

## ✅ STEP 5: Browser Compatibility

### Recommended Browsers:
```
✅ Chrome 90+ (Best support)
✅ Edge 90+ (Chromium-based)
✅ Firefox 88+ (Good support)
❌ Safari (Limited MJPEG support)
❌ Internet Explorer (Not supported)
```

### Browser Settings:
```
1. Enable JavaScript (required)
2. Allow images from all sources
3. Disable ad blockers (may interfere)
4. Clear cache if issues persist
```

---

## ✅ STEP 6: Dashboard Debug Mode

### Enable Debug Info:
When stream error occurs, dashboard shows:
```
┌──────────────────────────────────────┐
│ Debug Information:                   │
│ 📡 URL: http://10.148.218.219:81/... │
│ 🔄 Retry: 2/5 (Auto-reconnect ON)   │
│ 📊 Frames received: 0                │
│ ⏱️ Reconnect delay: 3s               │
└──────────────────────────────────────┘
```

**What to check:**
- URL format correct? (http://IP:81/stream)
- Retry count increasing? (auto-reconnect working)
- Frames received = 0? (no connection established)

### Console Logs:
```javascript
// Open browser console (F12)
// Look for these logs:

🎥 Starting ESP32-CAM stream: http://10.148.218.219:81/stream
✅ Stream frame loaded successfully
⚠️ Connection check failed (this is normal for CORS)
❌ Stream error occurred
🔄 Auto-retry attempt 1/5...
```

---

## ✅ STEP 7: Advanced Fixes

### Fix 1: Force Restart Everything
```bash
# 1. Stop web dashboard
Ctrl + C (in terminal)

# 2. Restart proxy server
cd d:\webdevprojek\IotCobwengdev
.\start-fire-detection-complete.bat

# 3. Power cycle ESP32-CAM
- Disconnect power
- Wait 10 seconds
- Reconnect power
- Wait for boot (5-10 seconds)

# 4. Check Serial Monitor for IP
- Open Arduino IDE
- Tools → Serial Monitor
- Look for "Camera Ready!" message

# 5. Start dashboard
Open http://localhost:5173/#/live-stream
Click "Start"
```

### Fix 2: Re-flash ESP32-CAM
```
If ESP32-CAM not responding:

1. Open Arduino IDE
2. File → Examples → ESP32 → Camera → CameraWebServer
3. Update WiFi credentials:
   const char* ssid = "YOUR_WIFI";
   const char* password = "YOUR_PASSWORD";
4. Select board: "AI Thinker ESP32-CAM"
5. Upload sketch
6. Check Serial Monitor for IP address
7. Test: http://<IP>:81/stream in browser
```

### Fix 3: Factory Reset ESP32-CAM
```
If nothing works:

1. Erase flash:
   esptool.py erase_flash
   
2. Re-upload CameraWebServer sketch

3. Verify in Serial Monitor:
   ✅ WiFi connected
   ✅ IP address displayed
   ✅ Camera Ready message

4. Test stream in browser first
5. Then test in dashboard
```

---

## 📊 EXPECTED BEHAVIOR

### ✅ Normal Operation:
```
1. Click "▶️ Start" button
2. Button changes to "⏸️ Stop" (red)
3. Stream appears within 2-3 seconds
4. "🔴 LIVE" indicator shows in top-right
5. FPS counter updates (bottom-left)
6. Frame counter increases (bottom-right)
7. No error messages
```

### ✅ Performance Metrics:
```
Quality    | FPS  | Latency | Bandwidth
-----------|------|---------|----------
Low        | 15   | < 100ms | 500 KB/s
Medium     | 20   | < 200ms | 1.2 MB/s
High       | 25   | < 300ms | 3.5 MB/s
```

---

## 🎯 QUICK CHECKLIST

Before asking for help, verify:
```
□ ESP32-CAM powered with 5V/2A adapter
□ LED indicator on ESP32-CAM is lit
□ Serial Monitor shows "Camera Ready!" message
□ IP address correct (check Serial Monitor)
□ Stream works when opened directly in browser
□ URL format: http://IP:81/stream (no https, no typos)
□ ESP32-CAM and computer on SAME WiFi network
□ Ping test successful (no timeouts)
□ Dashboard running (http://localhost:5173)
□ Browser console shows no CORS errors
□ Settings panel has correct URL
□ Auto-reconnect is enabled
□ Tried clicking "Restart" button
□ Tried hard refresh (Ctrl + Shift + R)
```

---

## 🆘 STILL NOT WORKING?

### Collect This Information:
```
1. ESP32-CAM IP address: _________________
2. Browser used: _________________
3. Error message in dashboard: _________________
4. Console errors (F12): _________________
5. Serial Monitor output: _________________
6. Stream works in browser? Yes / No
7. Ping test result: Success / Timeout
8. WiFi network same? Yes / No
```

### Test URLs:
```
# Test 1: Stream in browser
http://10.148.218.219:81/stream

# Test 2: Camera info
http://10.148.218.219/

# Test 3: Dashboard
http://localhost:5173/#/live-stream
```

### Debug Command:
```javascript
// Run in browser console (F12):
console.log('Stream URL:', document.querySelector('img[alt*="ESP32"]')?.src);
console.log('Stream loaded:', document.querySelector('img[alt*="ESP32"]')?.complete);
console.log('Natural size:', document.querySelector('img[alt*="ESP32"]')?.naturalWidth);
```

---

## ✅ SUCCESS INDICATORS

You know it's working when:
```
✅ Stream visible in dashboard
✅ 🔴 LIVE indicator shows
✅ FPS counter updates (> 10 FPS)
✅ Frame counter increases
✅ No error overlay
✅ Connection badge shows "Online"
✅ Can take snapshots
✅ Fullscreen works
```

---

## 📚 RELATED DOCUMENTATION

- `ESP32-CAM-COMPLETE-SETUP.md` - Hardware setup
- `ESP32-CAM-LIVE-STREAM-COMPLETE.md` - Full feature guide
- `FIRE-DETECTION-QUICK-START.md` - System setup

---

**If issue persists after ALL steps, provide:**
1. Screenshot of error
2. Browser console logs (F12)
3. Serial Monitor output
4. Network configuration

**Status: 🔧 TROUBLESHOOTING GUIDE COMPLETE**
