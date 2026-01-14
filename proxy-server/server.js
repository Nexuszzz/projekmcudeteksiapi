import express from 'express'
import { WebSocketServer } from 'ws'
import mqtt from 'mqtt'
import cors from 'cors'
import { config } from 'dotenv'
import multer from 'multer'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Import video routes (ES module)
import videoRoutes from './routes/video.js'

// Import auth routes (ES module)
import authRoutes from './routes/auth.js'

// Load environment variables
config()

const PORT = process.env.PORT || 8080
const MQTT_HOST = process.env.MQTT_HOST || 'localhost'
const MQTT_PORT = process.env.MQTT_PORT || 1883
const MQTT_USERNAME = process.env.MQTT_USERNAME || ''
const MQTT_PASSWORD = process.env.MQTT_PASSWORD || ''
const TOPIC_EVENT = process.env.TOPIC_EVENT || 'lab/zaks/event'
const TOPIC_LOG = process.env.TOPIC_LOG || 'lab/zaks/log'
const TOPIC_STATUS = process.env.TOPIC_STATUS || 'lab/zaks/status'
const TOPIC_ALERT = process.env.TOPIC_ALERT || 'lab/zaks/alert'
const TOPIC_STREAM = process.env.TOPIC_STREAM || 'lab/zaks/stream'
const TOPIC_ESP32CAM_IP = process.env.TOPIC_ESP32CAM_IP || 'lab/zaks/esp32cam/ip'
const TOPIC_ALL = 'lab/zaks/#'

// ================================================================================
// GOWA (GO-WHATSAPP) AUTO NOTIFICATION SYSTEM
// ================================================================================
// GOWA1: Local/default server  |  GOWA2: Production server at flx.web.id
const GOWA_SERVER_URL = process.env.GOWA_SERVER_URL || 'http://localhost:3000'
const GOWA2_SERVER_URL = process.env.GOWA2_SERVER_URL || 'https://gowa2.flx.web.id'
const USE_GOWA2 = process.env.USE_GOWA2 === 'true' || true  // Default use GOWA2
const ACTIVE_GOWA_URL = USE_GOWA2 ? GOWA2_SERVER_URL : GOWA_SERVER_URL

const RECIPIENTS_FILE = path.join(__dirname, 'whatsapp-recipients.json')
const ALERT_GROUPS_FILE = path.join(__dirname, 'alert-groups.json')
const GAS_DANGER_THRESHOLD = parseInt(process.env.GAS_THRESHOLD) || 4095  // ADC max = bahaya gas
const NOTIFICATION_COOLDOWN = parseInt(process.env.NOTIFICATION_COOLDOWN) || 60000  // 60 detik cooldown

console.log(`📱 GOWA Server: ${ACTIVE_GOWA_URL} (${USE_GOWA2 ? 'GOWA2' : 'GOWA1'})`)

// In-memory recipients storage
let whatsappRecipients = []
let lastNotificationTime = 0
let lastGasNotificationTime = 0  // Separate cooldown for gas
let lastFireNotificationTime = 0  // Separate cooldown for fire
let notificationStats = {
  totalSent: 0,
  lastSent: null,
  failures: []
}

// Alert Groups storage for WhatsApp Group notifications
let alertGroups = []
let fireAlertToGroupEnabled = false
let lastGroupNotificationTime = 0

// Load alert groups from file
function loadAlertGroups() {
  try {
    if (fs.existsSync(ALERT_GROUPS_FILE)) {
      const data = fs.readFileSync(ALERT_GROUPS_FILE, 'utf8')
      const parsed = JSON.parse(data)
      alertGroups = parsed.groups || []
      fireAlertToGroupEnabled = parsed.fireAlertEnabled || false
      console.log(`📱 Loaded ${alertGroups.length} alert groups (enabled: ${fireAlertToGroupEnabled})`)
      alertGroups.forEach(g => {
        console.log(`   - ${g.name}: ${g.jid} (${g.enabled ? '✅' : '❌'})`)
      })
    }
  } catch (error) {
    console.error('❌ Failed to load alert groups:', error.message)
  }
}

// Save alert groups to file
function saveAlertGroups() {
  try {
    const data = { groups: alertGroups, fireAlertEnabled: fireAlertToGroupEnabled }
    fs.writeFileSync(ALERT_GROUPS_FILE, JSON.stringify(data, null, 2))
    console.log(`💾 Saved ${alertGroups.length} alert groups`)
  } catch (error) {
    console.error('❌ Failed to save alert groups:', error.message)
  }
}

// Send WhatsApp notification to GROUPS via GOWA2
async function sendGowaGroupNotification(message, alertType = 'fire', imageBase64 = null) {
  const now = Date.now()
  
  if (now - lastGroupNotificationTime < NOTIFICATION_COOLDOWN) {
    const remaining = Math.round((NOTIFICATION_COOLDOWN - (now - lastGroupNotificationTime)) / 1000)
    console.log(`⏳ Group notification cooldown active (${remaining}s remaining)`)
    return { success: false, reason: 'cooldown', remaining }
  }
  
  if (!fireAlertToGroupEnabled) {
    console.log('⚠️ Fire alert to groups is disabled')
    return { success: false, reason: 'disabled' }
  }
  
  const enabledGroups = alertGroups.filter(g => g.enabled !== false)
  if (enabledGroups.length === 0) {
    console.log('⚠️ No alert groups enabled')
    return { success: false, reason: 'no_groups' }
  }
  
  console.log(`\n${'='.repeat(60)}`)
  console.log(`📤 SENDING ${alertType.toUpperCase()} ALERT TO ${enabledGroups.length} GROUPS (GOWA2)`)
  console.log(`${'='.repeat(60)}`)
  
  const results = []
  lastGroupNotificationTime = now
  
  for (const group of enabledGroups) {
    try {
      console.log(`📤 Sending to group: ${group.name} (${group.jid})...`)
      
      let response
      
      if (imageBase64) {
        // Send image with caption to group
        response = await fetch(`${GOWA2_SERVER_URL}/send/image`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            phone: group.jid,
            image: imageBase64,
            caption: message
          })
        })
      } else {
        // Send text message to group
        response = await fetch(`${GOWA2_SERVER_URL}/send/message`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            phone: group.jid,
            message: message
          })
        })
      }
      
      const data = await response.json()
      
      if (response.ok && data.code === 'SUCCESS') {
        console.log(`✅ SUCCESS: Sent to group ${group.name}`)
        results.push({ jid: group.jid, name: group.name, success: true })
        notificationStats.totalSent++
        notificationStats.lastSent = new Date().toISOString()
      } else {
        console.error(`❌ FAILED: ${group.name} - ${data.message || JSON.stringify(data)}`)
        results.push({ jid: group.jid, name: group.name, success: false, error: data })
      }
    } catch (error) {
      console.error(`❌ ERROR: ${group.name} - ${error.message}`)
      results.push({ jid: group.jid, name: group.name, success: false, error: error.message })
    }
    
    // Small delay between messages
    await new Promise(resolve => setTimeout(resolve, 500))
  }
  
  console.log(`${'='.repeat(60)}`)
  console.log(`📊 Group Results: ${results.filter(r => r.success).length}/${results.length} sent successfully`)
  console.log(`${'='.repeat(60)}\n`)
  
  return { success: true, results }
}

