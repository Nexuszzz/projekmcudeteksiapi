# 📖 API Reference

Dokumentasi API untuk IoT Fire Detection Dashboard.

## 📡 MQTT Topics

### Telemetry Topic (Publish)

**Topic**: Sesuai `VITE_TOPIC_LOG` (default: `lab/zaks/log`)

**Direction**: ESP32 → Dashboard

**QoS**: 0 atau 1

**Payload Format**:

```typescript
{
  id: string          // ESP32 chip ID
  t: number | null    // Temperature (°C)
  h: number | null    // Humidity (%)
  gasA: number | null // Gas analog (0-4095)
  gasD: number | null // Gas digital (0 or 1)
  alarm: boolean      // Alarm status
}
```

**Example**:

```json
{
  "id": "A1B2C3D4E5F6",
  "t": 28.5,
  "h": 65.0,
  "gasA": 1850,
  "gasD": 0,
  "alarm": false
}
```

**Validation Rules**:
- `id`: String (default: "unknown")
- `t`: Number or null (default: null)
- `h`: Number or null (default: null)
- `gasA`: Integer 0-4095 or null (default: null)
- `gasD`: Integer 0-1 or null (default: null)
- `alarm`: Boolean (default: false)

### Command Topic (Subscribe)

**Topic**: Sesuai `VITE_TOPIC_EVENT` (default: `lab/zaks/event`)

**Direction**: Dashboard → ESP32

**QoS**: 1

**Payload Format**: Plain string

**Commands**:

| Command | Description | Example |
|---------|-------------|---------|
| `BUZZER_ON` | Turn buzzer ON | `BUZZER_ON` |
| `BUZZER_OFF` | Turn buzzer OFF | `BUZZER_OFF` |
| `THR=<value>` | Set gas threshold | `THR=2000` |

**Threshold Range**: 100-4000

### Status Topic (Publish)

**Topic**: Sesuai `VITE_TOPIC_STATUS` (default: `lab/zaks/status`)

**Direction**: ESP32 → Dashboard

**QoS**: 1 (retained)

**Payload Format**:

```typescript
{
  id: string       // ESP32 chip ID
  status: string   // "online" | "offline"
  ip?: string      // ESP32 IP address
  rssi?: number    // WiFi signal strength
}
```

**Example**:

```json
{
  "id": "A1B2C3D4E5F6",
  "status": "online",
  "ip": "192.168.1.50",
  "rssi": -45
}
```

## 🗂️ Data Store (Zustand)

### State Interface

```typescript
interface TelemetryStore {
  // Data
  data: TelemetryData[]
  lastUpdate: Date | null
  
  // Connection
  connectionStatus: ConnectionStatus
  clientId: string | null
  errorMessage: string | null
  
  // Preferences
  preferences: AppPreferences
  
  // UI State
  timeRange: TimeRange
  
  // Actions
  addTelemetryData: (data: TelemetryData) => void
  clearData: () => void
  setConnectionStatus: (status: ConnectionStatus) => void
  setClientId: (id: string) => void
  setError: (message: string | null) => void
  setTheme: (theme: 'light' | 'dark') => void
  setGasThreshold: (threshold: number) => void
  setMuteAlarms: (mute: boolean, duration?: number) => void
  setTimeRange: (range: TimeRange) => void
  getFilteredData: () => TelemetryData[]
}
```

### Usage Examples

```typescript
import { useTelemetryStore } from './store/useTelemetryStore'

// In component
function MyComponent() {
  // Select specific state
  const data = useTelemetryStore((state) => state.data)
  const connectionStatus = useTelemetryStore((state) => state.connectionStatus)
  
  // Select actions
  const setTheme = useTelemetryStore((state) => state.setTheme)
  
  // Use filtered data
  const filteredData = useTelemetryStore((state) => state.getFilteredData())
  
  // ...
}
```

## 🔌 Custom Hooks

### useMqttClient

Hook untuk mengelola koneksi MQTT.

**Returns**:

```typescript
{
  isConnected: boolean
  connect: () => void
  disconnect: () => void
  publish: (topic: string, message: string) => boolean
  sendCommand: (command: string) => boolean
  setBuzzer: (state: boolean) => boolean
  setGasThreshold: (threshold: number) => boolean
  config: MqttConfig
}
```

**Usage**:

```typescript
import { useMqttClient } from './hooks/useMqttClient'

function ControlPanel() {
  const { isConnected, setBuzzer, setGasThreshold } = useMqttClient()
  
  const handleBuzzerOn = () => {
    if (isConnected) {
      setBuzzer(true)
    }
  }
  
  // ...
}
```

## 🛠️ Utility Functions

### Validation

#### parseTelemetryPayload

Parse dan validasi MQTT payload.

```typescript
function parseTelemetryPayload(
  payload: string | Buffer
): ValidationResult

interface ValidationResult {
  success: boolean
  data?: TelemetryPayload
  error?: string
}
```

**Example**:

```typescript
import { parseTelemetryPayload } from './utils/validation'

const result = parseTelemetryPayload(mqttPayload)

if (result.success && result.data) {
  // Use validated data
  console.log(result.data.t, result.data.h)
} else {
  console.error('Invalid payload:', result.error)
}
```

#### isTelemetryPayload

Type guard untuk telemetry payload.

