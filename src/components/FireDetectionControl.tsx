import { useState, useEffect } from 'react';
import { Flame, Play, Square, RefreshCw, Settings, AlertTriangle } from 'lucide-react';

const API_BASE = import.meta.env.VITE_API_URL || 'https://api.latom.flx.web.id';

interface ServiceStatus {
  running: boolean;
  lastDetection?: string;
  confidence?: number;
  cfUrl?: string;
}

export default function FireDetectionControl() {
  const [status, setStatus] = useState<ServiceStatus>({ running: false });
  const [loading, setLoading] = useState(false);
  const [cfUrl, setCfUrl] = useState('');
  const [showSettings, setShowSettings] = useState(false);
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    fetchStatus();
    fetchCfUrl();
    const interval = setInterval(fetchStatus, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchStatus = async () => {
    try {
      const res = await fetch(`${API_BASE}/api/fire-detect/status`);
      const data = await res.json();
      setStatus(data);
    } catch (e) {
      console.error('Failed to fetch status:', e);
    }
  };

  const fetchCfUrl = async () => {
    try {
      const res = await fetch(`${API_BASE}/api/cf-url`);
      const data = await res.json();
      if (data.url) setCfUrl(data.url);
    } catch (e) {
      console.error('Failed to fetch CF URL:', e);
    }
  };

  const saveCfUrl = async () => {
    try {
      await fetch(`${API_BASE}/api/cf-url`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: cfUrl })
      });
      setShowSettings(false);
    } catch (e) {
      console.error('Failed to save CF URL:', e);
    }
  };

  const startDetection = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/api/fire-detect/start`, { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        setStatus(prev => ({ ...prev, running: true }));
        addLog('🟢 Fire detection started');
      } else {
        addLog(`❌ Failed: ${data.error}`);
      }
    } catch (e) {
      addLog('❌ Failed to start detection');
    }
    setLoading(false);
  };

  const stopDetection = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/api/fire-detect/stop`, { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        setStatus(prev => ({ ...prev, running: false }));
        addLog('🔴 Fire detection stopped');
      }
    } catch (e) {
      addLog('❌ Failed to stop detection');
    }
    setLoading(false);
  };

  const testDetection = async () => {
    setLoading(true);
    addLog('🔍 Running test detection...');
    try {
      const res = await fetch(`${API_BASE}/api/fire-detect/test`, { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        addLog(`✅ Test: ${data.detected ? `🔥 Fire detected (${(data.confidence * 100).toFixed(1)}%)` : '✅ No fire detected'}`);
      } else {
        addLog(`❌ Test failed: ${data.error}`);
      }
    } catch (e) {
      addLog('❌ Test failed');
    }
    setLoading(false);
  };

  const addLog = (msg: string) => {
    const time = new Date().toLocaleTimeString();
    setLogs(prev => [`[${time}] ${msg}`, ...prev.slice(0, 9)]);
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
      <div className="p-6">
        {/* Header */}
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Flame className="w-5 h-5 text-orange-500" />
            VPS Fire Detection
          </h3>
          <div className="flex items-center gap-2">
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${
              status.running 
                ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300' 
                : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300'
            }`}>
              {status.running ? '● Running' : '○ Stopped'}
            </span>
            <button
              onClick={() => setShowSettings(!showSettings)}
              className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              <Settings className="w-5 h-5 text-gray-500" />
            </button>
          </div>
        </div>

        {/* Settings Panel */}
        {showSettings && (
          <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <h4 className="font-medium mb-2 text-gray-900 dark:text-white">Cloudflare Tunnel URL</h4>
            <div className="flex gap-2">
              <input
                type="text"
                value={cfUrl}
                onChange={(e) => setCfUrl(e.target.value)}
                placeholder="https://xxx.trycloudflare.com"
                className="flex-1 px-3 py-2 border rounded-lg dark:bg-gray-600 dark:border-gray-500 dark:text-white"
              />
              <button
                onClick={saveCfUrl}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save
              </button>
            </div>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
              Run on laptop: <code className="bg-gray-200 dark:bg-gray-600 px-1 rounded">cloudflared tunnel --url http://ESP32_IP:80</code>
            </p>
          </div>
        )}

        {/* Control Buttons */}
        <div className="flex gap-3 mb-4">
          {!status.running ? (
            <button
              onClick={startDetection}
              disabled={loading}
              className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-green-600 hover:bg-green-700 disabled:bg-green-400 text-white rounded-lg font-medium transition-colors"
            >
              <Play className="w-5 h-5" />
              Start Detection
            </button>
          ) : (
            <button
              onClick={stopDetection}
              disabled={loading}
              className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-red-600 hover:bg-red-700 disabled:bg-red-400 text-white rounded-lg font-medium transition-colors"
            >
              <Square className="w-5 h-5" />
              Stop Detection
            </button>
          )}
          <button
            onClick={testDetection}
            disabled={loading}
            className="flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white rounded-lg font-medium transition-colors"
          >
            <RefreshCw className={`w-5 h-5 ${loading ? 'animate-spin' : ''}`} />
            Test
          </button>
        </div>

        {/* Status Info */}
        {status.running && status.lastDetection && (
          <div className="mb-4 p-3 bg-orange-50 dark:bg-orange-900/30 border border-orange-200 dark:border-orange-800 rounded-lg">
            <div className="flex items-center gap-2 text-orange-700 dark:text-orange-300">
              <AlertTriangle className="w-4 h-4" />
              <span className="font-medium">Last Detection</span>
            </div>
            <p className="text-sm text-orange-600 dark:text-orange-400 mt-1">
              {status.lastDetection} - Confidence: {((status.confidence || 0) * 100).toFixed(1)}%
            </p>
          </div>
        )}

        {/* Cloudflare URL Display */}
        {cfUrl && (
          <div className="mb-4 p-3 bg-purple-50 dark:bg-purple-900/30 border border-purple-200 dark:border-purple-800 rounded-lg">
            <div className="flex items-center gap-2 text-purple-700 dark:text-purple-300">
              <span className="text-sm font-medium">📡 Cloudflare Tunnel</span>
            </div>
            <p className="text-xs text-purple-600 dark:text-purple-400 mt-1 break-all">
              {cfUrl}
            </p>
          </div>
        )}

        {/* Logs */}
        {logs.length > 0 && (
          <div className="mt-4">
            <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Activity Log</h4>
            <div className="bg-gray-900 rounded-lg p-3 max-h-40 overflow-y-auto">
              {logs.map((log, i) => (
                <div key={i} className="text-xs text-gray-300 font-mono">{log}</div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
