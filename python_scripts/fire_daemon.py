#!/usr/bin/env python3
"""
Fire Detection Daemon - Auto Start/Stop based on ESP32-CAM status
=================================================================
- Listens to MQTT for ESP32-CAM online/offline events
- Auto-starts fire detection when camera comes online
- Auto-stops when camera goes offline or heartbeat timeout
- Uses Cloudflare Tunnel URL for reliable access
- Sends WhatsApp Group notifications via GOWA2 when fire detected

Run: python3 fire_daemon.py
"""

import paho.mqtt.client as mqtt
import requests
import cv2
import numpy as np
import time
import threading
import signal
import sys
import json
import os
import base64
from datetime import datetime

# Lazy load YOLO
YOLO = None

# ====== Configuration ======
MQTT_BROKER = os.getenv('MQTT_BROKER', '3.27.11.106')
MQTT_PORT = int(os.getenv('MQTT_PORT', 1883))
MQTT_USER = os.getenv('MQTT_USER', 'zaks')
MQTT_PASS = os.getenv('MQTT_PASSWORD', 'enggangodinginmcu')

TOPIC_IP = "lab/zaks/esp32cam/ip"
TOPIC_EVENT = "lab/zaks/event"
TOPIC_ALERT = "lab/zaks/fire/alert"
TOPIC_STATUS = "lab/zaks/fire/status"

# ESP32-CAM URLs - will be updated dynamically from MQTT
ESP32_URL_CLOUDFLARE = os.getenv('ESP32_CAM_URL', 'https://esp32cam.izinmok.my.id/capture')
ESP32_URL_PUBLIC = None  # Updated from MQTT broadcast
ESP32_URL_LOCAL = None   # Updated from MQTT broadcast
USE_PUBLIC_IP = os.getenv('USE_PUBLIC_IP', 'true').lower() == 'true'  # Prefer public IP over Cloudflare

# YOLO Model
MODEL_PATH = os.getenv('MODEL_PATH', '/home/ubuntu/rtsp-project/python_scripts/fire_yolov8s_ultra_best.pt')

# Detection settings
CONFIDENCE_THRESHOLD = float(os.getenv('CONF_THRESHOLD', 0.35))
DETECTION_INTERVAL = int(os.getenv('DETECT_INTERVAL', 5))  # seconds
HEARTBEAT_TIMEOUT = int(os.getenv('HEARTBEAT_TIMEOUT', 120))  # seconds

# ====== GOWA2 WhatsApp Group Notification ======
GOWA2_API_URL = os.getenv('GOWA2_API_URL', 'https://gowa2.flx.web.id')
BACKEND_API_URL = os.getenv('BACKEND_API_URL', 'http://localhost:8080')  # Backend server for alert groups config
WHATSAPP_GROUP_ENABLED = os.getenv('WHATSAPP_GROUP_ENABLED', 'true').lower() == 'true'
WHATSAPP_COOLDOWN = int(os.getenv('WHATSAPP_COOLDOWN', 60))  # seconds between group notifications
last_whatsapp_time = 0

# ====== Global State ======
camera_online = False
camera_info = {}
last_heartbeat = 0
detection_thread = None
stop_detection = threading.Event()
model = None
mqtt_client = None


def log(msg, level="INFO"):
    """Print with timestamp"""
    ts = datetime.now().strftime("%H:%M:%S")
    print(f"[{ts}] [{level}] {msg}")


# ====== WhatsApp Group Functions ======
def get_alert_groups():
    """Fetch alert groups configuration from backend"""
    try:
        response = requests.get(f"{BACKEND_API_URL}/api/alert-groups", timeout=10)
        if response.status_code == 200:
            data = response.json()
            groups = data.get('groups', [])
            enabled = data.get('fireAlertEnabled', False)
            log(f"📱 Loaded {len(groups)} alert groups (enabled: {enabled})")
            return groups, enabled
        else:
            log(f"Failed to fetch alert groups: {response.status_code}", "WARN")
    except requests.exceptions.ConnectionError:
        log(f"Backend not available at {BACKEND_API_URL}, trying local config", "WARN")
        # Try to load from local file as fallback
        local_config = '/home/ubuntu/rtsp-project/proxy-server/alert-groups.json'
        if os.path.exists(local_config):
            with open(local_config, 'r') as f:
                data = json.load(f)
                return data.get('groups', []), data.get('fireAlertEnabled', False)
    except Exception as e:
        log(f"Error fetching alert groups: {e}", "ERROR")
    return [], False


