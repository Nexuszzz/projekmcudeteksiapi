# 📞 Test Call Feature - User Guide

## 🎯 Fitur Test Call di Dashboard

Fitur **Test Call** memungkinkan Anda untuk **test koneksi Twilio** dan memastikan nomor emergency bisa menerima panggilan SEBELUM terjadi kebakaran sungguhan.

---

## 🖥️ Tampilan di Dashboard

### **Lokasi Fitur:**
```
Dashboard → Emergency Voice Calls Section
```

### **Button Test Call:**

Setiap emergency number yang ditambahkan akan memiliki button:

**SEBELUM TEST:**
```
┌─────────────────────────────────────────────────────────┐
│  👤 Security Team                                       │
│  📞 +6289677175597                                      │
│  📅 Added: 05 Nov 2024, 20:48                          │
│                                                         │
│                              [📤 Test Call]  [🗑️]      │
└─────────────────────────────────────────────────────────┘
```

**SESUDAH TEST (Berhasil):**
```
┌─────────────────────────────────────────────────────────┐
│  👤 Security Team                                       │
│  📞 +6289677175597                                      │
│  📅 Added: 05 Nov 2024, 20:48                          │
│                                                         │
│                              [✅ Tested]  [🗑️]         │
└─────────────────────────────────────────────────────────┘
```

**LOADING STATE:**
```
┌─────────────────────────────────────────────────────────┐
│  👤 Security Team                                       │
│  📞 +6289677175597                                      │
│  📅 Added: 05 Nov 2024, 20:48                          │
│                                                         │
│                              [⏳ Calling...]  [🗑️]     │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Cara Menggunakan

### **Step 1: Tambah Emergency Number**

1. Buka Dashboard: `http://localhost:5173`
2. Scroll ke section **"Emergency Voice Calls"**
3. Klik button **"Add Number"**
4. Masukkan:
   - Phone Number: `+6289677175597` (dengan kode negara)
   - Name: `Security Team` (opsional)
5. Klik **"Add Number"**

### **Step 2: Test Call**

1. Cari nomor yang baru ditambahkan di list
2. Klik button **"Test Call"** (warna biru dengan icon 📤)
3. Akan muncul konfirmasi dialog:
   ```
   🔔 Test Emergency Call
   
   This will make a real phone call to:
   Security Team
   +6289677175597
   
   You will hear:
   "This is a test call from the Fire Detection 
   Voice Call Server. If you can hear this message, 
   the system is working correctly."
   
   Proceed?
   ```
4. Klik **OK** untuk melanjutkan

### **Step 3: Tunggu Panggilan**

1. Button akan berubah menjadi **"Calling..."** dengan animasi loading
2. Tunggu 5-30 detik
3. **Nomor telepon Anda akan BERDERING!** 📞
4. Angkat telepon dan dengar pesan otomatis

### **Step 4: Verifikasi Hasil**

**Jika BERHASIL:**
- ✅ Dashboard akan show success message dengan Call SID
- Button berubah jadi hijau: **"✅ Tested"**
- Tooltip menunjukkan waktu test terakhir

**Jika GAGAL:**
- ❌ Dashboard akan show error message
- Penjelasan lengkap kenapa gagal
- Solusi untuk fix masalah

---

## 📊 Status Messages

### **✅ Success Message:**
```
✅ Test call initiated successfully!
📞 Calling Security Team...
🆔 Call SID: CA1234567890abcdef
📊 Status: queued

⏳ Please wait for the call on +6289677175597
If you don't receive it within 30 seconds, check if 
the number is verified (trial accounts).
```

### **❌ Error: Number Not Verified (Trial Account)**
```
❌ Number Not Verified (Trial Account)

The number +6289677175597 is not verified...

📋 To verify this number:
1. Go to: console.twilio.com
2. Navigate to: Phone Numbers → Manage → Verified Caller IDs
3. Click "Add a new Caller ID"
4. Enter: +6289677175597
5. Verify via SMS code

Or upgrade to a paid Twilio account to call any number.
```

### **❌ Error: Connection Error**
```
❌ Connection Error

Failed to connect to voice call server.
Error: Network error

Please ensure voice-call-server is running on port 3002.
```

