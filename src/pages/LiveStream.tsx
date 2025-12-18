import { useState } from 'react';
import { Camera, Video } from 'lucide-react';
import ESP32CamStream from '../components/ESP32CamStreamNew';
import VideoGallery from '../components/VideoGallery';

export default function LiveStream() {
  const [showInfo, setShowInfo] = useState(false);
  const [viewMode, setViewMode] = useState<'single' | 'grid'>('single');
  const [activeTab, setActiveTab] = useState<'stream' | 'recordings'>('stream');

  // Grid view component
  const GridView = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <h3 className="text-lg font-semibold mb-2">Camera 1</h3>
        <ESP32CamStream />
      </div>
      <div>
        <h3 className="text-lg font-semibold mb-2">Camera 2</h3>
        <ESP32CamStream />
      </div>
      <div>
        <h3 className="text-lg font-semibold mb-2">Camera 3</h3>
        <ESP32CamStream />
      </div>
      <div>
        <h3 className="text-lg font-semibold mb-2">Camera 4</h3>
        <ESP32CamStream />
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            ESP32-CAM Live Stream
          </h1>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            Monitor real-time video feed from ESP32-CAM modules
          </p>
        </div>
      </div>

      {/* Tab Navigation */}
      <div className="flex gap-2 border-b border-gray-200 dark:border-gray-700">
        <button
          onClick={() => setActiveTab('stream')}
          className={`flex items-center gap-2 px-4 py-2 border-b-2 transition-colors ${
            activeTab === 'stream'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
          }`}
        >
          <Camera className="w-5 h-5" />
          <span className="font-medium">Live Stream</span>
        </button>
        <button
          onClick={() => setActiveTab('recordings')}
          className={`flex items-center gap-2 px-4 py-2 border-b-2 transition-colors ${
            activeTab === 'recordings'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
          }`}
        >
          <Video className="w-5 h-5" />
          <span className="font-medium">Recordings</span>
        </button>
      </div>

      {/* Controls - Only show on stream tab */}
      {activeTab === 'stream' && (
        <div className="flex gap-3 flex-wrap">
          <button
            onClick={() => setShowInfo(!showInfo)}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              showInfo
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            {showInfo ? 'Hide Info' : 'Show Info'}
          </button>
          <button
            onClick={() => setViewMode('single')}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              viewMode === 'single'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            Single View
          </button>
          <button
            onClick={() => setViewMode('grid')}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              viewMode === 'grid'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            Grid View
          </button>
        </div>
      )}

      {/* Info Panel - Only show on stream tab */}
      {activeTab === 'stream' && showInfo && (
        <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
          <h3 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
            📡 ESP32-CAM Information
          </h3>
          <ul className="space-y-1 text-sm text-blue-800 dark:text-blue-200">
            <li>• Stream URL: http://ESP32_IP:81/stream</li>
            <li>• Default resolution: 1024x768 (SXGA)</li>
            <li>• Format: MJPEG over HTTP</li>
            <li>• Frame rate: ~15-20 FPS (depends on WiFi)</li>
            <li>• Latency: ~200-500ms</li>
          </ul>
        </div>
      )}

      {/* Content - Conditional based on active tab */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        {activeTab === 'stream' ? (
          viewMode === 'single' ? (
            <ESP32CamStream />
          ) : (
            <GridView />
          )
        ) : (
          <VideoGallery />
        )}
      </div>

      {/* Stream Tips - Only show on stream tab */}
      {activeTab === 'stream' && (
        <div className="grid md:grid-cols-3 gap-4">
          <div className="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
            <h4 className="font-semibold text-gray-900 dark:text-white mb-2">
              💡 Connection Tips
            </h4>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Ensure ESP32-CAM is powered with 5V 2A adapter. USB power may be insufficient for WiFi streaming.
            </p>
          </div>
          <div className="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
            <h4 className="font-semibold text-gray-900 dark:text-white mb-2">
              🔧 Troubleshooting
            </h4>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              If stream freezes, check WiFi signal strength. ESP32-CAM works best within 10m of router.
            </p>
          </div>
          <div className="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
            <h4 className="font-semibold text-gray-900 dark:text-white mb-2">
              ⚡ Performance
            </h4>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Lower resolution (SVGA/VGA) reduces latency. Adjust in ESP32-CAM settings if needed.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