def get_whatsapp_recipients():
    """Fetch WhatsApp recipients from backend"""
    try:
        response = requests.get(f"{BACKEND_API_URL}/api/recipients", timeout=10)
        if response.status_code == 200:
            data = response.json()
            recipients = data.get('recipients', [])
            enabled = [r for r in recipients if r.get('enabled', True)]
            log(f"📱 Loaded {len(enabled)}/{len(recipients)} enabled recipients")
            return enabled
        else:
            log(f"Failed to fetch recipients: {response.status_code}", "WARN")
    except requests.exceptions.ConnectionError:
        log(f"Backend not available at {BACKEND_API_URL}", "WARN")
    except Exception as e:
        log(f"Error fetching recipients: {e}", "ERROR")
    return []


def send_whatsapp_alert_full(detections, image_path=None):
    """Send fire alert to both individual recipients AND WhatsApp Groups via GOWA2"""
    global last_whatsapp_time
    
    if not WHATSAPP_GROUP_ENABLED:
        log("WhatsApp notification disabled", "WARN")
        return False
    
    # Check cooldown
    now = time.time()
    if now - last_whatsapp_time < WHATSAPP_COOLDOWN:
        remaining = int(WHATSAPP_COOLDOWN - (now - last_whatsapp_time))
        log(f"⏳ WhatsApp cooldown active ({remaining}s remaining)")
        return False
    
    # Build alert message
    detection_text = "\n".join([
        f"  • {d['class']}: {d['confidence']*100:.1f}%"
        for d in detections
    ])
    
    message = f"""🚨 *PERINGATAN KEBAKARAN!* 🔥

*Lokasi:* VPS Fire Detection (ESP32-CAM)
*Waktu:* {datetime.now().strftime('%Y-%m-%d %H:%M:%S WIB')}
*Kamera:* {camera_info.get('id', 'esp32cam')}

*Detail Deteksi:*
{detection_text}

⚠️ Segera periksa lokasi!
🔗 Dashboard: http://3.27.11.106:5173

_Pesan otomatis dari Fire Detection Daemon_"""

    # Read image as base64 if available
    image_base64 = None
    if image_path and os.path.exists(image_path):
        try:
            with open(image_path, 'rb') as img_file:
                image_base64 = base64.b64encode(img_file.read()).decode('utf-8')
            log(f"📷 Image loaded: {os.path.basename(image_path)}")
        except Exception as e:
            log(f"Failed to read image: {e}", "WARN")
    
    total_success = 0
    last_whatsapp_time = now
    
    # ========================================
    # PART 1: Send to Individual Recipients
    # ========================================
    recipients = get_whatsapp_recipients()
    if recipients:
        log(f"\n{'='*60}")
        log(f"📤 SENDING TO {len(recipients)} INDIVIDUAL RECIPIENTS (GOWA2)")
        log(f"{'='*60}")
        
        for recipient in recipients:
            phone = recipient.get('phone', '').replace('+', '')
            name = recipient.get('name', phone)
            
            try:
                log(f"📤 Sending to: {name} ({phone})...")
                
                if image_base64:
                    response = requests.post(
                        f"{GOWA2_API_URL}/send/image",
                        json={'phone': phone, 'image': image_base64, 'caption': message},
                        timeout=30
                    )
                else:
                    response = requests.post(
                        f"{GOWA2_API_URL}/send/message",
                        json={'phone': phone, 'message': message},
                        timeout=30
                    )
                
                data = response.json()
                if response.status_code == 200 and data.get('code') == 'SUCCESS':
                    log(f"✅ SUCCESS: Sent to {name}")
                    total_success += 1
                else:
                    log(f"❌ FAILED: {name} - {data.get('message', str(data))}", "WARN")
                    
            except Exception as e:
                log(f"❌ ERROR: {name} - {e}", "ERROR")
            
            time.sleep(0.5)  # Delay between messages
    
    # ========================================
    # PART 2: Send to WhatsApp Groups
    # ========================================
    groups, groups_enabled = get_alert_groups()
    
    if groups_enabled:
        enabled_groups = [g for g in groups if g.get('enabled', True)]
        
        if enabled_groups:
            log(f"\n{'='*60}")
            log(f"📤 SENDING TO {len(enabled_groups)} WHATSAPP GROUPS (GOWA2)")
            log(f"{'='*60}")
            
            for group in enabled_groups:
                jid = group.get('jid', '')
                name = group.get('name', jid)
                
                try:
                    log(f"📤 Sending to group: {name} ({jid})...")
                    
                    if image_base64:
                        response = requests.post(
                            f"{GOWA2_API_URL}/send/image",
                            json={'phone': jid, 'image': image_base64, 'caption': message},
                            timeout=30
                        )
                    else:
                        response = requests.post(
                            f"{GOWA2_API_URL}/send/message",
                            json={'phone': jid, 'message': message},
                            timeout=30
                        )
                    
                    data = response.json()
                    if response.status_code == 200 and data.get('code') == 'SUCCESS':
                        log(f"✅ SUCCESS: Sent to group {name}")
                        total_success += 1
                    else:
                        log(f"❌ FAILED: {name} - {data.get('message', str(data))}", "WARN")
                        
                except Exception as e:
                    log(f"❌ ERROR: {name} - {e}", "ERROR")
                
                time.sleep(0.5)  # Delay between messages
        else:
            log("⚠️ No alert groups enabled")
    else:
        log("⚠️ Fire alert to groups is disabled in settings")
    
    log(f"\n{'='*60}")
    log(f"📊 TOTAL RESULTS: {total_success} messages sent successfully")
    log(f"{'='*60}\n")
    
    return total_success > 0


