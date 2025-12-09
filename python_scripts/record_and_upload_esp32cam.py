"""
ESP32-CAM Video Recording & Upload Script
Saves MJPEG stream to local file, then uploads to web server
"""

import cv2
import requests
import time
from datetime import datetime
import os

# Configuration
ESP32_CAM_IP = "10.148.218.219"  # Change to your ESP32-CAM IP
STREAM_URL = f"http://{ESP32_CAM_IP}:81/stream"
UPLOAD_API = "http://localhost:8080/api/video/upload"
SAVE_DIR = "D:/esp32cam_recordings"  # Local save directory

# Recording settings
RECORD_DURATION = 60  # seconds (0 = unlimited)
OUTPUT_FORMAT = ".mp4"
FOURCC = cv2.VideoWriter_fourcc(*'mp4v')
FPS = 20  # Target FPS

# Create save directory
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)
    print(f"📁 Created directory: {SAVE_DIR}")

def record_video():
    """Record video from ESP32-CAM MJPEG stream"""
    
    print(f"\n{'='*70}")
    print(f"📹 ESP32-CAM Video Recording Script")
    print(f"{'='*70}")
    print(f"Stream URL: {STREAM_URL}")
    print(f"Save Directory: {SAVE_DIR}")
    print(f"Duration: {RECORD_DURATION}s ({RECORD_DURATION/60:.1f} minutes)")
    print(f"Target FPS: {FPS}")
    print(f"{'='*70}\n")
    
    # Generate filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"esp32cam_{timestamp}{OUTPUT_FORMAT}"
    filepath = os.path.join(SAVE_DIR, filename)
    
    print(f"📝 Recording to: {filename}")
    print(f"⏳ Connecting to ESP32-CAM...")
    
    # Open MJPEG stream
    cap = cv2.VideoCapture(STREAM_URL)
    
    if not cap.isOpened():
        print(f"❌ ERROR: Cannot connect to ESP32-CAM")
        print(f"   Check:")
        print(f"   1. ESP32-CAM is powered on")
        print(f"   2. IP address is correct: {ESP32_CAM_IP}")
        print(f"   3. Computer and ESP32-CAM on same network")
        print(f"   4. Test URL in browser: {STREAM_URL}")
        return None
    
    # Get frame dimensions
    ret, frame = cap.read()
    if not ret:
        print(f"❌ ERROR: Cannot read frame from stream")
        cap.release()
        return None
    
    height, width = frame.shape[:2]
    print(f"✅ Connected! Stream resolution: {width}x{height}")
    
    # Create video writer
    writer = cv2.VideoWriter(filepath, FOURCC, FPS, (width, height))
    
    print(f"🎬 Recording started...")
    start_time = time.time()
    frame_count = 0
    
    try:
        while True:
            ret, frame = cap.read()
            
            if not ret:
                print(f"\n⚠️  Warning: Lost connection to stream")
                break
            
            # Write frame
            writer.write(frame)
            frame_count += 1
            
            # Display progress every second
            elapsed = time.time() - start_time
            if frame_count % FPS == 0:
                remaining = RECORD_DURATION - elapsed if RECORD_DURATION > 0 else 0
                print(f"\r⏱️  Recording: {int(elapsed)}s | Frames: {frame_count} | FPS: {frame_count/elapsed:.1f}", end="")
                
                if RECORD_DURATION > 0 and remaining <= 0:
                    break
            
            # Stop on 'q' key (if display window is open)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                print(f"\n⏹️  Stopped by user")
                break
                
    except KeyboardInterrupt:
        print(f"\n⏹️  Recording interrupted by user")
    
    finally:
        # Cleanup
        cap.release()
        writer.release()
        cv2.destroyAllWindows()
        
        elapsed = time.time() - start_time
        file_size = os.path.getsize(filepath) / (1024 * 1024)  # MB
        
        print(f"\n\n{'='*70}")
        print(f"✅ Recording Complete!")
        print(f"{'='*70}")
        print(f"📝 File: {filename}")
        print(f"📁 Path: {filepath}")
        print(f"⏱️  Duration: {elapsed:.1f}s")
        print(f"🎞️  Frames: {frame_count}")
        print(f"📊 Avg FPS: {frame_count/elapsed:.1f}")
        print(f"💾 Size: {file_size:.2f} MB")
        print(f"{'='*70}\n")
        
        return filepath, {
            'cameraIp': ESP32_CAM_IP,
            'startTime': int(start_time * 1000),
            'duration': int(elapsed)
        }

def upload_video(filepath, metadata):
    """Upload recorded video to web server"""
    
    if not filepath or not os.path.exists(filepath):
        print(f"❌ ERROR: Video file not found: {filepath}")
        return False
    
    print(f"📤 Uploading to web server...")
    print(f"   API: {UPLOAD_API}")
    print(f"   File: {os.path.basename(filepath)}")
    
    try:
        # Prepare multipart form data
        files = {
            'video': open(filepath, 'rb')
        }
        
        data = {
            'cameraIp': metadata['cameraIp'],
            'startTime': metadata['startTime'],
            'duration': metadata['duration']
        }
        
        # Upload
        response = requests.post(UPLOAD_API, files=files, data=data, timeout=300)
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Upload successful!")
                print(f"   Server path: {result['file']['path']}")
                print(f"   File size: {result['file']['size'] / (1024*1024):.2f} MB")
                return True
            else:
                print(f"❌ Upload failed: {result.get('error', 'Unknown error')}")
                return False
        else:
            print(f"❌ Upload failed: HTTP {response.status_code}")
            print(f"   Response: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ Upload timeout (>5 minutes)")
        print(f"   File too large or network too slow")
        return False
    except Exception as e:
        print(f"❌ Upload error: {e}")
        return False
    finally:
        files['video'].close()

def main():
    """Main execution flow"""
    
    print(f"\n🚀 Starting ESP32-CAM Video Recording System\n")
    
    # Step 1: Record video
    result = record_video()
    
    if not result:
        print(f"\n❌ Recording failed. Exiting.")
        return
    
    filepath, metadata = result
    
    # Step 2: Upload video
    print(f"\n")
    upload_success = upload_video(filepath, metadata)
    
    if upload_success:
        print(f"\n🎉 Process completed successfully!")
        print(f"   ✅ Video recorded: {filepath}")
        print(f"   ✅ Video uploaded to web server")
        print(f"\n📺 View on dashboard:")
        print(f"   http://localhost:5173/live-stream → Recordings tab")
    else:
        print(f"\n⚠️  Video recorded but upload failed")
        print(f"   File saved locally: {filepath}")
        print(f"   You can manually upload later")
    
    print(f"\n{'='*70}\n")

if __name__ == "__main__":
    main()
