# 🔧 Twilio Trial Account - Verified Caller IDs Required

## ❌ MASALAH YANG TERJADI:

Error dari screenshot:
```
Failed to call +6287847529293: The number +6287847529293 is unverified. 
Trial accounts may only make calls to verified numbers.
```

**Root Cause:** Anda menggunakan **Twilio Trial Account** yang memiliki batasan keamanan.

---

## 🎯 TWILIO TRIAL ACCOUNT LIMITATIONS:

### Trial Account Rules:
1. ✅ **Bisa** membuat calls
2. ❌ **HANYA** ke nomor yang sudah **VERIFIED** di Twilio Console
3. ❌ **TIDAK BISA** call ke nomor random/unverified
4. ⚠️ Call akan ditambah prefix message: "This is a test call from Twilio..."

### Batasan Lain:
- Limited credits ($15.50 free)
- Call prefixed dengan Twilio test message
- Cannot remove Twilio branding
- Limited to verified numbers only

---

## ✅ SOLUSI:

### OPSI 1: Verify Nomor di Twilio Console (GRATIS!)

**Step-by-step:**

#### 1. Login ke Twilio Console
```
https://console.twilio.com
```

#### 2. Go to Verified Caller IDs
```
Phone Numbers → Manage → Verified Caller IDs
```

Atau langsung:
```
https://console.twilio.com/us1/develop/phone-numbers/manage/verified
```

#### 3. Click "Add a new Caller ID"

#### 4. Pilih "Call You"

**Why?** Indonesia (+62) numbers must be verified via phone call, not SMS.

#### 5. Enter Phone Number
```
+6287847529293
```

Format: **HARUS dengan `+62`** (country code Indonesia)

#### 6. Click "Call Me Now"

Twilio akan:
1. Menelepon nomor tersebut
2. Robotic voice akan bacakan **verification code** (6 digit)
3. Catat code tersebut

#### 7. Enter Verification Code

Masukkan 6-digit code yang dibacakan di telepon.

#### 8. Click "Verify"

✅ **Nomor sekarang VERIFIED!**

#### 9. Ulangi untuk SEMUA Emergency Numbers

Verify setiap nomor yang ingin menerima emergency call:
- +6287847529293
- +628123456789
- dll.

---

### OPSI 2: Upgrade to Paid Account (RECOMMENDED untuk Production!)

**Why Upgrade?**
- ✅ Call ke **SEMUA nomor** (tidak perlu verify)
- ✅ No Twilio branding/prefix message
- ✅ Professional calls
- ✅ Higher limits
- ✅ Production-ready

**How to Upgrade:**

1. Go to: https://console.twilio.com/us1/billing
2. Click: "Upgrade"
3. Add payment method (credit card)
4. Minimum topup: $20
5. Done! Account upgraded

**Cost:**
- Voice calls to Indonesia: ~$0.02 - $0.05 per minute
- Very affordable for emergency system!

---

### OPSI 3: Use Verified Numbers Only (Temporary)

**Quick Fix:**
- Hanya gunakan nomor yang sudah verified
- Add ke emergency list hanya nomor yang sudah di-verify
- Sementara sampai upgrade account

---

## 🔍 HOW TO CHECK VERIFIED NUMBERS:

### Via Twilio Console:
```
https://console.twilio.com/us1/develop/phone-numbers/manage/verified
```

You'll see list of verified numbers.

### Via API:
```bash
curl -X GET "https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID_HERE/OutgoingCallerIds.json" \
  -u "YOUR_ACCOUNT_SID_HERE:YOUR_AUTH_TOKEN_HERE"
```

---

## 📋 STEP-BY-STEP: Verify Multiple Numbers

### 1. List Semua Emergency Numbers
```
+6287847529293 (z)
+628967175597 (z1) ← Already verified!
+628123456789 (Security Team)
etc.
```

### 2. Verify Satu Per Satu

**For each number:**
1. Go to Verified Caller IDs
2. Click "Add new Caller ID"
3. Enter number with +62
4. Choose "Call You"
5. Answer phone call
6. Listen to verification code
7. Enter code
8. Verify

**Repeat untuk semua nomor!**

### 3. Test After Verification

```bash
# Test call via API
curl -X POST http://localhost:3002/api/voice-call/test ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\":\"+6287847529293\"}"
```

**Expected:** Call berhasil! ✅

---

## 🧪 TESTING VERIFIED NUMBERS

