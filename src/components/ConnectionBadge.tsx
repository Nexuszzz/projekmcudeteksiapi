import { Wifi, WifiOff, Loader2 } from 'lucide-react'
import type { ConnectionStatus } from '../types/telemetry'

interface ConnectionBadgeProps {
  status: ConnectionStatus
  broker: string
  clientId: string | null
}

export function ConnectionBadge({ status, broker, clientId }: ConnectionBadgeProps) {
  const getStatusConfig = (status: ConnectionStatus) => {
    switch (status) {
      case 'connected':
        return {
          icon: Wifi,
          text: 'Connected',
          className: 'bg-green-500/20 text-green-600 dark:text-green-400 border-green-500/30',
          iconClassName: 'text-green-600 dark:text-green-400',
        }
      case 'connecting':
        return {
          icon: Loader2,
          text: 'Connecting',
          className: 'bg-yellow-500/20 text-yellow-600 dark:text-yellow-400 border-yellow-500/30',
          iconClassName: 'text-yellow-600 dark:text-yellow-400 animate-spin',
        }
      case 'error':
        return {
          icon: WifiOff,
          text: 'Error',
          className: 'bg-red-500/20 text-red-600 dark:text-red-400 border-red-500/30',
          iconClassName: 'text-red-600 dark:text-red-400',
        }
      default:
        return {
          icon: WifiOff,
          text: 'Disconnected',
          className: 'bg-gray-500/20 text-gray-600 dark:text-gray-400 border-gray-500/30',
          iconClassName: 'text-gray-600 dark:text-gray-400',
        }
    }
  }

  const config = getStatusConfig(status)
  const Icon = config.icon

  return (
    <div
      className={`flex items-center gap-2 px-3 py-1.5 rounded-lg border ${config.className} transition-all duration-200`}
      role="status"
      aria-label={`MQTT ${config.text}`}
    >
      <Icon className={`h-4 w-4 ${config.iconClassName}`} aria-hidden="true" />
      <div className="flex flex-col">
        <span className="text-sm font-medium">{config.text}</span>
        {status === 'connected' && clientId && (
          <span className="text-xs opacity-70">
            {broker.replace('ws://', '').replace('wss://', '').split('/')[0]}
          </span>
        )}
      </div>
    </div>
  )
}
