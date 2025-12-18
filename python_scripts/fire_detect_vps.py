#!/usr/bin/env python3
"""
🔥 FIRE DETECTION VPS - HEADLESS MODE
======================================
Script deteksi api untuk dijalankan di VPS tanpa display.
Fitur:
- Auto IP detection via MQTT dari ESP32-CAM
- YOLO fire detection (CPU mode)
- Gemini AI verification
- Auto upload foto ke Fire Gallery
- Auto upload video ke Recordings
- WhatsApp notification via GOWA
- MQTT alert broadcast
- WebSocket logging ke dashboard

Author: Fire Detection System
Version: 4.0 (VPS Headless)
"""

import cv2
import numpy as np
import time
import os
import json
import requests
import base64
import threading
import signal
import sys
import argparse
from queue import Queue, Empty
from datetime import datetime
import traceback

# ============================================================================
# ARGUMENT PARSER
# ============================================================================
parser = argparse.ArgumentParser(description='Fire Detection VPS - Headless Mode')
parser.add_argument('--stream-url', type=str, help='ESP32-CAM stream URL (override MQTT)')
parser.add_argument('--camera-ip', type=str, help='ESP32-CAM IP address')
parser.add_argument('--model', type=str, help='YOLO model path')
parser.add_argument('--conf', type=float, default=0.35, help='YOLO confidence threshold')
parser.add_argument('--no-gemini', action='store_true', help='Disable Gemini verification')
parser.add_argument('--no-record', action='store_true', help='Disable video recording')
parser.add_argument('--no-whatsapp', action='store_true', help='Disable WhatsApp notifications')
parser.add_argument('--debug', action='store_true', help='Enable debug logging')
args = parser.parse_args()

# ============================================================================
# IMPORTS WITH FALLBACKS
# ============================================================================

try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError:
    print("❌ ultralytics not installed! Run: pip install ultralytics")
    sys.exit(1)

try:
    import paho.mqtt.client as mqtt
    try:
        from paho.mqtt.enums import CallbackAPIVersion
        MQTT_V2 = True
    except ImportError:
        MQTT_V2 = False
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False
    print("⚠️  paho-mqtt not installed - MQTT disabled")

try:
    from dotenv import load_dotenv
    load_dotenv()
except:
    pass