### Script untuk Test:

```powershell
# Test call to verified number
$body = @{phoneNumber="+6287847529293"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:3002/api/voice-call/test" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

Write-Host "Response:" -ForegroundColor Green
$response | ConvertTo-Json
```

**Expected Response:**
```json
{
  "success": true,
  "callSid": "CA...",
  "status": "queued",
  "to": "+6287847529293"
}
```

**Then check:** Phone should ring in 5-10 seconds!

---

## ⚠️ COMMON ERRORS:

### Error 1: "Unverified" (Your Current Issue)
```
The number +62... is unverified. Trial accounts may only make calls to verified numbers.
```

**Fix:** Verify number di Twilio Console (Opsi 1 di atas)

---

### Error 2: "Invalid Phone Number"
```
The 'To' number +62... is not a valid phone number.
```

**Fix:** 
- HARUS pakai `+62` (country code)
- Format: `+62812345678` (no spaces, dashes, atau karakter lain)

---

### Error 3: "Insufficient Funds"
```
Insufficient funds to create call
```

**Fix:** Add credits atau upgrade account

---

## 💰 TWILIO PRICING (Indonesia)

### Trial Account:
- $15.50 free credits
- Can only call verified numbers
- Calls have Twilio prefix message

### Paid Account:
- Voice calls to Indonesia: ~$0.0255 per minute
- Example: 1 minute emergency call = ~Rp 400
- Very affordable!

**Calculation:**
- 10 emergency calls/month
- 1 minute each
- Cost: ~$0.255 = Rp 4,000/month

**Worth it for production!**

---

## 🎯 RECOMMENDED SOLUTION:

### For Testing (Now):
✅ **Verify 2-3 nomor** di Twilio Console
- Your number: +6287847529293
- Backup number: +628967175597 (already verified!)
- Security team: +628123456789

**Time needed:** 5 minutes per number

---

### For Production (Later):
✅ **Upgrade to Paid Account**
- No verification needed
- Professional calls
- No Twilio branding
- Worth the small cost!

**Cost:** ~Rp 50,000/month for typical usage

---

## 📝 VERIFICATION CHECKLIST:

Before using emergency voice calls:

- [ ] Login to Twilio Console
- [ ] Go to Verified Caller IDs
- [ ] Add each emergency number:
  - [ ] +6287847529293
  - [ ] +628967175597 (already done!)
  - [ ] +628123456789
  - [ ] (add more as needed)
- [ ] Verify each via phone call
- [ ] Test each number with test call
- [ ] Confirm calls received
- [ ] Ready for production!

---

## 🚀 QUICK FIX (RIGHT NOW):

### 1. Verify Your Primary Number

```
1. Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
2. Click: "Add a new Caller ID"
3. Enter: +6287847529293
4. Choose: "Call You"
5. Answer phone, listen to code
6. Enter code
7. Verify!
```

**Time:** 2 minutes

### 2. Test Immediately

```bash
curl -X POST http://localhost:3002/api/voice-call/test ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\":\"+6287847529293\"}"
```

### 3. Trigger Fire Detection

Run fire detection, nomor akan di-call otomatis!

---

## 📞 ALTERNATIVE: Use Only Verified Numbers

Temporary workaround:

1. **Remove** unverified numbers dari emergency list
2. **Keep** only verified numbers:
   - +628967175597 (z1) ← This works!
3. **Add** more after verification

**Delete unverified number:**
```bash
# Via UI: Click X button next to number
# Or via API:
curl -X DELETE http://localhost:3002/api/voice-call/numbers/[number_id]
```

---

## 🎉 AFTER VERIFICATION:

Setelah nomor verified:

✅ Emergency calls akan berfungsi normal
✅ No more "unverified" errors
✅ Phone akan ring saat fire detected
✅ Voice message played
✅ System fully operational!

---

## 📊 SUMMARY:

### Problem:
❌ Twilio Trial Account cannot call unverified numbers

### Solutions:
1. ✅ **Verify numbers** in Twilio Console (FREE, 5 min/number)
2. ✅ **Upgrade account** to paid ($20 minimum, no limits)
3. ✅ **Use verified only** (temporary workaround)

### Recommended:
- **Now:** Verify your primary numbers (2-3 numbers)
- **Production:** Upgrade to paid account
- **Cost:** Very affordable (~Rp 50k/month)

---

**🔥 After verification, emergency calls will work perfectly!** 📞
