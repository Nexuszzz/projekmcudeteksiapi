import { useState } from 'react'
import { Flame, Sun, Moon, RefreshCw, Clock, BellOff, Bell, Settings, Gauge, MessageSquare, Video } from 'lucide-react'
import { format } from 'date-fns'
import { useLocation, useNavigate } from 'react-router-dom'
import { ConnectionBadge } from './ConnectionBadge'
import { SettingsPanel } from './SettingsPanel'
import { useTelemetryStore } from '../store/useTelemetryStore'
import { useMqttClient } from '../hooks/useMqttClient'

interface HeaderProps { }

export function Header({ }: HeaderProps) {
  const navigate = useNavigate()
  const location = useLocation()

  const {
    connectionStatus,
    clientId,
    lastUpdate,
    preferences,
    setTheme,
    setMuteAlarms,
  } = useTelemetryStore()

  const { connect, config } = useMqttClient()

  const [showSettings, setShowSettings] = useState(false)

  const currentPath = location.pathname

  const handleThemeToggle = () => {
    setTheme(preferences.theme === 'dark' ? 'light' : 'dark')
  }

  const handleReconnect = () => {
    connect()
  }

  const handleToggleMute = () => {
    setMuteAlarms(!preferences.muteAlarms, 5 * 60 * 1000) // Mute for 5 minutes
  }

  const isMuted = preferences.muteAlarms && preferences.muteUntil && Date.now() < preferences.muteUntil

  return (
    <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 shadow-sm">
      <div className="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo & Title */}
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-gradient-to-br from-orange-500 to-red-600 rounded-lg">
                <Flame className="h-6 w-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900 dark:text-gray-100">
                  Fire Detection Dashboard
                </h1>
                <p className="text-xs text-gray-600 dark:text-gray-400 hidden sm:block">
                  Real-time IoT Monitoring & Control
                </p>
              </div>
            </div>

            {/* Navigation Tabs */}
            <nav className="hidden md:flex items-center gap-2 ml-8">
              <button
                onClick={() => navigate('/')}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all ${currentPath === '/'
                  ? 'bg-gradient-to-r from-blue-500 to-blue-600 text-white shadow-lg shadow-blue-500/30'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-600'
                  }`}
              >
                <Gauge className="h-4 w-4" />
                <span>Dashboard</span>
              </button>

              <button
                onClick={() => navigate('/live-stream')}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all ${currentPath === '/live-stream'
                  ? 'bg-gradient-to-r from-red-500 to-orange-600 text-white shadow-lg shadow-red-500/30'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-600'
                  }`}
              >
                <Video className="h-4 w-4" />
                <span>Live Stream</span>
              </button>

              <button
                onClick={() => navigate('/whatsapp')}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all ${currentPath === '/whatsapp'
                  ? 'bg-gradient-to-r from-green-500 to-green-600 text-white shadow-lg shadow-green-500/30'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-600'
                  }`}
              >
                <MessageSquare className="h-4 w-4" />
                <span>WhatsApp</span>
              </button>
            </nav>
          </div>

          {/* Right Section */}
          <div className="flex items-center gap-3">
            {/* Last Update */}
            {lastUpdate && (
              <div className="hidden lg:flex items-center gap-2 px-3 py-1.5 bg-gray-100 dark:bg-gray-700 rounded-lg">
                <Clock className="h-4 w-4 text-gray-600 dark:text-gray-400" />
                <div className="text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Last update: </span>
                  <span className="font-medium text-gray-900 dark:text-gray-100">
                    {format(lastUpdate, 'HH:mm:ss')}
                  </span>
                </div>
              </div>
            )}

            {/* Connection Status */}
            <ConnectionBadge
              status={connectionStatus}
              broker={config.url}
              clientId={clientId}
            />

            {/* Mute Alarms */}
            <button
              onClick={handleToggleMute}
              className={`p-2 rounded-lg transition-colors ${isMuted
                ? 'bg-yellow-500/20 text-yellow-600 dark:text-yellow-400'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-600'
                }`}
              aria-label={isMuted ? 'Unmute alarms' : 'Mute alarms'}
              title={isMuted ? 'Alarms muted for 5 minutes' : 'Mute alarms for 5 minutes'}
            >
              {isMuted ? <BellOff className="h-5 w-5" /> : <Bell className="h-5 w-5" />}
            </button>

            {/* Reconnect */}
            <button
              onClick={handleReconnect}
              className="p-2 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
              aria-label="Reconnect to MQTT"
              title="Reconnect to MQTT broker"
            >
              <RefreshCw className="h-5 w-5" />
            </button>

            {/* Theme Toggle */}
            <button
              onClick={handleThemeToggle}
              className="p-2 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
              aria-label={`Switch to ${preferences.theme === 'dark' ? 'light' : 'dark'} mode`}
            >
              {preferences.theme === 'dark' ? (
                <Sun className="h-5 w-5" />
              ) : (
                <Moon className="h-5 w-5" />
              )}
            </button>

            {/* Settings Button */}
            <button
              onClick={() => setShowSettings(true)}
              className="p-2 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors"
              aria-label="Open settings"
              title="Settings"
            >
              <Settings className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Settings Panel */}
      <SettingsPanel isOpen={showSettings} onClose={() => setShowSettings(false)} />
    </header>
  )
}