print("\n" + "="*70)
print("🔥 FIRE DETECTION VPS - HEADLESS MODE")
print("="*70)
print(f"   Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print(f"   Python: {sys.version.split()[0]}")
print(f"   OpenCV: {cv2.__version__}")
print("="*70 + "\n")

# ============================================================================
# CONFIGURATION
# ============================================================================

# VPS API Configuration
VPS_API_BASE = os.getenv('VPS_API_BASE', 'http://localhost:8080')
FIRE_DETECTION_API = f"{VPS_API_BASE}/api/fire-detection"
VIDEO_UPLOAD_API = f"{VPS_API_BASE}/api/video/upload"

# MQTT Configuration
MQTT_BROKER = os.getenv('MQTT_BROKER', '3.27.11.106')
MQTT_PORT = int(os.getenv('MQTT_PORT', 1883))
MQTT_USER = os.getenv('MQTT_USER', 'zaks')
MQTT_PASSWORD = os.getenv('MQTT_PASSWORD', 'enggangodinginmcu')
MQTT_TOPIC_IP = "lab/zaks/esp32cam/ip"
MQTT_TOPIC_ALERT = "lab/zaks/alert"
MQTT_TOPIC_EVENT = "lab/zaks/event"
MQTT_TOPIC_LOG = "lab/zaks/log"

# ESP32-CAM (from args or MQTT)
ESP32_CAM_IP = args.camera_ip or os.getenv('ESP32_CAM_IP')
STREAM_URL = args.stream_url or os.getenv('ESP32_CAM_STREAM')

# Model Configuration
MODEL_PATH = args.model or os.getenv('MODEL_PATH')
MODEL_PATHS = [
    "/home/ubuntu/rtsp-project/python_scripts/fire_yolov8s_ultra_best.pt",
    "/home/ubuntu/rtsp-project/python_scripts/fire_yolov8n_best.pt",
    os.path.join(os.path.dirname(__file__), "fire_yolov8s_ultra_best.pt"),
    os.path.join(os.path.dirname(__file__), "fire_yolov8n_best.pt"),
    "fire_yolov8s_ultra_best.pt",
    "fire_yolov8n_best.pt",
]

# Find model
if MODEL_PATH is None:
    for path in MODEL_PATHS:
        if os.path.exists(path):
            MODEL_PATH = path
            break

if MODEL_PATH is None or not os.path.exists(MODEL_PATH):
    print(f"❌ YOLO model not found!")
    print(f"   Searched paths:")
    for p in MODEL_PATHS:
        print(f"   - {p}")
    sys.exit(1)

print(f"✅ Model: {MODEL_PATH}")

# Detection Parameters
CONF_THRESHOLD = args.conf
MIN_AREA = 200
ENABLE_COLOR_VALIDATION = True
MIN_ORANGE_RED_RATIO = 0.15
MAX_WHITE_RATIO = 0.60

# Gemini Configuration
ENABLE_GEMINI = not args.no_gemini
GEMINI_API_KEY = os.getenv("GOOGLE_API_KEY", os.getenv("GEMINI_API_KEY", ""))
GEMINI_MODEL = "gemini-2.0-flash-lite"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
GEMINI_SCORE_THRESHOLD = 0.50

if ENABLE_GEMINI and not GEMINI_API_KEY:
    print("⚠️  Gemini API key not set - verification disabled")
    ENABLE_GEMINI = False

# Recording Configuration
ENABLE_RECORDING = not args.no_record
RECORD_DIR = os.getenv('RECORD_DIR', '/tmp/fire_recordings')
RECORD_DURATION = 30
RECORD_FPS = 15
RECORD_COOLDOWN = 60

os.makedirs(RECORD_DIR, exist_ok=True)

# WhatsApp/GOWA Configuration
ENABLE_WHATSAPP = not args.no_whatsapp
GOWA_API_URL = os.getenv('GOWA_API_URL', 'https://gowa2.flx.web.id')
GOWA_AUTH = os.getenv('GOWA_AUTH', 'Basic YWRtaW46R293YTJBZG1pbjIwMjU=')

# Alert Cooldowns
ALERT_COOLDOWN = 5.0
WHATSAPP_COOLDOWN = 60
UPLOAD_COOLDOWN = 10

# ============================================================================
# GLOBAL STATE
# ============================================================================

mqtt_client = None
camera_discovered = threading.Event()
stop_detection = threading.Event()
detection_running = False

# Camera info
camera_info = {
    "ip": ESP32_CAM_IP,
    "stream_url": STREAM_URL,
    "id": "unknown"
}

# Timing
last_alert_time = 0
last_whatsapp_time = 0
last_record_time = 0
last_upload_time = 0

# Stats
stats = {
    "frames_processed": 0,
    "yolo_detections": 0,
    "color_rejected": 0,
    "gemini_verified": 0,
    "gemini_rejected": 0,
    "photos_uploaded": 0,
    "videos_recorded": 0,
    "whatsapp_sent": 0,
    "start_time": time.time()
}

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

def signal_handler(signum, frame):
    """Handle shutdown signals"""
    print(f"\n\n🛑 Received signal {signum}, shutting down...")
    stop_detection.set()

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# ============================================================================
# MQTT FUNCTIONS
# ============================================================================

def on_mqtt_connect(client, userdata, flags, rc):
    """MQTT connection callback"""
    if rc == 0:
        print(f"✅ MQTT connected to {MQTT_BROKER}")
        client.subscribe(MQTT_TOPIC_IP)
        print(f"📡 Subscribed: {MQTT_TOPIC_IP}")
    else:
        print(f"❌ MQTT connection failed: {rc}")

def on_mqtt_message(client, userdata, msg):
    """MQTT message callback"""
    global camera_info
    
    try:
        if msg.topic == MQTT_TOPIC_IP:
            payload = json.loads(msg.payload.decode())
            
            cam_ip = payload.get("ip")
            cam_stream = payload.get("stream_url")
            cam_id = payload.get("id", payload.get("chipId", "unknown"))
            
            if cam_ip and cam_stream:
                camera_info = {
                    "ip": cam_ip,
                    "stream_url": cam_stream,
                    "id": cam_id,
                    "ssid": payload.get("ssid", "N/A"),
                    "rssi": payload.get("rssi", 0)
                }
                
                print(f"\n📸 Camera discovered: {cam_id}")
                print(f"   IP: {cam_ip}")
                print(f"   Stream: {cam_stream}")
                
                camera_discovered.set()
                
    except Exception as e:
        if args.debug:
            print(f"⚠️  MQTT parse error: {e}")

def setup_mqtt():
    """Setup MQTT connection"""
    global mqtt_client
    
    if not MQTT_AVAILABLE:
        return False
    
    print(f"\n[MQTT] Connecting to {MQTT_BROKER}:{MQTT_PORT}...")
    
    try:
        import uuid
        client_id = f"fire_vps_{uuid.uuid4().hex[:8]}"
        
        if MQTT_V2:
            mqtt_client = mqtt.Client(
                callback_api_version=CallbackAPIVersion.VERSION1,
                client_id=client_id
            )
        else:
            mqtt_client = mqtt.Client(client_id)
        
        mqtt_client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
        mqtt_client.on_connect = on_mqtt_connect
        mqtt_client.on_message = on_mqtt_message
        
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        return True
    except Exception as e:
        print(f"❌ MQTT error: {e}")
        return False

def publish_mqtt(topic, data):
    """Publish to MQTT"""
    if mqtt_client and mqtt_client.is_connected():
        try:
            payload = json.dumps(data) if isinstance(data, dict) else str(data)
            mqtt_client.publish(topic, payload)
            return True
        except Exception as e:
            if args.debug:
                print(f"⚠️  MQTT publish error: {e}")
    return False

def send_fire_alert(confidence, gemini_verified=False, gemini_score=0):
    """Send fire alert via MQTT"""
    alert_data = {
        "event": "fire_detected",
        "source": "fire_detector_vps",
        "timestamp": int(time.time() * 1000),
        "camera_id": camera_info.get("id", "unknown"),
        "camera_ip": camera_info.get("ip", "unknown"),
        "yolo_confidence": round(confidence, 3),
        "gemini_verified": gemini_verified,
        "gemini_score": round(gemini_score, 3) if gemini_score else None
    }
    
    publish_mqtt(MQTT_TOPIC_ALERT, alert_data)
    publish_mqtt(MQTT_TOPIC_EVENT, alert_data)

# ============================================================================
# COLOR VALIDATION
# ============================================================================

def validate_fire_color(roi):
    """Validate fire by color analysis"""
    if roi is None or roi.size == 0:
        return False, "Empty ROI", {}
    
    try:
        hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
        total_pixels = roi.shape[0] * roi.shape[1]
        
        # Fire colors (red/orange/yellow)
        masks = []
        masks.append(cv2.inRange(hsv, np.array([0, 100, 100]), np.array([10, 255, 255])))
        masks.append(cv2.inRange(hsv, np.array([170, 100, 100]), np.array([180, 255, 255])))
        masks.append(cv2.inRange(hsv, np.array([10, 100, 100]), np.array([25, 255, 255])))
        masks.append(cv2.inRange(hsv, np.array([25, 100, 100]), np.array([35, 255, 255])))
        
        fire_mask = masks[0]
        for m in masks[1:]:
            fire_mask = fire_mask | m
        
        fire_ratio = cv2.countNonZero(fire_mask) / total_pixels
        
        # White detection (lights)
        gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        _, white_mask = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)
        white_ratio = cv2.countNonZero(white_mask) / total_pixels
        
        avg_sat = np.mean(hsv[:, :, 1])
        
        stats = {
            "fire_ratio": round(fire_ratio * 100, 1),
            "white_ratio": round(white_ratio * 100, 1),
            "saturation": round(avg_sat, 1)
        }
        
        if white_ratio > MAX_WHITE_RATIO:
            return False, f"Too white ({white_ratio*100:.0f}%)", stats
        
        if fire_ratio < MIN_ORANGE_RED_RATIO:
            return False, f"Low fire colors ({fire_ratio*100:.0f}%)", stats
        
        if avg_sat < 50:
            return False, f"Low saturation ({avg_sat:.0f})", stats
        
        return True, f"Fire colors OK ({fire_ratio*100:.0f}%)", stats
        
    except Exception as e:
        return True, f"Color check error: {e}", {}

