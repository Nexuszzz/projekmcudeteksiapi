import { useMemo } from 'react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'
import { format } from 'date-fns'
import { useTelemetryStore } from '../store/useTelemetryStore'
import { downsampleData } from '../utils/time'
import type { TimeRange } from '../types/telemetry'

const TIME_RANGE_OPTIONS: { value: TimeRange; label: string }[] = [
  { value: 'live', label: 'Live' },
  { value: '1h', label: '1 Hour' },
  { value: '6h', label: '6 Hours' },
  { value: '24h', label: '24 Hours' },
  { value: 'all', label: 'All Data' },
]

export function LiveChart() {
  const { data, timeRange, setTimeRange, getFilteredData } = useTelemetryStore()

  const chartData = useMemo(() => {
    const filtered = getFilteredData()
    // Downsample to max 1000 points for performance
    const downsampled = downsampleData(filtered, 1000)

    return downsampled.map((item) => ({
      timestamp: item.timestamp.getTime(),
      time: format(item.timestamp, 'HH:mm:ss'),
      t: item.t,
      h: item.h,
      gasA: item.gasA,
    }))
  }, [data, timeRange, getFilteredData])

  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-3 shadow-lg">
          <p className="text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            {format(new Date(payload[0].payload.timestamp), 'HH:mm:ss')}
          </p>
          {payload.map((entry: any, index: number) => (
            <div key={index} className="flex items-center justify-between gap-4 text-sm">
              <span style={{ color: entry.color }} className="font-medium">
                {entry.name}:
              </span>
              <span className="text-gray-900 dark:text-gray-100">
                {entry.value !== null ? entry.value.toFixed(2) : 'N/A'}
              </span>
            </div>
          ))}
        </div>
      )
    }
    return null
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100">
          Real-Time Sensor Data
        </h2>

        <div className="flex gap-2 flex-wrap">
          {TIME_RANGE_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() => setTimeRange(option.value)}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${timeRange === option.value
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                }`}
              aria-pressed={timeRange === option.value}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {chartData.length === 0 ? (
        <div className="h-80 flex items-center justify-center text-gray-500 dark:text-gray-400">
          <div className="text-center">
            <p className="text-lg font-medium mb-2">No data available</p>
            <p className="text-sm">Waiting for telemetry data from MQTT...</p>
          </div>
        </div>
      ) : (
        <ResponsiveContainer width="100%" height={400}>
          <LineChart
            data={chartData}
            margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
          >
            <CartesianGrid strokeDasharray="3 3" className="stroke-gray-200 dark:stroke-gray-700" />
            <XAxis
              dataKey="time"
              tick={{ fill: 'currentColor' }}
              className="text-gray-600 dark:text-gray-400"
              angle={-45}
              textAnchor="end"
              height={80}
            />
            <YAxis
              tick={{ fill: 'currentColor' }}
              className="text-gray-600 dark:text-gray-400"
            />
            <Tooltip content={<CustomTooltip />} />
            <Legend
              wrapperStyle={{
                paddingTop: '20px',
              }}
              iconType="line"
            />
            <Line
              type="monotone"
              dataKey="t"
              name="Temperature (°C)"
              stroke="#ef4444"
              strokeWidth={2}
              dot={false}
              isAnimationActive={false}
            />
            <Line
              type="monotone"
              dataKey="h"
              name="Humidity (%)"
              stroke="#3b82f6"
              strokeWidth={2}
              dot={false}
              isAnimationActive={false}
            />
            <Line
              type="monotone"
              dataKey="gasA"
              name="Gas Analog"
              stroke="#10b981"
              strokeWidth={2}
              dot={false}
              isAnimationActive={false}
            />
          </LineChart>
        </ResponsiveContainer>
      )}

      <div className="mt-4 text-sm text-gray-600 dark:text-gray-400 text-center">
        Displaying {chartData.length} data points
        {data.length > 1000 && ` (downsampled from ${data.length})`}
      </div>
    </div>
  )
}
