import express from 'express';
import cors from 'cors';
import mqtt from 'mqtt';
import twilio from 'twilio';
import { config } from 'dotenv';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
config({ path: path.join(__dirname, '.env') });

const app = express();
const PORT = process.env.VOICE_CALL_PORT || 3002;

// CORS Configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:5173'];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
app.use(express.json());

// State
let emergencyCallNumbers = [];
let mqttClient = null;
let lastVoiceCallTime = 0;
const VOICE_CALL_COOLDOWN = 120000; // 2 minutes

// Load emergency call numbers from file
function loadEmergencyCallNumbers() {
  try {
    const callNumbersFile = path.join(__dirname, 'emergency-call-numbers.json');
    if (fs.existsSync(callNumbersFile)) {
      const data = fs.readFileSync(callNumbersFile, 'utf8');
      emergencyCallNumbers = JSON.parse(data);
      console.log(`📞 Loaded ${emergencyCallNumbers.length} emergency call numbers`);
    }
  } catch (err) {
    console.error('Error loading emergency call numbers:', err.message);
  }
}

// Save emergency call numbers to file
function saveEmergencyCallNumbers() {
  try {
    const callNumbersFile = path.join(__dirname, 'emergency-call-numbers.json');
    fs.writeFileSync(callNumbersFile, JSON.stringify(emergencyCallNumbers, null, 2));
  } catch (err) {
    console.error('Error saving emergency call numbers:', err.message);
  }
}

// MQTT Configuration
const MQTT_CONFIG = {
  host: process.env.MQTT_HOST,
  port: parseInt(process.env.MQTT_PORT || '1883'),
  username: process.env.MQTT_USER,
  password: process.env.MQTT_PASSWORD,
};

// Twilio Configuration
const TWILIO_CONFIG = {
  accountSid: process.env.TWILIO_ACCOUNT_SID,
  authToken: process.env.TWILIO_AUTH_TOKEN,
  phoneNumber: process.env.TWILIO_PHONE_NUMBER,
  voiceUrl: process.env.TWILIO_VOICE_URL || 'https://demo.twilio.com/welcome/voice/',
};

// Initialize Twilio Client
let twilioClient = null;
let twilioEnabled = false;

if (TWILIO_CONFIG.accountSid && TWILIO_CONFIG.authToken && TWILIO_CONFIG.phoneNumber) {
  try {
    twilioClient = twilio(TWILIO_CONFIG.accountSid, TWILIO_CONFIG.authToken);
    twilioEnabled = true;
    console.log('✅ Twilio Voice Call initialized');
    console.log(`   Phone: ${TWILIO_CONFIG.phoneNumber}`);
  } catch (err) {
    console.error('⚠️  Twilio initialization failed:', err.message);
    twilioEnabled = false;
  }
} else {
  console.log('⚠️  Twilio Voice Call disabled (missing credentials in .env)');
}

// Initialize MQTT
function initMQTT() {
  if (!MQTT_CONFIG.host || !MQTT_CONFIG.username || !MQTT_CONFIG.password) {
    console.log('⚠️  MQTT disabled (missing credentials)');
    return;
  }

  mqttClient = mqtt.connect(`mqtt://${MQTT_CONFIG.host}:${MQTT_CONFIG.port}`, {
    username: MQTT_CONFIG.username,
    password: MQTT_CONFIG.password,
    clientId: `voice-call-server-${Date.now()}`,
  });

  mqttClient.on('connect', () => {
    console.log('✅ MQTT Connected');
    
    // Subscribe to fire photo topic
    mqttClient.subscribe('lab/zaks/fire_photo', (err) => {
      if (err) {
        console.error('❌ MQTT Subscription error:', err);
      } else {
        console.log('📥 Subscribed to: lab/zaks/fire_photo');
      }
    });
  });

  mqttClient.on('message', async (topic, message) => {
    try {
      const data = JSON.parse(message.toString());
      
      // Handle fire detection with voice call
      if (topic === 'lab/zaks/fire_photo' && twilioEnabled && emergencyCallNumbers.length > 0) {
        await handleFireDetectionWithVoiceCall(data);
      }
    } catch (err) {
      console.error('Error processing MQTT message:', err);
    }
  });

  mqttClient.on('error', (err) => {
    console.error('❌ MQTT Error:', err.message);
  });
}