# ============================================================================
# GEMINI VERIFICATION
# ============================================================================

def verify_with_gemini(frame):
    """Verify fire with Gemini AI"""
    if not ENABLE_GEMINI:
        return None, None, "Disabled"
    
    try:
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 80])
        image_b64 = base64.b64encode(buffer).decode('utf-8')
        
        prompt = """Analyze this image for REAL FIRE detection.
REAL FIRE: Actual flames, smoke, burning materials, flickering fire
FALSE POSITIVE: LED lights, lamps, reflections, orange objects, sunset

Response in JSON only:
{"is_fire": true/false, "confidence": 0.0-1.0, "reason": "brief reason"}"""
        
        payload = {
            "contents": [{
                "parts": [
                    {"text": prompt},
                    {"inline_data": {"mime_type": "image/jpeg", "data": image_b64}}
                ]
            }],
            "generationConfig": {"temperature": 0.1, "maxOutputTokens": 150}
        }
        
        response = requests.post(
            f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            text = data['candidates'][0]['content']['parts'][0]['text']
            
            import re
            match = re.search(r'\{[^{}]+\}', text, re.DOTALL)
            if match:
                result = json.loads(match.group())
                return (
                    result.get("is_fire", False),
                    result.get("confidence", 0),
                    result.get("reason", "")
                )
        
        return None, None, f"API error: {response.status_code}"
        
    except Exception as e:
        return None, None, str(e)

# ============================================================================
# API UPLOAD FUNCTIONS
# ============================================================================

def upload_fire_detection(frame, confidence, bbox, gemini_score=None, gemini_reason=None, gemini_verified=False):
    """Upload fire detection to backend API"""
    global last_upload_time, stats
    
    current_time = time.time()
    if current_time - last_upload_time < UPLOAD_COOLDOWN:
        return False
    
    try:
        # Encode frame
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
        
        # Prepare multipart form data
        files = {
            'snapshot': ('fire_detection.jpg', buffer.tobytes(), 'image/jpeg')
        }
        
        data = {
            'confidence': str(confidence),
            'bbox': json.dumps(bbox),
            'cameraIp': camera_info.get('ip', 'unknown'),
            'cameraId': camera_info.get('id', 'esp32cam_vps'),
            'yoloModel': os.path.basename(MODEL_PATH),
            'geminiScore': str(gemini_score) if gemini_score else '',
            'geminiReason': gemini_reason or '',
            'geminiVerified': 'true' if gemini_verified else 'false'
        }
        
        response = requests.post(
            FIRE_DETECTION_API,
            files=files,
            data=data,
            timeout=15
        )
        
        if response.status_code == 200 or response.status_code == 201:
            result = response.json()
            print(f"   📸 Photo uploaded: {result.get('detection', {}).get('id', 'OK')}")
            stats["photos_uploaded"] += 1
            last_upload_time = current_time
            return True
        else:
            print(f"   ⚠️  Upload failed: {response.status_code}")
            if args.debug:
                print(f"      Response: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"   ⚠️  Upload error: {e}")
        return False

def upload_video(filepath, camera_ip, start_time, duration):
    """Upload recorded video to backend"""
    global stats
    
    try:
        if not os.path.exists(filepath):
            return False
        
        file_size = os.path.getsize(filepath)
        print(f"   📤 Uploading video: {os.path.basename(filepath)} ({file_size/1024/1024:.1f} MB)")
        
        with open(filepath, 'rb') as f:
            files = {
                'video': (os.path.basename(filepath), f, 'video/mp4')
            }
            data = {
                'cameraIp': camera_ip,
                'startTime': str(int(start_time * 1000)),
                'duration': str(duration)
            }
            
            response = requests.post(
                VIDEO_UPLOAD_API,
                files=files,
                data=data,
                timeout=120
            )
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✅ Video uploaded: {result.get('file', {}).get('filename', 'OK')}")
            stats["videos_recorded"] += 1
            
            # Delete local file after successful upload
            try:
                os.remove(filepath)
            except:
                pass
            
            return True
        else:
            print(f"   ⚠️  Video upload failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"   ⚠️  Video upload error: {e}")
        return False

# ============================================================================
# WHATSAPP NOTIFICATION
# ============================================================================

def send_whatsapp_alert(frame, confidence, gemini_verified=False):
    """Send WhatsApp alert via GOWA"""
    global last_whatsapp_time, stats
    
    if not ENABLE_WHATSAPP:
        return False
    
    current_time = time.time()
    if current_time - last_whatsapp_time < WHATSAPP_COOLDOWN:
        return False
    
    try:
        # Get recipients from backend
        resp = requests.get(f"{VPS_API_BASE}/api/recipients", timeout=5)
        if resp.status_code != 200:
            print("   ⚠️  Failed to get recipients")
            return False
        
        recipients = resp.json().get('recipients', [])
        enabled_recipients = [r for r in recipients if r.get('enabled', True)]
        
        if not enabled_recipients:
            print("   ⚠️  No enabled recipients")
            return False
        
        # Encode image
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
        image_b64 = base64.b64encode(buffer).decode('utf-8')
        
        timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        
        message = f"""🔥 *FIRE DETECTED - VPS ALERT!*

⚠️ *DANGEROUS CONDITION DETECTED*

📊 *Detection Details:*
• YOLO Confidence: *{confidence*100:.1f}%*
• Gemini Verified: *{'✅ Yes' if gemini_verified else '❌ No'}*

📹 *Camera:* {camera_info.get('id', 'ESP32-CAM')}
🌐 *IP:* {camera_info.get('ip', 'Unknown')}
⏰ *Time:* {timestamp}

⚡ *Please check immediately!*

_Sent from Fire Detection VPS_"""
        
        success_count = 0
        for recipient in enabled_recipients:
            phone = recipient.get('phone', '').replace('+', '')
            
            try:
                # Send image with caption
                resp = requests.post(
                    f"{GOWA_API_URL}/send/image",
                    headers={
                        'Content-Type': 'application/json',
                        'Authorization': GOWA_AUTH
                    },
                    json={
                        'phone': phone,
                        'image': image_b64,
                        'caption': message
                    },
                    timeout=30
                )
                
                if resp.status_code == 200 and resp.json().get('code') == 'SUCCESS':
                    success_count += 1
                    print(f"   📱 WhatsApp sent to {recipient.get('name', phone)}")
                    
            except Exception as e:
                if args.debug:
                    print(f"   ⚠️  WhatsApp error for {phone}: {e}")
        
        if success_count > 0:
            last_whatsapp_time = current_time
            stats["whatsapp_sent"] += success_count
            return True
            
        return False
        
    except Exception as e:
        print(f"   ⚠️  WhatsApp error: {e}")
        return False

# ============================================================================
# VIDEO RECORDING
# ============================================================================

def record_fire_video(stream_url, camera_ip):
    """Record video when fire detected"""
    global stats
    
    if not ENABLE_RECORDING:
        return
    
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"fire_{timestamp}.mp4"
        filepath = os.path.join(RECORD_DIR, filename)
        
        print(f"   🎬 Recording started: {filename}")
        
        cap = cv2.VideoCapture(stream_url)
        if not cap.isOpened():
            print(f"   ❌ Failed to open stream for recording")
            return
        
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)) or 640
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)) or 480
        
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(filepath, fourcc, RECORD_FPS, (width, height))
        
        start_time = time.time()
        frames_written = 0
        
        while time.time() - start_time < RECORD_DURATION and not stop_detection.is_set():
            ret, frame = cap.read()
            if ret:
                out.write(frame)
                frames_written += 1
            else:
                time.sleep(0.05)
        
        duration = time.time() - start_time
        
        cap.release()
        out.release()
        
        print(f"   ✅ Recording saved: {filepath}")
        print(f"      Frames: {frames_written}, Duration: {duration:.1f}s")
        
        # Upload to server
        upload_video(filepath, camera_ip, start_time, int(duration))
        
    except Exception as e:
        print(f"   ❌ Recording error: {e}")
        traceback.print_exc()

