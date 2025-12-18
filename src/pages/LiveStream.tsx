import { useState, useEffect, useRef, useCallback } from 'react';
import { Camera, Play, Square, RefreshCw, Settings, Wifi, WifiOff, Maximize2, Minimize2, Volume2, VolumeX, Image, Video, AlertTriangle, CheckCircle, Clock, Signal } from 'lucide-react';

// Default ESP32-CAM URL via Cloudflare Tunnel
const DEFAULT_STREAM_URL = 'https://esp32cam.izinmok.my.id';

type StreamMode = 'mjpeg' | 'snapshot';

interface CameraStatus {
  online: boolean;
  lastCheck: Date | null;
  latency: number | null;
  fps: number;
}

export default function LiveStream() {
  // Stream state
  const [streamUrl, setStreamUrl] = useState(DEFAULT_STREAM_URL);
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamMode, setStreamMode] = useState<StreamMode>('mjpeg');
  const [streamError, setStreamError] = useState('');
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  
  // Camera status
  const [cameraStatus, setCameraStatus] = useState<CameraStatus>({
    online: false,
    lastCheck: null,
    latency: null,
    fps: 0
  });
  
  // Snapshot mode state
  const [frameCount, setFrameCount] = useState(0);
  const [refreshInterval, setRefreshInterval] = useState(500);
  
  // Settings
  const [showSettings, setShowSettings] = useState(false);
  const [customUrl, setCustomUrl] = useState('');
  
  // Refs
  const imgRef = useRef<HTMLImageElement>(null);
  const mjpegRef = useRef<HTMLImageElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const fpsCounterRef = useRef<number>(0);
  const lastFpsUpdateRef = useRef<number>(Date.now());

  // Check camera status
  const checkCameraStatus = useCallback(async () => {
    const startTime = Date.now();
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000);
      
      const response = await fetch(`${streamUrl}/status`, {
        signal: controller.signal,
        mode: 'cors'
      });
      clearTimeout(timeoutId);
      
      if (response.ok) {
        const latency = Date.now() - startTime;
        setCameraStatus(prev => ({
          ...prev,
          online: true,
          lastCheck: new Date(),
          latency
        }));
        setStreamError('');
        return true;
      }
    } catch (err) {
      console.log('Camera status check failed:', err);
    }
    
    setCameraStatus(prev => ({
      ...prev,
      online: false,
      lastCheck: new Date()
    }));
    return false;
  }, [streamUrl]);

  // Start MJPEG stream
  const startMjpegStream = useCallback(() => {
    if (mjpegRef.current) {
      mjpegRef.current.src = `${streamUrl}/stream?${Date.now()}`;
      setIsStreaming(true);
      setStreamError('');
      
      // FPS counter
      fpsCounterRef.current = 0;
      lastFpsUpdateRef.current = Date.now();
    }
  }, [streamUrl]);

  // Start snapshot stream (polling)
  const startSnapshotStream = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
    
    const loadFrame = () => {
      if (!imgRef.current) return;
      
      const img = new window.Image();
      img.crossOrigin = 'anonymous';
      
      img.onload = () => {
        if (imgRef.current) {
          imgRef.current.src = img.src;
          setFrameCount(prev => prev + 1);
          fpsCounterRef.current++;
          
          // Update FPS every second
          const now = Date.now();
          if (now - lastFpsUpdateRef.current >= 1000) {
            setCameraStatus(prev => ({
              ...prev,
              fps: fpsCounterRef.current,
              online: true
            }));
            fpsCounterRef.current = 0;
            lastFpsUpdateRef.current = now;
          }
        }
      };
      
      img.onerror = () => {
        setCameraStatus(prev => ({ ...prev, online: false }));
        setStreamError('Failed to load frame');
      };
      
      img.src = `${streamUrl}/capture?t=${Date.now()}`;
    };
    
    loadFrame();
    intervalRef.current = setInterval(loadFrame, refreshInterval);
    setIsStreaming(true);
    setStreamError('');
  }, [streamUrl, refreshInterval]);

  // Start stream based on mode
  const startStream = useCallback(() => {
    if (streamMode === 'mjpeg') {
      startMjpegStream();
    } else {
      startSnapshotStream();
    }
  }, [streamMode, startMjpegStream, startSnapshotStream]);

  // Stop stream
  const stopStream = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
    if (mjpegRef.current) {
      mjpegRef.current.src = '';
    }
    setIsStreaming(false);
  }, []);

  // Toggle fullscreen
  const toggleFullscreen = () => {
    if (!containerRef.current) return;
    
    if (!document.fullscreenElement) {
      containerRef.current.requestFullscreen();
      setIsFullscreen(true);
    } else {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  // Handle MJPEG stream events
  const handleMjpegLoad = () => {
    setCameraStatus(prev => ({ ...prev, online: true }));
    setStreamError('');
    
    // FPS counter for MJPEG
    fpsCounterRef.current++;
    const now = Date.now();
    if (now - lastFpsUpdateRef.current >= 1000) {
      setCameraStatus(prev => ({
        ...prev,
        fps: fpsCounterRef.current
      }));
      fpsCounterRef.current = 0;
      lastFpsUpdateRef.current = now;
    }
  };

  const handleMjpegError = () => {
    setCameraStatus(prev => ({ ...prev, online: false }));
    setStreamError('ESP32-CAM not responding. Check camera connection.');
    setIsStreaming(false);
  };

  // Save custom URL
  const saveSettings = () => {
    if (customUrl) {
      setStreamUrl(customUrl.replace(/\/$/, '')); // Remove trailing slash
    }
    setShowSettings(false);
    stopStream();
  };

  // Reset to default
  const resetToDefault = () => {
    setStreamUrl(DEFAULT_STREAM_URL);
    setCustomUrl('');
    setShowSettings(false);
    stopStream();
  };

  // Initialize - check camera status on mount
  useEffect(() => {
    checkCameraStatus();
    const statusInterval = setInterval(checkCameraStatus, 30000);
    
    return () => {
      clearInterval(statusInterval);
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [checkCameraStatus]);

  // Handle fullscreen change
  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  return (
    <div className="space-y-6 p-4 md:p-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-white flex items-center gap-3">
            <Camera className="w-7 h-7 md:w-8 md:h-8 text-blue-500" />
            Live Stream
          </h1>
          <p className="text-sm md:text-base text-gray-600 dark:text-gray-400 mt-1">
            ESP32-CAM via Cloudflare Tunnel
          </p>
        </div>
        
        <button
          onClick={() => setShowSettings(!showSettings)}
          className="p-2.5 rounded-lg bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
          title="Settings"
        >
          <Settings className="w-5 h-5" />
        </button>
      </div>

      {/* Settings Panel */}
      {showSettings && (
        <div className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-lg border border-gray-200 dark:border-gray-700">
          <h3 className="font-semibold mb-4 text-gray-900 dark:text-white flex items-center gap-2">
            <Settings className="w-5 h-5" />
            Stream Settings
          </h3>
          
          <div className="space-y-5">
            {/* URL Setting */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-700 dark:text-gray-300">
                ESP32-CAM URL (Cloudflare Tunnel)
              </label>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={customUrl || streamUrl}
                  onChange={(e) => setCustomUrl(e.target.value)}
                  placeholder="https://esp32cam.izinmok.my.id"
                  className="flex-1 px-3 py-2.5 border rounded-lg dark:bg-gray-700 dark:border-gray-600 text-gray-900 dark:text-white font-mono text-sm"
                />
                <button
                  onClick={saveSettings}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
                >
                  Save
                </button>
              </div>
              <p className="text-xs text-gray-500 mt-2">
                Current: <code className="bg-gray-100 dark:bg-gray-700 px-1 rounded">{streamUrl}</code>
              </p>
            </div>
            
            {/* Stream Mode */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-700 dark:text-gray-300">
                Stream Mode
              </label>
              <div className="flex gap-3">
                <button
                  onClick={() => { setStreamMode('mjpeg'); stopStream(); }}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg border-2 transition-all ${
                    streamMode === 'mjpeg'
                      ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300'
                      : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                  }`}
                >
                  <Video className="w-5 h-5" />
                  <div className="text-left">
                    <p className="font-medium">MJPEG Stream</p>
                    <p className="text-xs opacity-70">Continuous video</p>
                  </div>
                </button>
                <button
                  onClick={() => { setStreamMode('snapshot'); stopStream(); }}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg border-2 transition-all ${
                    streamMode === 'snapshot'
                      ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300'
                      : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                  }`}
                >
                  <Image className="w-5 h-5" />
                  <div className="text-left">
                    <p className="font-medium">Snapshot Mode</p>
                    <p className="text-xs opacity-70">Polling images</p>
                  </div>
                </button>
              </div>
            </div>
            
            {/* Refresh Interval (Snapshot mode only) */}
            {streamMode === 'snapshot' && (
              <div>
                <label className="block text-sm font-medium mb-2 text-gray-700 dark:text-gray-300">
                  Refresh Interval: {refreshInterval}ms (~{Math.round(1000/refreshInterval)} FPS)
                </label>
                <input
                  type="range"
                  min="200"
                  max="2000"
                  step="100"
                  value={refreshInterval}
                  onChange={(e) => setRefreshInterval(Number(e.target.value))}
                  className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer"
                />
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>Fast (200ms)</span>
                  <span>Slow (2000ms)</span>
                </div>
              </div>
            )}
            
            {/* Reset Button */}
            <button
              onClick={resetToDefault}
              className="text-sm text-red-600 hover:text-red-700 dark:text-red-400 hover:underline"
            >
              Reset to Default URL
            </button>
          </div>
        </div>
      )}

      {/* Main Content */}
      <div className="grid grid-cols-1 xl:grid-cols-4 gap-6">
        {/* Video Stream - Takes most space */}
        <div className="xl:col-span-3">
          <div 
            ref={containerRef}
            className="bg-gray-900 rounded-xl shadow-lg overflow-hidden"
          >
            {/* Stream Header */}
            <div className="p-3 md:p-4 border-b border-gray-700 flex items-center justify-between bg-gray-800">
              <div className="flex items-center gap-3">
                {cameraStatus.online ? (
                  <div className="flex items-center gap-2">
                    <span className="relative flex h-3 w-3">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                    </span>
                    <span className="font-semibold text-red-500">LIVE</span>
                  </div>
                ) : (
                  <div className="flex items-center gap-2 text-gray-400">
                    <WifiOff className="w-4 h-4" />
                    <span className="font-medium">OFFLINE</span>
                  </div>
                )}
                
                {isStreaming && cameraStatus.fps > 0 && (
                  <span className="text-xs text-gray-400 bg-gray-700 px-2 py-1 rounded">
                    {cameraStatus.fps} FPS
                  </span>
                )}
              </div>
              
              <div className="flex items-center gap-2">
                {/* Stream Controls */}
                {!isStreaming ? (
                  <button
                    onClick={startStream}
                    className="flex items-center gap-1.5 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-medium transition-colors"
                  >
                    <Play className="w-4 h-4" />
                    Start
                  </button>
                ) : (
                  <button
                    onClick={stopStream}
                    className="flex items-center gap-1.5 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm font-medium transition-colors"
                  >
                    <Square className="w-4 h-4" />
                    Stop
                  </button>
                )}
                
                <button
                  onClick={() => { stopStream(); setTimeout(startStream, 300); }}
                  className="p-2 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition-colors"
                  title="Refresh"
                >
                  <RefreshCw className="w-4 h-4" />
                </button>
                
                <button
                  onClick={() => setIsMuted(!isMuted)}
                  className="p-2 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition-colors"
                  title={isMuted ? 'Unmute' : 'Mute'}
                >
                  {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
                </button>
                
                <button
                  onClick={toggleFullscreen}
                  className="p-2 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition-colors"
                  title="Fullscreen"
                >
                  {isFullscreen ? <Minimize2 className="w-4 h-4" /> : <Maximize2 className="w-4 h-4" />}
                </button>
              </div>
            </div>
            
            {/* Video Display */}
            <div className="relative aspect-video bg-black flex items-center justify-center min-h-[300px] md:min-h-[400px]">
              {isStreaming ? (
                <>
                  {streamMode === 'mjpeg' ? (
                    <img
                      ref={mjpegRef}
                      alt="ESP32-CAM MJPEG Stream"
                      className="w-full h-full object-contain"
                      onLoad={handleMjpegLoad}
                      onError={handleMjpegError}
                    />
                  ) : (
                    <img
                      ref={imgRef}
                      alt="ESP32-CAM Snapshot"
                      className="w-full h-full object-contain"
                    />
                  )}
                  
                  {/* Overlay info */}
                  <div className="absolute top-3 left-3 flex items-center gap-2">
                    <span className="bg-black/60 text-white text-xs px-2 py-1 rounded backdrop-blur-sm">
                      {streamMode === 'mjpeg' ? '📹 MJPEG' : '📸 Snapshot'}
                    </span>
                  </div>
                  
                  {/* Frame counter for snapshot mode */}
                  {streamMode === 'snapshot' && (
                    <div className="absolute bottom-3 left-3">
                      <span className="bg-black/60 text-white text-xs px-2 py-1 rounded backdrop-blur-sm">
                        Frame: {frameCount}
                      </span>
                    </div>
                  )}
                </>
              ) : (
                <div className="text-center text-gray-400 p-8">
                  {streamError ? (
                    <div className="flex flex-col items-center">
                      <AlertTriangle className="w-16 h-16 text-yellow-500 mb-4" />
                      <p className="text-lg mb-2">{streamError}</p>
                      <button
                        onClick={startStream}
                        className="mt-4 px-6 py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium"
                      >
                        Retry
                      </button>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center">
                      <Camera className="w-20 h-20 mb-4 opacity-30" />
                      <p className="text-xl mb-2">ESP32-CAM Stream</p>
                      <p className="text-sm text-gray-500 mb-4">
                        Click Start to begin streaming
                      </p>
                      <button
                        onClick={startStream}
                        className="px-6 py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium flex items-center gap-2"
                      >
                        <Play className="w-5 h-5" />
                        Start Stream
                      </button>
                    </div>
                  )}
                </div>
              )}
            </div>
            
            {/* Stream URL Info */}
            <div className="p-3 bg-gray-800 border-t border-gray-700">
              <div className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2 text-gray-400">
                  <Signal className="w-4 h-4" />
                  <span className="font-mono text-xs truncate max-w-[300px]">
                    {streamUrl}/{streamMode === 'mjpeg' ? 'stream' : 'capture'}
                  </span>
                </div>
                {cameraStatus.latency && (
                  <span className="text-gray-500 text-xs">
                    Latency: {cameraStatus.latency}ms
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Side Panel */}
        <div className="xl:col-span-1 space-y-4">
          {/* Camera Status Card */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
            <div className="p-4 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-blue-500 to-cyan-500">
              <h3 className="font-semibold flex items-center gap-2 text-white">
                <Wifi className="w-5 h-5" />
                Camera Status
              </h3>
            </div>
            
            <div className="p-4 space-y-3">
              {/* Online Status */}
              <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <span className="text-gray-600 dark:text-gray-300 text-sm">Status</span>
                <div className={`flex items-center gap-2 font-medium ${cameraStatus.online ? 'text-green-600' : 'text-red-500'}`}>
                  {cameraStatus.online ? (
                    <>
                      <CheckCircle className="w-4 h-4" />
                      Online
                    </>
                  ) : (
                    <>
                      <WifiOff className="w-4 h-4" />
                      Offline
                    </>
                  )}
                </div>
              </div>
              
              {/* Latency */}
              <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <span className="text-gray-600 dark:text-gray-300 text-sm">Latency</span>
                <span className="font-mono text-sm">
                  {cameraStatus.latency ? `${cameraStatus.latency}ms` : '---'}
                </span>
              </div>
              
              {/* FPS */}
              <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <span className="text-gray-600 dark:text-gray-300 text-sm">FPS</span>
                <span className="font-mono text-sm">
                  {cameraStatus.fps > 0 ? cameraStatus.fps : '---'}
                </span>
              </div>
              
              {/* Last Check */}
              <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <span className="text-gray-600 dark:text-gray-300 text-sm flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  Last Check
                </span>
                <span className="text-xs text-gray-500">
                  {cameraStatus.lastCheck?.toLocaleTimeString() || 'Never'}
                </span>
              </div>
              
              {/* Refresh Button */}
              <button
                onClick={checkCameraStatus}
                className="w-full py-2.5 text-sm bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors font-medium flex items-center justify-center gap-2"
              >
                <RefreshCw className="w-4 h-4" />
                Check Status
              </button>
            </div>
          </div>
          
          {/* Quick Links */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-4">
            <h4 className="font-semibold mb-3 text-gray-900 dark:text-white text-sm">Quick Links</h4>
            <div className="space-y-2">
              <a
                href={`${streamUrl}/stream`}
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full px-3 py-2 text-sm bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-center"
              >
                📹 Open MJPEG Stream
              </a>
              <a
                href={`${streamUrl}/capture`}
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full px-3 py-2 text-sm bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-center"
              >
                📸 Capture Snapshot
              </a>
              <a
                href={`${streamUrl}/status`}
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full px-3 py-2 text-sm bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-center"
              >
                📊 Camera Status JSON
              </a>
            </div>
          </div>
          
          {/* Info Card */}
          <div className="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl p-4 border border-blue-200 dark:border-blue-800">
            <h4 className="font-semibold text-blue-700 dark:text-blue-300 mb-2 text-sm">💡 Tips</h4>
            <ul className="text-xs text-blue-600 dark:text-blue-400 space-y-1.5">
              <li>• <strong>MJPEG</strong> - Best for real-time monitoring</li>
              <li>• <strong>Snapshot</strong> - Lower bandwidth, adjustable FPS</li>
              <li>• Stream requires Cloudflare tunnel active</li>
              <li>• Check firewall if connection fails</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