---

## 🎯 Fitur Detail

### **1. Visual Feedback**

**Button States:**
- 🔵 **Blue** = Belum pernah di-test
- 🟢 **Green** = Sudah pernah di-test (verified working)
- ⏳ **Loading** = Sedang dalam proses call

### **2. Tooltip Informasi**

**Hover mouse di button untuk lihat:**
- Belum test: "🔔 Click to make a test call\nVoice message will be played"
- Sudah test: "Last Test: 06 Nov 2024, 20:48\nCall SID: abcdef12"

### **3. Test Call History**

Sistem menyimpan hasil test terakhir:
- Timestamp (kapan di-test)
- Call SID (ID panggilan dari Twilio)
- Status (queued, ringing, in-progress, completed)

### **4. Responsive Design**

**Desktop:**
- Button menampilkan icon + text: "📤 Test Call"

**Mobile/Tablet:**
- Button menampilkan icon saja: "📤"
- Text disembunyikan untuk save space

---

## 🔧 Backend API

### **Endpoint:**
```
POST http://localhost:3002/api/voice-call/test
```

### **Request:**
```json
{
  "phoneNumber": "+6289677175597",
  "message": "Custom message (optional)"
}
```

### **Response (Success):**
```json
{
  "success": true,
  "callSid": "CA1234567890abcdef",
  "status": "queued",
  "to": "+6289677175597",
  "from": "+12174398497",
  "message": "Test call initiated successfully"
}
```

### **Response (Error):**
```json
{
  "success": false,
  "error": "The number is unverified...",
  "code": "21608",
  "moreInfo": "https://www.twilio.com/docs/errors/21608"
}
```

---

## 🐛 Troubleshooting

### **Problem 1: Nomor Tidak Menerima Call**

**Symptoms:**
- API response sukses (Call SID muncul)
- Tapi HP tidak berdering
- Dashboard show success message

**Root Cause:**
- Trial account Twilio
- Nomor belum diverifikasi

**Solution:**
1. Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
2. Click **"Add a new Caller ID"**
3. Enter nomor: `+6289677175597`
4. Choose **SMS verification**
5. Enter code yang diterima via SMS
6. ✅ Test lagi!

### **Problem 2: "Connection Error"**

**Symptoms:**
- Dashboard show: "Failed to connect to voice call server"

**Root Cause:**
- Voice call server tidak running

**Solution:**
```bash
# Check if server running
curl http://localhost:3002/health

# If not, start it:
cd d:\IotCobwengdev-backup-20251103-203857\voice-call-server
npm start
```

### **Problem 3: "Twilio not enabled"**

**Symptoms:**
- Button disabled (tidak bisa diklik)
- Status show: "Twilio Not Configured"

**Root Cause:**
- `.env` file belum di-setup

**Solution:**
```bash
cd voice-call-server
# Edit .env
TWILIO_ACCOUNT_SID=ACxxxxx
TWILIO_AUTH_TOKEN=xxxxx
TWILIO_PHONE_NUMBER=+12174398497

# Restart server
npm start
```

### **Problem 4: Button Tidak Muncul**

**Symptoms:**
- List emergency numbers tampil
- Tapi tidak ada button "Test Call"

**Root Cause:**
- Frontend belum di-update

**Solution:**
```bash
# Stop dashboard (Ctrl+C)
# Restart:
cd d:\IotCobwengdev-backup-20251103-203857
npm run dev
```

---

## 💡 Best Practices

### **1. Test Semua Nomor**

✅ **DO:**
- Test setiap nomor segera setelah ditambahkan
- Re-test setelah upgrade Twilio account
- Test ulang setiap bulan

❌ **DON'T:**
- Menambah banyak nomor tanpa test
- Assume nomor pasti bisa dihubungi
- Lupa test setelah ganti Twilio credentials

### **2. Verify Sebelum Production**

```bash
# Development Checklist:
□ Add emergency number
□ Click "Test Call"
□ Receive call on phone
□ Hear voice message clearly
□ Confirm sistem working

# Production Checklist:
□ All numbers tested
□ All numbers verified (trial) or account upgraded
□ Cooldown configured (2 minutes)
□ Team notified about automatic calls
```

