import { useState, useMemo } from 'react'
import { format } from 'date-fns'
import { Search, FileJson, FileSpreadsheet } from 'lucide-react'
import { useTelemetryStore } from '../store/useTelemetryStore'
import { exportToCSV, exportToJSONL, downloadFile, generateFilename } from '../utils/export'


const ITEMS_PER_PAGE = 50

export function LogTable() {
  const data = useTelemetryStore((state) => state.data)

  const [searchQuery, setSearchQuery] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')

  // Filter and search data
  const filteredData = useMemo(() => {
    let filtered = [...data].reverse() // Show newest first

    // Search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((item) => {
        return (
          item.id.toLowerCase().includes(query) ||
          item.rawJson?.toLowerCase().includes(query) ||
          format(item.timestamp, 'yyyy-MM-dd HH:mm:ss').includes(query)
        )
      })
    }

    // Date range filter
    if (startDate) {
      const start = new Date(startDate).getTime()
      filtered = filtered.filter((item) => item.timestamp.getTime() >= start)
    }
    if (endDate) {
      const end = new Date(endDate).getTime() + 86400000 // Add 1 day
      filtered = filtered.filter((item) => item.timestamp.getTime() <= end)
    }

    return filtered
  }, [data, searchQuery, startDate, endDate])

  // Pagination
  const totalPages = Math.ceil(filteredData.length / ITEMS_PER_PAGE)
  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * ITEMS_PER_PAGE
    const end = start + ITEMS_PER_PAGE
    return filteredData.slice(start, end)
  }, [filteredData, currentPage])

  // Reset to page 1 when filters change
  useMemo(() => {
    setCurrentPage(1)
  }, [searchQuery, startDate, endDate])

  const handleExportCSV = () => {
    const csv = exportToCSV(filteredData)
    const filename = generateFilename('telemetry-data', 'csv')
    downloadFile(csv, filename, 'text/csv')
  }

  const handleExportJSONL = () => {
    const jsonl = exportToJSONL(filteredData)
    const filename = generateFilename('telemetry-data', 'jsonl')
    downloadFile(jsonl, filename, 'application/jsonl')
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 mb-6">
        <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100">
          Telemetry Log
        </h2>

        <div className="flex gap-2 flex-wrap">
          <button
            onClick={handleExportCSV}
            disabled={filteredData.length === 0}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-sm"
            aria-label="Export as CSV"
          >
            <FileSpreadsheet className="h-4 w-4" />
            Export CSV
          </button>

          <button
            onClick={handleExportJSONL}
            disabled={filteredData.length === 0}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-sm"
            aria-label="Export as JSONL"
          >
            <FileJson className="h-4 w-4" />
            Export JSONL
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500"
            aria-label="Search telemetry data"
          />
        </div>

        {/* Start Date */}
        <div>
          <input
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            className="w-full px-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500"
            aria-label="Start date filter"
          />
        </div>

        {/* End Date */}
        <div>
          <input
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            className="w-full px-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500"
            aria-label="End date filter"
          />
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="sticky top-0 bg-gray-50 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700">
            <tr>
              <th className="px-4 py-3 text-left font-semibold text-gray-900 dark:text-gray-100">
                Timestamp
              </th>
              <th className="px-4 py-3 text-left font-semibold text-gray-900 dark:text-gray-100">
                Device ID
              </th>
              <th className="px-4 py-3 text-right font-semibold text-gray-900 dark:text-gray-100">
                Temp (°C)
              </th>
              <th className="px-4 py-3 text-right font-semibold text-gray-900 dark:text-gray-100">
                Humidity (%)
              </th>
              <th className="px-4 py-3 text-right font-semibold text-gray-900 dark:text-gray-100">
                Gas A
              </th>
              <th className="px-4 py-3 text-center font-semibold text-gray-900 dark:text-gray-100">
                Gas D
              </th>
              <th className="px-4 py-3 text-center font-semibold text-gray-900 dark:text-gray-100">
                Alarm
              </th>
              <th className="px-4 py-3 text-left font-semibold text-gray-900 dark:text-gray-100">
                Raw JSON
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {paginatedData.length === 0 ? (
              <tr>
                <td colSpan={8} className="px-4 py-8 text-center text-gray-500 dark:text-gray-400">
                  {data.length === 0 ? 'No data available' : 'No results found'}
                </td>
              </tr>
            ) : (
              paginatedData.map((item, index) => (
                <tr
                  key={`${item.timestamp.getTime()}-${index}`}
                  className="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
                >
                  <td className="px-4 py-3 text-gray-900 dark:text-gray-100 whitespace-nowrap">
                    {format(item.timestamp, 'yyyy-MM-dd HH:mm:ss')}
                  </td>
                  <td className="px-4 py-3 text-gray-700 dark:text-gray-300 font-mono text-xs">
                    {item.id}
                  </td>
                  <td className="px-4 py-3 text-right text-gray-900 dark:text-gray-100">
                    {item.t !== null ? item.t.toFixed(2) : 'N/A'}
                  </td>
                  <td className="px-4 py-3 text-right text-gray-900 dark:text-gray-100">
                    {item.h !== null ? item.h.toFixed(2) : 'N/A'}
                  </td>
                  <td className="px-4 py-3 text-right text-gray-900 dark:text-gray-100">
                    {item.gasA !== null ? item.gasA : 'N/A'}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={`inline-block px-2 py-1 rounded text-xs font-medium ${item.gasD === 1
                        ? 'bg-green-500/20 text-green-700 dark:text-green-300'
                        : 'bg-gray-500/20 text-gray-700 dark:text-gray-300'
                        }`}
                    >
                      {item.gasD === 1 ? 'ON' : 'OFF'}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={`inline-block px-2 py-1 rounded text-xs font-medium ${item.alarm
                        ? 'bg-red-500/20 text-red-700 dark:text-red-300'
                        : 'bg-gray-500/20 text-gray-700 dark:text-gray-300'
                        }`}
                    >
                      {item.alarm ? 'ON' : 'OFF'}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-gray-700 dark:text-gray-300 font-mono text-xs max-w-xs truncate">
                    {item.rawJson || 'N/A'}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-6 pt-4 border-t border-gray-200 dark:border-gray-700">
          <div className="text-sm text-gray-600 dark:text-gray-400">
            Showing {((currentPage - 1) * ITEMS_PER_PAGE) + 1} to{' '}
            {Math.min(currentPage * ITEMS_PER_PAGE, filteredData.length)} of{' '}
            {filteredData.length} results
          </div>

          <div className="flex gap-2">
            <button
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              className="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-medium transition-colors hover:bg-gray-200 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              aria-label="Previous page"
            >
              Previous
            </button>

            <div className="flex items-center gap-2 px-4 py-2 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                Page {currentPage} of {totalPages}
              </span>
            </div>

            <button
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              className="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg font-medium transition-colors hover:bg-gray-200 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              aria-label="Next page"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
