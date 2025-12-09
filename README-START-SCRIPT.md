# 🚀 Quick Start Guide

## ⚡ Cara Paling Cepat

**Double-click file ini:**
```
🚀-START-HERE.bat
```

Atau:
```
START-ALL-SERVICES.bat
```

**Done!** Semua services akan start otomatis.

---

## ❌ JANGAN Gunakan Script Lama!

### Script LAMA (BROKEN):
```
start-fire-detection-complete.bat          ← MISSING WhatsApp Server!
start-fire-detection-system.bat           ← Old version
RESTART_ALL_SERVERS.bat                   ← For troubleshooting only
```

**Problem:** Missing WhatsApp Server = No alerts!

---

## ✅ Script BARU (WORKING):

### Pilihan 1: Quick Start (RECOMMENDED!)
```
🚀-START-HERE.bat
```
- Paling mudah
- Auto-call complete script
- Just double-click!

### Pilihan 2: Complete with Details
```
START-ALL-SERVICES.bat
```
- Full details
- Health checks
- Service verification
- Troubleshooting info

### Pilihan 3: Fixed Version (Minimal)
```
start-fire-detection-complete-FIXED.bat
```
- Basic functionality
- Less verbose
- No verification

---

## 📊 Yang Di-Start:

### ✅ 4 Services:

1. **Proxy Server** (Port 8080)
   - Backend API
   - MQTT integration
   - Fire detection endpoint

2. **WhatsApp Server** (Port 3001) ⭐ PENTING!
   - WhatsApp notifications (Baileys)
   - Emergency voice calls (Twilio)
   - Recipient management

3. **Dashboard Frontend** (Port 5173)
   - Web UI
   - Real-time monitoring
   - Configuration

4. **Python Fire Detection** (Manual)
   - ESP32-CAM connection
   - YOLO detection
   - Gemini AI verification

---

## 🔍 Verification

Setelah start, check ini:

### ✅ Proxy Server:
```
http://localhost:8080/health
```
Response: `{"status":"ok"}`

### ✅ WhatsApp Server:
```
http://localhost:3001/api/whatsapp/status
```
Response: `{"status":"..."}`

### ✅ Voice Call API:
```
http://localhost:3001/api/voice-call/config
```
Response: `{"enabled":true,...}`

### ✅ Dashboard:
```
http://localhost:5173
```
Opens web UI

---

## 🚨 Troubleshooting

### Issue: Services not starting

**Solution:**
```bash
# Kill all node processes
taskkill /F /IM node.exe

# Start again
🚀-START-HERE.bat
```

---

### Issue: Port already in use

**Solution:**
```bash
# Check what's using the port
netstat -ano | findstr ":8080"
netstat -ano | findstr ":3001"
netstat -ano | findstr ":5173"

# Kill specific process
taskkill /F /PID [PID_NUMBER]
```

---

### Issue: Voice calls not working

**Check:**
1. WhatsApp Server window shows Twilio status
2. Run diagnostic:
   ```bash
   curl http://localhost:3001/api/voice-call/config
   ```
3. Look for: `"enabled": true`
4. If `false`, add Twilio credentials to `whatsapp-server\.env`

---

## 📱 Next Steps After Starting

### 1. Open Dashboard
```
http://localhost:5173
```

### 2. Configure WhatsApp (if not connected)
- Go to: WhatsApp Settings
- Generate Pairing Code
- Enter code in WhatsApp app

### 3. Add Recipients
- Go to: WhatsApp Integration
- Add phone numbers for WhatsApp alerts

### 4. Add Emergency Numbers (NEW!)
- Scroll to: "Emergency Voice Calls"
- Click: "Add Number"
- Enter: Phone with country code (+628...)
- Enter: Name

### 5. Start Fire Detection
```bash
cd d:\zakaiot
python fire_detect_esp32_ultimate.py
```

### 6. Test!
Trigger fire detection and check:
- ✅ WhatsApp message sent
- ✅ Emergency voice call made
- ✅ ESP32 buzzer activated

---

## 🎯 Alert Flow

When fire detected:

```
🔥 Fire Detected
    ↓
Gemini AI Verification
    ↓
✅ Confirmed Fire
    ↓
┌──────────────┬────────────────┬──────────────┐
│              │                │              │
↓              ↓                ↓              ↓
📱 WhatsApp    📞 Voice Call    🚨 Buzzer     📊 Dashboard
Message        (Twilio)         (MQTT)        Update
```

---

## 💡 Tips

- ✅ Keep all terminal windows open
- ✅ Monitor each window for errors
- ✅ WhatsApp must be connected for alerts
- ✅ Voice calls require Twilio credentials
- ✅ Press F12 in browser for debug logs
- ✅ Check MQTT connection in logs

---

## 📁 File Structure

```
d:\IotCobwengdev-backup-20251103-203857\
│
├── 🚀-START-HERE.bat                    ← USE THIS!
├── START-ALL-SERVICES.bat               ← Complete version
├── start-fire-detection-complete-FIXED.bat  ← Minimal fixed
│
├── ❌ start-fire-detection-complete.bat      ← OLD, DON'T USE!
│
├── proxy-server\                        ← Backend API
├── whatsapp-server\                     ← Alerts & Calls
├── src\                                 ← Frontend
│
└── Documentation:
    ├── COMPARISON-OLD-VS-NEW.md         ← Script comparison
    ├── SCRIPT-ANALYSIS-SUMMARY.md       ← Detailed analysis
    ├── FINAL-FIX-INSTRUCTIONS.md        ← Voice call fix
    └── README-START-SCRIPT.md           ← This file
```

---

## ⚙️ Configuration Files

### Required .env files:

1. **proxy-server\.env**
   - MQTT credentials
   - Server port

2. **whatsapp-server\.env**
   - MQTT credentials
   - WhatsApp config
   - **Twilio credentials** (for voice calls)

---

## 📞 Voice Call Setup

### If voice calls not working:

1. Check `whatsapp-server\.env` has:
   ```env
   TWILIO_ACCOUNT_SID=AC...
   TWILIO_AUTH_TOKEN=...
   TWILIO_PHONE_NUMBER=+1...
   TWILIO_VOICE_URL=https://demo.twilio.com/welcome/voice/
   ```

2. Restart WhatsApp Server window

3. Verify:
   ```bash
   curl http://localhost:3001/api/voice-call/config
   ```

4. Look for: `"enabled": true`

---

## 🎉 Success Criteria

System is working when:

- ✅ 3 terminal windows open (Proxy, WhatsApp, Dashboard)
- ✅ All health checks pass
- ✅ Dashboard loads at http://localhost:5173
- ✅ WhatsApp status shows "connected"
- ✅ Voice call config shows "enabled: true"
- ✅ Can add emergency numbers
- ✅ Fire detection triggers alerts

---

## 🆘 Need Help?

### Documentation:
- `COMPARISON-OLD-VS-NEW.md` - Script differences
- `SCRIPT-ANALYSIS-SUMMARY.md` - Technical details
- `TWILIO-VOICE-CALL-SETUP.md` - Voice call setup
- `FINAL-FIX-INSTRUCTIONS.md` - Troubleshooting

### Quick Tests:
```bash
# Test all endpoints
curl http://localhost:8080/health
curl http://localhost:3001/api/whatsapp/status
curl http://localhost:3001/api/voice-call/config
```

### Check Logs:
- Proxy Server window
- WhatsApp Server window (most important!)
- Dashboard window
- Browser console (F12)

---

**🔥 System Ready! Stay Safe! 🚨**
