# 🧪 Advanced Test Call - 5 Metode Pengujian Twilio

## 🎯 Overview

Sistem test call telah ditingkatkan dengan **5 metode pengujian berbeda** sesuai dokumentasi resmi Twilio. Setiap metode menguji aspek berbeda dari Twilio Voice API.

---

## 📋 5 Metode Pengujian

### **Method 1: Basic TwiML String** ⭐ PALING SEDERHANA
**Purpose:** Test inline TwiML dengan emergency fire alert message

**Features:**
- ✅ Inline TwiML (tidak butuh public URL)
- ✅ Emergency fire alert message
- ✅ Voice: Polly.Joanna (female, English)
- ✅ Fastest implementation

**Voice Message:**
```
"Fire! Fire! Fire! Emergency! Fire detected! 
This is an automatic emergency call from the 
Fire Detection System."
```

**Twilio API Call:**
```javascript
twilioClient.calls.create({
  twiml: "<Response><Say voice='Polly.Joanna'>Fire! Fire! ...</Say></Response>",
  to: toNumber,
  from: fromNumber
});
```

**Use Case:** Production fire alerts (fastest, most reliable)

---

### **Method 2: TwiML URL** 🌐 EXTERNAL URL
**Purpose:** Test dengan TwiML dari external URL

**Features:**
- ✅ External TwiML from Twilio demo server
- ✅ Test HTTP GET request
- ✅ Demo message from Twilio

**TwiML URL:**
```
http://demo.twilio.com/docs/voice.xml
```

**Voice Message:**
```
"Thanks for calling. Your call is important to us..."
(Standard Twilio demo message)
```

**Twilio API Call:**
```javascript
twilioClient.calls.create({
  url: "http://demo.twilio.com/docs/voice.xml",
  to: toNumber,
  from: fromNumber,
  method: "GET"
});
```

**Use Case:** Test external TwiML server, development testing

---

### **Method 3: Status Callbacks** 📊 TRACKING
**Purpose:** Test call lifecycle tracking dengan webhooks

**Features:**
- ✅ Status callbacks untuk 4 events
- ✅ Track: initiated, ringing, answered, completed
- ✅ POST data ke callback URL
- ✅ Real-time call monitoring

**Voice Message:**
```
"Test three. This call has status callbacks 
enabled for tracking."
```

**Callback Events:**
1. **initiated** - Call dimulai
2. **ringing** - Phone sedang berdering
3. **answered** - Call dijawab
4. **completed** - Call selesai

**Twilio API Call:**
```javascript
twilioClient.calls.create({
  twiml: "<Response><Say>Test three...</Say></Response>",
  to: toNumber,
  from: fromNumber,
  statusCallback: "http://localhost:3002/api/twilio/call-status",
  statusCallbackEvent: ["initiated", "ringing", "answered", "completed"],
  statusCallbackMethod: "POST"
});
```

**Use Case:** Analytics, monitoring, advanced tracking

---

### **Method 4: Call Recording** 📼 RECORDING
**Purpose:** Test perekaman panggilan

**Features:**
- ✅ Record entire call
- ✅ Recording callback webhook
- ✅ Available in Twilio Console
- ✅ Quality assurance

**Voice Message:**
```
"Test four. This call is being recorded for 
quality assurance purposes."
```

**Recording Events:**
1. **in-progress** - Recording dimulai
2. **completed** - Recording selesai

**Twilio API Call:**
```javascript
twilioClient.calls.create({
  twiml: "<Response><Say>Test four...</Say></Response>",
  to: toNumber,
  from: fromNumber,
  record: true,
  recordingStatusCallback: "http://localhost:3002/api/twilio/recording-status",
  recordingStatusCallbackEvent: ["completed", "in-progress"]
});
```

**Recording Access:**
```
https://console.twilio.com/us1/monitor/logs/calls/{CallSID}
→ View recording
→ Download MP3/WAV
→ Playback in browser
```

**Use Case:** Quality assurance, compliance, evidence

---

### **Method 5: Extended Timeout** ⏱️ LONG WAIT
**Purpose:** Test dengan timeout lebih lama (120 detik)

**Features:**
- ✅ 120 seconds timeout (default: 60s)
- ✅ Useful untuk slow network
- ✅ Better for international calls
- ✅ Higher answer rate

**Voice Message:**
```
"Test five. This call has an extended timeout 
of two minutes."
```

