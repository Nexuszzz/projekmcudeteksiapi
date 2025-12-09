# 🔥 IoT Fire Detection Dashboard

Dashboard monitoring dan kontrol real-time untuk proyek IoT deteksi kebakaran berbasis ESP32 dengan komunikasi MQTT.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![React](https://img.shields.io/badge/React-18.2-blue)
![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Fitur Utama

### 📊 Monitoring Real-time
- **Kartu Metrik**: Tampilan ringkas untuk Temperature, Humidity, Gas Analog, Gas Digital, dan Alarm Status
- **Grafik Interaktif**: Multi-series line chart dengan zoom, pan, dan range selector (Live/1h/6h/24h)
- **Status Koneksi**: Indikator real-time status koneksi MQTT dengan badge warna
- **Auto-update**: Data streaming otomatis tanpa refresh manual

### 🎛️ Kontrol Jarak Jauh
- **Buzzer Control**: ON/OFF buzzer melalui MQTT command
- **Gas Threshold**: Atur ambang deteksi gas (100-4000 ADC) dengan slider interaktif
- **Command Feedback**: Notifikasi toast untuk setiap perintah terkirim

### 📝 Data Logging
- **Tabel Log Lengkap**: Semua data telemetry dengan timestamp, raw JSON
- **Pencarian & Filter**: Search tekstual dan filter rentang waktu
- **Pagination**: Navigasi data dengan 50 item per halaman
- **Export Data**: Ekspor ke CSV dan JSONL format

### 🎨 UI/UX Modern
- **Dark/Light Mode**: Toggle tema dengan persist di localStorage
- **Responsive Design**: Optimized untuk desktop, tablet, dan mobile
- **Semantic Colors**: Warna berbeda untuk status alarm dan warning
- **Accessibility**: ARIA labels dan keyboard navigation support

### 🔔 Notifikasi
- **Browser Notification**: Alert otomatis saat alarm terdeteksi
- **Mute Control**: Opsi mute alarm sementara (5 menit)
- **Toast Messages**: Feedback visual untuk setiap aksi

## 🏗️ Teknologi Stack

- **Frontend Framework**: React 18 + Vite
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS v3
- **State Management**: Zustand
- **Charts**: Recharts
- **MQTT Client**: MQTT.js via WebSocket
- **Icons**: Lucide React
- **Date Handling**: date-fns
- **Validation**: Zod

## 📋 Prasyarat

- **Node.js**: v18.x atau lebih baru
- **npm** atau **pnpm**: Package manager
- **MQTT Broker**: Mosquitto atau broker lain yang support WebSocket

## 🚀 Quick Start

### 1. Clone & Install Dependencies

```bash
# Clone repository
git clone <repository-url>
cd IotCobwengdev

# Install dependencies
npm install
```

### 2. Konfigurasi Environment

Buat file `.env` di root project (copy dari `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` dengan konfigurasi broker MQTT Anda:

```env
# MQTT Broker Configuration
VITE_MQTT_URL=ws://192.168.1.100:9001/mqtt
VITE_MQTT_USERNAME=your_username
VITE_MQTT_PASSWORD=your_password

# MQTT Topics
VITE_TOPIC_PUB=nimak/deteksi-api/telemetry
VITE_TOPIC_CMD=nimak/deteksi-api/cmd
VITE_TOPIC_STATUS=nimak/deteksi-api/status

# Optional
VITE_MAX_DATA_POINTS=10000
```

### 3. Jalankan Development Server

```bash
npm run dev
```

Dashboard akan tersedia di `http://localhost:3000`

### 4. Build untuk Production

```bash
npm run build
```

Output akan tersimpan di folder `dist/`

## 🔌 Setup MQTT Broker

### Mosquitto dengan WebSocket Support

#### Windows

1. **Install Mosquitto** dari [mosquitto.org/download](https://mosquitto.org/download/)

2. **Edit konfigurasi** `mosquitto.conf`:

```conf
# Default MQTT listener
listener 1883
protocol mqtt

# WebSocket listener
listener 9001
protocol websockets

# Authentication (opsional)
allow_anonymous true
# Atau gunakan password file:
# password_file C:/mosquitto/passwd
```

3. **Jalankan Mosquitto**:

```bash
mosquitto -c mosquitto.conf -v
```

#### Linux/MacOS

```bash
# Install
sudo apt-get install mosquitto mosquitto-clients

# Edit config
sudo nano /etc/mosquitto/mosquitto.conf

# Add WebSocket listener
listener 9001
protocol websockets

# Restart
sudo systemctl restart mosquitto
```

### Test Koneksi MQTT

```bash
# Subscribe ke topik telemetry
mosquitto_sub -h localhost -t "nimak/deteksi-api/telemetry" -v

# Publish test data
mosquitto_pub -h localhost -t "nimak/deteksi-api/telemetry" -m '{"id":"ESP32-001","t":28.5,"h":65.0,"gasA":1850,"gasD":0,"alarm":false}'
```

## 📡 Format Payload ESP32

### Telemetry Data (Publish ke `VITE_TOPIC_PUB`)

```json
{
  "id": "ESP32-12345",
  "t": 27.5,
  "h": 62.0,
  "gasA": 1830,
  "gasD": 0,
  "alarm": false
}
```

**Field Descriptions:**
- `id` (string): Unique identifier ESP32 (chip ID)
- `t` (number): Temperature dari sensor DHT22 dalam °C
- `h` (number): Humidity dari sensor DHT22 dalam %
- `gasA` (number): Gas analog reading (0-4095 ADC)
- `gasD` (number): Gas digital output (0 atau 1)
- `alarm` (boolean): Status alarm di perangkat

### Command Data (Subscribe dari `VITE_TOPIC_CMD`)

ESP32 harus subscribe ke topik command dan handle:

```
BUZZER_ON    # Nyalakan buzzer
BUZZER_OFF   # Matikan buzzer
THR=2000     # Set gas threshold ke 2000
```

## 🗂️ Struktur Proyek

```
IotCobwengdev/
├── public/
├── src/
│   ├── components/
│   │   ├── ConnectionBadge.tsx    # Status koneksi MQTT
│   │   ├── ControlPanel.tsx       # Panel kontrol buzzer & threshold
│   │   ├── Header.tsx             # Header dengan theme toggle
│   │   ├── LiveChart.tsx          # Grafik real-time
│   │   ├── LogTable.tsx           # Tabel data log dengan filter
│   │   ├── MetricCard.tsx         # Kartu metrik individual
│   │   └── MetricCards.tsx        # Grid kartu metrik
│   ├── hooks/
│   │   └── useMqttClient.ts       # Custom hook MQTT client
│   ├── store/
│   │   └── useTelemetryStore.ts   # Zustand store
│   ├── types/
│   │   └── telemetry.ts           # TypeScript interfaces
│   ├── utils/
│   │   ├── export.ts              # CSV/JSONL export utilities
│   │   ├── storage.ts             # localStorage utilities
│   │   ├── time.ts                # Time filtering utilities
│   │   └── validation.ts          # Payload validation (Zod)
│   ├── App.tsx                    # Main application
│   ├── main.tsx                   # Entry point
│   └── index.css                  # Global styles
├── .env.example                   # Environment template
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
└── README.md
```

## 🎯 Cara Menggunakan

### 1. Monitor Data Real-time

- Dashboard akan otomatis connect ke MQTT broker saat dibuka
- Data telemetry dari ESP32 akan muncul di kartu metrik, grafik, dan tabel log
- Status koneksi ditampilkan di header (hijau = connected)

### 2. Kontrol Buzzer

1. Pastikan status MQTT "Connected"
2. Klik tombol **Buzzer ON** atau **Buzzer OFF**
3. Command akan dikirim ke topik `VITE_TOPIC_CMD`
4. Toast notification akan muncul sebagai feedback

### 3. Atur Gas Threshold

1. Gunakan slider untuk adjust nilai (100-4000)
2. Klik tombol **Apply** untuk mengirim ke ESP32
3. Nilai threshold akan tersimpan di localStorage

### 4. Export Data Log

1. Gunakan filter untuk memilih data yang ingin diekspor:
   - Search box: cari berdasarkan text
   - Date range: filter berdasarkan tanggal
2. Klik **Export CSV** atau **Export JSONL**
3. File akan otomatis terunduh

### 5. Toggle Dark Mode

- Klik icon 🌙 atau ☀️ di header
- Preferensi tema akan tersimpan di localStorage

## 🔧 Troubleshooting

### MQTT Tidak Connect

**Problem**: Status "Disconnected" atau "Error"

**Solusi**:
1. Pastikan MQTT broker berjalan: `mosquitto -v`
2. Cek WebSocket listener aktif di port 9001
3. Verifikasi URL di `.env` (format: `ws://HOST:PORT/mqtt`)
4. Cek firewall tidak block port 9001
5. Test dengan MQTT Explorer atau mosquitto_sub

### Data Tidak Muncul

**Problem**: Tidak ada data di dashboard

**Solusi**:
1. Cek ESP32 publish ke topik yang benar
2. Verifikasi format payload JSON valid
3. Buka browser console untuk lihat error validation
4. Test manual dengan mosquitto_pub

### Perintah Kontrol Tidak Diterima ESP32

**Problem**: Buzzer/threshold tidak berubah

**Solusi**:
1. Pastikan ESP32 subscribe ke topik command
2. Cek serial monitor ESP32 untuk debug log
3. Verifikasi format command string sesuai
4. Test dengan mosquitto_pub manual

## 🧪 Testing

### Manual Testing Payload

Gunakan mosquitto_pub untuk test:

```bash
# Test data normal
mosquitto_pub -h localhost -t "nimak/deteksi-api/telemetry" \
  -m '{"id":"TEST-001","t":25.0,"h":60.0,"gasA":1500,"gasD":0,"alarm":false}'

# Test alarm aktif
mosquitto_pub -h localhost -t "nimak/deteksi-api/telemetry" \
  -m '{"id":"TEST-001","t":45.0,"h":80.0,"gasA":3500,"gasD":1,"alarm":true}'

# Test data dengan field hilang (akan di-default)
mosquitto_pub -h localhost -t "nimak/deteksi-api/telemetry" \
  -m '{"id":"TEST-001"}'
```

## 📊 Performance Optimization

### Data Management
- **Sliding Window**: Maksimum 10,000 data points di memory
- **Downsampling**: Chart hanya render 1,000 points untuk performa
- **Pagination**: Tabel log dibatasi 50 item per halaman

### Rendering
- **React.memo**: Komponen tidak re-render jika props sama
- **Zustand Selectors**: Subscribe hanya ke state yang diperlukan
- **requestAnimationFrame**: Smooth chart updates

## 🔐 Security Best Practices

1. **Jangan commit file `.env`** ke repository
2. Gunakan **password authentication** di MQTT broker untuk production
3. Gunakan **WSS (WebSocket Secure)** jika deploy ke internet
4. Implementasi **TLS/SSL** untuk enkripsi komunikasi
5. Limit **MQTT topic ACL** untuk keamanan

## 🌐 Deployment

### Build untuk Production

```bash
npm run build
```

### Deploy ke Static Hosting

#### Netlify/Vercel

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=dist
```

#### Nginx

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Author

**IoT Fire Detection Team**

## 🙏 Acknowledgments

- ESP32 community
- Mosquitto MQTT Broker
- React & Vite teams
- Recharts library contributors

## 📞 Support

Jika ada pertanyaan atau masalah:
- Open an issue di repository
- Email: support@example.com

---

**Made with ❤️ using React + TypeScript + MQTT**
