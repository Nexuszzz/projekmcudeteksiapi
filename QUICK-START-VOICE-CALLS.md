# 🚨 Quick Start: Twilio Voice Call Integration

## 📱 Setup dalam 5 Menit

### 1️⃣ Configure Twilio Credentials

Edit file `whatsapp-server/.env` (jika belum ada, copy dari `.env.example`):

```bash
cd whatsapp-server
copy .env.example .env
notepad .env
```

Tambahkan credentials Twilio Anda:

```env
# Twilio Voice Call Configuration
TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE
TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE
TWILIO_PHONE_NUMBER=+12174398497
TWILIO_VOICE_URL=https://demo.twilio.com/welcome/voice/
```

### 2️⃣ Install Dependencies

```bash
cd whatsapp-server
npm install
```

This will install:
- `twilio@^5.0.0` (Voice Call SDK)
- Other existing dependencies

### 3️⃣ Start Backend Server

```bash
npm start
```

Expected output:
```
✅ Twilio Voice Call initialized
   Phone: +12174398497
📞 Loaded 0 emergency call numbers
```

### 4️⃣ Start Frontend Dashboard

```bash
cd ..
npm run dev
```

Open browser: `http://localhost:5173`

### 5️⃣ Add Emergency Numbers

Buka dashboard → **WhatsApp Integration** → Scroll ke bawah ke section **"Emergency Voice Calls"**

Click **"Add Number"**:
- Phone Number: `+628123456789` (dengan country code!)
- Name: `Security Team`
- Click **Add Number**

✅ Done! Sistem siap untuk automatic emergency calls!

---

## 🧪 Testing

### Test 1: Manual Test Call

Di dashboard, click tombol **🔔 (Bell icon)** pada nomor yang sudah ditambahkan.

Expected result:
- Nomor telepon akan menerima panggilan otomatis
- Voice message: "Emergency Alert! Fire detected..."

### Test 2: Automatic Trigger dari Fire Detection

1. Jalankan Python fire detection:
   ```bash
   cd d:\zakaiot
   python fire_detect_esp32_ultimate.py
   ```

2. Masukkan ESP32-CAM IP address

3. Deteksi api dengan YOLO + Gemini

4. Automatic flow:
   ```
   Fire Detected → Proxy Server → MQTT → WhatsApp Server
       ↓
   - WhatsApp message dengan foto ✅
   - Emergency voice calls ✅ (NEW!)
   ```

---

## 📊 Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ fire_detect_esp32_ultimate.py                           │
│ (YOLO + Gemini AI)                                      │
└───────────────────┬─────────────────────────────────────┘
                    │ Fire Detected!
                    ↓
┌─────────────────────────────────────────────────────────┐
│ proxy-server (port 8080)                                │
│ POST /api/fire-detection (snapshot + metadata)         │
└───────────────────┬─────────────────────────────────────┘
                    │ Publish MQTT
                    ↓ topic: lab/zaks/fire_photo
┌─────────────────────────────────────────────────────────┐
│ whatsapp-server (port 3001)                             │
│ Subscribe MQTT → Receive fire detection                │
└─────┬───────────────────────────────────────────────┬───┘
      │                                               │
      ↓                                               ↓
┌─────────────────┐                       ┌────────────────────┐
│ Baileys         │                       │ Twilio Voice       │
│ WhatsApp API    │                       │ Call API           │
└────────┬────────┘                       └────────┬───────────┘
         │                                         │
         ↓                                         ↓
   📱 WhatsApp                               📞 Phone Call
   dengan foto                               dengan voice message
```

---

## 🔧 API Endpoints

Base URL: `http://localhost:3001/api/voice-call`

### GET `/numbers`
List semua emergency call numbers

Response:
```json
{
  "success": true,
  "numbers": [
    {
      "id": "1730735280123",
      "phoneNumber": "+628123456789",
      "name": "Security Team",
      "addedAt": 1730735280123
    }
  ],
  "twilioEnabled": true,
  "cooldown": 120
}
```

### POST `/numbers`
Tambah emergency call number

Request:
```json
{
  "phoneNumber": "+628123456789",
  "name": "Security Team"
}
```

Response:
```json
{
  "success": true,
  "number": {
    "id": "1730735280123",
    "phoneNumber": "+628123456789",
    "name": "Security Team",
    "addedAt": 1730735280123
  }
}
```

### DELETE `/numbers/:id`
Hapus emergency call number

Response:
```json
{
  "success": true,
  "message": "Emergency call number removed"
}
```

### POST `/test`
Test manual call

Request:
```json
{
  "phoneNumber": "+628123456789"
}
```

Response:
```json
{
  "success": true,
  "callSid": "CA1234567890abcdef1234567890abcdef",
  "status": "queued",
  "to": "+628123456789",
  "from": "+12174398497"
}
```

### GET `/config`
Check Twilio configuration status

Response:
```json
{
  "enabled": true,
  "configured": true,
  "phoneNumber": "+12174398497",
  "voiceUrl": "https://demo.twilio.com/welcome/voice/",
  "emergencyNumbersCount": 1
}
```

---

## 🎯 Voice Message Format

Default message (English):

> **Emergency Alert!**
> 
> Fire detected with **[confidence]%** confidence at **[location]**.
> 
> Please check the location immediately.
> 
> This is an automated emergency call from the Fire Detection System.
> 
> _(pause 1 second)_
> 
> **Repeating:** Emergency! Fire detected at **[location]**. Confidence level: **[confidence]** percent.

Voice: **Alice** (English, US)
Duration: ~15-20 seconds

---

## ⚙️ Configuration Options

### Cooldown Settings

Di `whatsapp-server/server.js`:

```javascript
const VOICE_CALL_COOLDOWN = 120000; // 2 minutes (default)
```

Ubah sesuai kebutuhan:
- 60000 = 1 minute
- 120000 = 2 minutes (recommended)
- 300000 = 5 minutes

### Custom Voice Message

Edit `handleFireDetectionWithVoiceCall()` function untuk customize TwiML message.

Bahasa Indonesia:
```javascript
const twimlMessage = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="alice" language="id-ID">
    Peringatan darurat! Api terdeteksi dengan tingkat keyakinan ${confidencePercent} persen 
    di lokasi ${location}. Harap segera cek lokasi. Ini adalah panggilan otomatis dari 
    Sistem Deteksi Kebakaran.
  </Say>
</Response>`;
```

---

## 💰 Biaya Twilio

**Outbound calls:**
- Indonesia: ~$0.015/minute
- USA: ~$0.013/minute
- Other countries: Check [Twilio Pricing](https://www.twilio.com/voice/pricing)

**Phone number rental:**
- ~$1.00/month

**Example calculation:**
- 10 emergency calls/month
- ~20 seconds per call = 0.33 minutes
- 10 calls × 0.33 min × $0.015 = **~$0.05/month**

Very affordable for critical safety system! 🔥

---

## ❓ Troubleshooting

### Problem: "Twilio not enabled"

**Check:**
1. File `.env` exists di folder `whatsapp-server/`
2. Credentials valid
3. Restart server

**Fix:**
```bash
cd whatsapp-server
copy .env.example .env
# Edit .env, tambah TWILIO_* credentials
npm start
```

---

### Problem: "Twilio not configured. Please add credentials"

**Cause:** Twilio credentials tidak ada di `.env`

**Fix:** Edit `whatsapp-server/.env`:
```env
TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE
TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE
TWILIO_PHONE_NUMBER=+12174398497
```

---

### Problem: Test call gagal

**Check:**
1. Twilio account active? Login ke [Twilio Console](https://console.twilio.com)
2. Phone number verified?
3. Country code format benar? (`+[country][number]`)
4. Balance cukup?

**Common errors:**
- `21211`: Invalid phone number format → Harus pakai `+`
- `21606`: From number not verified → Verify di Twilio Console
- `20003`: Authentication failed → Check Auth Token

---

### Problem: Calls tidak terkirim saat fire detection

**Debug:**

1. Check MQTT connection:
   ```bash
   curl http://localhost:3001/api/voice-call/config
   ```

2. Check emergency numbers:
   ```bash
   curl http://localhost:3001/api/voice-call/numbers
   ```

3. Check whatsapp-server logs untuk error messages

4. Test manual call untuk verify credentials working

---

## 📁 Files Modified/Created

### Backend:
1. `whatsapp-server/package.json` - Added `twilio` dependency
2. `whatsapp-server/.env.example` - Added Twilio config
3. `whatsapp-server/server.js` - Voice Call Manager implementation
4. `whatsapp-server/emergency-call-numbers.json` - Auto-created (gitignored)

### Frontend:
1. `src/components/VoiceCallManager.tsx` - NEW component
2. `src/components/WhatsAppIntegration.tsx` - Integrated VoiceCallManager

### Python:
1. `fire_detect_esp32_ultimate.py` - Updated documentation

### Documentation:
1. `TWILIO-VOICE-CALL-SETUP.md` - Full setup guide
2. `QUICK-START-VOICE-CALLS.md` - This file (quick reference)

---

## 🎉 Success Checklist

✅ Twilio credentials configured in `.env`  
✅ Dependencies installed (`npm install`)  
✅ Backend server running (port 3001)  
✅ Frontend dashboard accessible (port 5173)  
✅ Emergency numbers added via UI  
✅ Test call berhasil  
✅ Fire detection Python script running  
✅ Automatic calls triggered on fire detection  

---

## 🆚 WhatsApp vs Voice Call

| Aspek | WhatsApp (Baileys) | Voice Call (Twilio) |
|-------|-------------------|---------------------|
| **Type** | Messaging | Phone Call |
| **Urgency** | Medium | 🔴 **High** |
| **Attention** | May be silent | **Loud ringing** |
| **Photo Support** | ✅ Yes | ❌ No |
| **Voice Message** | ❌ No | ✅ Yes |
| **International** | ✅ Free | 💰 Paid |
| **Reliability** | Depends on internet | **Telco network** |
| **Response Time** | ~1-5 sec | **Immediate** |
| **Hard to Ignore** | ❌ No | ✅ **YES!** |

**Best Practice:** Gunakan KEDUA sistem
- WhatsApp: Detailed info + foto
- Voice Call: **Immediate urgent alert**

---

## 🔐 Security Best Practices

**NEVER commit `.env` file!**

❌ Bad:
```bash
git add whatsapp-server/.env
git commit -m "Add credentials"  # JANGAN!
```

✅ Good:
```bash
# .env sudah ada di .gitignore
# Only store in:
# - Local development machine
# - Production server environment variables
```

**Never share publicly:**
- TWILIO_ACCOUNT_SID
- TWILIO_AUTH_TOKEN

---

## 📞 Support & Docs

- **Twilio Console:** https://console.twilio.com
- **Twilio Voice API Docs:** https://www.twilio.com/docs/voice
- **Twilio Pricing:** https://www.twilio.com/voice/pricing
- **TwiML Reference:** https://www.twilio.com/docs/voice/twiml

---

**🔥 Emergency calls = Faster response = Lives saved! 🚨**

Sistem sekarang **PRODUCTION-READY** dengan dual notification:
1. 📱 WhatsApp messages (detailed info + photo)
2. 📞 **Emergency voice calls** (immediate urgent alert)

Stay safe! 🛡️