// Handle Fire Detection with Emergency Voice Call
async function handleFireDetectionWithVoiceCall(data) {
  if (!twilioEnabled || !twilioClient) {
    console.log('⚠️  Twilio not enabled - skipping voice calls');
    return;
  }

  if (emergencyCallNumbers.length === 0) {
    console.log('⚠️  No emergency call numbers configured');
    return;
  }

  console.log('📞 Handling fire detection with emergency voice calls...');

  const { detection } = data;

  // Check cooldown to prevent spam
  const now = Date.now();
  if ((now - lastVoiceCallTime) < VOICE_CALL_COOLDOWN) {
    console.log(`⏳ Voice call cooldown active. Skipping call (${Math.round((VOICE_CALL_COOLDOWN - (now - lastVoiceCallTime)) / 1000)}s remaining)`);
    return;
  }
  lastVoiceCallTime = now;

  // Build voice message data
  const confidencePercent = (detection.confidence * 100).toFixed(0);
  const location = detection.cameraId || 'Unknown location';
  const timestamp = new Date(detection.timestamp).toLocaleString('en-US');

  console.log(`🔥 Fire Detection Details:`);
  console.log(`   Confidence: ${confidencePercent}%`);
  console.log(`   Location: ${location}`);
  console.log(`   Camera IP: ${detection.cameraIp}`);
  console.log(`   Time: ${timestamp}`);

  // Build TwiML message (inline - works without public URL)
  const twimlMessage = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="Polly.Joanna">
    Emergency Alert! Fire detected with ${confidencePercent} percent confidence at ${location}.
    This is an automated emergency call from the Fire Detection System.
    Please check the camera location immediately and take appropriate action.
    Fire confidence level is ${confidencePercent} percent.
  </Say>
  <Pause length="1"/>
  <Say voice="Polly.Joanna">
    I repeat: Fire detected at ${location}. Confidence: ${confidencePercent} percent. Respond immediately!
  </Say>
</Response>`;

  // Make calls to all emergency numbers
  const callResults = [];
  for (const callNumber of emergencyCallNumbers) {
    try {
      const toNumber = callNumber.phoneNumber.startsWith('+') 
        ? callNumber.phoneNumber 
        : `+${callNumber.phoneNumber}`;

      console.log(`📞 Calling ${callNumber.name || toNumber}...`);

      // Try inline TwiML first (works without public URL)
      const call = await twilioClient.calls.create({
        to: toNumber,
        from: TWILIO_CONFIG.phoneNumber,
        twiml: twimlMessage,  // Inline TwiML - no public URL needed!
        timeout: 60,  // Wait 60 seconds for answer
      });

      console.log(`✅ Emergency call initiated to ${callNumber.name || toNumber}`);
      console.log(`   Call SID: ${call.sid}`);
      console.log(`   Status: ${call.status}`);
      console.log(`   Direction: ${call.direction}`);
      
      callResults.push({
        number: callNumber.phoneNumber,
        name: callNumber.name,
        sid: call.sid,
        status: call.status,
        success: true
      });
      
    } catch (err) {
      console.error(`❌ Failed to call ${callNumber.phoneNumber}:`, err.message);
      
      // Check for common errors
      if (err.message.includes('unverified') || err.message.includes('verify')) {
        console.error(`   ⚠️  This number is UNVERIFIED on trial account!`);
        console.error(`   📋 Verify at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified`);
      }
      
      callResults.push({
        number: callNumber.phoneNumber,
        name: callNumber.name,
        error: err.message,
        success: false
      });
    }
  }

  // Summary
  const successCount = callResults.filter(r => r.success).length;
  const failCount = callResults.filter(r => !r.success).length;
  
  console.log('\n✅ Emergency voice calls completed');
  console.log(`   Success: ${successCount}/${emergencyCallNumbers.length}`);
  if (failCount > 0) {
    console.log(`   Failed: ${failCount}`);
  }
  
  return callResults;
}

// ==================== API ENDPOINTS ====================

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok',
    service: 'voice-call-server',
    port: PORT,
    twilioEnabled,
    mqttConnected: mqttClient?.connected || false,
    emergencyNumbersCount: emergencyCallNumbers.length
  });
});

// Get emergency call numbers
app.get('/api/voice-call/numbers', (req, res) => {
  res.json({ 
    success: true,
    numbers: emergencyCallNumbers,
    twilioEnabled,
    cooldown: VOICE_CALL_COOLDOWN / 1000
  });
});

// Add emergency call number
app.post('/api/voice-call/numbers', (req, res) => {
  const { phoneNumber, name } = req.body;

  if (!phoneNumber) {
    return res.status(400).json({ error: 'Phone number required' });
  }

  if (!twilioEnabled) {
    return res.status(400).json({ error: 'Twilio not configured. Please add credentials to .env file' });
  }

  // Clean and validate phone number
  let cleanPhone = phoneNumber.replace(/[^0-9+]/g, '');
  
  // Add + if not present
  if (!cleanPhone.startsWith('+')) {
    cleanPhone = '+' + cleanPhone;
  }
  
  // Check if already exists
  const exists = emergencyCallNumbers.find(n => n.phoneNumber === cleanPhone);
  if (exists) {
    return res.status(400).json({ error: 'Phone number already added' });
  }

  const callNumber = {
    id: Date.now().toString(),
    phoneNumber: cleanPhone,
    name: name || cleanPhone,
    addedAt: Date.now(),
  };

  emergencyCallNumbers.push(callNumber);
  saveEmergencyCallNumbers();
  
  console.log(`📞 Added emergency call number: ${callNumber.name} (${callNumber.phoneNumber})`);
  
  res.json({ success: true, number: callNumber });
});

// Remove emergency call number
app.delete('/api/voice-call/numbers/:id', (req, res) => {
  const { id } = req.params;
  const initialLength = emergencyCallNumbers.length;
  emergencyCallNumbers = emergencyCallNumbers.filter((n) => n.id !== id);
  
  if (emergencyCallNumbers.length < initialLength) {
    saveEmergencyCallNumbers();
    console.log(`📞 Removed emergency call number: ${id}`);
    res.json({ success: true, message: 'Emergency call number removed' });
  } else {
    res.status(404).json({ error: 'Number not found' });
  }
});

// Test emergency call - Simple (Legacy)
app.post('/api/voice-call/test', async (req, res) => {
  const { phoneNumber, message } = req.body;

  if (!twilioEnabled || !twilioClient) {
    return res.status(400).json({ error: 'Twilio not enabled' });
  }

  if (!phoneNumber) {
    return res.status(400).json({ error: 'Phone number required' });
  }

  try {
    const toNumber = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;

    // Use custom message or default test message
    const testMessage = message || 'This is a test call from the Fire Detection Voice Call Server. If you can hear this message, the system is working correctly.';
    
    const twimlMessage = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="Polly.Joanna">${testMessage}</Say>
</Response>`;

    const call = await twilioClient.calls.create({
      to: toNumber,
      from: TWILIO_CONFIG.phoneNumber,
      twiml: twimlMessage,  // Inline TwiML - works without public URL!
      timeout: 60
    });

    console.log(`📞 Test call initiated to ${toNumber}`);
    console.log(`   Call SID: ${call.sid}`);
    console.log(`   Status: ${call.status}`);

    res.json({ 
      success: true, 
      callSid: call.sid,
      status: call.status,
      to: toNumber,
      from: TWILIO_CONFIG.phoneNumber,
      message: 'Test call initiated successfully'
    });
  } catch (err) {
    console.error('❌ Test call failed:', err);
    
    // Provide helpful error messages
    let errorMessage = err.message;
    if (err.message.includes('unverified') || err.message.includes('verify')) {
      errorMessage += ' - This number must be verified on your Twilio trial account. Visit: https://console.twilio.com/us1/develop/phone-numbers/manage/verified';
    }
    
    res.status(500).json({ 
      success: false, 
      error: errorMessage,
      code: err.code,
      moreInfo: err.moreInfo || null
    });
  }
});

