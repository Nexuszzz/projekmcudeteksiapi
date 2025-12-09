# 🔧 QUICK FIX - Voice Call Server Error

## ❌ Error Yang Terjadi

```
Connection Error
Failed to connect to voice call server.
Error: Unexpected token '<', "<!DOCTYPE "... is not valid JSON
```

---

## 🎯 PENYEBAB

Server mengembalikan **HTML** bukan **JSON**, yang artinya:

1. ❌ **Voice-call-server TIDAK RUNNING**
2. ❌ Port 3002 tidak accessible
3. ❌ Server crash atau error

---

## ✅ SOLUSI CEPAT

### **Option 1: Otomatis (Recommended)** ⚡

**Double-click file ini:**
```
d:\IotCobwengdev-backup-20251103-203857\FIX-VOICE-CALL-SERVER.bat
```

Script akan:
- ✅ Check apakah server running
- ✅ Kill old process if needed
- ✅ Restart voice-call-server
- ✅ Verify server started successfully

**Tunggu sampai muncul:**
```
✅ Voice Call Server is running on port 3002!
```

**Lalu:**
1. Kembali ke dashboard
2. **Refresh page** (Ctrl+R atau F5)
3. ✅ Error hilang!

---

### **Option 2: Manual** 🛠️

#### **Step 1: Check Server Status**

```powershell
# Check if port 3002 is in use
netstat -ano | findstr ":3002"
```

**If empty:** Server tidak running ❌

**If shows PID:** Server running tapi ada masalah ⚠️

#### **Step 2: Start Voice Call Server**

```powershell
# Kill old process (if any)
# Get PID from netstat output, then:
taskkill /F /PID <PID_NUMBER>

# Navigate to project
cd d:\IotCobwengdev-backup-20251103-203857

# Start server
cd voice-call-server
npm start
```

**Expected Output:**
```
============================================================
📞 Voice Call Server (Twilio)
📡 Running on http://localhost:3002
============================================================

✅ Twilio Initialized
   Account: AC123...
   Phone: +12174398497

💡 API Endpoints:
   GET  /health
   GET  /api/voice-call/config
   GET  /api/voice-call/numbers
   POST /api/voice-call/numbers
   DEL  /api/voice-call/numbers/:id
   POST /api/voice-call/test
   POST /api/voice-call/test-advanced

📡 MQTT Broker: mqtt://localhost:1883
🟢 MQTT Connected to broker
✅ Subscribed to topic: lab/zaks/fire_photo
```

#### **Step 3: Verify Server**

**Test health endpoint:**
```powershell
curl http://localhost:3002/health
```

**Expected:**
```json
{
  "status": "ok",
  "service": "voice-call-server",
  "port": 3002,
  "twilio": {
    "enabled": true,
    "configured": true
  },
  "mqtt": {
    "connected": true
  },
  "uptime": "0h 0m 15s"
}
```

#### **Step 4: Test Config Endpoint**

```powershell
curl http://localhost:3002/api/voice-call/config
```

**Expected:**
```json
{
  "enabled": true,
  "configured": true,
  "phoneNumber": "+12174398497",
  "voiceUrl": "http://localhost:3002/api/twilio/voice",
  "emergencyNumbersCount": 1
}
```

#### **Step 5: Refresh Dashboard**

1. Go to: http://localhost:5173
2. Press **Ctrl+R** or **F5**
3. ✅ Error should be gone!

---

## 🔍 TROUBLESHOOTING

### **Error: "Cannot find module 'twilio'"**

```powershell
cd voice-call-server
npm install
npm start
```

### **Error: "TWILIO_ACCOUNT_SID is not defined"**

**Fix .env file:**

```powershell
cd voice-call-server
notepad .env
```

**Add your Twilio credentials:**
```env
TWILIO_ACCOUNT_SID=AC1234567890abcdef
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+12174398497
PORT=3002
```

**Save and restart:**
```powershell
npm start
```

### **Error: Port 3002 already in use**

**Find and kill the process:**

```powershell
# Find PID
netstat -ano | findstr ":3002"

# Kill process (replace <PID> with actual PID)
taskkill /F /PID <PID>

# Start server
npm start
```

### **Error: "Twilio not enabled"**

**Check Twilio credentials:**

1. Go to: https://console.twilio.com
2. Copy Account SID and Auth Token
3. Update `voice-call-server\.env`
4. Restart server

---

## 🚀 START ALL SERVERS (Complete Reset)

**If nothing works, start from scratch:**

### **Step 1: Stop All**

```powershell
# Kill all Node.js processes
taskkill /F /IM node.exe
```

### **Step 2: Start Everything**

```powershell
cd d:\IotCobwengdev-backup-20251103-203857
🚀-START-HERE-SEPARATED.bat
```

**Wait for all 4 services:**
```
✅ Proxy Server (8080)
✅ WhatsApp Server (3001)
✅ Voice Call Server (3002)
✅ Dashboard (5173)
```

### **Step 3: Verify**

**Check all ports:**
```powershell
netstat -ano | findstr ":8080 :3001 :3002 :5173"
```

**Should show 4 ports in use.**

### **Step 4: Open Dashboard**

```
http://localhost:5173
```

**✅ Everything should work now!**

---

## 🎯 PREVENTION

### **Always Start With:**

```powershell
cd d:\IotCobwengdev-backup-20251103-203857
🚀-START-HERE-SEPARATED.bat
```

**This ensures:**
- All servers start in correct order
- Dependencies loaded
- Ports available
- Logs visible

### **Don't:**

- ❌ Start servers individually (unless debugging)
- ❌ Close terminal windows
- ❌ Use Ctrl+C without restarting
- ❌ Change port numbers

---

## ✅ SUCCESS CHECKLIST

After fixing, verify:

- [ ] Voice call server running on port 3002
- [ ] Health check returns JSON: `http://localhost:3002/health`
- [ ] Config returns JSON: `http://localhost:3002/api/voice-call/config`
- [ ] Dashboard loads without errors
- [ ] "Emergency Voice Calls" section visible
- [ ] "Twilio Enabled" shows with green checkmark
- [ ] Can add emergency numbers
- [ ] "Test Call" button works
- [ ] "5 Tests" button works

---

## 📞 QUICK TEST

After server starts, test immediately:

```powershell
# Test 1: Health
curl http://localhost:3002/health

# Test 2: Config
curl http://localhost:3002/api/voice-call/config

# Test 3: Numbers
curl http://localhost:3002/api/voice-call/numbers
```

**All should return JSON (not HTML)!**

---

## 🎉 DONE!

If error persists after all steps:

1. Check console logs in browser (F12)
2. Check voice-call-server terminal for errors
3. Verify .env file has correct Twilio credentials
4. Try different browser (Chrome, Firefox, Edge)
5. Check firewall/antivirus not blocking port 3002

---

**Updated: Nov 8, 2024, 06:30 WIB**
**Made with 🔧 to fix voice call server errors quickly**
