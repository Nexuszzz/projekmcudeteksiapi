import { useState } from 'react'
import ESP32CamStream from '../components/ESP32CamStream'
import VideoGallery from '../components/VideoGallery'
import { Camera, Grid3x3, Maximize2, Settings, Info, Video } from 'lucide-react'

export default function LiveStream() {
  const [viewMode, setViewMode] = useState<'single' | 'grid'>('single')
  const [showInfo, setShowInfo] = useState(true)
  const [activeTab, setActiveTab] = useState<'stream' | 'recordings'>('stream')

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 py-8">
      <div className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Header Section */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-gradient-to-br from-red-500 to-orange-600 rounded-xl shadow-lg">
                <Camera className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                  ESP32-CAM Live Stream & Recordings
                </h1>
                <p className="text-gray-600 dark:text-gray-400 mt-1">
                  Real-time Fire Detection with AI-Powered Computer Vision + Video Recording
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => setActiveTab('stream')}
                className={`px-4 py-2 rounded-lg font-medium transition-all ${
                  activeTab === 'stream'
                    ? 'bg-blue-500 text-white shadow-lg'
                    : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                }`}
              >
                <Camera className="w-5 h-5 inline mr-2" />
                Live Stream
              </button>

              <button
                onClick={() => setActiveTab('recordings')}
                className={`px-4 py-2 rounded-lg font-medium transition-all ${
                  activeTab === 'recordings'
                    ? 'bg-purple-500 text-white shadow-lg'
                    : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                }`}
              >
                <Video className="w-5 h-5 inline mr-2" />
                Recordings
              </button>

              {activeTab === 'stream' && (
                <>
                  <button
                    onClick={() => setShowInfo(!showInfo)}
                    className={`p-2 rounded-lg transition-all ${
                      showInfo 
                        ? 'bg-blue-500 text-white shadow-lg' 
                        : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                    }`}
                    title="Toggle Info Panel"
                  >
                    <Info className="w-5 h-5" />
                  </button>

                  <button
                    onClick={() => setViewMode('single')}
                    className={`p-2 rounded-lg transition-all ${
                      viewMode === 'single'
                        ? 'bg-blue-500 text-white shadow-lg'
                        : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                    }`}
                    title="Single View"
                  >
                    <Maximize2 className="w-5 h-5" />
                  </button>

                  <button
                    onClick={() => setViewMode('grid')}
                    className={`p-2 rounded-lg transition-all ${
                      viewMode === 'grid'
                        ? 'bg-blue-500 text-white shadow-lg'
                        : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                    }`}
                    title="Grid View"
                  >
                    <Grid3x3 className="w-5 h-5" />
                  </button>
                </>
              )}
            </div>
          </div>

          {/* Info Panel */}
          {showInfo && activeTab === 'stream' && (
            <div className="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6 shadow-sm">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="flex items-start gap-3">
                  <div className="p-2 bg-blue-500 rounded-lg">
                    <Camera className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">
                      Live Streaming
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      Real-time MJPEG stream dari ESP32-CAM dengan latency rendah (&lt;300ms)
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="p-2 bg-red-500 rounded-lg">
                    <Settings className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">
                      AI Fire Detection
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      YOLOv10 model untuk deteksi api real-time dengan accuracy 85-95%
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="p-2 bg-purple-500 rounded-lg">
                    <Video className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">
                      Video Recording
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      Record stream ke file MP4, simpan di laptop, upload ke web otomatis
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Main Content */}
        {activeTab === 'stream' ? (
          viewMode === 'single' ? (
            <div className="mb-8">
              <ESP32CamStream />
            </div>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
              <ESP32CamStream />
              <ESP32CamStream />
              <ESP32CamStream />
              <ESP32CamStream />
            </div>
          )
        ) : (
          <VideoGallery />
        )}
      </div>
    </main>
  )
}
