import { describe, it, expect } from 'vitest'
import { parseTelemetryPayload, isTelemetryPayload } from './validation'

describe('parseTelemetryPayload', () => {
  it('should parse valid telemetry payload', () => {
    const payload = '{"id":"ESP32-001","t":27.5,"h":62.0,"gasA":1830,"gasD":0,"alarm":false}'
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(true)
    expect(result.data).toEqual({
      id: 'ESP32-001',
      t: 27.5,
      h: 62.0,
      gasA: 1830,
      gasD: 0,
      alarm: false,
    })
  })

  it('should handle missing optional fields with defaults', () => {
    const payload = '{"id":"ESP32-001"}'
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(true)
    expect(result.data).toEqual({
      id: 'ESP32-001',
      t: null,
      h: null,
      gasA: null,
      gasD: null,
      alarm: false,
    })
  })

  it('should default id to "unknown" if missing', () => {
    const payload = '{"t":25.0}'
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(true)
    expect(result.data?.id).toBe('unknown')
  })

  it('should reject gasA out of range', () => {
    const payload = '{"id":"ESP32-001","gasA":5000}'
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(false)
    expect(result.error).toContain('gasA')
  })

  it('should reject invalid JSON', () => {
    const payload = 'invalid json'
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(false)
    expect(result.error).toBeDefined()
  })

  it('should parse Buffer payload', () => {
    const payload = Buffer.from('{"id":"ESP32-001","t":28.0}')
    const result = parseTelemetryPayload(payload)

    expect(result.success).toBe(true)
    expect(result.data?.t).toBe(28.0)
  })
})

describe('isTelemetryPayload', () => {
  it('should return true for valid payload', () => {
    const data = {
      id: 'ESP32-001',
      t: 27.5,
      h: 62.0,
      gasA: 1830,
      gasD: 0,
      alarm: false,
    }

    expect(isTelemetryPayload(data)).toBe(true)
  })

  it('should return false for invalid payload', () => {
    const data = {
      id: 'ESP32-001',
      gasA: 5000, // Out of range
    }

    expect(isTelemetryPayload(data)).toBe(false)
  })
})
