# 🔧 ESP32-CAM IP Configuration Guide

## 📱 **Python Script - Interactive IP Input**

### **Cara Menggunakan:**

```bash
# Run script
cd D:\rtsp-main\python_scripts
python fire_detect_record_ultimate.py

# Script akan bertanya IP ESP32-CAM:
ESP32-CAM CONFIGURATION
================================================================================
Enter ESP32-CAM IP address
Examples:
  - 10.148.218.219
  - 192.168.1.100
  - 192.168.43.1

ESP32-CAM IP: █
```

### **Input Options:**

**Option 1: Gunakan IP dari .env (jika ada)**
```
Found IP in .env: 10.148.218.219
Use this IP? (Y/n): Y  # Tekan Enter atau ketik Y
✅ ESP32-CAM IP set to: 10.148.218.219
```

**Option 2: Input IP baru**
```
Found IP in .env: 10.148.218.219
Use this IP? (Y/n): n  # Ketik n untuk ganti

Enter ESP32-CAM IP address
ESP32-CAM IP: 192.168.1.100  # Ketik IP baru
✅ ESP32-CAM IP set to: 192.168.1.100
```

**Option 3: Tidak ada .env**
```
Enter ESP32-CAM IP address
ESP32-CAM IP: 10.148.218.219  # Langsung ketik IP
✅ ESP32-CAM IP set to: 10.148.218.219
```

### **Validasi IP:**

Script akan validasi format IP:
```bash
ESP32-CAM IP: 192.168.1  # ❌ Invalid
❌ Invalid IP format! Please enter valid IPv4 address (e.g., 192.168.1.100)

ESP32-CAM IP: 192.168.1.100  # ✅ Valid
✅ ESP32-CAM IP set to: 192.168.1.100
📡 Stream URL: http://192.168.1.100:81/stream
```

---

## 🌐 **Web Dashboard - Settings Panel**

### **Cara Mengubah IP di Dashboard:**

1. **Buka Dashboard:**
   ```
   http://localhost:5173/live-stream
   ```

2. **Klik Tab "Live Stream"**

3. **Klik Icon ⚙️ Settings** (di toolbar)

4. **Edit IP di Input Field:**
   ```
   📡 ESP32-CAM IP Address or Stream URL
   ┌─────────────────────────────────────────┐
   │ 10.148.218.219                      [Test]│
   └─────────────────────────────────────────┘
   
   💡 Formats accepted:
   • Just IP: 10.148.218.219 (auto-adds :81/stream)
   • Full URL: http://10.148.218.219:81/stream
   • With port: 192.168.1.100:81 (auto-adds http:// and /stream)
   
   ✅ Changes are saved automatically!
   ```

5. **Format yang Diterima:**

   | Input Format | Auto-converted to |
   |-------------|-------------------|
   | `10.148.218.219` | `http://10.148.218.219:81/stream` |
   | `192.168.1.100:81` | `http://192.168.1.100:81/stream` |
   | `192.168.1.100:81/stream` | `http://192.168.1.100:81/stream` |
   | `http://10.148.218.219:81` | `http://10.148.218.219:81/stream` |
   | `http://10.148.218.219:81/stream` | *(unchanged)* |

6. **Test Connection:**
   - Klik tombol **[Test]** untuk buka stream di tab baru
   - Verify stream berfungsi sebelum apply

7. **Apply Changes:**
   - Klik **"Apply & Restart"** untuk restart stream dengan IP baru
   - Atau klik **"Cancel"** untuk batal

---

## 🔄 **Auto-Save Feature**

### **Python Script:**
- IP yang diinput **TIDAK** disimpan
- Harus input ulang setiap kali run script
- **Recommendation:** Gunakan `.env` file untuk permanent config

### **Web Dashboard:**
- IP otomatis disimpan ke **localStorage**
- Persisten across browser refresh
- Tidak perlu input ulang kecuali ganti IP

---

## 💾 **Permanent Configuration (.env)**

### **Setup .env File:**

```bash
# Create/edit .env file
cd D:\rtsp-main
notepad .env
```

**Add line:**
```env
ESP32_CAM_IP=10.148.218.219
```

**Save and close**

### **Cara Kerja:**

```bash
# Run script
python fire_detect_record_ultimate.py

# Script akan otomatis detect .env:
Found IP in .env: 10.148.218.219
Use this IP? (Y/n): Y  # Tekan Enter

✅ ESP32-CAM IP set to: 10.148.218.219
📡 Stream URL: http://10.148.218.219:81/stream
```

---

## 🎯 **Quick Reference**