**Twilio API Call:**
```javascript
twilioClient.calls.create({
  twiml: "<Response><Say>Test five...</Say></Response>",
  to: toNumber,
  from: fromNumber,
  timeout: 120  // 2 minutes
});
```

**Use Case:** International calls, slow carriers, patient waiting

---

## 🚀 Cara Menggunakan di Dashboard

### **Step 1: Start Services**

```bash
cd d:\IotCobwengdev-backup-20251103-203857
🚀-START-HERE-SEPARATED.bat
```

### **Step 2: Open Dashboard**

```
http://localhost:5173
```

### **Step 3: Add Emergency Number**

1. Scroll to "Emergency Voice Calls"
2. Click "Add Number"
3. Enter phone number (with +)
4. Click "Add Number"

### **Step 4: Advanced Test**

1. Find your number in the list
2. Click **"🔔 5 Tests"** button (PURPLE)
3. Advanced test panel akan muncul
4. Pilih salah satu dari 5 metode
5. Confirm dialog
6. Wait for call!

---

## 🎨 UI Dashboard

### **Normal View:**
```
┌────────────────────────────────────────────────────────┐
│  📞 Security Team                                      │
│  +6289677175597                                        │
│  Added: 07 Nov 2024, 19:53                            │
│                                                        │
│          [📤 Test Call]  [🔔 5 Tests]  [🗑️ Remove]   │
└────────────────────────────────────────────────────────┘
```