// Load recipients from file
function loadRecipients() {
  try {
    if (fs.existsSync(RECIPIENTS_FILE)) {
      const data = fs.readFileSync(RECIPIENTS_FILE, 'utf8')
      const parsed = JSON.parse(data)
      if (Array.isArray(parsed) && parsed.length > 0) {
        whatsappRecipients = parsed
        console.log(`📱 Loaded ${whatsappRecipients.length} WhatsApp recipients:`)
        whatsappRecipients.forEach(r => {
          console.log(`   - ${r.name}: ${r.phone} (${r.enabled ? '✅ enabled' : '❌ disabled'})`)
        })
      } else {
        console.log('📱 No recipients in file')
      }
    } else {
      console.log('📱 Recipients file not found, creating empty one')
      fs.writeFileSync(RECIPIENTS_FILE, '[]')
    }
  } catch (error) {
    console.error('❌ Failed to load recipients:', error.message)
    whatsappRecipients = []
  }
}

// Save recipients to file
function saveRecipients() {
  try {
    fs.writeFileSync(RECIPIENTS_FILE, JSON.stringify(whatsappRecipients, null, 2))
    console.log(`💾 Saved ${whatsappRecipients.length} recipients to file`)
  } catch (error) {
    console.error('❌ Failed to save recipients:', error.message)
  }
}

// Send WhatsApp notification via GOWA
async function sendGowaNotification(message, alertType = 'general') {
  const now = Date.now()
  
  // Check cooldown per alert type
  let lastTime = lastNotificationTime
  if (alertType === 'gas') lastTime = lastGasNotificationTime
  if (alertType === 'fire') lastTime = lastFireNotificationTime
  
  if (now - lastTime < NOTIFICATION_COOLDOWN) {
    const remaining = Math.round((NOTIFICATION_COOLDOWN - (now - lastTime)) / 1000)
    console.log(`⏳ ${alertType.toUpperCase()} notification cooldown active (${remaining}s remaining)`)
    return { success: false, reason: 'cooldown', remaining }
  }
  
  // Reload recipients from file (in case updated externally)
  loadRecipients()
  
  if (whatsappRecipients.length === 0) {
    console.log('⚠️ No WhatsApp recipients configured - cannot send notification')
    return { success: false, reason: 'no_recipients' }
  }
  
  const enabledRecipients = whatsappRecipients.filter(r => r.enabled !== false)
  if (enabledRecipients.length === 0) {
    console.log('⚠️ All recipients are disabled')
    return { success: false, reason: 'all_disabled' }
  }
  
  console.log(`\n${'='.repeat(60)}`)
  console.log(`📤 SENDING ${alertType.toUpperCase()} ALERT TO ${enabledRecipients.length} RECIPIENTS`)
  console.log(`${'='.repeat(60)}`)
  
  const results = []
  
  // Update cooldown
  if (alertType === 'gas') lastGasNotificationTime = now
  else if (alertType === 'fire') lastFireNotificationTime = now
  else lastNotificationTime = now
  
  for (const recipient of enabledRecipients) {
    // Format phone number (ensure 628xxx format)
    let phone = String(recipient.phone || '').replace(/[^0-9]/g, '')
    if (phone.startsWith('0')) {
      phone = '62' + phone.substring(1)
    }
    if (!phone.startsWith('62')) {
      phone = '62' + phone
    }
    
    if (phone.length < 10) {
      console.log(`⚠️ Invalid phone for ${recipient.name}: ${phone}`)
      continue
    }
    
    try {
      console.log(`📤 Sending to ${recipient.name} (${phone})...`)
      
      const response = await fetch(`${GOWA_SERVER_URL}/send/message`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          phone: phone,
          message: message
        })
      })
      
      const data = await response.json()
      
      if (response.ok && data.code === 'SUCCESS') {
        console.log(`✅ SUCCESS: Sent to ${recipient.name}`)
        results.push({ phone, name: recipient.name, success: true })
        notificationStats.totalSent++
        notificationStats.lastSent = new Date().toISOString()
      } else {
        console.error(`❌ FAILED: ${recipient.name} - ${data.message || JSON.stringify(data)}`)
        results.push({ phone, name: recipient.name, success: false, error: data })
        notificationStats.failures.push({
          phone,
          error: data.message || 'Unknown error',
          timestamp: new Date().toISOString()
        })
      }
    } catch (error) {
      console.error(`❌ ERROR: ${recipient.name} - ${error.message}`)
      results.push({ phone, name: recipient.name, success: false, error: error.message })
    }
    
    // Small delay between messages to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 500))
  }
  
  console.log(`${'='.repeat(60)}`)
  console.log(`📊 Results: ${results.filter(r => r.success).length}/${results.length} sent successfully`)
  console.log(`${'='.repeat(60)}\n`)
  
  return { success: true, results }
}

// Create alert message based on type
function createAlertMessage(alertType, data) {
  const timestamp = new Date().toLocaleString('id-ID', { 
    timeZone: 'Asia/Jakarta',
    dateStyle: 'medium',
    timeStyle: 'short'
  })
  
  switch (alertType) {
    case 'fire':
      return `🔥 *PERINGATAN KEBAKARAN!*\n\n` +
             `⚠️ Sensor mendeteksi api!\n\n` +
             `📍 Lokasi: Lab IoT\n` +
             `📅 Waktu: ${timestamp}\n` +
             `🔢 Device: ${data.deviceId || 'ESP32'}\n\n` +
             `_Segera periksa lokasi dan ambil tindakan!_\n\n` +
             `🤖 _Pesan otomatis dari Fire Detection System_`
    
    case 'gas':
      return `⚠️ *PERINGATAN KEBOCORAN GAS!*\n\n` +
             `💨 Level gas BERBAHAYA terdeteksi!\n\n` +
             `📊 Level: ${data.gasValue || 4095} ADC (MAX)\n` +
             `📍 Lokasi: Lab IoT\n` +
             `📅 Waktu: ${timestamp}\n` +
             `🔢 Device: ${data.deviceId || 'ESP32'}\n\n` +
             `⚡ _Tindakan: Segera ventilasi area dan matikan sumber gas!_\n\n` +
             `🤖 _Pesan otomatis dari Fire Detection System_`
    
    case 'fire_camera':
      return `🔥 *KEBAKARAN TERDETEKSI - AI VISION!*\n\n` +
             `📸 Kamera ESP32-CAM mendeteksi api!\n\n` +
             `📊 Confidence: ${((data.confidence || 0) * 100).toFixed(0)}%\n` +
             `📍 Camera: ${data.cameraIp || 'Unknown'}\n` +
             `📅 Waktu: ${timestamp}\n\n` +
             `${data.geminiVerified ? '✅ Terverifikasi Gemini AI' : '⚠️ Belum diverifikasi AI'}\n\n` +
             `_Segera periksa lokasi!_\n\n` +
             `🤖 _Pesan otomatis dari AI Fire Detection System_`
    
    default:
      return `⚠️ *ALERT: ${alertType.toUpperCase()}*\n\n` +
             `📅 Waktu: ${timestamp}\n` +
             `📊 Data: ${JSON.stringify(data, null, 2)}\n\n` +
             `🤖 _Pesan otomatis dari Fire Detection System_`
  }
}

