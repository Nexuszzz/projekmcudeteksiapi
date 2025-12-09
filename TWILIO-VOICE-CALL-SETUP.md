# 🔥 Twilio Voice Call Integration - Setup Guide

## 📞 Fitur Baru: Automatic Emergency Voice Calls

Sistem sekarang dapat **melakukan panggilan telepon otomatis** ke nomor emergency saat deteksi api, menggunakan **Twilio Voice API**.

### ✅ Mengapa Menggunakan Twilio (Bukan Baileys)?

**Baileys TIDAK BISA** digunakan untuk voice calls karena:
- Baileys hanya wrapper untuk WhatsApp Web API
- WhatsApp Web tidak expose voice call functionality
- Baileys hanya support: text, images, documents, groups

**Twilio Voice API** adalah solusi yang tepat karena:
- ✅ Support actual phone calls ke nomor telepon regular
- ✅ REST API yang mudah diintegrasikan  
- ✅ Customizable voice message dengan TwiML
- ✅ Global coverage dengan reliable infrastructure

---

## 🚀 Quick Setup

### 1. Setup Twilio Account

Anda sudah memiliki Twilio account dengan credentials:
- **Account SID**: `YOUR_ACCOUNT_SID_HERE`
- **Auth Token**: `YOUR_AUTH_TOKEN_HERE`
- **Phone Number**: `+1 217 439 8497` (dari screenshot)
- **Voice URL**: `https://demo.twilio.com/welcome/voice/`

### 2. Configure Environment Variables

Edit file `whatsapp-server/.env` dan tambahkan:

```env
# Twilio Voice Call Configuration
TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE
TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE
TWILIO_PHONE_NUMBER=+12174398497
TWILIO_VOICE_URL=https://demo.twilio.com/welcome/voice/
```

**⚠️ PENTING**: Jika `.env` belum ada, copy dari `.env.example`:
```bash
cd whatsapp-server
copy .env.example .env
# Edit .env dan tambahkan credentials Twilio di atas
```

### 3. Install Dependencies

```bash
cd whatsapp-server
npm install
```

Twilio SDK sudah ditambahkan ke `package.json`:
```json
"twilio": "^5.0.0"
```

### 4. Start Server

```bash
npm start
```

Server akan menampilkan:
```
✅ Twilio Voice Call initialized
   Phone: +12174398497
```

Jika Twilio tidak configured:
```
⚠️  Twilio Voice Call disabled (missing credentials in .env)
```

---

## 📱 Cara Menggunakan

### A. Tambah Emergency Call Numbers (via API)

**GET** - List emergency numbers:
```bash
curl http://localhost:3001/api/voice-call/numbers
```

**POST** - Add emergency number:
```bash
curl -X POST http://localhost:3001/api/voice-call/numbers \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"+628123456789\", \"name\": \"Security Team\"}"
```

Format nomor telepon:
- ✅ Include country code: `+628123456789` (Indonesia)
- ✅ Include country code: `+12125551234` (USA)
- ❌ Tanpa country code: `08123456789` (akan ditambahkan + otomatis)

**DELETE** - Remove emergency number:
```bash
curl -X DELETE http://localhost:3001/api/voice-call/numbers/{id}
```

**POST** - Test call (manual):
```bash
curl -X POST http://localhost:3001/api/voice-call/test \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"+628123456789\"}"
```

**GET** - Check Twilio configuration:
```bash
curl http://localhost:3001/api/voice-call/config
```

### B. Automatic Trigger dari Fire Detection

Ketika fire detection terjadi (dari Python `fire_detect_esp32_ultimate.py`):

1. **Fire terdeteksi** oleh YOLO + Gemini AI
2. **MQTT message** dikirim ke topic `lab/zaks/fire_photo`
3. **WhatsApp Server** receive message dan trigger:
   - ✅ Send WhatsApp message dengan foto ke semua recipients
   - ✅ **Make emergency voice calls** ke semua emergency numbers
4. **Voice message**: "Emergency Alert! Fire detected with XX% confidence at [location]. Please check immediately."

**Cooldown**: 
- WhatsApp: 60 detik
- Voice Call: **120 detik** (2 menit) - untuk prevent spam calls

### C. Voice Message Content

Default voice message (English):
```
"Emergency Alert! Fire detected with [confidence]% confidence at [location]. 
Please check the location immediately. 
This is an automated emergency call from the Fire Detection System.

Repeating: Emergency! Fire detected at [location]. 
Confidence level: [confidence] percent."
```

Voice: **Alice** (English, US)

---

## 🎯 API Endpoints Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/voice-call/numbers` | List emergency call numbers |
| POST | `/api/voice-call/numbers` | Add emergency call number |
| DELETE | `/api/voice-call/numbers/:id` | Remove emergency call number |
| POST | `/api/voice-call/test` | Test manual call |
| GET | `/api/voice-call/config` | Check Twilio config status |
| POST | `/api/twilio/call-status` | Webhook for call status updates |