# ============================================================================
# MAIN DETECTION LOOP
# ============================================================================

def run_detection():
    """Main fire detection loop"""
    global detection_running, last_alert_time, last_record_time, stats
    
    stream_url = camera_info.get('stream_url')
    camera_ip = camera_info.get('ip')
    
    if not stream_url:
        print("❌ No stream URL available")
        return
    
    print(f"\n🎬 Starting fire detection...")
    print(f"   Stream: {stream_url}")
    print(f"   Camera IP: {camera_ip}")
    print(f"   Model: {MODEL_PATH}")
    print(f"   Confidence threshold: {CONF_THRESHOLD}")
    
    # Load YOLO model
    print(f"   Loading YOLO model...")
    try:
        model = YOLO(MODEL_PATH)
        print(f"   ✅ Model loaded")
    except Exception as e:
        print(f"   ❌ Model load error: {e}")
        return
    
    # Connect to stream
    print(f"   Connecting to stream...")
    cap = cv2.VideoCapture(stream_url)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    
    retry_count = 0
    while not cap.isOpened() and retry_count < 5:
        print(f"   ⚠️  Connection failed, retrying ({retry_count+1}/5)...")
        time.sleep(2)
        cap = cv2.VideoCapture(stream_url)
        retry_count += 1
    
    if not cap.isOpened():
        print(f"   ❌ Failed to connect to stream")
        return
    
    print(f"   ✅ Stream connected!")
    detection_running = True
    
    # Send MQTT status
    publish_mqtt(MQTT_TOPIC_EVENT, {
        "event": "detection_started",
        "source": "fire_detector_vps",
        "camera_ip": camera_ip,
        "stream_url": stream_url,
        "timestamp": int(time.time() * 1000)
    })
    
    print("\n" + "="*60)
    print("🔥 FIRE DETECTION RUNNING (HEADLESS VPS MODE)")
    print("="*60)
    print("   Press Ctrl+C to stop")
    print("="*60 + "\n")
    
    frame_count = 0
    fps_time = time.time()
    fps = 0
    reconnect_attempts = 0
    
    while not stop_detection.is_set():
        ret, frame = cap.read()
        
        if not ret:
            reconnect_attempts += 1
            if reconnect_attempts > 10:
                print("\n⚠️  Too many reconnection attempts, waiting 30s...")
                time.sleep(30)
                reconnect_attempts = 0
            
            print(f"⚠️  Stream error, reconnecting ({reconnect_attempts})...")
            cap.release()
            time.sleep(2)
            cap = cv2.VideoCapture(stream_url)
            continue
        
        reconnect_attempts = 0
        frame_count += 1
        stats["frames_processed"] += 1
        current_time = time.time()
        
        # Calculate FPS
        if current_time - fps_time >= 10.0:
            fps = frame_count / (current_time - fps_time)
            frame_count = 0
            fps_time = current_time
            
            # Log stats periodically
            uptime = current_time - stats["start_time"]
            print(f"📊 Stats: FPS={fps:.1f} | Frames={stats['frames_processed']} | "
                  f"Detections={stats['yolo_detections']} | Verified={stats['gemini_verified']} | "
                  f"Photos={stats['photos_uploaded']} | Videos={stats['videos_recorded']} | "
                  f"Uptime={uptime/60:.1f}min")
        
        # Run YOLO detection
        results = model(frame, conf=CONF_THRESHOLD, verbose=False)
        
        fire_detected = False
        best_detection = None
        
        for r in results:
            for box in r.boxes:
                conf = float(box.conf[0])
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                area = (x2 - x1) * (y2 - y1)
                
                if area < MIN_AREA:
                    continue
                
                stats["yolo_detections"] += 1
                
                # Color validation
                if ENABLE_COLOR_VALIDATION:
                    roi = frame[y1:y2, x1:x2]
                    is_valid, reason, color_stats = validate_fire_color(roi)
                    
                    if not is_valid:
                        stats["color_rejected"] += 1
                        if args.debug:
                            print(f"   🎨 Color rejected: {reason}")
                        continue
                
                fire_detected = True
                if best_detection is None or conf > best_detection["conf"]:
                    best_detection = {
                        "conf": conf,
                        "bbox": [x1, y1, x2, y2],
                        "area": area
                    }
        
        # Process fire detection
        if fire_detected and best_detection:
            if current_time - last_alert_time >= ALERT_COOLDOWN:
                print(f"\n🔥 FIRE DETECTED! Confidence: {best_detection['conf']:.0%}")
                
                # Gemini verification
                gemini_verified = False
                gemini_score = None
                gemini_reason = None
                
                if ENABLE_GEMINI:
                    is_fire, gemini_score, gemini_reason = verify_with_gemini(frame)
                    
                    if is_fire is not None:
                        if is_fire and gemini_score >= GEMINI_SCORE_THRESHOLD:
                            gemini_verified = True
                            stats["gemini_verified"] += 1
                            print(f"   ✅ Gemini VERIFIED: {gemini_score:.0%} - {gemini_reason}")
                        else:
                            stats["gemini_rejected"] += 1
                            print(f"   ❌ Gemini REJECTED: {gemini_score:.0%} - {gemini_reason}")
                    else:
                        print(f"   ⚠️  Gemini error: {gemini_reason}")
                
                # Send MQTT alert
                send_fire_alert(best_detection["conf"], gemini_verified, gemini_score)
                
                # Upload photo to Fire Gallery
                upload_fire_detection(
                    frame,
                    best_detection["conf"],
                    best_detection["bbox"],
                    gemini_score,
                    gemini_reason,
                    gemini_verified
                )
                
                # WhatsApp notification (only if Gemini verified or Gemini disabled)
                if gemini_verified or not ENABLE_GEMINI:
                    send_whatsapp_alert(frame, best_detection["conf"], gemini_verified)
                    
                    # Start video recording
                    if ENABLE_RECORDING and current_time - last_record_time >= RECORD_COOLDOWN:
                        threading.Thread(
                            target=record_fire_video,
                            args=(stream_url, camera_ip),
                            daemon=True
                        ).start()
                        last_record_time = current_time
                
                last_alert_time = current_time
    
    # Cleanup
    detection_running = False
    cap.release()
    
    # Send stop event
    publish_mqtt(MQTT_TOPIC_EVENT, {
        "event": "detection_stopped",
        "source": "fire_detector_vps",
        "timestamp": int(time.time() * 1000)
    })
    
    print("\n✅ Detection stopped")

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