// Process MQTT event for alerts
async function processAlertEvent(topic, payload) {
  try {
    let data
    try {
      data = JSON.parse(payload)
    } catch {
      data = { raw: payload }
    }
    
    console.log(`🔍 Processing alert event from ${topic}:`, data)
    
    // Check for fire detection event
    if (data.event === 'flame_on' || data.type === 'fire' || data.flame === true) {
      console.log('🔥 FIRE DETECTED! Sending notifications...')
      const message = createAlertMessage('fire', { deviceId: data.id || data.deviceId })
      
      // Send to individual recipients
      await sendGowaNotification(message, 'fire')
      
      // Also send to WhatsApp Groups via GOWA2
      if (fireAlertToGroupEnabled && alertGroups.length > 0) {
        console.log('📱 Also sending to WhatsApp Groups...')
        await sendGowaGroupNotification(message, 'fire')
      }
      return
    }
    
    // Check for ESP32-CAM fire detection (from Python VPS script)
    if (data.event === 'fire_detected' || data.type === 'fire_detection_photo') {
      console.log('📸 ESP32-CAM FIRE DETECTED! Sending notifications...')
      const message = createAlertMessage('fire_camera', {
        confidence: data.yolo_confidence || data.confidence,
        cameraIp: data.camera_ip || data.cameraIp,
        geminiVerified: data.gemini_verified || data.geminiVerified
      })
      
      // Send to individual recipients
      await sendGowaNotification(message, 'fire')
      
      // Also send to WhatsApp Groups via GOWA2
      if (fireAlertToGroupEnabled && alertGroups.length > 0) {
        console.log('📱 Also sending to WhatsApp Groups...')
        await sendGowaGroupNotification(message, 'fire')
      }
      return
    }
    
    // Check for gas leak (gasA >= 4095)
    if (data.gasA !== undefined && data.gasA >= GAS_DANGER_THRESHOLD) {
      console.log(`💨 GAS DANGER! Level: ${data.gasA} (threshold: ${GAS_DANGER_THRESHOLD})`)
      const message = createAlertMessage('gas', { gasValue: data.gasA, deviceId: data.id })
      
      // Send to individual recipients
      await sendGowaNotification(message, 'gas')
      
      // Also send to WhatsApp Groups
      if (fireAlertToGroupEnabled && alertGroups.length > 0) {
        console.log('📱 Also sending gas alert to WhatsApp Groups...')
        await sendGowaGroupNotification(message, 'gas')
      }
      return
    }
    
    // Check for alarm state
    if (data.alarm === true || data.alarm === 1) {
      console.log('🚨 ALARM TRIGGERED! Checking reason...')
      if (data.gasA && data.gasA >= GAS_DANGER_THRESHOLD) {
        const message = createAlertMessage('gas', { gasValue: data.gasA, deviceId: data.id })
        await sendGowaNotification(message, 'gas')
        if (fireAlertToGroupEnabled) await sendGowaGroupNotification(message, 'gas')
      } else {
        const message = createAlertMessage('fire', { deviceId: data.id })
        await sendGowaNotification(message, 'fire')
        if (fireAlertToGroupEnabled) await sendGowaGroupNotification(message, 'fire')
      }
      return
    }
    
  } catch (error) {
    console.error('❌ Error processing alert event:', error.message)
  }
}

// Initialize recipients on startup
loadRecipients()
loadAlertGroups()

// ================================================================================


// Create Express app
const app = express()

// COMPREHENSIVE CORS CONFIGURATION for Vercel compatibility
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'http://localhost:5173',
    'http://localhost:8080',
    'https://rtsp-main.vercel.app',
    'https://rtsp-main-krj3w64cm-nexuszzzs-projects.vercel.app',
    /.*\.vercel\.app$/,  // Allow all Vercel domains
    'http://3.27.11.106:3000',
    'http://3.27.11.106:5173',
    'http://3.27.11.106:8080',
    'http://3.27.11.106',
    'https://latom.flx.web.id',
    'https://api.latom.flx.web.id',
    /.*\.flx\.web\.id$/  // Allow all flx.web.id subdomains
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With', 
    'Content-Type', 
    'Accept',
    'Authorization',
    'Cache-Control',
    'X-Access-Token'
  ],
  credentials: true,
  optionsSuccessStatus: 200
}

app.use(cors(corsOptions))

// Additional CORS headers for preflight
app.use((req, res, next) => {
  const origin = req.headers.origin
  if (corsOptions.origin.some(o => 
    (typeof o === 'string' && o === origin) || 
    (o instanceof RegExp && o.test(origin))
  )) {
    res.setHeader('Access-Control-Allow-Origin', origin)
  }
  res.setHeader('Access-Control-Allow-Credentials', 'true')
  if (req.method === 'OPTIONS') {
    res.sendStatus(200)
    return
  }
  next()
})

app.use(express.json())

// Create uploads directory for fire detection snapshots
const uploadsDir = path.join(__dirname, 'uploads', 'fire-detections')
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
  console.log(`📁 Created uploads directory: ${uploadsDir}`)
}

// Serve static files from uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')))

// Serve static files from recordings (for video playback)
const recordingsDir = path.join(__dirname, 'recordings')
if (!fs.existsSync(recordingsDir)) {
  fs.mkdirSync(recordingsDir, { recursive: true })
  console.log(`📁 Created recordings directory: ${recordingsDir}`)
}
app.use('/recordings', express.static(recordingsDir))

// Mount video routes
app.use('/api/video', videoRoutes)

// Mount auth routes
app.use('/api/auth', authRoutes)

// ================================================================================
// PROXY ROUTES FOR GO-WHATSAPP (GOWA) API
// These routes forward requests to the Go-WhatsApp REST API server
// GitHub: https://github.com/aldinokemal/go-whatsapp-web-multidevice
// ================================================================================

// GOWA_SERVER_URL already defined above in auto notification section

// Helper function to proxy requests with support for multipart
async function proxyRequest(targetUrl, req, res, options = {}) {
  try {
    const headers = {}
    
    // Copy content-type if exists
    if (req.headers['content-type']) {
      headers['Content-Type'] = req.headers['content-type']
    }
    
    const fetchOptions = {
      method: req.method,
      headers,
    }
    
    if (req.method !== 'GET' && req.method !== 'HEAD' && req.body) {
      if (req.headers['content-type']?.includes('application/json')) {
        fetchOptions.body = JSON.stringify(req.body)
        headers['Content-Type'] = 'application/json'
      }
    }
    
    console.log(`🔄 Proxying to: ${targetUrl}`)
    const response = await fetch(targetUrl, fetchOptions)
    const data = await response.json()
    
    res.status(response.status).json(data)
  } catch (error) {
    console.error(`Proxy error to ${targetUrl}:`, error.message)
    res.status(503).json({
      success: false,
      code: 'SERVICE_UNAVAILABLE',
      error: `Service unavailable: ${error.message}`,
      target: targetUrl
    })
  }
}