---

## 🔧 Troubleshooting

### Problem: "Twilio not enabled"

**Solusi:**
1. Check `.env` file exists: `whatsapp-server/.env`
2. Verify credentials:
   ```env
   TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE
   TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE
   TWILIO_PHONE_NUMBER=+12174398497
   ```
3. Restart server: `npm start`

### Problem: Calls not working

**Solusi:**
1. Verify Twilio account active
2. Check phone number verified in Twilio console
3. Check call logs di Twilio console
4. Verify country code format: `+[country][number]`

### Problem: "No emergency call numbers configured"

**Solusi:**
```bash
curl -X POST http://localhost:3001/api/voice-call/numbers \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"+628123456789\", \"name\": \"Emergency Contact\"}"
```

---

## 📊 Integration dengan Python Fire Detection

File `fire_detect_esp32_ultimate.py` sudah terintegrasi:

1. Fire detection → Send to proxy-server → MQTT publish
2. WhatsApp server subscribe MQTT topic `lab/zaks/fire_photo`
3. Auto trigger: WhatsApp message + Voice calls

**Flow:**
```
Python Fire Detection 
  → HTTP POST to proxy-server
    → MQTT publish (lab/zaks/fire_photo)
      → WhatsApp Server receive
        → Send WhatsApp message
        → Make emergency voice calls (NEW!)
```

---

## 🆚 Comparison: WhatsApp vs Voice Call

| Feature | WhatsApp (Baileys) | Voice Call (Twilio) |
|---------|-------------------|---------------------|
| Type | Messaging | Phone Call |
| Notification | Silent (depends on phone) | **Loud ringing** |
| Urgency | Medium | **High** |
| Attention | May be ignored | **Hard to ignore** |
| Photo Support | ✅ Yes | ❌ No |
| Voice Message | ❌ No | ✅ Yes |
| International | ✅ Free | 💰 Paid (per call) |
| Reliability | Depends on WhatsApp | **Telco infrastructure** |

**Best Practice**: Use BOTH
- WhatsApp: Detailed info dengan foto
- Voice Call: Immediate attention untuk emergency

---

## 💰 Twilio Pricing

- **Outbound calls**: ~$0.01 - $0.05 per minute (depends on country)
- **Incoming calls**: Free
- **Phone number**: ~$1/month

Check: https://www.twilio.com/voice/pricing

---

## 🔐 Security Notes

**⚠️ JANGAN COMMIT `.env` FILE!**

File `.env` sudah di-gitignore. Credentials Twilio harus disimpan **HANYA** di:
- Local `.env` file
- Production server environment variables

**Never expose:**
- TWILIO_ACCOUNT_SID
- TWILIO_AUTH_TOKEN

---

## ✅ Testing

### Test 1: Check Twilio Config
```bash
curl http://localhost:3001/api/voice-call/config
```

Expected output:
```json
{
  "enabled": true,
  "configured": true,
  "phoneNumber": "+12174398497",
  "voiceUrl": "https://demo.twilio.com/welcome/voice/",
  "emergencyNumbersCount": 0
}
```

### Test 2: Add Emergency Number
```bash
curl -X POST http://localhost:3001/api/voice-call/numbers \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"+628123456789\", \"name\": \"Test User\"}"
```

### Test 3: Manual Test Call
```bash
curl -X POST http://localhost:3001/api/voice-call/test \
  -H "Content-Type: application/json" \
  -d "{\"phoneNumber\": \"+628123456789\"}"
```

Check phone - should receive call!

### Test 4: Trigger dari Fire Detection

Run Python fire detection:
```bash
cd d:\zakaiot
python fire_detect_esp32_ultimate.py
```

Deteksi api → Auto call emergency numbers!

---

## 📝 Files Modified

1. `whatsapp-server/package.json` - Added `twilio` dependency
2. `whatsapp-server/.env.example` - Added Twilio config
3. `whatsapp-server/server.js` - Added Voice Call Manager:
   - Twilio client initialization
   - Emergency call numbers management
   - Voice call handler function
   - MQTT integration
   - API endpoints

---

## 🎉 Ready to Use!

Sistem sekarang support **automatic emergency voice calls**:

✅ WhatsApp messaging (photo + text)
✅ **Emergency phone calls** (voice alert)
✅ MQTT integration
✅ Web dashboard
✅ Fire detection dengan AI

**Next Steps:**
1. Setup `.env` dengan Twilio credentials
2. Install dependencies: `npm install`
3. Start server: `npm start`
4. Add emergency numbers via API atau frontend
5. Test dengan fire detection!

---

📞 **Emergency calls = Faster response = Lives saved!** 🔥🚨
