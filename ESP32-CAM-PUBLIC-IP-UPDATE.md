# 🌐 ESP32-CAM Update: Broadcast Public IP ke MQTT

## Masalah
VPS di cloud tidak bisa akses ESP32-CAM di jaringan lokal (private IP `10.192.22.x`).

## Solusi
1. **Port Forwarding** di router: External `8081` → Internal `10.192.22.219:81`
2. **ESP32-CAM** broadcast **Public IP + External Port** ke MQTT

---

## Step 1: Port Forwarding di Router

Buka router admin panel, tambahkan rule:

| Field | Value |
|-------|-------|
| Service Name | ESP32-CAM-Stream |
| Protocol | TCP |
| External Port | `8081` |
| Internal IP | `10.192.22.219` |
| Internal Port | `81` |

> Setelah ini, stream bisa diakses dari: `http://YOUR_PUBLIC_IP:8081/stream`

---

## Step 2: Update Arduino Code

Tambahkan fungsi untuk **get Public IP** dan broadcast ke MQTT:

### Tambahkan di bagian atas (setelah includes):

```cpp
// ==================== PUBLIC IP CONFIG ====================
// Set Public IP router secara manual ATAU auto-detect
// Jika router support, biarkan kosong untuk auto-detect via api.ipify.org

String PUBLIC_IP = "";           // Kosongkan untuk auto-detect, atau isi manual: "123.45.67.89"
const int EXTERNAL_PORT = 8081;  // Port forwarding external port
// ==========================================================
```

### Tambahkan fungsi getPublicIP():

```cpp
// ==================== GET PUBLIC IP ====================
String getPublicIP() {
  if (PUBLIC_IP.length() > 0) {
    Serial.println("[PUBLIC] Using manual IP: " + PUBLIC_IP);
    return PUBLIC_IP;
  }
  
  Serial.println("[PUBLIC] Getting public IP from api.ipify.org...");
  
  HTTPClient http;
  http.begin("http://api.ipify.org");
  http.setTimeout(10000);
  
  int httpCode = http.GET();
  String ip = "";
  
  if (httpCode == HTTP_CODE_OK) {
    ip = http.getString();
    ip.trim();
    Serial.println("[PUBLIC] Got IP: " + ip);
  } else {
    Serial.printf("[PUBLIC] Failed to get IP, code: %d\n", httpCode);
    // Fallback ke local IP
    ip = WiFi.localIP().toString();
    Serial.println("[PUBLIC] Fallback to local: " + ip);
  }
  
  http.end();
  return ip;
}
```

### Update fungsi publishCameraIP():

**GANTI** fungsi `publishCameraIP()` yang lama dengan ini:

```cpp
void publishCameraIP() {
  if (!mqttClient.connected()) return;
  
  // Get Public IP (auto atau manual)
  String publicIP = getPublicIP();
  String localIP = WiFi.localIP().toString();
  
  // Build stream URLs
  String publicStreamUrl = "http://" + publicIP + ":" + String(EXTERNAL_PORT) + "/stream";
  String localStreamUrl = "http://" + localIP + ":81/stream";
  
  StaticJsonDocument<512> doc;
  doc["ip"] = publicIP;                    // VPS akan pakai ini
  doc["local_ip"] = localIP;               // Untuk referensi
  doc["port"] = EXTERNAL_PORT;             // External port
  doc["local_port"] = 81;                  // Internal port
  doc["stream_url"] = publicStreamUrl;     // URL yang VPS pakai
  doc["local_stream_url"] = localStreamUrl; // URL lokal
  doc["capture_url"] = "http://" + publicIP + ":" + String(EXTERNAL_PORT) + "/capture";
  doc["id"] = camera_id;
  doc["rssi"] = WiFi.RSSI();
  doc["uptime"] = millis() / 1000;
  doc["flash"] = flashEnabled;
  
  String payload;
  serializeJson(doc, payload);
  
  String topic = String(mqtt_topic) + "/" + camera_id + "/status";
  
  // Publish dengan retain
  if (mqttClient.publish(mqtt_topic, payload.c_str(), true)) {
    Serial.println("[MQTT] Published (retained):");
    Serial.println("  Topic: " + String(mqtt_topic));
    Serial.println("  Public: " + publicIP + ":" + String(EXTERNAL_PORT));
    Serial.println("  Local:  " + localIP + ":81");
  }
  
  // Juga publish ke topic status
  mqttClient.publish(topic.c_str(), payload.c_str(), true);
}
```

---

## Step 3: Verifikasi

### Test dari luar jaringan:
```bash
# Dari VPS atau HP dengan data seluler:
curl http://YOUR_PUBLIC_IP:8081/capture
```

### Check MQTT message:
```bash
# Di VPS:
mosquitto_sub -h 3.27.11.106 -u zaks -P enggangodinginmcu -t "lab/zaks/esp32cam/ip" -v
```

Harus muncul:
```json
{
  "ip": "YOUR_PUBLIC_IP",
  "local_ip": "10.192.22.219",
  "port": 8081,
  "stream_url": "http://YOUR_PUBLIC_IP:8081/stream",
  ...
}
```

---

## Step 4: Restart Fire Detection Service

```bash
sudo systemctl restart fire-detect
journalctl -u fire-detect -f
```

Harus bisa connect ke stream sekarang! 🎉

---

## Troubleshooting

### Public IP tidak bisa diakses?
1. Pastikan port forwarding aktif di router
2. Cek firewall router tidak block port 8081
3. Beberapa ISP block incoming connections - hubungi ISP

### api.ipify.org gagal?
Set manual di kode:
```cpp
String PUBLIC_IP = "123.45.67.89";  // Ganti dengan public IP router
```

Cek public IP router di: https://whatismyipaddress.com/

### Stream timeout?
- ESP32-CAM mungkin perlu restart setelah port forwarding aktif
- Pastikan Internal IP di router sesuai dengan IP ESP32-CAM