def load_model():
    """Load YOLO model lazily"""
    global model, YOLO
    if model is None:
        log("Loading YOLO model...")
        if YOLO is None:
            from ultralytics import YOLO as YOLOClass
            YOLO = YOLOClass
        model = YOLO(MODEL_PATH)
        log(f"Model loaded: {os.path.basename(MODEL_PATH)}")
    return model


def get_capture_url():
    """Get best available capture URL - prioritize Public IP > Cloudflare > Local"""
    global ESP32_URL_PUBLIC, ESP32_URL_LOCAL, ESP32_URL_CLOUDFLARE
    
    urls_to_try = []
    
    # Priority 1: Public IP (most reliable for VPS access)
    if USE_PUBLIC_IP and ESP32_URL_PUBLIC:
        urls_to_try.append((ESP32_URL_PUBLIC, "Public IP"))
    
    # Priority 2: Cloudflare tunnel
    urls_to_try.append((ESP32_URL_CLOUDFLARE, "Cloudflare"))
    
    # Priority 3: Local IP (usually not accessible from VPS)
    if ESP32_URL_LOCAL:
        urls_to_try.append((ESP32_URL_LOCAL, "Local IP"))
    
    return urls_to_try


def capture_image():
    """Capture image from ESP32-CAM - tries multiple URLs"""
    urls_to_try = get_capture_url()
    
    for url, source in urls_to_try:
        try:
            log(f"📸 Trying capture from {source}: {url}")
            resp = requests.get(url, timeout=15)
            
            if resp.status_code == 200 and len(resp.content) > 1000:
                img_array = np.frombuffer(resp.content, dtype=np.uint8)
                img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
                if img is not None:
                    log(f"✅ Captured from {source}: {len(resp.content)} bytes, {img.shape[1]}x{img.shape[0]}")
                    return img
                else:
                    log(f"❌ Failed to decode image from {source}", "WARN")
            else:
                log(f"❌ Bad response from {source}: {resp.status_code}, {len(resp.content)} bytes", "WARN")
                
        except requests.Timeout:
            log(f"⏱️ Timeout from {source} (15s)", "WARN")
        except requests.ConnectionError as e:
            log(f"🔌 Connection error from {source}: {e}", "WARN")
        except Exception as e:
            log(f"❌ Capture error from {source}: {e}", "ERROR")
    
    log("❌ All capture sources failed!", "ERROR")
    return None


def detect_fire(img):
    """Run YOLO fire detection"""
    global model
    if model is None:
        model = load_model()
    
    results = model(img, conf=CONFIDENCE_THRESHOLD, verbose=False)
    
    detections = []
    for r in results:
        for box in r.boxes:
            cls_id = int(box.cls[0])
            conf = float(box.conf[0])
            cls_name = model.names[cls_id]
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            detections.append({
                'class': cls_name,
                'confidence': round(conf, 3),
                'bbox': [x1, y1, x2, y2]
            })
    
    return detections, results


def send_alert(detections, img_path=None):
    """Send fire alert via MQTT and WhatsApp (individuals + groups)"""
    global mqtt_client
    
    # 1. Send via MQTT (existing behavior)
    if mqtt_client and mqtt_client.is_connected():
        alert = {
            'event': 'FIRE_DETECTED',
            'detections': detections,
            'image': img_path,
            'camera': camera_info.get('id', 'esp32cam'),
            'timestamp': datetime.now().isoformat(),
        }
        mqtt_client.publish(TOPIC_ALERT, json.dumps(alert), retain=False)
        log(f"🚨 MQTT ALERT SENT: {len(detections)} detection(s)")
    
    # 2. Send to WhatsApp (individuals + groups) via GOWA2
    try:
        wa_result = send_whatsapp_alert_full(detections, img_path)
        if wa_result:
            log("✅ WhatsApp notification(s) sent!")
    except Exception as e:
        log(f"WhatsApp notification error: {e}", "ERROR")