### **Advanced Test Panel Open:**
```
┌────────────────────────────────────────────────────────┐
│  📞 Security Team                                      │
│  +6289677175597                                        │
│  Added: 07 Nov 2024, 19:53                            │
│                                                        │
│          [📤 Test Call]  [🔔 5 Tests]  [🗑️ Remove]   │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ 🔔 Advanced Test - Choose Method                 │ │
│  │                                                   │ │
│  │ [1. Basic TwiML - Emergency Fire Alert       ]   │ │
│  │    Simple inline message                         │ │
│  │                                                   │ │
│  │ [2. TwiML URL - Demo Twilio                  ]   │ │
│  │    External TwiML from Twilio demo               │ │
│  │                                                   │ │
│  │ [3. Status Callbacks                         ]   │ │
│  │    Track call lifecycle events                   │ │
│  │                                                   │ │
│  │ [4. Call Recording                           ]   │ │
│  │    Record the test call                          │ │
│  │                                                   │ │
│  │ [5. Extended Timeout                         ]   │ │
│  │    120 seconds timeout                           │ │
│  │                                                   │ │
│  │ [Cancel]                                         │ │
│  └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

## 🔌 Backend API

### **Endpoint:**
```
POST /api/voice-call/test-advanced
```

### **Request:**
```json
{
  "phoneNumber": "+6289677175597",
  "testMethod": 1,  // 1-5
  "customMessage": "Optional custom message"
}
```

### **Response (Success):**
```json
{
  "success": true,
  "callSid": "CA1234567890abcdef",
  "status": "queued",
  "testMethod": 1,
  "testDescription": "Basic TwiML String - Emergency Fire Alert",
  "to": "+6289677175597",
  "from": "+12174398497",
  "additionalInfo": {
    "method": "Inline TwiML",
    "voice": "Polly.Joanna",
    "message": "Fire! Fire! Fire! ..."
  },
  "message": "Test call initiated successfully - Basic TwiML String - Emergency Fire Alert"
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

## 📊 Backend Logging

### **Console Output Example:**

```
📞 Advanced Test Call - Method 3
   To: +6289677175597
   From: +12174398497
✅ Test call created!
   Call SID: CA1234567890abcdef
   Status: queued
   Test: TwiML with Status Callbacks

[8 seconds later...]

📊 Call Status Update (8s later):
   SID: CA1234567890abcdef
   Status: in-progress
   Duration: 0s
   🎤 IN-PROGRESS - Call is active
```

---

## 🧪 Testing Checklist

### **For Each Method:**

- [ ] Click "5 Tests" button
- [ ] Select method 1-5
- [ ] Confirm dialog
- [ ] Success message appears
- [ ] Phone rings
- [ ] Voice message heard
- [ ] Message matches method description
- [ ] Button turns green "Tested"
- [ ] Tooltip shows method number

### **Method-Specific Checks:**

**Method 1:**
- [ ] Emergency fire alert message heard
- [ ] Clear and loud
- [ ] English voice (Joanna)

**Method 2:**
- [ ] Twilio demo message heard
- [ ] "Thanks for calling..." message

**Method 3:**
- [ ] Call received
- [ ] Check backend logs for status callbacks
- [ ] 4 events logged (initiated, ringing, answered, completed)

**Method 4:**
- [ ] Call received
- [ ] Recording message heard
- [ ] Check Twilio Console for recording
- [ ] Recording playable

**Method 5:**
- [ ] Call received
- [ ] Timeout message heard
- [ ] Phone rang even if slow network

---

## 🔧 Configuration

### **Backend Settings:**

**File:** `voice-call-server/server.js`

```javascript
// Status callback URL (Method 3)
statusCallback: `http://localhost:${PORT}/api/twilio/call-status`

// Recording callback URL (Method 4)
recordingStatusCallback: `http://localhost:${PORT}/api/twilio/recording-status`

// Timeout duration (Method 5)
timeout: 120  // seconds
```

### **Auto Status Check:**

Backend automatically checks call status after 8 seconds:
```javascript
setTimeout(async () => {
  const callStatus = await twilioClient.calls(call.sid).fetch();
  console.log(`📊 Call Status Update (8s later):`);
  console.log(`   Status: ${callStatus.status}`);
  console.log(`   Duration: ${callStatus.duration}s`);
}, 8000);
```

---

## 📈 Use Case Matrix

| Method | Best For | Production | Development | Analytics | Recording |
|--------|----------|------------|-------------|-----------|-----------|
| **1. Basic TwiML** | Fire alerts | ✅ YES | ✅ YES | ❌ NO | ❌ NO |
| **2. TwiML URL** | External TwiML | ⚠️ DEPENDS | ✅ YES | ❌ NO | ❌ NO |
| **3. Callbacks** | Tracking | ✅ YES | ✅ YES | ✅ YES | ❌ NO |
| **4. Recording** | Compliance | ✅ YES | ✅ YES | ✅ YES | ✅ YES |
| **5. Long Timeout** | International | ✅ YES | ✅ YES | ❌ NO | ❌ NO |

---

## 💡 Recommendations

### **For Production Fire Detection:**

✅ **Primary:** Method 1 (Basic TwiML)
- Fastest
- Most reliable
- No external dependencies

✅ **Secondary:** Method 4 (Recording)
- Evidence of fire alerts
- Compliance
- Post-incident review

### **For Development:**

✅ **Test All 5 Methods** before deployment
- Verify cada metode bekerja
- Identify best method for your use case
- Test with real phone numbers

### **For Analytics:**

✅ **Method 3 (Callbacks)** essential
- Track call success rate
- Monitor answer rate
- Analyze call duration
- Debug issues

---

## 🐛 Troubleshooting

### **Method 2 Fails:**
**Issue:** TwiML URL tidak accessible

**Solution:**
- Check internet connection
- Try different TwiML URL
- Use Method 1 instead (inline TwiML)

### **Method 3 No Callbacks:**
**Issue:** Status callbacks tidak received

**Solution:**
- Check backend logs
- Verify webhook endpoint working
- Use ngrok for testing (if need public URL)

### **Method 4 No Recording:**
**Issue:** Recording tidak available

**Solution:**
- Check Twilio Console
- Wait 1-2 minutes for processing
- Verify recording enabled in Twilio account

### **Method 5 Timeout:**
**Issue:** Call tidak dijawab within 120s

**Solution:**
- Check phone signal
- Try different number
- Reduce timeout if needed

---

## 📞 Support

**Documentation:**
- [Twilio Voice API](https://www.twilio.com/docs/voice/make-calls)
- [TwiML Reference](https://www.twilio.com/docs/voice/twiml)
- [Status Callbacks](https://www.twilio.com/docs/voice/api/call-resource#statuscallback)
- [Call Recording](https://www.twilio.com/docs/voice/tutorials/how-to-record-phone-calls)

**Testing:**
- Backend Logs: voice-call-server terminal
- Twilio Console: https://console.twilio.com/us1/monitor/logs/calls
- Browser Console: F12 → Console tab

---

## ✅ Success Criteria

Your 5-method test system is working when:

✅ All 5 methods accessible from dashboard
✅ Each method makes successful call
✅ Voice messages match method description
✅ Success messages show correct test method
✅ Backend logs show detailed info
✅ Test results saved (green badge)
✅ Tooltip shows method number
✅ No errors in console

---

**🎉 Sistem 5 Metode Test Siap Digunakan!**

**Updated: Nov 7, 2024**
**Made with 🧪 for Comprehensive Twilio Testing**