// ====================
// GOWA API Proxy Routes
// ====================

// App routes (login, logout, reconnect, devices)
app.get('/gowa/app/login', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/app/login`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/app/login-with-code', async (req, res) => {
  const phone = req.query.phone
  const targetUrl = `${GOWA_SERVER_URL}/app/login-with-code?phone=${phone}`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/app/logout', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/app/logout`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/app/reconnect', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/app/reconnect`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/app/devices', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/app/devices`
  await proxyRequest(targetUrl, req, res)
})

// Send routes
app.post('/gowa/send/message', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/message`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/image', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/image`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/file', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/file`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/video', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/video`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/audio', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/audio`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/contact', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/contact`
  await proxyRequest(targetUrl, req, res)
})

app.post('/gowa/send/location', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/send/location`
  await proxyRequest(targetUrl, req, res)
})

// User routes
app.get('/gowa/user/info', async (req, res) => {
  const phone = req.query.phone
  const targetUrl = `${GOWA_SERVER_URL}/user/info?phone=${phone}`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/user/avatar', async (req, res) => {
  const phone = req.query.phone
  const targetUrl = `${GOWA_SERVER_URL}/user/avatar?phone=${phone}`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/user/my/contacts', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/user/my/contacts`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/user/my/groups', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/user/my/groups`
  await proxyRequest(targetUrl, req, res)
})

// Chat routes
app.get('/gowa/chat/list', async (req, res) => {
  const targetUrl = `${GOWA_SERVER_URL}/chat/list`
  await proxyRequest(targetUrl, req, res)
})

app.get('/gowa/chat/messages', async (req, res) => {
  const { phone, limit } = req.query
  const targetUrl = `${GOWA_SERVER_URL}/chat/messages?phone=${phone}&limit=${limit || 50}`
  await proxyRequest(targetUrl, req, res)
})

// Catch-all for other GOWA routes
app.all('/gowa/*', async (req, res) => {
  const path = req.path.replace('/gowa', '')
  const queryString = req.url.includes('?') ? req.url.split('?')[1] : ''
  const targetUrl = `${GOWA_SERVER_URL}${path}${queryString ? '?' + queryString : ''}`
  console.log(`📱 Proxying GOWA request: ${req.method} ${targetUrl}`)
  await proxyRequest(targetUrl, req, res)
})

// ================================================================================
// WHATSAPP RECIPIENTS MANAGEMENT API
// These endpoints manage notification recipients stored on server
// ================================================================================

// Get all recipients
app.get('/api/recipients', (req, res) => {
  res.json({
    success: true,
    recipients: whatsappRecipients,
    stats: notificationStats
  })
})

// Add new recipient
app.post('/api/recipients', (req, res) => {
  const { name, phone, enabled = true } = req.body
  
  if (!name || !phone) {
    return res.status(400).json({
      success: false,
      error: 'Name and phone are required'
    })
  }
  
  // Validate phone format
  const cleanPhone = phone.replace(/[^0-9]/g, '')
  if (cleanPhone.length < 10 || cleanPhone.length > 15) {
    return res.status(400).json({
      success: false,
      error: 'Invalid phone number format'
    })
  }
  
  // Check for duplicates
  const exists = whatsappRecipients.find(r => 
    r.phone.replace(/[^0-9]/g, '') === cleanPhone
  )
  if (exists) {
    return res.status(409).json({
      success: false,
      error: 'Phone number already registered'
    })
  }
  
  const recipient = {
    id: `rec_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`,
    name,
    phone: cleanPhone,
    enabled,
    createdAt: new Date().toISOString()
  }
  
  whatsappRecipients.push(recipient)
  saveRecipients()
  
  console.log(`📱 Added recipient: ${name} (${phone})`)
  
  res.json({
    success: true,
    recipient,
    message: 'Recipient added successfully'
  })
})

// Update recipient
app.put('/api/recipients/:id', (req, res) => {
  const { id } = req.params
  const { name, phone, enabled } = req.body
  
  const index = whatsappRecipients.findIndex(r => r.id === id)
  if (index === -1) {
    return res.status(404).json({
      success: false,
      error: 'Recipient not found'
    })
  }
  
  if (name) whatsappRecipients[index].name = name
  if (phone) whatsappRecipients[index].phone = phone.replace(/[^0-9]/g, '')
  if (enabled !== undefined) whatsappRecipients[index].enabled = enabled
  whatsappRecipients[index].updatedAt = new Date().toISOString()
  
  saveRecipients()
  
  res.json({
    success: true,
    recipient: whatsappRecipients[index],
    message: 'Recipient updated successfully'
  })
})

// Delete recipient
app.delete('/api/recipients/:id', (req, res) => {
  const { id } = req.params
  const index = whatsappRecipients.findIndex(r => r.id === id)
  
  if (index === -1) {
    return res.status(404).json({
      success: false,
      error: 'Recipient not found'
    })
  }
  
  const removed = whatsappRecipients.splice(index, 1)[0]
  saveRecipients()
  
  console.log(`🗑️ Removed recipient: ${removed.name}`)
  
  res.json({
    success: true,
    message: 'Recipient deleted successfully'
  })
})

// Toggle recipient enabled status
app.patch('/api/recipients/:id/toggle', (req, res) => {
  const { id } = req.params
  const recipient = whatsappRecipients.find(r => r.id === id)
  
  if (!recipient) {
    return res.status(404).json({
      success: false,
      error: 'Recipient not found'
    })
  }
  
  recipient.enabled = !recipient.enabled
  recipient.updatedAt = new Date().toISOString()
  saveRecipients()
  
  res.json({
    success: true,
    recipient,
    message: `Recipient ${recipient.enabled ? 'enabled' : 'disabled'}`
  })
})

// Sync recipients from frontend (bulk update)
app.post('/api/recipients/sync', (req, res) => {
  const { recipients: newRecipients } = req.body
  
  if (!Array.isArray(newRecipients)) {
    return res.status(400).json({
      success: false,
      error: 'Recipients must be an array'
    })
  }
  
  // Validate and transform recipients
  const validRecipients = newRecipients.map((r, index) => ({
    id: r.id || `rec_${Date.now()}_${index}`,
    name: r.name || `Recipient ${index + 1}`,
    phone: (r.phone || r.number || '').replace(/[^0-9]/g, ''),
    enabled: r.enabled !== false,
    createdAt: r.createdAt || new Date().toISOString()
  })).filter(r => r.phone.length >= 10)
  
  whatsappRecipients = validRecipients
  saveRecipients()
  
  console.log(`🔄 Synced ${validRecipients.length} recipients from frontend`)
  
  res.json({
    success: true,
    count: validRecipients.length,
    recipients: validRecipients
  })
})

// Test notification to specific recipient
app.post('/api/recipients/:id/test', async (req, res) => {
  const { id } = req.params
  const recipient = whatsappRecipients.find(r => r.id === id)
  
  if (!recipient) {
    return res.status(404).json({
      success: false,
      error: 'Recipient not found'
    })
  }
  
  // Format phone
  let phone = recipient.phone.replace(/[^0-9]/g, '')
  if (phone.startsWith('0')) phone = '62' + phone.substring(1)
  if (!phone.startsWith('62')) phone = '62' + phone
  
  const timestamp = new Date().toLocaleString('id-ID', { timeZone: 'Asia/Jakarta' })
  const testMessage = `🧪 *TEST NOTIFIKASI*\n\n` +
                     `Ini adalah pesan test dari Fire Detection System.\n\n` +
                     `📱 Recipient: ${recipient.name}\n` +
                     `📅 Waktu: ${timestamp}\n\n` +
                     `✅ Jika Anda menerima pesan ini, sistem notifikasi berfungsi dengan baik!\n\n` +
                     `🤖 _Pesan otomatis dari Fire Detection System_`
  
  try {
    const response = await fetch(`${GOWA_SERVER_URL}/send/message`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone, message: testMessage })
    })
    
    const data = await response.json()
    
    if (response.ok) {
      res.json({
        success: true,
        message: 'Test message sent successfully',
        recipient: recipient.name
      })
    } else {
      res.status(response.status).json({
        success: false,
        error: data.message || 'Failed to send test message',
        details: data
      })
    }
  } catch (error) {
    res.status(503).json({
      success: false,
      error: `Failed to send: ${error.message}`
    })
  }
})

// Manual trigger alert (for testing)
app.post('/api/alert/trigger', async (req, res) => {
  const { type = 'fire', data = {} } = req.body
  
  console.log(`🔔 Manual alert trigger: ${type}`)
  
  const message = createAlertMessage(type, data)
  const result = await sendGowaNotification(message, type)
  
  res.json({
    success: result.success,
    type,
    result
  })
})

// Get notification stats
app.get('/api/notifications/stats', (req, res) => {
  res.json({
    success: true,
    stats: notificationStats,
    recipientCount: whatsappRecipients.length,
    enabledCount: whatsappRecipients.filter(r => r.enabled !== false).length,
    gasThreshold: GAS_DANGER_THRESHOLD,
    cooldowns: {
      general: Math.max(0, NOTIFICATION_COOLDOWN - (Date.now() - lastNotificationTime)),
      gas: Math.max(0, NOTIFICATION_COOLDOWN - (Date.now() - lastGasNotificationTime)),
      fire: Math.max(0, NOTIFICATION_COOLDOWN - (Date.now() - lastFireNotificationTime))
    }
  })
})

// Get/Set gas threshold
app.get('/api/config/gas-threshold', (req, res) => {
  res.json({
    success: true,
    threshold: GAS_DANGER_THRESHOLD,
    description: 'Gas ADC value threshold for triggering alert (0-4095)'
  })
})

// Simulate gas alert for testing
app.post('/api/test/gas-alert', async (req, res) => {
  const { gasValue = 4095 } = req.body
  
  console.log(`\n🧪 SIMULATING GAS ALERT with value: ${gasValue}`)
  
  // Create fake telemetry payload
  const fakePayload = JSON.stringify({
    id: 'TEST-DEVICE',
    gasA: gasValue,
    gasD: true,
    alarm: true,
    t: 25.0,
    h: 60.0
  })
  
  await processAlertEvent('lab/zaks/log', fakePayload)
  
  res.json({
    success: true,
    message: `Gas alert simulated with value ${gasValue}`,
    threshold: GAS_DANGER_THRESHOLD,
    wouldTrigger: gasValue >= GAS_DANGER_THRESHOLD
  })
})

// Simulate fire alert for testing
app.post('/api/test/fire-alert', async (req, res) => {
  console.log(`\n🧪 SIMULATING FIRE ALERT`)
  
  // Create fake event payload
  const fakePayload = JSON.stringify({
    event: 'flame_on',
    id: 'TEST-DEVICE',
    flame: true
  })
  
  await processAlertEvent('lab/zaks/event', fakePayload)
  
  res.json({
    success: true,
    message: 'Fire alert simulated'
  })
})

// Reload recipients from file
app.post('/api/recipients/reload', (req, res) => {
  loadRecipients()
  res.json({
    success: true,
    count: whatsappRecipients.length,
    recipients: whatsappRecipients
  })
})

// Reset cooldowns (for testing)
app.post('/api/notifications/reset-cooldown', (req, res) => {
  lastNotificationTime = 0
  lastGasNotificationTime = 0
  lastFireNotificationTime = 0
  lastGroupNotificationTime = 0
  res.json({
    success: true,
    message: 'All cooldowns reset'
  })
})

// ================================================================================
// ALERT GROUPS API - WhatsApp Group Notifications
// ================================================================================

// Get alert groups configuration
app.get('/api/alert-groups', (req, res) => {
  res.json({
    success: true,
    alertGroups: alertGroups,
    fireAlertEnabled: fireAlertToGroupEnabled,
    gowaServer: GOWA2_SERVER_URL
  })
})

// Save alert groups configuration
app.post('/api/alert-groups', (req, res) => {
  const { groups, fireAlertEnabled } = req.body
  
  if (groups !== undefined) {
    if (!Array.isArray(groups)) {
      return res.status(400).json({
        success: false,
        error: 'groups must be an array'
      })
    }
    alertGroups = groups.map(g => ({
      jid: g.jid,
      name: g.name,
      enabled: g.enabled !== false
    }))
  }
  
  if (fireAlertEnabled !== undefined) {
    fireAlertToGroupEnabled = fireAlertEnabled
  }
  
  saveAlertGroups()
  
  console.log(`📱 Alert groups updated: ${alertGroups.length} groups, enabled: ${fireAlertToGroupEnabled}`)
  
  res.json({
    success: true,
    alertGroups: alertGroups,
    fireAlertEnabled: fireAlertToGroupEnabled
  })
})

// Toggle fire alert to groups
app.post('/api/alert-groups/toggle', (req, res) => {
  fireAlertToGroupEnabled = !fireAlertToGroupEnabled
  saveAlertGroups()
  
  res.json({
    success: true,
    fireAlertEnabled: fireAlertToGroupEnabled,
    message: `Fire alert to groups ${fireAlertToGroupEnabled ? 'enabled' : 'disabled'}`
  })
})

// Add a group to alert list
app.post('/api/alert-groups/add', (req, res) => {
  const { jid, name } = req.body
  
  if (!jid || !name) {
    return res.status(400).json({
      success: false,
      error: 'jid and name are required'
    })
  }
  
  // Check if already exists
  if (alertGroups.find(g => g.jid === jid)) {
    return res.status(409).json({
      success: false,
      error: 'Group already in alert list'
    })
  }
  
  alertGroups.push({ jid, name, enabled: true })
  saveAlertGroups()
  
  res.json({
    success: true,
    alertGroups: alertGroups
  })
})

// Remove a group from alert list
app.delete('/api/alert-groups/:jid', (req, res) => {
  const { jid } = req.params
  const index = alertGroups.findIndex(g => g.jid === jid)
  
  if (index === -1) {
    return res.status(404).json({
      success: false,
      error: 'Group not found in alert list'
    })
  }
  
  alertGroups.splice(index, 1)
  saveAlertGroups()
  
  res.json({
    success: true,
    alertGroups: alertGroups
  })
})

// Test send to groups
app.post('/api/alert-groups/test', async (req, res) => {
  const timestamp = new Date().toLocaleString('id-ID', { timeZone: 'Asia/Jakarta' })
  const testMessage = `🧪 *TEST ALERT - WhatsApp Group*\n\n` +
                     `Ini adalah pesan test dari Fire Detection System.\n\n` +
                     `📅 Waktu: ${timestamp}\n` +
                     `📱 Server: GOWA2\n\n` +
                     `✅ Jika grup ini menerima pesan, notifikasi grup berfungsi!\n\n` +
                     `🤖 _Pesan otomatis dari Fire Detection System_`
  
  // Temporarily bypass cooldown for test
  lastGroupNotificationTime = 0
  
  const result = await sendGowaGroupNotification(testMessage, 'test')
  
  res.json({
    success: result.success,
    results: result.results || [],
    message: result.reason || 'Test sent'
  })
})

// Fetch available WhatsApp groups from GOWA2
app.get('/api/whatsapp-groups', async (req, res) => {
  try {
    const response = await fetch(`${GOWA2_SERVER_URL}/user/my/groups`, {
      headers: { 'Accept': 'application/json' }
    })
    
    if (!response.ok) {
      throw new Error(`GOWA2 returned ${response.status}`)
    }
    
    const data = await response.json()
    
    if (data.code === 'SUCCESS' && data.results?.data) {
      res.json({
        success: true,
        groups: data.results.data,
        count: data.results.data.length
      })
    } else {
      res.json({
        success: false,
        error: data.message || 'No groups found'
      })
    }
  } catch (error) {
    console.error('Failed to fetch WhatsApp groups:', error.message)
    res.status(503).json({
      success: false,
      error: `Failed to fetch groups: ${error.message}`
    })
  }
})

// ================================================================================

// Serve static files from public folder (for login page)
const publicDir = path.join(__dirname, 'public')
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true })
}
app.use(express.static(publicDir))

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir)
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now()
    const ext = path.extname(file.originalname)
    cb(null, `fire_${timestamp}${ext}`)
  }
})

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png']
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true)
    } else {
      cb(new Error('Invalid file type. Only JPEG and PNG allowed.'))
    }
  }
})

// In-memory storage for fire detection logs (max 100 recent detections)
const fireDetectionLogs = []
const MAX_FIRE_LOGS = 100

// ESP32-CAM livestream data
const esp32Streams = new Map() // cameraId -> { ip, streamUrl, lastSeen, status }
const streamClients = new Set() // WebSocket clients for stream
let currentStreamFrame = null // Current frame buffer for MJPEG stream

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    mqtt: mqttClient?.connected ? 'connected' : 'disconnected',
    clients: wsClients.size,
    fireDetections: fireDetectionLogs.length,
  })
})

// API Status endpoint (used by frontend)
app.get('/api/status', (req, res) => {
  res.json({
    status: 'ok',
    mqtt: mqttClient?.connected ? 'connected' : 'disconnected',
    clients: wsClients.size,
    fireDetections: fireDetectionLogs.length,
    esp32Cameras: esp32Streams.size,
    streamClients: streamClients.size,
    timestamp: new Date().toISOString(),
    server: 'EC2 Fire Detection API',
    version: '1.0.0'
  })
})

// ESP32-CAM stream endpoints
app.get('/api/stream/cameras', (req, res) => {
  const cameras = Array.from(esp32Streams.entries()).map(([id, data]) => ({
    id,
    ip: data.ip,
    streamUrl: data.streamUrl,
    status: data.status,
    lastSeen: data.lastSeen
  }))
  
  res.json({
    success: true,
    cameras: cameras,
    count: cameras.length
  })
})

// Proxy ESP32-CAM stream
app.get('/api/stream/:cameraId', async (req, res) => {
  const { cameraId } = req.params
  const camera = esp32Streams.get(cameraId)
  
  if (!camera) {
    return res.status(404).json({
      success: false,
      error: 'Camera not found'
    })
  }
  
  try {
    // Proxy MJPEG stream from ESP32-CAM
    const response = await fetch(camera.streamUrl)
    
    if (!response.ok) {
      throw new Error(`Stream unavailable: ${response.status}`)
    }
    
    res.setHeader('Content-Type', 'multipart/x-mixed-replace; boundary=frame')
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate')
    res.setHeader('Pragma', 'no-cache')
    res.setHeader('Expires', '0')
    
    response.body.pipe(res)
    
  } catch (error) {
    console.error(`Stream proxy error for ${cameraId}:`, error.message)
    res.status(503).json({
      success: false,
      error: 'Stream unavailable',
      cameraId
    })
  }
})

// Fire Detection API - POST new detection with snapshot
app.post('/api/fire-detection', upload.single('snapshot'), (req, res) => {
  try {
    const {
      confidence,
      bbox,
      geminiScore,
      geminiReason,
      geminiVerified,
      cameraIp,
      cameraId,
      yoloModel,
    } = req.body

    // Validate required fields
    if (!confidence || !bbox || !cameraIp) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: confidence, bbox, cameraIp'
      })
    }

    // Parse bbox (should be JSON string "[x1, y1, x2, y2]")
    let parsedBbox
    try {
      parsedBbox = typeof bbox === 'string' ? JSON.parse(bbox) : bbox
    } catch (e) {
      return res.status(400).json({
        success: false,
        error: 'Invalid bbox format. Expected array [x1, y1, x2, y2]'
      })
    }

    // Create detection log entry
    const detectionLog = {
      id: `fire_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      confidence: parseFloat(confidence),
      bbox: {
        x1: parsedBbox[0],
        y1: parsedBbox[1],
        x2: parsedBbox[2],
        y2: parsedBbox[3],
        width: parsedBbox[2] - parsedBbox[0],
        height: parsedBbox[3] - parsedBbox[1],
      },
      geminiScore: geminiScore ? parseFloat(geminiScore) : null,
      geminiReason: geminiReason || null,
      geminiVerified: geminiVerified === 'true' || geminiVerified === true,
      snapshotUrl: req.file ? `/uploads/fire-detections/${req.file.filename}` : null,
      cameraId: cameraId || 'esp32cam_unknown',
      cameraIp: cameraIp,
      yoloModel: yoloModel || 'yolov8n',
      status: 'active',
    }

    // Add to logs (sliding window)
    fireDetectionLogs.unshift(detectionLog)
    if (fireDetectionLogs.length > MAX_FIRE_LOGS) {
      // Remove oldest detection and its snapshot file
      const removed = fireDetectionLogs.pop()
      if (removed.snapshotUrl) {
        const filePath = path.join(__dirname, removed.snapshotUrl)
        fs.unlink(filePath, (err) => {
          if (err) console.error(`Failed to delete old snapshot: ${filePath}`)
        })
      }
    }

    console.log(`🔥 Fire detection logged: ${detectionLog.id}`)
    console.log(`   Confidence: ${detectionLog.confidence}`)
    console.log(`   Gemini: ${detectionLog.geminiVerified ? detectionLog.geminiScore : 'N/A'}`)
    console.log(`   Snapshot: ${detectionLog.snapshotUrl || 'N/A'}`)
    console.log(`   Camera: ${detectionLog.cameraIp}`)

    // Broadcast to WebSocket clients
    const wsMessage = {
      type: 'fire-detection',
      data: detectionLog,
      timestamp: new Date().toISOString(),
    }

    wsClients.forEach((client) => {
      if (client.readyState === 1) {
        client.send(JSON.stringify(wsMessage))
      }
    })

    // Publish to MQTT for WhatsApp notification
    if (mqttClient?.connected) {
      const mqttPayload = {
        type: 'fire_detection_photo',
        detection: {
          id: detectionLog.id,
          timestamp: detectionLog.timestamp,
          confidence: detectionLog.confidence,
          bbox: detectionLog.bbox,
          geminiScore: detectionLog.geminiScore,
          geminiReason: detectionLog.geminiReason,
          geminiVerified: detectionLog.geminiVerified,
          cameraId: detectionLog.cameraId,
          cameraIp: detectionLog.cameraIp,
          yoloModel: detectionLog.yoloModel,
          status: detectionLog.status,
        },
        snapshot: {
          url: detectionLog.snapshotUrl,
          // Full path for WhatsApp server to read
          fullPath: req.file ? path.join(uploadsDir, req.file.filename) : null,
          filename: req.file ? req.file.filename : null,
        }
      }

      mqttClient.publish(
        'lab/zaks/fire_photo',
        JSON.stringify(mqttPayload),
        { qos: 1, retain: false },
        (err) => {
          if (err) {
            console.error('❌ Failed to publish fire photo to MQTT:', err)
          } else {
            console.log('✅ Fire photo published to MQTT topic: lab/zaks/fire_photo')
          }
        }
      )
    }

    res.json({
      success: true,
      detection: detectionLog,
      message: 'Fire detection logged successfully'
    })
  } catch (error) {
    console.error('❌ Error processing fire detection:', error)
    res.status(500).json({
      success: false,
      error: error.message
    })
  }
})