// Advanced Test Call - 5 Test Methods
app.post('/api/voice-call/test-advanced', async (req, res) => {
  const { phoneNumber, testMethod, customMessage } = req.body;

  if (!twilioEnabled || !twilioClient) {
    return res.status(400).json({ 
      success: false,
      error: 'Twilio not enabled' 
    });
  }

  if (!phoneNumber) {
    return res.status(400).json({ 
      success: false,
      error: 'Phone number required' 
    });
  }

  if (!testMethod) {
    return res.status(400).json({ 
      success: false,
      error: 'Test method required (1-5)' 
    });
  }

  try {
    const toNumber = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;
    let call;
    let testDescription = '';
    let additionalInfo = {};

    console.log(`📞 Advanced Test Call - Method ${testMethod}`);
    console.log(`   To: ${toNumber}`);
    console.log(`   From: ${TWILIO_CONFIG.phoneNumber}`);

    switch (parseInt(testMethod)) {
      // TEST 1: Basic Call dengan TwiML String (Paling Simple)
      case 1:
        testDescription = 'Basic TwiML String - Emergency Fire Alert';
        const message1 = customMessage || 'Fire! Fire! Fire! Emergency! Fire detected! This is an automatic emergency call from the Fire Detection System.';
        
        call = await twilioClient.calls.create({
          twiml: `<Response><Say voice="Polly.Joanna">${message1}</Say></Response>`,
          to: toNumber,
          from: TWILIO_CONFIG.phoneNumber,
        });
        
        additionalInfo = {
          method: 'Inline TwiML',
          voice: 'Polly.Joanna',
          message: message1
        };
        break;

      // TEST 2: Call dengan URL (Demo Twilio)
      case 2:
        testDescription = 'TwiML URL - Demo Twilio Voice';
        
        call = await twilioClient.calls.create({
          url: 'http://demo.twilio.com/docs/voice.xml',
          to: toNumber,
          from: TWILIO_CONFIG.phoneNumber,
          method: 'GET'
        });
        
        additionalInfo = {
          method: 'TwiML URL',
          url: 'http://demo.twilio.com/docs/voice.xml',
          httpMethod: 'GET'
        };
        break;

      // TEST 3: Call dengan StatusCallback
      case 3:
        testDescription = 'TwiML with Status Callbacks';
        const message3 = customMessage || 'Test three. This call has status callbacks enabled for tracking.';
        
        call = await twilioClient.calls.create({
          twiml: `<Response><Say voice="Polly.Joanna" language="en-US">${message3}</Say></Response>`,
          to: toNumber,
          from: TWILIO_CONFIG.phoneNumber,
          statusCallback: `http://localhost:${PORT}/api/twilio/call-status`,
          statusCallbackEvent: ['initiated', 'ringing', 'answered', 'completed'],
          statusCallbackMethod: 'POST'
        });
        
        additionalInfo = {
          method: 'TwiML with Callbacks',
          statusCallback: `http://localhost:${PORT}/api/twilio/call-status`,
          events: ['initiated', 'ringing', 'answered', 'completed']
        };
        break;

      // TEST 4: Call dengan Recording
      case 4:
        testDescription = 'Call with Recording Enabled';
        const message4 = customMessage || 'Test four. This call is being recorded for quality assurance purposes.';
        
        call = await twilioClient.calls.create({
          twiml: `<Response><Say voice="Polly.Joanna">${message4}</Say></Response>`,
          to: toNumber,
          from: TWILIO_CONFIG.phoneNumber,
          record: true,
          recordingStatusCallback: `http://localhost:${PORT}/api/twilio/recording-status`,
          recordingStatusCallbackEvent: ['completed', 'in-progress']
        });
        
        additionalInfo = {
          method: 'TwiML with Recording',
          recording: true,
          recordingCallback: `http://localhost:${PORT}/api/twilio/recording-status`
        };
        break;

      // TEST 5: Call dengan Timeout Panjang
      case 5:
        testDescription = 'Extended Timeout (120 seconds)';
        const message5 = customMessage || 'Test five. This call has an extended timeout of two minutes.';
        
        call = await twilioClient.calls.create({
          twiml: `<Response><Say voice="Polly.Joanna">${message5}</Say></Response>`,
          to: toNumber,
          from: TWILIO_CONFIG.phoneNumber,
          timeout: 120  // Tunggu 2 menit
        });
        
        additionalInfo = {
          method: 'TwiML with Extended Timeout',
          timeout: 120,
          timeoutUnit: 'seconds'
        };
        break;

      default:
        return res.status(400).json({ 
          success: false,
          error: 'Invalid test method. Must be 1-5' 
        });
    }

    console.log(`✅ Test call created!`);
    console.log(`   Call SID: ${call.sid}`);
    console.log(`   Status: ${call.status}`);
    console.log(`   Test: ${testDescription}`);

    // Wait 8 seconds then check status
    setTimeout(async () => {
      try {
        const callStatus = await twilioClient.calls(call.sid).fetch();
        console.log(`📊 Call Status Update (8s later):`);
        console.log(`   SID: ${call.sid}`);
        console.log(`   Status: ${callStatus.status}`);
        console.log(`   Duration: ${callStatus.duration || 0}s`);
        
        if (callStatus.status === 'busy') {
          console.log(`   ⚠️  BUSY - Carrier block or number busy`);
        } else if (callStatus.status === 'completed') {
          console.log(`   ✅ COMPLETED - Call finished successfully`);
        } else if (callStatus.status === 'in-progress') {
          console.log(`   🎤 IN-PROGRESS - Call is active`);
        } else if (callStatus.status === 'no-answer') {
          console.log(`   📵 NO-ANSWER - Call not answered`);
        } else if (callStatus.status === 'failed') {
          console.log(`   ❌ FAILED - Error code: ${callStatus.errorCode}`);
        }
      } catch (err) {
        console.error(`❌ Error checking call status:`, err.message);
      }
    }, 8000);

    res.json({ 
      success: true, 
      callSid: call.sid,
      status: call.status,
      testMethod: parseInt(testMethod),
      testDescription: testDescription,
      to: toNumber,
      from: TWILIO_CONFIG.phoneNumber,
      additionalInfo: additionalInfo,
      message: `Test call initiated successfully - ${testDescription}`
    });
    
  } catch (err) {
    console.error('❌ Advanced test call failed:', err);
    
    // Provide helpful error messages
    let errorMessage = err.message;
    if (err.message.includes('unverified') || err.message.includes('verify')) {
      errorMessage += ' - This number must be verified on your Twilio trial account. Visit: https://console.twilio.com/us1/develop/phone-numbers/manage/verified';
    }
    
    res.status(500).json({ 
      success: false, 
      error: errorMessage,
      code: err.code,
      moreInfo: err.moreInfo || null
    });
  }
});