def update_status(status, message=""):
    """Update daemon status via MQTT"""
    global mqtt_client
    if mqtt_client and mqtt_client.is_connected():
        payload = {
            'status': status,
            'message': message,
            'camera_online': camera_online,
            'timestamp': datetime.now().isoformat()
        }
        mqtt_client.publish(TOPIC_STATUS, json.dumps(payload), retain=True)


def detection_loop():
    """Main detection loop - runs while camera is online"""
    global camera_online, stop_detection
    
    log("🔥 Fire detection loop STARTED")
    update_status("running", "Detection active")
    
    # Load model at start
    load_model()
    
    consecutive_failures = 0
    max_failures = 5
    detection_count = 0
    fire_count = 0
    
    while not stop_detection.is_set() and camera_online:
        try:
            # Capture image
            img = capture_image()
            
            if img is None:
                consecutive_failures += 1
                if consecutive_failures >= max_failures:
                    log(f"Too many failures ({consecutive_failures}), stopping...", "ERROR")
                    break
                stop_detection.wait(DETECTION_INTERVAL)
                continue
            
            consecutive_failures = 0
            detection_count += 1
            
            # Run detection
            detections, results = detect_fire(img)
            
            if detections:
                fire_count += 1
                log(f"🚨 FIRE DETECTED!")
                for d in detections:
                    log(f"   └─ {d['class']}: {d['confidence']*100:.1f}%")
                
                # Save detection image
                annotated = results[0].plot()
                filename = f"/tmp/fire_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
                cv2.imwrite(filename, annotated)
                log(f"   └─ Saved: {filename}")
                
                send_alert(detections, filename)
            else:
                log(f"✅ Safe (#{detection_count})")
            
            # Wait before next capture
            stop_detection.wait(DETECTION_INTERVAL)
            
        except Exception as e:
            log(f"Detection error: {e}", "ERROR")
            stop_detection.wait(DETECTION_INTERVAL)
    
    log(f"🛑 Detection loop STOPPED (detections: {detection_count}, fires: {fire_count})")
    update_status("stopped", "Detection stopped")


def start_detection():
    """Start fire detection in background thread"""
    global detection_thread, stop_detection, camera_online
    
    if detection_thread and detection_thread.is_alive():
        log("Detection already running")
        return
    
    camera_online = True
    stop_detection.clear()
    detection_thread = threading.Thread(target=detection_loop, daemon=True)
    detection_thread.start()
    log("🟢 Detection thread started")


def stop_detection_thread():
    """Stop fire detection"""
    global detection_thread, stop_detection, camera_online
    
    log("Stopping detection...")
    camera_online = False
    stop_detection.set()
    
    if detection_thread:
        detection_thread.join(timeout=5)
        detection_thread = None
    
    log("🔴 Detection stopped")
    update_status("stopped", "Camera offline")


# ====== MQTT Callbacks ======
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        log("✅ MQTT Connected to broker")
        client.subscribe(TOPIC_IP)
        client.subscribe(TOPIC_EVENT)
        log(f"   └─ Subscribed: {TOPIC_IP}")
        log(f"   └─ Subscribed: {TOPIC_EVENT}")
        update_status("waiting", "Waiting for camera")
    else:
        log(f"❌ MQTT Connection failed: {rc}", "ERROR")


