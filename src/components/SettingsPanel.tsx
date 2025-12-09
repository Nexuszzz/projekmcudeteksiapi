import { useState, useEffect } from 'react'
import { 
  Settings, 
  X, 
  Save, 
  RotateCcw, 
  Moon, 
  Sun, 
  Bell, 
  BellOff,
  RefreshCw,
  Volume2,
  VolumeX
} from 'lucide-react'

interface SettingsConfig {
  theme: 'light' | 'dark' | 'auto'
  autoRefreshInterval: number // seconds
  enableNotifications: boolean
  enableSound: boolean
  enableAnimations: boolean
  compactMode: boolean
}

const DEFAULT_SETTINGS: SettingsConfig = {
  theme: 'auto',
  autoRefreshInterval: 30,
  enableNotifications: true,
  enableSound: true,
  enableAnimations: true,
  compactMode: false
}

interface SettingsPanelProps {
  isOpen: boolean
  onClose: () => void
}

export function SettingsPanel({ isOpen, onClose }: SettingsPanelProps) {
  const [settings, setSettings] = useState<SettingsConfig>(DEFAULT_SETTINGS)
  const [hasChanges, setHasChanges] = useState(false)

  // Load settings from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('dashboard-settings')
    if (saved) {
      try {
        const parsed = JSON.parse(saved)
        setSettings({ ...DEFAULT_SETTINGS, ...parsed })
      } catch (e) {
        console.error('Failed to load settings:', e)
      }
    }
  }, [])

  // Apply theme changes
  useEffect(() => {
    if (settings.theme === 'dark') {
      document.documentElement.classList.add('dark')
    } else if (settings.theme === 'light') {
      document.documentElement.classList.remove('dark')
    } else {
      // Auto: use system preference
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    }
  }, [settings.theme])

  const handleChange = <K extends keyof SettingsConfig>(
    key: K,
    value: SettingsConfig[K]
  ) => {
    setSettings(prev => ({ ...prev, [key]: value }))
    setHasChanges(true)
  }

  const handleSave = () => {
    localStorage.setItem('dashboard-settings', JSON.stringify(settings))
    setHasChanges(false)
    
    // Dispatch custom event for other components to react
    window.dispatchEvent(new CustomEvent('settings-updated', { detail: settings }))
    
    // Show toast notification
    showToast('Settings saved successfully!', 'success')
  }

  const handleReset = () => {
    if (confirm('Reset all settings to default values?')) {
      setSettings(DEFAULT_SETTINGS)
      setHasChanges(true)
    }
  }

  const showToast = (message: string, type: 'success' | 'error') => {
    // Simple toast notification (you can enhance this)
    const toast = document.createElement('div')
    toast.className = `fixed bottom-4 right-4 px-6 py-3 rounded-lg shadow-lg z-50 ${
      type === 'success' ? 'bg-green-600' : 'bg-red-600'
    } text-white font-medium animate-fade-in`
    toast.textContent = message
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.classList.add('animate-fade-out')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/50 z-40 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Settings Panel */}
      <div className="fixed right-0 top-0 h-full w-full sm:w-[480px] bg-white dark:bg-gray-800 shadow-2xl z-50 overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 p-6 z-10">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <Settings className="w-6 h-6 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                  Settings
                </h2>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  Configure your dashboard preferences
                </p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
            >
              <X className="w-5 h-5 text-gray-600 dark:text-gray-400" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Appearance Section */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Appearance
            </h3>
            
            {/* Theme */}
            <div className="space-y-3">
              <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Theme
              </label>
              <div className="grid grid-cols-3 gap-3">
                {(['light', 'dark', 'auto'] as const).map((theme) => (
                  <button
                    key={theme}
                    onClick={() => handleChange('theme', theme)}
                    className={`p-3 rounded-lg border-2 transition-all ${
                      settings.theme === theme
                        ? 'border-blue-600 bg-blue-50 dark:bg-blue-900/20'
                        : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
                    }`}
                  >
                    <div className="flex flex-col items-center gap-2">
                      {theme === 'light' && <Sun className="w-5 h-5" />}
                      {theme === 'dark' && <Moon className="w-5 h-5" />}
                      {theme === 'auto' && <RefreshCw className="w-5 h-5" />}
                      <span className="text-sm font-medium capitalize">{theme}</span>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Compact Mode */}
            <div className="mt-4 flex items-center justify-between">
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Compact Mode
                </label>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  Reduce spacing and padding
                </p>
              </div>
              <button
                onClick={() => handleChange('compactMode', !settings.compactMode)}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                  settings.compactMode ? 'bg-blue-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    settings.compactMode ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            </div>

            {/* Enable Animations */}
            <div className="mt-4 flex items-center justify-between">
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Enable Animations
                </label>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  Smooth transitions and effects
                </p>
              </div>
              <button
                onClick={() => handleChange('enableAnimations', !settings.enableAnimations)}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                  settings.enableAnimations ? 'bg-blue-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    settings.enableAnimations ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            </div>
          </section>

          {/* Notifications Section */}
          <section className="pt-6 border-t border-gray-200 dark:border-gray-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Notifications
            </h3>

            {/* Enable Notifications */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                {settings.enableNotifications ? (
                  <Bell className="w-5 h-5 text-blue-600" />
                ) : (
                  <BellOff className="w-5 h-5 text-gray-400" />
                )}
                <div>
                  <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                    Enable Notifications
                  </label>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    Show fire detection alerts
                  </p>
                </div>
              </div>
              <button
                onClick={() => handleChange('enableNotifications', !settings.enableNotifications)}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                  settings.enableNotifications ? 'bg-blue-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    settings.enableNotifications ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            </div>

            {/* Enable Sound */}
            <div className="mt-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                {settings.enableSound ? (
                  <Volume2 className="w-5 h-5 text-blue-600" />
                ) : (
                  <VolumeX className="w-5 h-5 text-gray-400" />
                )}
                <div>
                  <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                    Enable Sound
                  </label>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    Play alert sounds
                  </p>
                </div>
              </div>
              <button
                onClick={() => handleChange('enableSound', !settings.enableSound)}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                  settings.enableSound ? 'bg-blue-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    settings.enableSound ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            </div>
          </section>

          {/* Auto-Refresh Section */}
          <section className="pt-6 border-t border-gray-200 dark:border-gray-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Auto-Refresh
            </h3>

            {/* Auto Refresh Interval */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Dashboard Refresh Interval
                </label>
                <span className="text-sm font-semibold text-blue-600">
                  {settings.autoRefreshInterval}s
                </span>
              </div>
              <input
                type="range"
                min="5"
                max="120"
                step="5"
                value={settings.autoRefreshInterval}
                onChange={(e) => handleChange('autoRefreshInterval', parseInt(e.target.value))}
                className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer accent-blue-600"
              />
              <div className="flex justify-between text-xs text-gray-500">
                <span>5s</span>
                <span>30s</span>
                <span>60s</span>
                <span>120s</span>
              </div>
            </div>
          </section>
        </div>

        {/* Footer Actions */}
        <div className="sticky bottom-0 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 p-6">
          <div className="flex gap-3">
            <button
              onClick={handleReset}
              className="flex-1 flex items-center justify-center gap-2 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-300 transition-colors"
            >
              <RotateCcw className="w-4 h-4" />
              Reset
            </button>
            <button
              onClick={handleSave}
              disabled={!hasChanges}
              className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-lg transition-colors ${
                hasChanges
                  ? 'bg-blue-600 hover:bg-blue-700 text-white'
                  : 'bg-gray-300 dark:bg-gray-700 text-gray-500 cursor-not-allowed'
              }`}
            >
              <Save className="w-4 h-4" />
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </>
  )
}

// Export settings hook for other components
export function useSettings() {
  const [settings, setSettings] = useState<SettingsConfig>(DEFAULT_SETTINGS)

  useEffect(() => {
    const loadSettings = () => {
      const saved = localStorage.getItem('dashboard-settings')
      if (saved) {
        try {
          const parsed = JSON.parse(saved)
          setSettings({ ...DEFAULT_SETTINGS, ...parsed })
        } catch (e) {
          console.error('Failed to load settings:', e)
        }
      }
    }

    loadSettings()

    // Listen for settings updates
    const handleUpdate = (e: CustomEvent) => {
      setSettings(e.detail)
    }

    window.addEventListener('settings-updated', handleUpdate as EventListener)
    return () => {
      window.removeEventListener('settings-updated', handleUpdate as EventListener)
    }
  }, [])

  return settings
}
