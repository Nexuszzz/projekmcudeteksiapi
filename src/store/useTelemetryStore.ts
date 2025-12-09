import { create } from 'zustand'
import type { TelemetryData, ConnectionStatus, AppPreferences, TimeRange, FireDetectionData } from '../types/telemetry'
import { loadPreferences, savePreferences } from '../utils/storage'

const MAX_DATA_POINTS = Number(import.meta.env.VITE_MAX_DATA_POINTS) || 10000
const MAX_FIRE_DETECTIONS = 100

interface FireAlert {
  message: string
  type: 'fire' | 'gas' | 'info'
  timestamp: Date
}

interface TelemetryStore {
  // Data
  data: TelemetryData[]
  lastUpdate: Date | null
  
  // Fire Detections
  fireDetections: FireDetectionData[]
  
  // Connection
  connectionStatus: ConnectionStatus
  clientId: string | null
  errorMessage: string | null
  
  // Alerts
  fireAlert: FireAlert | null
  
  // Preferences
  preferences: AppPreferences
  
  // UI State
  timeRange: TimeRange
  
  // Actions
  addTelemetryData: (data: TelemetryData) => void
  clearData: () => void
  addFireDetection: (detection: FireDetectionData) => void
  updateFireDetection: (id: string, updates: Partial<FireDetectionData>) => void
  removeFireDetection: (id: string) => void
  setConnectionStatus: (status: ConnectionStatus) => void
  setClientId: (id: string) => void
  setError: (message: string | null) => void
  setFireAlert: (alert: FireAlert | null) => void
  setTheme: (theme: 'light' | 'dark') => void
  setGasThreshold: (threshold: number) => void
  setMuteAlarms: (mute: boolean, duration?: number) => void
  setTimeRange: (range: TimeRange) => void
  getFilteredData: () => TelemetryData[]
}

export const useTelemetryStore = create<TelemetryStore>((set, get) => {
  const initialPreferences = loadPreferences()
  
  // Apply theme on init
  if (typeof window !== 'undefined') {
    document.documentElement.classList.toggle('dark', initialPreferences.theme === 'dark')
  }

  return {
    // Initial state
    data: [],
    lastUpdate: null,
    fireDetections: [],
    connectionStatus: 'disconnected',
    clientId: null,
    errorMessage: null,
    fireAlert: null,
    preferences: initialPreferences,
    timeRange: 'live',

    // Add telemetry data with sliding window
    addTelemetryData: (newData) => {
      set((state) => {
        const updatedData = [...state.data, newData]
        
        // Sliding window: keep only last MAX_DATA_POINTS
        const trimmedData = updatedData.length > MAX_DATA_POINTS
          ? updatedData.slice(updatedData.length - MAX_DATA_POINTS)
          : updatedData

        return {
          data: trimmedData,
          lastUpdate: newData.timestamp,
        }
      })
    },

    clearData: () => {
      set({ data: [], lastUpdate: null })
    },

    // Fire detection actions
    addFireDetection: (detection) => {
      set((state) => {
        const updated = [detection, ...state.fireDetections]
        // Keep only last MAX_FIRE_DETECTIONS
        const trimmed = updated.length > MAX_FIRE_DETECTIONS
          ? updated.slice(0, MAX_FIRE_DETECTIONS)
          : updated
        return { fireDetections: trimmed }
      })
    },

    updateFireDetection: (id, updates) => {
      set((state) => ({
        fireDetections: state.fireDetections.map(det =>
          det.id === id ? { ...det, ...updates } : det
        )
      }))
    },

    removeFireDetection: (id) => {
      set((state) => ({
        fireDetections: state.fireDetections.filter(det => det.id !== id)
      }))
    },

    setConnectionStatus: (status) => {
      set({ connectionStatus: status })
      if (status === 'connected') {
        set({ errorMessage: null })
      }
    },

    setClientId: (id) => {
      set({ clientId: id })
    },

    setError: (message) => {
      set({ errorMessage: message, connectionStatus: 'error' })
    },

    setFireAlert: (alert) => {
      set({ fireAlert: alert })
    },

    setTheme: (theme) => {
      set((state) => {
        const newPreferences = { ...state.preferences, theme }
        savePreferences({ theme })
        
        // Apply theme
        if (typeof window !== 'undefined') {
          document.documentElement.classList.toggle('dark', theme === 'dark')
        }
        
        return { preferences: newPreferences }
      })
    },

    setGasThreshold: (gasThreshold) => {
      set((state) => {
        const newPreferences = { ...state.preferences, gasThreshold }
        savePreferences({ gasThreshold })
        return { preferences: newPreferences }
      })
    },

    setMuteAlarms: (mute, duration) => {
      set((state) => {
        const muteUntil = mute && duration ? Date.now() + duration : undefined
        const newPreferences = { ...state.preferences, muteAlarms: mute, muteUntil }
        savePreferences({ muteAlarms: mute, muteUntil })
        return { preferences: newPreferences }
      })
    },

    setTimeRange: (range) => {
      set({ timeRange: range })
    },

    getFilteredData: () => {
      const { data, timeRange } = get()
      
      if (timeRange === 'all' || timeRange === 'live') {
        return data
      }

      const rangeMs: Record<string, number> = {
        '1h': 60 * 60 * 1000,
        '6h': 6 * 60 * 60 * 1000,
        '24h': 24 * 60 * 60 * 1000,
      }

      const cutoff = Date.now() - (rangeMs[timeRange] || 0)
      return data.filter((item) => item.timestamp.getTime() >= cutoff)
    },
  }
})