def on_message(client, userdata, msg):
    global camera_online, camera_info, last_heartbeat, ESP32_URL_PUBLIC, ESP32_URL_LOCAL
    
    try:
        payload = json.loads(msg.payload.decode())
        
        if msg.topic == TOPIC_IP:
            # Camera IP announcement (retained message)
            camera_info = payload
            last_heartbeat = time.time()
            
            # Extract and update capture URLs from broadcast
            public_ip = payload.get('public_ip', payload.get('publicIp', ''))
            local_ip = payload.get('local_ip', payload.get('localIp', ''))
            stream_url = payload.get('stream_url', payload.get('streamUrl', ''))
            
            # Build capture URLs from broadcast data
            if public_ip:
                # Remove /stream suffix and add /capture
                if ':' in public_ip:
                    ESP32_URL_PUBLIC = f"http://{public_ip}/capture"
                else:
                    ESP32_URL_PUBLIC = f"http://{public_ip}:8081/capture"
                log(f"📡 Updated Public URL: {ESP32_URL_PUBLIC}")
            
            if local_ip:
                if ':' in local_ip:
                    ESP32_URL_LOCAL = f"http://{local_ip}/capture"
                else:
                    ESP32_URL_LOCAL = f"http://{local_ip}:81/capture"
                log(f"📡 Updated Local URL: {ESP32_URL_LOCAL}")
            
            log(f"📡 Camera announcement:")
            log(f"   └─ ID: {payload.get('id', 'unknown')}")
            log(f"   └─ Public: {public_ip or 'N/A'}")
            log(f"   └─ Local: {local_ip or 'N/A'}")
            log(f"   └─ RSSI: {payload.get('rssi', '?')} dBm")
            
            if not camera_online:
                log("🟢 Camera ONLINE - Starting detection...")
                start_detection()
                
        elif msg.topic == TOPIC_EVENT:
            event = payload.get('event', '')
            
            if event == 'esp32cam_online':
                log("🟢 ESP32-CAM came ONLINE")
                last_heartbeat = time.time()
                camera_info = payload
                if not camera_online:
                    start_detection()
                    
            elif event == 'heartbeat':
                last_heartbeat = time.time()
                rssi = payload.get('rssi', '?')
                uptime = payload.get('uptime', 0)
                log(f"💓 Heartbeat (RSSI: {rssi} dBm, uptime: {uptime}s)")
                
    except json.JSONDecodeError:
        pass  # Ignore non-JSON messages
    except Exception as e:
        log(f"Message error: {e}", "ERROR")


def on_disconnect(client, userdata, rc):
    log(f"⚠️ MQTT Disconnected (rc={rc})", "WARN")


def heartbeat_monitor():
    """Monitor heartbeat and stop detection if camera offline"""
    global camera_online, last_heartbeat
    
    log("Heartbeat monitor started")
    
    while True:
        time.sleep(30)
        
        if camera_online and last_heartbeat > 0:
            elapsed = time.time() - last_heartbeat
            if elapsed > HEARTBEAT_TIMEOUT:
                log(f"⚠️ No heartbeat for {elapsed:.0f}s - Camera OFFLINE", "WARN")
                stop_detection_thread()
                last_heartbeat = 0


def signal_handler(sig, frame):
    """Handle Ctrl+C"""
    log("\n🛑 Shutting down daemon...")
    stop_detection_thread()
    if mqtt_client:
        update_status("offline", "Daemon stopped")
        mqtt_client.disconnect()
    sys.exit(0)


def main():
    global mqtt_client
    
    print()
    print("=" * 60)
    print("🔥 FIRE DETECTION DAEMON v2.0")
    print("=" * 60)
    print(f"  MQTT Broker:  {MQTT_BROKER}:{MQTT_PORT}")
    print(f"  Cloudflare:   {ESP32_URL_CLOUDFLARE}")
    print(f"  Use Public:   {'✅ Yes' if USE_PUBLIC_IP else '❌ No'}")
    print(f"  Model:        {os.path.basename(MODEL_PATH)}")
    print(f"  Interval:     {DETECTION_INTERVAL}s")
    print(f"  Timeout:      {HEARTBEAT_TIMEOUT}s")
    print()
    print("  📱 WhatsApp Group Notification:")
    print(f"     GOWA2:     {GOWA2_API_URL}")
    print(f"     Backend:   {BACKEND_API_URL}")
    print(f"     Enabled:   {'✅ Yes' if WHATSAPP_GROUP_ENABLED else '❌ No'}")
    print(f"     Cooldown:  {WHATSAPP_COOLDOWN}s")
    print()
    print("  📡 Capture URL Priority:")
    print("     1. Public IP (from MQTT broadcast)")
    print("     2. Cloudflare Tunnel")
    print("     3. Local IP (usually not accessible)")
    print("=" * 60)
    print()
    print("Waiting for ESP32-CAM to come online...")
    print("(Camera broadcasts IP via MQTT every 30s)")
    print()
    
    # Setup signal handler
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Start heartbeat monitor
    monitor = threading.Thread(target=heartbeat_monitor, daemon=True)
    monitor.start()
    
    # Setup MQTT
    mqtt_client = mqtt.Client(client_id="fire-daemon-vps")
    mqtt_client.username_pw_set(MQTT_USER, MQTT_PASS)
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.on_disconnect = on_disconnect
    
    # Reconnect loop
    while True:
        try:
            log("Connecting to MQTT broker...")
            mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
            mqtt_client.loop_forever()
        except KeyboardInterrupt:
            break
        except Exception as e:
            log(f"MQTT error: {e}", "ERROR")
            log("Reconnecting in 5s...")
            time.sleep(5)


if __name__ == "__main__":
    main()