// TwiML endpoint for fire alert voice message
// NOTE: This endpoint is for testing or if you have a public URL
// For production with localhost, use inline TwiML in the call.create() method
app.post('/api/twilio/fire-alert-voice', (req, res) => {
  // Get fire detection data from request (if provided)
  const { confidence, location, cameraIp } = req.body || {};
  
  const confidenceText = confidence ? `with ${confidence} percent confidence` : '';
  const locationText = location || 'your location';
  
  res.type('text/xml');
  res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Joanna">
        Emergency Alert! Fire detected ${confidenceText} at ${locationText}.
        This is an automated emergency call from the Fire Detection System.
        Please check the location immediately and evacuate if necessary.
    </Say>
    <Pause length="1"/>
    <Say voice="Polly.Joanna">
        I repeat: Fire detected at ${locationText}. Respond immediately!
    </Say>
</Response>`);
});

// TwiML endpoint for testing (bilingual)
app.get('/api/twilio/test-voice', (req, res) => {
  res.type('text/xml');
  res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Joanna">
        This is a test call from the Fire Detection Voice Call Server.
    </Say>
    <Pause length="1"/>
    <Say voice="Polly.Joanna" language="id-ID">
        Ini adalah panggilan test dari sistem deteksi kebakaran.
    </Say>
</Response>`);
});

