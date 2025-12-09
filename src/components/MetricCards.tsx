import { Thermometer, Droplets, Wind, Activity, AlertTriangle } from 'lucide-react'
import { MetricCard } from './MetricCard'
import { useTelemetryStore } from '../store/useTelemetryStore'

export function MetricCards() {
  const data = useTelemetryStore((state) => state.data)
  const connectionStatus = useTelemetryStore((state) => state.connectionStatus)
  const preferences = useTelemetryStore((state) => state.preferences)
  const latestData = data[data.length - 1]

  const hasData = !!latestData
  const temperature = latestData?.t ?? 0
  const humidity = latestData?.h ?? 0
  const gasAnalog = latestData?.gasA ?? 0
  const gasDigital = latestData?.gasD ?? 0
  const alarm = latestData?.alarm ?? false

  // Gas threshold from user settings
  const gasThreshold = preferences.gasThreshold

  // Determine if showing placeholder
  const isWaiting = !hasData && connectionStatus === 'connected'

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
      <MetricCard
        title="Temperature"
        value={isWaiting ? '---' : temperature.toFixed(1)}
        unit="°C"
        icon={<Thermometer className="h-5 w-5" />}
      />
      
      <MetricCard
        title="Humidity"
        value={isWaiting ? '---' : humidity.toFixed(1)}
        unit="%"
        icon={<Droplets className="h-5 w-5" />}
      />
      
      <MetricCard
        title="Gas Level"
        value={isWaiting ? '---' : gasAnalog.toString()}
        unit="ADC"
        icon={<Wind className="h-5 w-5" />}
        alert={gasAnalog >= gasThreshold}
      />
      
      <MetricCard
        title="Gas Status"
        value={isWaiting ? '---' : (gasDigital === 1 ? 'DETECTED' : 'NORMAL')}
        icon={<Activity className="h-5 w-5" />}
        alert={gasDigital === 1}
      />
      
      <MetricCard
        title="Alarm Status"
        value={alarm ? 'ACTIVE' : 'NORMAL'}
        icon={<AlertTriangle className="h-5 w-5" />}
        alert={alarm}
      />
    </div>
  )
}