// Get all fire detection logs
app.get('/api/fire-detections', (req, res) => {
  const limit = parseInt(req.query.limit) || 50
  const status = req.query.status // 'active', 'resolved', 'false_positive'
  
  let logs = fireDetectionLogs
  
  if (status) {
    logs = logs.filter(log => log.status === status)
  }
  
  res.json({
    success: true,
    count: logs.length,
    detections: logs.slice(0, limit)
  })
})

// Update detection status
app.patch('/api/fire-detection/:id', (req, res) => {
  const { id } = req.params
  const { status } = req.body

  if (!['active', 'resolved', 'false_positive'].includes(status)) {
    return res.status(400).json({
      success: false,
      error: 'Invalid status. Must be: active, resolved, or false_positive'
    })
  }

  const detection = fireDetectionLogs.find(log => log.id === id)
  
  if (!detection) {
    return res.status(404).json({
      success: false,
      error: 'Detection not found'
    })
  }

  detection.status = status
  detection.updatedAt = new Date().toISOString()

  console.log(`✅ Updated detection ${id} status to: ${status}`)

  // Broadcast update
  const wsMessage = {
    type: 'fire-detection-update',
    data: detection,
    timestamp: new Date().toISOString(),
  }

  wsClients.forEach((client) => {
    if (client.readyState === 1) {
      client.send(JSON.stringify(wsMessage))
    }
  })

  res.json({
    success: true,
    detection
  })
})