### **Python Script Flow:**

```
1. Check .env file
   ├─ Found? → Ask "Use this IP?"
   │           ├─ Yes → Use .env IP
   │           └─ No → Ask for input
   └─ Not found? → Ask for input

2. Validate IP format
   ├─ Valid IPv4? → ✅ Proceed
   └─ Invalid? → ❌ Ask again

3. Set stream URL
   http://[IP]:81/stream

4. Start detection
```

### **Web Dashboard Flow:**

```
1. Load from localStorage
   └─ Default: http://10.148.218.219:81/stream

2. User clicks Settings ⚙️

3. User changes IP
   ├─ Just IP → Auto-add :81/stream
   ├─ IP:Port → Auto-add http:// and /stream
   └─ Full URL → Use as-is

4. Auto-save to localStorage

5. Click "Apply & Restart"
   └─ Stream reconnects with new IP
```

---

## 🐛 **Troubleshooting**

### **Problem: IP tidak tersimpan di Python script**

**Solution:**
```bash
# Create .env file
cd D:\rtsp-main
echo ESP32_CAM_IP=10.148.218.219 > .env

# Verify
type .env
# Output: ESP32_CAM_IP=10.148.218.219
```

---

### **Problem: Web dashboard tidak menyimpan IP**

**Possible causes:**
1. Browser private/incognito mode (localStorage disabled)
2. Browser cache cleared

**Solution:**
```
1. Open browser console (F12)
2. Check localStorage:
   localStorage.getItem('esp32cam_config')
   
3. If null, manually set:
   localStorage.setItem('esp32cam_config', JSON.stringify({
     url: 'http://10.148.218.219:81/stream',
     quality: 'medium',
     fps: 15
   }))
   
4. Refresh page
```

---

### **Problem: "Invalid IP format" di Python script**

**Valid formats:**
- ✅ `10.148.218.219`
- ✅ `192.168.1.100`
- ✅ `172.16.0.1`

**Invalid formats:**
- ❌ `192.168.1` (missing octet)
- ❌ `10.148.218.256` (octet > 255)
- ❌ `http://10.148.218.219` (include http://)
- ❌ `10.148.218.219:81` (include port)

**Correct input:**
```
ESP32-CAM IP: 192.168.1.100  # Just the IP, no port/protocol
```

---

### **Problem: Connection timeout di Python**

**Error:**
```
❌ Error: <urlopen error timed out>
```

**Check:**
1. ✅ ESP32-CAM powered on
2. ✅ IP address correct (check Arduino Serial Monitor)
3. ✅ Same network (PC & ESP32-CAM)
4. ✅ Port 81 accessible

**Test connection:**
```bash
# Test ping
ping 10.148.218.219

# Test HTTP
curl http://10.148.218.219:81/stream --max-time 5
```

---

## 📊 **Comparison: Python vs Web**

| Feature | Python Script | Web Dashboard |
|---------|--------------|---------------|
| **IP Input** | Interactive prompt | Settings panel UI |
| **Validation** | IPv4 format check | Auto-format + visual feedback |
| **Storage** | .env file (manual) | localStorage (automatic) |
| **Persistence** | Until .env changed | Until localStorage cleared |
| **Format Support** | IP only | IP, IP:Port, Full URL |
| **Test Connection** | Auto on start | Manual "Test" button |
| **Apply Changes** | Immediate | Restart required |

---

## 🎉 **Best Practices**

### **For Python Script:**
1. ✅ **Use .env file** untuk permanent config
2. ✅ **Verify IP** di Arduino Serial Monitor sebelum run
3. ✅ **Test connection** dengan browser first: `http://[IP]:81/stream`

### **For Web Dashboard:**
1. ✅ **Use full URL** jika ESP32 di network lain
2. ✅ **Test button** sebelum apply
3. ✅ **Restart stream** setelah ganti IP
4. ✅ **Check browser console** untuk debug

---

## 🆕 **What Changed**

### **Python Script:**
- ❌ **Before:** Hardcoded IP `10.148.218.219`
- ✅ **After:** Interactive input with .env support

### **Web Dashboard:**
- ❌ **Before:** Manual edit required in code
- ✅ **After:** Settings panel dengan auto-save

### **Benefits:**
- 🎯 **No code editing** needed untuk ganti IP
- 💾 **Persistent** di web (localStorage)
- ✅ **Validation** untuk prevent typos
- 🔄 **Easy switching** between multiple ESP32-CAM

---

**✅ Ready to use!** Sekarang IP ESP32-CAM bisa diubah dengan mudah tanpa edit code!
