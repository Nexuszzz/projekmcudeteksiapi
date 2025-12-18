// ESP32CamStream with Cloudflare Tunnel support
import { useState, useRef, useEffect } from 'react';
import { RefreshCw, Wifi, WifiOff, Settings, Camera } from 'lucide-react';

interface CameraInfo {
  id: string;
  ip: string;
  local_ip: string;
  stream_url: string;
  local_stream_url: string;
  ssid: string;
  rssi: number;
  uptime: number;
  camera_ready: boolean;
}

interface Props {
  cloudflareUrl?: string;
}

const API_BASE = import.meta.env.VITE_API_URL || 'https://api.latom.flx.web.id';

export default function ESP32CamStream({ cloudflareUrl: propCfUrl }: Props) {
  const [streamUrl, setStreamUrl] = useState('');
  const [inputUrl, setInputUrl] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamError, setStreamError] = useState<string | null>(null);
  const [cameraInfo, setCameraInfo] = useState<CameraInfo | null>(null);
  const [cloudflareUrl, setCloudflareUrl] = useState(propCfUrl || '');
  const [showSettings, setShowSettings] = useState(false);
  const [captureMode, setCaptureMode] = useState(false); // Use capture mode for HTTPS
  const [autoRefresh, setAutoRefresh] = useState(true);
  const streamRef = useRef<HTMLImageElement>(null);
  const refreshTimer = useRef<NodeJS.Timeout | null>(null);

  // Fetch camera info from API
  useEffect(() => {
    fetchCameraInfo();
    fetchCloudflareUrl();
    const interval = setInterval(fetchCameraInfo, 30000);
    return () => clearInterval(interval);
  }, []);

  const fetchCameraInfo = async () => {
    try {
      const res = await fetch(`${API_BASE}/api/stream/cameras`);
      const data = await res.json();
      if (data.cameras && data.cameras.length > 0) {
        setCameraInfo(data.cameras[0]);
      }
    } catch (e) {
      console.error('Failed to fetch camera info:', e);
    }
  };

  const fetchCloudflareUrl = async () => {
    try {
      const res = await fetch(`${API_BASE}/api/cf-url`);
      const data = await res.json();
      if (data.url) {
        setCloudflareUrl(data.url);
      }
    } catch (e) {
      console.error('Failed to fetch Cloudflare URL:', e);
    }
  };

  const saveCloudflareUrl = async () => {
    try {
      await fetch(`${API_BASE}/api/cf-url`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: cloudflareUrl })
      });
      setShowSettings(false);
    } catch (e) {
      console.error('Failed to save Cloudflare URL:', e);
    }
  };

  const startStream = () => {
    let url = inputUrl.trim() || cloudflareUrl;
    
    if (!url) {
      setStreamError('Please enter stream URL or configure Cloudflare tunnel');
      return;
    }

    // Auto-format IP to stream URL
    const ipPattern = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (ipPattern.test(url)) {
      url = `http://${url}:81/stream`;
    }

    // For HTTPS (Cloudflare), use capture mode with refresh
    const isHttps = url.startsWith('https://');
    if (isHttps) {
      setCaptureMode(true);
      setStreamUrl(url.replace(/\/$/, '') + '/capture');
      setIsStreaming(true);
      setStreamError(null);
      // Start auto-refresh
      if (autoRefresh) {
        startAutoRefresh(url.replace(/\/$/, '') + '/capture');
      }
    } else {
      setCaptureMode(false);
      setStreamUrl(url.includes('/stream') ? url : url + '/stream');
      setIsStreaming(true);
      setStreamError(null);
    }
  };

  const startAutoRefresh = (captureUrl: string) => {
    if (refreshTimer.current) clearInterval(refreshTimer.current);
    refreshTimer.current = setInterval(() => {
      if (streamRef.current && isStreaming) {
        streamRef.current.src = `${captureUrl}?t=${Date.now()}`;
      }
    }, 500); // Refresh every 500ms
  };

  const stopStream = () => {
    setIsStreaming(false);
    if (refreshTimer.current) {
      clearInterval(refreshTimer.current);
      refreshTimer.current = null;
    }
    if (streamRef.current) {
      streamRef.current.src = '';
    }
  };

  const handleError = () => {
    setStreamError('Failed to load stream. Check connection.');
  };

  const handleRefresh = () => {
    if (streamRef.current && streamUrl) {
      streamRef.current.src = `${streamUrl}?t=${Date.now()}`;
    }
  };

  // Use Cloudflare URL if available
  const useCloudflare = () => {
    if (cloudflareUrl) {
      setInputUrl(cloudflareUrl);
    }
  };

  // Use local URL from camera info
  const useLocalStream = () => {
    if (cameraInfo?.local_stream_url) {
      setInputUrl(cameraInfo.local_stream_url);
    }
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
      <div className="p-6">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Camera className="w-5 h-5" />
            ESP32-CAM Live Stream
          </h3>
          <button
            onClick={() => setShowSettings(!showSettings)}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <Settings className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Settings Panel */}
        {showSettings && (
          <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <h4 className="font-medium mb-2">Cloudflare Tunnel URL</h4>
            <div className="flex gap-2">
              <input
                type="text"
                value={cloudflareUrl}
                onChange={(e) => setCloudflareUrl(e.target.value)}
                placeholder="https://xxx.trycloudflare.com"
                className="flex-1 px-3 py-2 border rounded-lg dark:bg-gray-600 dark:border-gray-500"
              />
              <button
                onClick={saveCloudflareUrl}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Configure Cloudflare tunnel for remote access to ESP32-CAM
            </p>
          </div>
        )}

        {/* Camera Info */}
        {cameraInfo && (
          <div className="mb-4 p-3 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-lg">
            <div className="flex items-center gap-2 text-green-700 dark:text-green-300">
              <Wifi className="w-4 h-4" />
              <span className="font-medium">{cameraInfo.id}</span>
              <span className="text-sm">({cameraInfo.local_ip})</span>
              <span className="text-xs">RSSI: {cameraInfo.rssi}dBm</span>
            </div>
          </div>
        )}

        {/* URL Input */}
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Stream URL:
          </label>
          <div className="flex gap-2">
            <input
              type="text"
              value={inputUrl}
              onChange={(e) => setInputUrl(e.target.value)}
              placeholder="IP address or Cloudflare URL"
              className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
            <button
              onClick={isStreaming ? stopStream : startStream}
              className={`px-4 py-2 rounded-lg font-medium ${
                isStreaming
                  ? 'bg-red-600 hover:bg-red-700 text-white'
                  : 'bg-green-600 hover:bg-green-700 text-white'
              }`}
            >
              {isStreaming ? 'Stop' : 'Start'}
            </button>
          </div>
          
          {/* Quick buttons */}
          <div className="flex gap-2 mt-2">
            {cloudflareUrl && (
              <button
                onClick={useCloudflare}
                className="px-3 py-1 text-xs bg-purple-100 dark:bg-purple-900 text-purple-700 dark:text-purple-300 rounded-full hover:bg-purple-200"
              >
                📡 Use Cloudflare
              </button>
            )}
            {cameraInfo?.local_stream_url && (
              <button
                onClick={useLocalStream}
                className="px-3 py-1 text-xs bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 rounded-full hover:bg-blue-200"
              >
                🏠 Use Local
              </button>
            )}
          </div>
        </div>

        {/* Error Display */}
        {streamError && (
          <div className="mb-4 p-3 bg-red-100 dark:bg-red-900/30 border border-red-300 dark:border-red-700 rounded-lg flex items-center gap-2">
            <WifiOff className="w-4 h-4 text-red-500" />
            <p className="text-red-700 dark:text-red-300 text-sm">{streamError}</p>
          </div>
        )}

        {/* Stream Display */}
        <div className="relative bg-gray-900 rounded-lg overflow-hidden">
          {isStreaming ? (
            <>
              <img
                ref={streamRef}
                src={captureMode ? `${streamUrl}?t=${Date.now()}` : streamUrl}
                alt="ESP32-CAM Stream"
                onError={handleError}
                onLoad={() => setStreamError(null)}
                className="w-full h-auto max-h-[500px] object-contain"
              />
              {/* Refresh button for capture mode */}
              {captureMode && (
                <button
                  onClick={handleRefresh}
                  className="absolute top-2 right-2 p-2 bg-black/50 rounded-full hover:bg-black/70"
                >
                  <RefreshCw className="w-5 h-5 text-white" />
                </button>
              )}
              {/* Mode indicator */}
              <div className="absolute bottom-2 left-2 px-2 py-1 bg-black/50 rounded text-xs text-white">
                {captureMode ? '📸 Capture Mode (HTTPS)' : '🎬 Stream Mode'}
              </div>
            </>
          ) : (
            <div className="h-64 flex items-center justify-center text-gray-400">
              <div className="text-center">
                <div className="text-4xl mb-2">📹</div>
                <p>Enter URL and click Start to view stream</p>
                {cloudflareUrl && (
                  <p className="text-sm mt-2 text-green-400">
                    Cloudflare URL configured ✓
                  </p>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Auto-refresh toggle for capture mode */}
        {captureMode && isStreaming && (
          <div className="mt-4 flex items-center gap-2">
            <input
              type="checkbox"
              id="autoRefresh"
              checked={autoRefresh}
              onChange={(e) => {
                setAutoRefresh(e.target.checked);
                if (e.target.checked && isStreaming) {
                  startAutoRefresh(streamUrl);
                } else if (refreshTimer.current) {
                  clearInterval(refreshTimer.current);
                }
              }}
              className="rounded"
            />
            <label htmlFor="autoRefresh" className="text-sm text-gray-600 dark:text-gray-400">
              Auto-refresh (every 500ms)
            </label>
          </div>
        )}
      </div>
    </div>
  );
}