// Delete detection
app.delete('/api/fire-detection/:id', (req, res) => {
  const { id } = req.params
  const index = fireDetectionLogs.findIndex(log => log.id === id)
  
  if (index === -1) {
    return res.status(404).json({
      success: false,
      error: 'Detection not found'
    })
  }

  const [removed] = fireDetectionLogs.splice(index, 1)
  
  // Delete snapshot file
  if (removed.snapshotUrl) {
    const filePath = path.join(__dirname, removed.snapshotUrl)
    fs.unlink(filePath, (err) => {
      if (err) console.error(`Failed to delete snapshot: ${filePath}`)
    })
  }

  console.log(`🗑️  Deleted detection: ${id}`)

  res.json({
    success: true,
    message: 'Detection deleted successfully'
  })
})

// Create HTTP server
const server = app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on port ${PORT}`)
  console.log(`📡 MQTT broker: ${MQTT_HOST}:${MQTT_PORT}`)
})

// Create WebSocket server
const wss = new WebSocketServer({ server, path: '/ws' })
const wsClients = new Set()

// Connect to MQTT broker (TCP)
const mqttClient = mqtt.connect(`mqtt://${MQTT_HOST}:${MQTT_PORT}`, {
  username: MQTT_USERNAME,
  password: MQTT_PASSWORD,
  keepalive: 30,
  reconnectPeriod: 2000,
})

