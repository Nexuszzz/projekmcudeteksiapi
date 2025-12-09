import type { ReactNode } from 'react'

interface MetricCardProps {
  title: string
  value: string | number
  unit?: string
  icon: ReactNode
  className?: string
  alert?: boolean
}

export function MetricCard({ title, value, unit, icon, className = '', alert = false }: MetricCardProps) {
  return (
    <div
      className={`rounded-lg border p-4 transition-all duration-200 ${
        alert
          ? 'bg-red-500/10 border-red-500/50 shadow-red-500/20 shadow-lg'
          : 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 hover:shadow-lg'
      } ${className}`}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600 dark:text-gray-400 mb-1">
            {title}
          </p>
          <div className="flex items-baseline gap-1">
            <p className={`text-2xl font-bold ${
              alert 
                ? 'text-red-600 dark:text-red-400' 
                : 'text-gray-900 dark:text-gray-100'
            }`}>
              {value}
            </p>
            {unit && (
              <span className="text-sm text-gray-500 dark:text-gray-400">
                {unit}
              </span>
            )}
          </div>
        </div>
        <div className={`p-2 rounded-lg ${
          alert
            ? 'bg-red-500/20 text-red-600 dark:text-red-400'
            : 'bg-primary-500/10 text-primary-600 dark:text-primary-400'
        }`}>
          {icon}
        </div>
      </div>
    </div>
  )
}