def main():
    """Main entry point"""
    global camera_info
    
    print("\n" + "="*60)
    print("🔥 FIRE DETECTION VPS - HEADLESS MODE")
    print("="*60)
    
    # Check if stream URL provided via args
    if STREAM_URL:
        print(f"   Using provided stream URL: {STREAM_URL}")
        camera_info["stream_url"] = STREAM_URL
        if ESP32_CAM_IP:
            camera_info["ip"] = ESP32_CAM_IP
    else:
        # Setup MQTT and wait for camera
        if setup_mqtt():
            print(f"\n⏳ Waiting for ESP32-CAM broadcast via MQTT...")
            print(f"   Topic: {MQTT_TOPIC_IP}")
            
            if camera_discovered.wait(timeout=120):
                print(f"   ✅ Camera discovered!")
            else:
                print(f"\n❌ Timeout! No camera discovered via MQTT")
                print(f"   Use --stream-url to specify manually")
                return
        else:
            print(f"\n❌ MQTT setup failed and no stream URL provided")
            print(f"   Use --stream-url to specify manually")
            return
    
    # Verify stream URL
    if not camera_info.get("stream_url"):
        print("❌ No stream URL available")
        return
    
    # Start detection
    try:
        run_detection()
    except KeyboardInterrupt:
        print("\n\n🛑 Interrupted by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        traceback.print_exc()
    finally:
        # Cleanup
        stop_detection.set()
        
        if mqtt_client:
            mqtt_client.loop_stop()
            mqtt_client.disconnect()
        
        # Print final stats
        print("\n" + "="*60)
        print("📊 FINAL STATISTICS")
        print("="*60)
        uptime = time.time() - stats["start_time"]
        print(f"   Uptime: {uptime/60:.1f} minutes")
        print(f"   Frames processed: {stats['frames_processed']}")
        print(f"   YOLO detections: {stats['yolo_detections']}")
        print(f"   Color rejected: {stats['color_rejected']}")
        print(f"   Gemini verified: {stats['gemini_verified']}")
        print(f"   Gemini rejected: {stats['gemini_rejected']}")
        print(f"   Photos uploaded: {stats['photos_uploaded']}")
        print(f"   Videos recorded: {stats['videos_recorded']}")
        print(f"   WhatsApp sent: {stats['whatsapp_sent']}")
        print("="*60)

if __name__ == "__main__":
    main()
