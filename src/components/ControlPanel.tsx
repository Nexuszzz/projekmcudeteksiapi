import { useState, useCallback } from 'react'
import { Power, Check, Send } from 'lucide-react'
import { useMqttClient } from '../hooks/useMqttClient'
import { useTelemetryStore } from '../store/useTelemetryStore'

export function ControlPanel() {
  const { setBuzzer, setGasThreshold: sendGasThreshold } = useMqttClient()
  const { preferences, setGasThreshold, data, connectionStatus } = useTelemetryStore()
  const isConnected = connectionStatus === 'connected'
  const latestData = data[data.length - 1]
  const gasAnalog = latestData?.gasA ?? 0
  
  const [buzzerState, setBuzzerState] = useState(false)
  const [thresholdValue, setThresholdValue] = useState(preferences.gasThreshold)
  const [commandFeedback, setCommandFeedback] = useState<string | null>(null)
  const [debounceTimeout, setDebounceTimeout] = useState<NodeJS.Timeout | null>(null)

  const showFeedback = useCallback((message: string) => {
    setCommandFeedback(message)
    setTimeout(() => setCommandFeedback(null), 3000)
  }, [])

  const handleBuzzerToggle = useCallback((state: boolean) => {
    if (!isConnected) {
      showFeedback('❌ Not connected to MQTT')
      return
    }

    setBuzzerState(state)
    const success = setBuzzer(state)
    
    if (success) {
      showFeedback(`✓ Buzzer ${state ? 'ON' : 'OFF'} command sent`)
    } else {
      showFeedback('❌ Failed to send buzzer command')
    }
  }, [isConnected, setBuzzer, showFeedback])

  const handleThresholdChange = useCallback((value: number) => {
    setThresholdValue(value)
    
    // Debounce threshold updates
    if (debounceTimeout) {
      clearTimeout(debounceTimeout)
    }

    const timeout = setTimeout(() => {
      setGasThreshold(value)
    }, 500)

    setDebounceTimeout(timeout)
  }, [debounceTimeout, setGasThreshold])

  const handleThresholdApply = useCallback(() => {
    if (!isConnected) {
      showFeedback('❌ Not connected to MQTT')
      return
    }

    const success = sendGasThreshold(thresholdValue)
    
    if (success) {
      setGasThreshold(thresholdValue)
      showFeedback(`✓ Threshold set to ${thresholdValue}`)
    } else {
      showFeedback('❌ Failed to send threshold command')
    }
  }, [isConnected, thresholdValue, sendGasThreshold, setGasThreshold, showFeedback])

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
      <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-6">
        Remote Control
      </h2>

      {/* Command Feedback */}
      {commandFeedback && (
        <div className="mb-4 p-3 bg-primary-500/10 border border-primary-500/30 rounded-lg flex items-center gap-2 animate-fade-in">
          <Check className="h-4 w-4 text-primary-600 dark:text-primary-400" />
          <span className="text-sm font-medium text-primary-900 dark:text-primary-100">
            {commandFeedback}
          </span>
        </div>
      )}

      {/* Buzzer Control */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
          Buzzer Control
        </label>
        <div className="flex gap-3">
          <button
            onClick={() => handleBuzzerToggle(true)}
            disabled={!isConnected}
            className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg font-medium transition-all duration-200 ${
              buzzerState
                ? 'bg-green-600 text-white shadow-lg shadow-green-600/30'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
            } disabled:opacity-50 disabled:cursor-not-allowed`}
            aria-pressed={buzzerState}
          >
            <Power className="h-5 w-5" />
            <span>Buzzer ON</span>
          </button>
          
          <button
            onClick={() => handleBuzzerToggle(false)}
            disabled={!isConnected}
            className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg font-medium transition-all duration-200 ${
              !buzzerState
                ? 'bg-red-600 text-white shadow-lg shadow-red-600/30'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
            } disabled:opacity-50 disabled:cursor-not-allowed`}
            aria-pressed={!buzzerState}
          >
            <Power className="h-5 w-5" />
            <span>Buzzer OFF</span>
          </button>
        </div>
      </div>

      {/* Gas Threshold Control */}
      <div>
        <label htmlFor="gas-threshold" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
          Gas Threshold (ADC Value)
        </label>
        
        <div className="flex gap-3 items-end">
          <div className="flex-1">
            <input
              id="gas-threshold"
              type="range"
              min="100"
              max="4095"
              step="50"
              value={thresholdValue}
              onChange={(e) => handleThresholdChange(Number(e.target.value))}
              disabled={!isConnected}
              className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer accent-primary-600 disabled:opacity-50 disabled:cursor-not-allowed"
              aria-label="Gas threshold slider"
            />
            <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400 mt-1">
              <span>100</span>
              <span className="font-medium text-gray-900 dark:text-gray-100">
                {thresholdValue} {gasAnalog >= thresholdValue ? '⚠️ DANGER' : '✓ SAFE'}
              </span>
              <span>4095</span>
            </div>
          </div>
          
          <button
            onClick={handleThresholdApply}
            disabled={!isConnected}
            className="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            aria-label="Apply gas threshold"
          >
            <Send className="h-4 w-4" />
            Apply
          </button>
        </div>
      </div>

      {!isConnected && (
        <div className="mt-4 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-lg">
          <p className="text-sm text-yellow-800 dark:text-yellow-200">
            ⚠️ Controls disabled: Not connected to MQTT broker
          </p>
        </div>
      )}
    </div>
  )
}
