import { TelemetryPayloadSchema, type TelemetryPayload } from '../types/telemetry'

export interface ValidationResult {
  success: boolean
  data?: TelemetryPayload
  error?: string
}

/**
 * Safely parse and validate MQTT payload
 */
export function parseTelemetryPayload(payload: string | Buffer): ValidationResult {
  try {
    const jsonString = typeof payload === 'string' ? payload : payload.toString()
    const parsed = JSON.parse(jsonString)

    const result = TelemetryPayloadSchema.safeParse(parsed)

    if (result.success) {
      return {
        success: true,
        data: result.data,
      }
    } else {
      return {
        success: false,
        error: result.error.errors.map((e) => `${e.path.join('.')}: ${e.message}`).join(', '),
      }
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown parsing error',
    }
  }
}

/**
 * Type guard for telemetry payload
 */
export function isTelemetryPayload(data: unknown): data is TelemetryPayload {
  const result = TelemetryPayloadSchema.safeParse(data)
  return result.success
}