```typescript
function isTelemetryPayload(data: unknown): data is TelemetryPayload
```

### Export

#### exportToCSV

Export data ke format CSV.

```typescript
function exportToCSV(data: TelemetryData[]): string
```

#### exportToJSONL

Export data ke format JSONL.

```typescript
function exportToJSONL(data: TelemetryData[]): string
```

#### downloadFile

Download file ke browser.

```typescript
function downloadFile(
  content: string,
  filename: string,
  mimeType: string
): void
```

**Example**:

```typescript
import { exportToCSV, downloadFile, generateFilename } from './utils/export'

const csv = exportToCSV(telemetryData)
const filename = generateFilename('telemetry', 'csv')
downloadFile(csv, filename, 'text/csv')
```

### Storage

#### loadPreferences

Load preferences dari localStorage.

```typescript
function loadPreferences(): AppPreferences
```

#### savePreferences

Save preferences ke localStorage.

```typescript
function savePreferences(preferences: Partial<AppPreferences>): void
```

**Example**:

```typescript
import { savePreferences } from './utils/storage'

savePreferences({ theme: 'dark', gasThreshold: 2500 })
```

### Time

#### getTimeRangeMs

Konversi time range ke milliseconds.

```typescript
function getTimeRangeMs(range: TimeRange): number
```

#### filterByTimeRange

Filter data berdasarkan time range.

```typescript
function filterByTimeRange<T extends { timestamp: Date }>(
  data: T[],
  range: TimeRange
): T[]
```

#### downsampleData

Downsample data untuk performa chart.

```typescript
function downsampleData<T>(data: T[], maxPoints: number): T[]
```

## 🎨 Component Props

### ConnectionBadge

```typescript
interface ConnectionBadgeProps {
  status: ConnectionStatus
  broker: string
  clientId: string | null
}
```

### MetricCard

```typescript
interface MetricCardProps {
  title: string
  value: string | number
  unit?: string
  icon: ReactNode
  className?: string
  alert?: boolean
}
```

## 🔧 Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `VITE_MQTT_URL` | string | `ws://localhost:9001/mqtt` | MQTT WebSocket URL |
| `VITE_MQTT_USERNAME` | string | `''` | MQTT username |
| `VITE_MQTT_PASSWORD` | string | `''` | MQTT password |
| `VITE_TOPIC_EVENT` | string | `lab/zaks/event` | Event topic |
| `VITE_TOPIC_LOG` | string | `lab/zaks/log` | Log/Telemetry topic |
| `VITE_TOPIC_STATUS` | string | `lab/zaks/status` | Status topic |
| `VITE_TOPIC_ALERT` | string | `lab/zaks/alert` | Alert topic |
| `VITE_MAX_DATA_POINTS` | number | `10000` | Max data points in memory |

## 📊 Type Definitions

### TelemetryData

```typescript
interface TelemetryData {
  id: string
  t: number | null
  h: number | null
  gasA: number | null
  gasD: number | null
  alarm: boolean
  timestamp: Date
  rawJson?: string
}
```

### ConnectionStatus

```typescript
type ConnectionStatus = 'connected' | 'connecting' | 'disconnected' | 'error'
```

### TimeRange

```typescript
type TimeRange = 'live' | '1h' | '6h' | '24h' | 'all'
```

### AppPreferences

```typescript
interface AppPreferences {
  theme: 'light' | 'dark'
  gasThreshold: number
  muteAlarms: boolean
  muteUntil?: number
}
```

## 🔔 Browser Notifications

Dashboard menggunakan Web Notification API untuk alarm.

**Permission Request**:

```typescript
if ('Notification' in window && Notification.permission === 'default') {
  Notification.requestPermission()
}
```

**Trigger**:

Notifikasi otomatis muncul saat `alarm: true` dalam telemetry payload.

**Mute**:

User dapat mute notifikasi selama 5 menit via button di header.

## 💾 Data Persistence

### localStorage Keys

| Key | Type | Description |
|-----|------|-------------|
| `iot-dashboard-preferences` | JSON | User preferences (theme, threshold, mute) |

**Format**:

```json
{
  "theme": "dark",
  "gasThreshold": 2000,
  "muteAlarms": false,
  "muteUntil": 1234567890123
}
```

## 🚨 Error Handling

### MQTT Connection Errors

```typescript
mqttClient.on('error', (error) => {
  setError(error.message)
  // Error displayed in UI via badge and optional toast
})
```

### Payload Validation Errors

Invalid payloads logged ke console:

```typescript
console.error(`Invalid telemetry payload: ${result.error}`, payloadString)
```

Payload yang invalid **tidak** ditambahkan ke store.

## 🔐 Security Considerations

1. **No Credentials in Code**: Semua credentials via `.env`
2. **HTTPS/WSS Required**: Production harus gunakan secure protocols
3. **Input Validation**: Semua MQTT payloads divalidasi dengan Zod
4. **CORS**: Browser enforce same-origin atau CORS policies
5. **Rate Limiting**: Implement di broker atau proxy level

## 📈 Performance Tips

1. **Sliding Window**: Maksimum 10k data points di memory
2. **Downsampling**: Chart render max 1k points
3. **Pagination**: Table render 50 items per page
4. **Zustand Selectors**: Subscribe only to needed state
5. **React.memo**: Prevent unnecessary re-renders

---

**Last Updated**: 2024