### **3. Monitor Test Results**

**Track:**
- Last test date untuk setiap nomor
- Success rate (berapa % berhasil)
- Common errors
- Call duration (dari Twilio Console)

**Tools:**
- Dashboard (visual indicator)
- Twilio Console: https://console.twilio.com/us1/monitor/logs/calls
- Browser DevTools Console (F12)

---

## 📞 Voice Message Content

### **Default Test Message:**
```
"This is a test call from the Fire Detection Voice Call Server. 
If you can hear this message, the system is working correctly."
```

**Duration:** ~10 seconds

**Language:** English (US)

**Voice:** Polly.Joanna (Female)

### **Custom Message (Advanced):**

Bisa customize message via API:
```javascript
fetch('http://localhost:3002/api/voice-call/test', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    phoneNumber: '+6289677175597',
    message: 'Ini test dari sistem deteksi kebakaran. Jika bisa mendengar pesan ini, sistem berfungsi dengan baik.'
  })
});
```

---

## 🎯 Integration Flow

### **Test Call Flow:**

```
User clicks "Test Call" button
    ↓
Frontend: VoiceCallManager.tsx
    ↓
POST /api/voice-call/test
    ↓
Backend: voice-call-server/server.js
    ↓
Twilio API: calls.create()
    ↓
Twilio makes phone call
    ↓
User receives call
    ↓
Voice message plays
    ↓
Call ends
    ↓
Frontend updates:
  - Button → Green "Tested"
  - Success message shown
  - Test result saved
```

### **Real Fire Detection Flow:**

```
ESP32-CAM detects fire
    ↓
Python: YOLO + Gemini verify
    ↓
POST to Proxy Server (8080)
    ↓
MQTT publish: lab/zaks/fire_photo
    ↓
Voice Call Server receives MQTT
    ↓
Calls ALL emergency numbers
    ↓
Voice message with fire details:
  "Emergency! Fire detected with 89% confidence..."
```

---

## 📊 Metrics & Analytics

### **Track These Metrics:**

1. **Test Call Success Rate:**
   - Total tests: 10
   - Successful: 9
   - Failed: 1
   - Success rate: 90%

2. **Average Test Duration:**
   - From button click to call received
   - Target: <30 seconds

3. **Common Error Codes:**
   - 21608: Unverified number (most common on trial)
   - 21614: Invalid phone number format
   - 20003: Authentication error

4. **Monthly Test Frequency:**
   - Recommended: 1x per nomor per bulan
   - Track last test date

---

## 🎉 Success Criteria

Your Test Call feature is working correctly when:

✅ Button "Test Call" visible untuk setiap emergency number
✅ Click button → confirmation dialog muncul
✅ After confirm → loading state shown
✅ HP berdering dalam <30 detik
✅ Voice message terdengar jelas
✅ Success message dengan Call SID muncul
✅ Button berubah hijau "Tested"
✅ Tooltip show last test timestamp
✅ Error messages helpful dan actionable

---

## 🔗 Related Links

- **Twilio Console:** https://console.twilio.com
- **Verify Numbers:** https://console.twilio.com/us1/develop/phone-numbers/manage/verified
- **Call Logs:** https://console.twilio.com/us1/monitor/logs/calls
- **Error Codes:** https://www.twilio.com/docs/api/errors
- **Voice Pricing:** https://www.twilio.com/voice/pricing

---

## 📝 Summary

Fitur Test Call di dashboard memungkinkan Anda untuk:

1. ✅ Verify nomor bisa dihubungi via Twilio
2. ✅ Test voice message quality
3. ✅ Detect issues sebelum production
4. ✅ Visual tracking (green badge untuk tested numbers)
5. ✅ Detailed error messages dengan solusi
6. ✅ Test history dengan timestamp

**Gunakan fitur ini untuk memastikan sistem emergency call bekerja dengan baik SEBELUM terjadi kebakaran sungguhan!**

---

**Made with 📞 for Fire Safety Testing**
