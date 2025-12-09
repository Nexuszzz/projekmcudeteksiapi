import type { AppPreferences } from '../types/telemetry'

const PREFERENCES_KEY = 'iot-dashboard-preferences'

const defaultPreferences: AppPreferences = {
  theme: 'dark',
  gasThreshold: 3500, // Default threshold (ESP32 ADC: 0-4095)
  muteAlarms: false,
}

/**
 * Load app preferences from localStorage
 */
export function loadPreferences(): AppPreferences {
  try {
    const stored = localStorage.getItem(PREFERENCES_KEY)
    if (stored) {
      const parsed = JSON.parse(stored) as Partial<AppPreferences>
      return { ...defaultPreferences, ...parsed }
    }
  } catch (error) {
    console.error('Failed to load preferences:', error)
  }
  return defaultPreferences
}

/**
 * Save app preferences to localStorage
 */
export function savePreferences(preferences: Partial<AppPreferences>): void {
  try {
    const current = loadPreferences()
    const updated = { ...current, ...preferences }
    localStorage.setItem(PREFERENCES_KEY, JSON.stringify(updated))
  } catch (error) {
    console.error('Failed to save preferences:', error)
  }
}

/**
 * Clear all app data from localStorage
 */
export function clearPreferences(): void {
  try {
    localStorage.removeItem(PREFERENCES_KEY)
  } catch (error) {
    console.error('Failed to clear preferences:', error)
  }
}