mqttClient.on('connect', () => {
  console.log('✅ Connected to MQTT broker')
  
  // Subscribe to all lab/zaks topics using wildcard
  mqttClient.subscribe(TOPIC_ALL, (err) => {
    if (err) {
      console.error('❌ Subscription error:', err)
    } else {
      console.log(`📥 Subscribed to: ${TOPIC_ALL}`)
      console.log(`   Topics: event, log, status, alert`)
    }
  })
})

mqttClient.on('error', (error) => {
  console.error('❌ MQTT error:', error)
})

mqttClient.on('reconnect', () => {
  console.log('🔄 MQTT reconnecting...')
})

// Relay MQTT messages to all WebSocket clients
mqttClient.on('message', (topic, payload) => {
  const payloadString = payload.toString()
  const message = {
    topic,
    payload: payloadString,
    timestamp: new Date().toISOString(),
  }

  console.log(`📨 Received from MQTT: ${topic}`)
  
  // ================================================================================
  // AUTO WHATSAPP NOTIFICATION ON FIRE/GAS EVENTS
  // ================================================================================
  
  // Check for event topic (lab/zaks/event) - fire detection events
  if (topic === TOPIC_EVENT || topic.includes('/event')) {
    try {
      const eventData = JSON.parse(payloadString)
      console.log(`🔍 Event data:`, eventData)
      
      // Fire/flame detection
      if (eventData.event === 'flame_on' || eventData.type === 'fire' || eventData.flame === true) {
        console.log('🔥 FIRE EVENT DETECTED! Triggering WhatsApp notification...')
        processAlertEvent(topic, payloadString)
      }
    } catch (e) {
      // Not JSON, ignore
    }
  }
  
  // Check for log/telemetry topic (lab/zaks/log) - sensor data with gas readings
  if (topic === TOPIC_LOG || topic.includes('/log')) {
    try {
      const telemetryData = JSON.parse(payloadString)
      
      // Log current gas level for debugging
      if (telemetryData.gasA !== undefined) {
        const gasLevel = telemetryData.gasA
        const threshold = GAS_DANGER_THRESHOLD
        const percent = ((gasLevel / 4095) * 100).toFixed(1)
        
        // Only log every 10th reading or when near threshold
        if (gasLevel >= threshold * 0.8) {
          console.log(`⚠️ GAS LEVEL HIGH: ${gasLevel}/4095 (${percent}%) - Threshold: ${threshold}`)
        }
        
        // Check for dangerous gas level
        if (gasLevel >= threshold) {
          console.log(`\n🚨🚨🚨 DANGEROUS GAS LEVEL DETECTED! 🚨🚨🚨`)
          console.log(`   gasA = ${gasLevel} (threshold = ${threshold})`)
          console.log(`   Triggering WhatsApp notification...`)
          processAlertEvent(topic, payloadString)
        }
      }
      
      // Check for flame detection from sensor
      if (telemetryData.flame === true) {
        console.log(`\n🔥🔥🔥 FLAME DETECTED FROM SENSOR! 🔥🔥🔥`)
        console.log(`   Triggering WhatsApp notification...`)
        processAlertEvent(topic, payloadString)
      }
      
      // Check for alarm flag
      if (telemetryData.alarm === true || telemetryData.alarm === 1) {
        console.log(`\n🚨 ALARM FLAG DETECTED in telemetry!`)
        processAlertEvent(topic, payloadString)
      }
    } catch (e) {
      // Not JSON, ignore
    }
  }
  
  // Check for alert topic (lab/zaks/alert) - direct alerts
  if (topic === TOPIC_ALERT || topic.includes('/alert')) {
    console.log('🚨 ALERT TOPIC MESSAGE! Processing...')
    processAlertEvent(topic, payloadString)
  }
  
  // ================================================================================
  
  // Handle ESP32-CAM IP announcements
  if (topic === TOPIC_ESP32CAM_IP) {
    try {
      const data = JSON.parse(payloadString)
      const cameraId = data.chipId || data.id || 'esp32cam-default'
      
      esp32Streams.set(cameraId, {
        ip: data.ip,
        streamUrl: data.stream_url || `http://${data.ip}:81/stream`,
        lastSeen: Date.now(),
        status: 'online',
        ...data
      })
      
      console.log(`📹 ESP32-CAM registered: ${cameraId} -> ${data.ip}`)
      
      // Broadcast to stream clients
      const streamMessage = {
        type: 'camera-registered',
        cameraId,
        data: data,
        timestamp: new Date().toISOString()
      }
      
      streamClients.forEach(client => {
        if (client.readyState === 1) {
          client.send(JSON.stringify(streamMessage))
        }
      })
      
    } catch (error) {
      console.error('Error parsing ESP32-CAM IP announcement:', error)
    }
  }
  
  // Handle stream data if needed
  if (topic === TOPIC_STREAM) {
    // Forward stream data to WebSocket clients
    const streamMessage = {
      type: 'stream-data',
      data: payloadString,
      timestamp: new Date().toISOString()
    }
    
    streamClients.forEach(client => {
      if (client.readyState === 1) {
        client.send(JSON.stringify(streamMessage))
      }
    })
  }
  console.log(`   Payload: ${payloadString}`)
  console.log(`   Clients: ${wsClients.size} connected`)

  // Broadcast to all connected WebSocket clients
  let sentCount = 0
  wsClients.forEach((client) => {
    if (client.readyState === 1) { // WebSocket.OPEN = 1
      client.send(JSON.stringify(message))
      sentCount++
    }
  })
  console.log(`   ✅ Sent to ${sentCount} WebSocket clients\n`)
})