// Twilio webhook for call status updates
app.post('/api/twilio/call-status', (req, res) => {
  const { CallSid, CallStatus, To, From } = req.body;
  
  console.log(`📞 Call Status Update:`);
  console.log(`   SID: ${CallSid}`);
  console.log(`   Status: ${CallStatus}`);
  console.log(`   To: ${To}`);
  console.log(`   From: ${From}`);
  
  res.sendStatus(200);
});

// Get Twilio configuration status
app.get('/api/voice-call/config', (req, res) => {
  res.json({
    enabled: twilioEnabled,
    configured: !!(TWILIO_CONFIG.accountSid && TWILIO_CONFIG.authToken && TWILIO_CONFIG.phoneNumber),
    phoneNumber: twilioEnabled ? TWILIO_CONFIG.phoneNumber : null,
    voiceUrl: TWILIO_CONFIG.voiceUrl,
    emergencyNumbersCount: emergencyCallNumbers.length
  });
});

// Global error handlers
process.on('uncaughtException', (err) => {
  console.error('❌ UNCAUGHT EXCEPTION:', err);
  console.error('Stack:', err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ UNHANDLED REJECTION at:', promise);
  console.error('Reason:', reason);
});

// Start server with error handling
try {
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`📞 Voice Call Server (Twilio)`);
    console.log(`📡 Running on http://localhost:${PORT}`);
    console.log(`${'='.repeat(60)}\n`);
    
    // Load saved emergency call numbers
    loadEmergencyCallNumbers();
    
    // Initialize MQTT
    initMQTT();
    
    console.log('💡 API Endpoints:');
    console.log(`   GET  /health`);
    console.log(`   GET  /api/voice-call/config`);
    console.log(`   GET  /api/voice-call/numbers`);
    console.log(`   POST /api/voice-call/numbers`);
    console.log(`   DEL  /api/voice-call/numbers/:id`);
    console.log(`   POST /api/voice-call/test`);
    console.log(`   POST /api/voice-call/test-advanced\n`);
    
    console.log(`✅ Server started successfully!`);
    console.log(`   Twilio: ${twilioEnabled ? '✅ Enabled' : '❌ Disabled'}`);
    console.log(`   MQTT: ${mqttClient ? '🔄 Connecting...' : '❌ Disabled'}`);
    console.log(`   Emergency Numbers: ${emergencyCallNumbers.length}\n`);
  });

  server.on('error', (err) => {
    console.error('\n❌ SERVER ERROR:');
    console.error('Error:', err.message);
    
    if (err.code === 'EADDRINUSE') {
      console.error(`\n⚠️  Port ${PORT} is already in use!`);
      console.error('Solutions:');
      console.error('  1. Kill the process using port 3002:');
      console.error('     netstat -ano | findstr ":3002"');
      console.error('     taskkill /F /PID <PID>');
      console.error('  2. Change PORT in .env file\n');
    } else if (err.code === 'EACCES') {
      console.error(`\n⚠️  Permission denied on port ${PORT}`);
      console.error('Try running as administrator or use port > 1024\n');
    }
    
    process.exit(1);
  });
} catch (err) {
  console.error('\n❌ FAILED TO START SERVER:');
  console.error('Error:', err.message);
  console.error('Stack:', err.stack);
  
  console.error('\n🔍 Troubleshooting:');
  console.error('  1. Check .env file exists and has valid values');
  console.error('  2. Run: npm install');
  console.error('  3. Check port 3002 is available');
  console.error('  4. Check Node.js version: node --version (need v16+)\n');
  
  process.exit(1);
}
