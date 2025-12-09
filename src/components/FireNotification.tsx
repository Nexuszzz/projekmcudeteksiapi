import { useEffect, useState } from 'react'
import { useTelemetryStore } from '../store/useTelemetryStore'

interface Notification {
  id: string
  message: string
  type: 'fire' | 'gas' | 'info'
  timestamp: Date
}

export function FireNotification() {
  const [notifications, setNotifications] = useState<Notification[]>([])

  // Subscribe to store notifications
  useEffect(() => {
    let lastAlertTime = 0
    
    const unsubscribe = useTelemetryStore.subscribe((state) => {
      const fireAlert = state.fireAlert
      if (fireAlert) {
        const now = Date.now()
        
        // Prevent rapid duplicate alerts (minimum 3 seconds between alerts)
        if (now - lastAlertTime < 3000) {
          console.log('⏭️ Skipping duplicate alert (too soon)')
          return
        }
        
        lastAlertTime = now
        
        const notification: Notification = {
          id: now.toString(),
          message: fireAlert.message,
          type: fireAlert.type,
          timestamp: new Date(),
        }
        
        console.log('🔔 Showing notification:', notification)
        
        setNotifications((prev) => {
          // Check for exact duplicate in last 5 seconds
          const hasDuplicate = prev.some((n) => 
            n.message === notification.message && 
            n.type === notification.type &&
            now - new Date(n.timestamp).getTime() < 5000
          )
          
          if (hasDuplicate) {
            console.log('⏭️ Duplicate notification blocked')
            return prev
          }
          
          return [notification, ...prev].slice(0, 3)
        })

        // Auto remove after 10 seconds
        setTimeout(() => {
          setNotifications((prev) => prev.filter((n) => n.id !== notification.id))
        }, 10000)
      }
    })
    return unsubscribe
  }, [])

  if (notifications.length === 0) return null

  return (
    <div className="fixed top-20 right-4 z-50 space-y-2 max-w-md">
      {notifications.map((notification) => (
        <div
          key={notification.id}
          className={`
            animate-slide-in-right
            rounded-lg shadow-2xl p-4 border-l-4
            backdrop-blur-sm
            ${
              notification.type === 'fire'
                ? 'bg-red-500/95 border-red-700 text-white'
                : notification.type === 'gas'
                ? 'bg-orange-500/95 border-orange-700 text-white'
                : 'bg-blue-500/95 border-blue-700 text-white'
            }
          `}
        >
          <div className="flex items-start gap-3">
            {/* Icon */}
            <div className="flex-shrink-0 mt-0.5">
              {notification.type === 'fire' ? (
                <svg className="w-6 h-6 animate-pulse" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fillRule="evenodd"
                    d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z"
                    clipRule="evenodd"
                  />
                </svg>
              ) : notification.type === 'gas' ? (
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fillRule="evenodd"
                    d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                    clipRule="evenodd"
                  />
                </svg>
              ) : (
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fillRule="evenodd"
                    d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                    clipRule="evenodd"
                  />
                </svg>
              )}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold uppercase tracking-wider">
                {notification.type === 'fire'
                  ? '🔥 INDIKASI KEBAKARAN!'
                  : notification.type === 'gas'
                  ? '⚠️ GAS TERDETEKSI!'
                  : 'ℹ️ INFO'}
              </p>
              <p className="mt-1 text-sm font-medium">{notification.message}</p>
              <p className="mt-1 text-xs opacity-90">
                {notification.timestamp.toLocaleTimeString('id-ID')}
              </p>
            </div>

            {/* Close button */}
            <button
              onClick={() => {
                setNotifications((prev) => prev.filter((n) => n.id !== notification.id))
              }}
              className="flex-shrink-0 text-white/80 hover:text-white transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}