// Handle WebSocket connections
wss.on('connection', (ws, req) => {
  console.log('🔌 New WebSocket client connected')
  
  // Check if this is a stream client
  const isStreamClient = req.url?.includes('stream') || false
  
  if (isStreamClient) {
    streamClients.add(ws)
    console.log('📹 Stream client connected')
    
    // Send available cameras
    const cameras = Array.from(esp32Streams.entries()).map(([id, data]) => ({
      id, ip: data.ip, streamUrl: data.streamUrl, status: data.status
    }))
    
    ws.send(JSON.stringify({
      type: 'cameras-list',
      cameras: cameras,
      timestamp: new Date().toISOString()
    }))
  } else {
    wsClients.add(ws)
    console.log('📡 MQTT client connected')
  }

  // Send connection success message
  ws.send(JSON.stringify({
    type: 'connected',
    message: isStreamClient ? 'Connected to Stream proxy' : 'Connected to MQTT proxy',
    timestamp: new Date().toISOString(),
  }))

  // Handle messages from WebSocket clients (commands)
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data)
      
      if (message.type === 'publish' && message.topic && message.payload) {
        console.log(`📤 Publishing to MQTT: ${message.topic}`)
        mqttClient.publish(message.topic, message.payload, { qos: 1 })
      }
      
      if (message.type === 'subscribe-stream' && message.cameraId) {
        console.log(`📹 Client subscribing to stream: ${message.cameraId}`)
        // Mark this client as interested in specific camera stream
        ws.subscribedCamera = message.cameraId
      }
      
    } catch (error) {
      console.error('❌ Error handling WebSocket message:', error)
    }
  })

  // Handle client disconnect
  ws.on('close', () => {
    console.log('🔌 WebSocket client disconnected')
    wsClients.delete(ws)
    streamClients.delete(ws)
  })

  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error)
    wsClients.delete(ws)
    streamClients.delete(ws)
  })
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('⏹️  Shutting down gracefully...')
  
  wss.clients.forEach((client) => {
    client.close()
  })
  
  mqttClient.end()
  server.close(() => {
    console.log('👋 Server closed')
    process.exit(0)
  })
})

console.log(`
╔═══════════════════════════════════════════════════════════╗
║          MQTT WebSocket Proxy Server                      ║
║                                                           ║
║  WebSocket endpoint: ws://localhost:${PORT}/ws              ║
║  Health check: http://localhost:${PORT}/health             ║
║                                                           ║
║  Relaying topics (lab/zaks/#):                           ║
║  - ${TOPIC_EVENT.padEnd(48)} ║
║  - ${TOPIC_LOG.padEnd(48)} ║
║  - ${TOPIC_STATUS.padEnd(48)} ║
║  - ${TOPIC_ALERT.padEnd(48)} ║
╚═══════════════════════════════════════════════════════════╝
`)
