import { z } from 'zod'

// Zod schema for telemetry payload validation
export const TelemetryPayloadSchema = z.object({
  id: z.string().default('unknown'),
  t: z.number().nullable().default(null),
  h: z.number().nullable().default(null),
  gasA: z.number().int().min(0).max(4095).nullable().default(null),
  // Accept both boolean and number for gasD (ESP32 sends boolean)
  gasD: z.union([z.boolean(), z.number().int().min(0).max(1)]).nullable().default(null)
    .transform(val => typeof val === 'boolean' ? (val ? 1 : 0) : val),
  alarm: z.boolean().default(false),
  // Optional fields from ESP32
  gasMv: z.number().optional(),
  flame: z.boolean().optional(),
}).passthrough() // Allow additional fields without failing validation

export type TelemetryPayload = z.infer<typeof TelemetryPayloadSchema>

export interface TelemetryData extends TelemetryPayload {
  timestamp: Date
  rawJson?: string
}

export type ConnectionStatus = 'connected' | 'connecting' | 'disconnected' | 'error'

export interface MqttConfig {
  url: string
  username: string
  password: string
  topicPub: string
  topicCmd: string
  topicStatus: string
}

export type TimeRange = 'live' | '1h' | '6h' | '24h' | 'all'

export interface ChartDataPoint {
  timestamp: number
  t: number | null
  h: number | null
  gasA: number | null
}

export type Theme = 'light' | 'dark'

export interface AppPreferences {
  theme: Theme
  gasThreshold: number
  muteAlarms: boolean
  muteUntil?: number
}

// Fire Detection Types
export interface BoundingBox {
  x1: number
  y1: number
  x2: number
  y2: number
  width?: number
  height?: number
}

export interface FireDetectionData {
  id: string
  timestamp: Date
  confidence: number
  bbox: BoundingBox
  geminiScore?: number
  geminiReason?: string
  geminiVerified: boolean
  snapshotUrl?: string
  cameraId: string
  cameraIp: string
  yoloModel: string
  status: 'active' | 'resolved' | 'false_positive'
}

export interface FireDetectionAlert {
  id: string
  src: 'yolo_gemini' | 'yolo_only' | 'manual'
  alert: 'flame_detected'
  conf: number
  gemini_score?: number
  gemini_reason?: string
  gemini_verified?: boolean
  bbox: number[] // [x1, y1, x2, y2]
  buzzer_duration?: number
  led_blink?: number
  ts: number
  camera_ip?: string
}
