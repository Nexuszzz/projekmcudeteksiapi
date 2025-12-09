# 🚀 Quick Reference: Separated Services

## ⚡ Quick Start (3 Steps!)

### 1️⃣ Start All Services
```bash
START-SEPARATED-SERVICES.bat
```

### 2️⃣ Wait for 4 Windows
- Proxy Server (8080)
- WhatsApp Server (3001)
- Voice Call Server (3002) ← NEW!
- Dashboard (5173)

### 3️⃣ Open Dashboard
```
http://localhost:5173
```

**Done!** ✅

---

## 📊 Service Ports

| Service | Port | Purpose | Tech |
|---------|------|---------|------|
| **Proxy Server** | 8080 | Backend + MQTT | Express + MQTT |
| **WhatsApp Server** | 3001 | WhatsApp messaging | Baileys |
| **Voice Call Server** | 3002 | Emergency calls | Twilio |
| **Dashboard** | 5173 | Web UI | React |

---

## 🧪 Quick Test

```bash
# Test all services
TEST-SEPARATED-SERVICES.bat

# Or manual:
curl http://localhost:8080/health              # Proxy
curl http://localhost:3001/api/whatsapp/status # WhatsApp
curl http://localhost:3002/health              # Voice Call
curl http://localhost:3002/api/voice-call/config # Twilio config
```

---

## 🔧 Individual Service Commands

### Start Proxy Server:
```bash
cd proxy-server
npm start
```

### Start WhatsApp Server:
```bash
cd whatsapp-server
npm start
```

### Start Voice Call Server:
```bash
cd voice-call-server
npm start
```

### Start Dashboard:
```bash
npm run dev
```

---

## 🚨 Troubleshooting

### Port Already in Use?

**Port 3001:**
```bash
.\kill-port-3001.bat
```

**Port 3002:**
```bash
for /f "tokens=5" %a in ('netstat -ano ^| findstr :3002') do taskkill /F /PID %a
```

**All Ports:**
```bash
taskkill /F /IM node.exe
```

---

## 📞 Voice Call Setup

### Check if Twilio Configured:
```bash
curl http://localhost:3002/api/voice-call/config
```

**Expected:**
```json
{
  "enabled": true,
  "configured": true,
  "phoneNumber": "+12174398497"
}
```

### If Disabled:

1. Edit `voice-call-server\.env`
2. Add:
   ```env
   TWILIO_ACCOUNT_SID=AC...
   TWILIO_AUTH_TOKEN=...
   TWILIO_PHONE_NUMBER=+1...
   ```
3. Restart: `cd voice-call-server & npm start`

---

## 📱 Add Emergency Numbers

### Via Dashboard UI:
1. Open: http://localhost:5173
2. Go to: WhatsApp Integration
3. Scroll to: Emergency Voice Calls
4. Click: Add Number
5. Enter phone with country code
6. Save!

### Via API:
```powershell
$body = @{phoneNumber="+628123456789"; name="Security"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:3002/api/voice-call/numbers" -Method Post -ContentType "application/json" -Body $body
```

---

## 🔥 Fire Detection Flow

```
Fire Detected (Python)
    ↓
Proxy Server (8080)
    ↓
MQTT Publish
    ↓
    ├─→ WhatsApp Server (3001) → 📱 Message
    │
    └─→ Voice Call Server (3002) → 📞 Call
```

---

## 📁 Important Files

### Configuration:
- `proxy-server\.env`
- `whatsapp-server\.env`
- `voice-call-server\.env` ← NEW!

### Data:
- `whatsapp-server\recipients.json`
- `voice-call-server\emergency-call-numbers.json` ← NEW!

### Logs:
- Check each terminal window separately

---

## ✅ Verification Checklist

After starting services:

- [ ] 4 terminal windows open
- [ ] Proxy Server shows "MQTT Connected"
- [ ] WhatsApp Server shows "MQTT Connected"
- [ ] Voice Call Server shows "Twilio Voice Call initialized"
- [ ] Dashboard opens at http://localhost:5173
- [ ] Can access WhatsApp Integration page
- [ ] Can see "Emergency Voice Calls" section
- [ ] Can add emergency numbers
- [ ] Test call works

---

## 🎯 Common Commands

```bash
# Start all
START-SEPARATED-SERVICES.bat

# Test all
TEST-SEPARATED-SERVICES.bat

# Kill all
taskkill /F /IM node.exe

# Check ports
netstat -ano | findstr ":8080"
netstat -ano | findstr ":3001"
netstat -ano | findstr ":3002"
netstat -ano | findstr ":5173"
```

---

## 💡 Tips

- ✅ Keep all terminal windows open
- ✅ Monitor Voice Call window for call logs
- ✅ WhatsApp and Voice Call logs are SEPARATE
- ✅ Can restart Voice Call without affecting WhatsApp
- ✅ Much easier to debug!

---

## 📖 Full Documentation

- `SEPARATED-ARCHITECTURE.md` - Architecture details
- `COMPARISON-OLD-VS-NEW.md` - Before vs After
- `TWILIO-VOICE-CALL-SETUP.md` - Twilio setup guide

---

**🎉 Enjoy your SEPARATED and CLEAN architecture!** 🚀
