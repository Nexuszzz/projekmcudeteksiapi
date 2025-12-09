# MQTT WebSocket Proxy Server

Proxy server untuk meneruskan pesan MQTT dari TCP broker ke WebSocket clients. Berguna jika MQTT broker Anda hanya membuka port TCP (1883) tanpa WebSocket support.

## 🎯 Kapan Menggunakan Proxy Ini?

Gunakan proxy server ini jika:
- MQTT broker hanya support TCP port 1883 (tidak ada WebSocket)
- Tidak bisa mengakses konfigurasi broker untuk enable WebSocket
- Browser tidak bisa koneksi langsung ke MQTT TCP

## 📦 Installation

```bash
cd proxy-server
npm install
```

## ⚙️ Configuration

1. Copy `.env.example` ke `.env`:

```bash
cp .env.example .env
```

2. Edit `.env` dengan konfigurasi broker MQTT Anda:

```env
# Proxy Server Configuration
PORT=8080

# MQTT Broker (TCP)
MQTT_HOST=192.168.1.100
MQTT_PORT=1883
MQTT_USERNAME=your_username
MQTT_PASSWORD=your_password

# Topics to relay
TOPIC_TELEMETRY=nimak/deteksi-api/telemetry
TOPIC_CMD=nimak/deteksi-api/cmd
TOPIC_STATUS=nimak/deteksi-api/status
```

## 🚀 Running the Proxy

### Development mode (with auto-reload):

```bash
npm run dev
```

### Production mode:

```bash
npm start
```

Server akan berjalan di `http://localhost:8080`

## 🔌 WebSocket Endpoint

Clients dapat connect ke:

```
ws://localhost:8080/ws
```

## 📡 How It Works

1. **Proxy server** connects ke MQTT broker via TCP (port 1883)
2. **Browser clients** connect ke proxy via WebSocket (port 8080)
3. **Messages flow**:
   - MQTT → Proxy → WebSocket clients (telemetry data)
   - WebSocket clients → Proxy → MQTT (commands)

```
ESP32 → MQTT Broker (TCP:1883) → Proxy Server → WebSocket (8080) → Browser
                                        ↓
                                    Commands
                                        ↓
ESP32 ← MQTT Broker (TCP:1883) ← Proxy Server ← WebSocket (8080) ← Browser
```

## 🔧 Frontend Configuration

Update `.env` di frontend project:

```env
# Ganti MQTT_URL ke proxy WebSocket endpoint
VITE_MQTT_URL=ws://localhost:8080/ws

# Topics tetap sama
VITE_TOPIC_PUB=nimak/deteksi-api/telemetry
VITE_TOPIC_CMD=nimak/deteksi-api/cmd
VITE_TOPIC_STATUS=nimak/deteksi-api/status
```

**NOTE**: Jika menggunakan proxy, Anda tidak perlu username/password di frontend karena autentikasi dilakukan di proxy server.

## 📊 Health Check

Check status proxy server:

```bash
curl http://localhost:8080/health
```

Response:

```json
{
  "status": "ok",
  "mqtt": "connected",
  "clients": 2
}
```

## 🧪 Testing

### Test dengan wscat:

```bash
# Install wscat
npm install -g wscat

# Connect to proxy
wscat -c ws://localhost:8080/ws

# Send command
> {"type":"publish","topic":"nimak/deteksi-api/cmd","payload":"BUZZER_ON"}
```

## 🐛 Troubleshooting

### Proxy tidak connect ke MQTT broker

**Cek**:
1. MQTT broker running di `MQTT_HOST:MQTT_PORT`
2. Firewall tidak block port 1883
3. Username/password benar (jika ada)

**Test koneksi**:

```bash
mosquitto_sub -h <MQTT_HOST> -p 1883 -t "nimak/deteksi-api/#" -u <username> -P <password> -v
```

### WebSocket clients tidak terima messages

**Cek**:
1. Browser console untuk error WebSocket
2. Health check endpoint: `http://localhost:8080/health`
3. Server logs untuk error messages

## 🔐 Security Notes

- Proxy server tidak menggunakan HTTPS/WSS by default
- Untuk production, gunakan reverse proxy (Nginx) dengan SSL
- Implementasi rate limiting jika diperlukan
- Restrict CORS origins di production

## 📝 Production Deployment

### With PM2:

```bash
npm install -g pm2

# Start
pm2 start server.js --name mqtt-proxy

# Auto-start on boot
pm2 startup
pm2 save
```

### With Docker:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8080
CMD ["node", "server.js"]
```

Build and run:

```bash
docker build -t mqtt-proxy .
docker run -p 8080:8080 --env-file .env mqtt-proxy
```

## 🌐 Reverse Proxy (Nginx)

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📄 License

MIT
