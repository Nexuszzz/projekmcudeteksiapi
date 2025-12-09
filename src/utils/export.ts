import type { TelemetryData } from '../types/telemetry'
import { format } from 'date-fns'

/**
 * Export telemetry data to CSV format
 */
export function exportToCSV(data: TelemetryData[]): string {
  const headers = ['Timestamp', 'Device ID', 'Temperature (°C)', 'Humidity (%)', 'Gas Analog', 'Gas Digital', 'Alarm', 'Raw JSON']
  const rows = data.map((item) => [
    format(item.timestamp, 'yyyy-MM-dd HH:mm:ss'),
    item.id,
    item.t?.toFixed(2) ?? 'N/A',
    item.h?.toFixed(2) ?? 'N/A',
    item.gasA ?? 'N/A',
    item.gasD ?? 'N/A',
    item.alarm ? 'ON' : 'OFF',
    `"${item.rawJson?.replace(/"/g, '""') ?? ''}"`,
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map((row) => row.join(',')),
  ].join('\n')

  return csvContent
}

/**
 * Export telemetry data to JSONL format
 */
export function exportToJSONL(data: TelemetryData[]): string {
  return data
    .map((item) => {
      const exportItem = {
        timestamp: format(item.timestamp, 'yyyy-MM-dd HH:mm:ss'),
        id: item.id,
        t: item.t,
        h: item.h,
        gasA: item.gasA,
        gasD: item.gasD,
        alarm: item.alarm,
      }
      return JSON.stringify(exportItem)
    })
    .join('\n')
}

/**
 * Download data as file
 */
export function downloadFile(content: string, filename: string, mimeType: string): void {
  const blob = new Blob([content], { type: mimeType })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

/**
 * Generate filename with timestamp
 */
export function generateFilename(prefix: string, extension: string): string {
  const timestamp = format(new Date(), 'yyyyMMdd-HHmmss')
  return `${prefix}-${timestamp}.${extension}`
}
