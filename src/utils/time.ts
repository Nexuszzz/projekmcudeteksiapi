import type { TimeRange } from '../types/telemetry'

/**
 * Get milliseconds for time range
 */
export function getTimeRangeMs(range: TimeRange): number {
  switch (range) {
    case '1h':
      return 60 * 60 * 1000
    case '6h':
      return 6 * 60 * 60 * 1000
    case '24h':
      return 24 * 60 * 60 * 1000
    case 'all':
    case 'live':
      return Infinity
    default:
      return Infinity
  }
}

/**
 * Filter data by time range
 */
export function filterByTimeRange<T extends { timestamp: Date }>(
  data: T[],
  range: TimeRange
): T[] {
  if (range === 'all' || range === 'live') {
    return data
  }

  const rangeMs = getTimeRangeMs(range)
  const now = Date.now()

  return data.filter((item) => now - item.timestamp.getTime() <= rangeMs)
}

/**
 * Downsample data for chart performance
 */
export function downsampleData<T>(data: T[], maxPoints: number): T[] {
  if (data.length <= maxPoints) {
    return data
  }

  const step = Math.ceil(data.length / maxPoints)
  const result: T[] = []

  for (let i = 0; i < data.length; i += step) {
    result.push(data[i])
  }

  return result
}
