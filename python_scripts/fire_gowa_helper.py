"""
🔥 Fire Detection - Go-WhatsApp (GOWA) API Helper
=================================================

This module provides functions to send fire detection alerts
via Go-WhatsApp REST API (https://github.com/aldinokemal/go-whatsapp-web-multidevice)

Replaces the old Baileys-based WhatsApp helper.

Features:
- Send text messages
- Send images with captions
- Check connection status
- Get recipients from localStorage sync

Usage:
    from fire_gowa_helper import send_fire_alert, check_gowa_connection

Author: GitHub Copilot
Date: December 17, 2025
"""

import os
import json
import base64
import requests
from datetime import datetime
from typing import Optional, Tuple, List, Dict

# ============================================================================
# CONFIGURATION
# ============================================================================

# GOWA API Configuration - No hardcoded URLs
# Default to localhost:3000 (GOWA default port)
# In production, use proxy at port 8080
GOWA_API_URL = os.getenv('GOWA_API_URL', 'http://localhost:3000')

# Recipients file (synced from frontend localStorage)
RECIPIENTS_FILE = os.path.join(os.path.dirname(__file__), 'gowa_recipients.json')

# Request timeout
REQUEST_TIMEOUT = 30

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_gowa_url() -> str:
    """Get GOWA API URL from environment or default"""
    return os.getenv('GOWA_API_URL', GOWA_API_URL)


def check_gowa_connection() -> Tuple[bool, str]:
    """
    Check if GOWA server is connected to WhatsApp
    
    Returns:
        Tuple[bool, str]: (is_connected, message)
    """
    try:
        url = f"{get_gowa_url()}/app/devices"
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('code') == 'SUCCESS' and data.get('results'):
                devices = data['results']
                if len(devices) > 0:
                    return True, f"Connected: {devices[0].get('name', 'Unknown')}"
            return False, "Not connected to WhatsApp"
        else:
            return False, f"Server error: {response.status_code}"
            
    except requests.exceptions.ConnectionError:
        return False, "GOWA server not running"
    except requests.exceptions.Timeout:
        return False, "Connection timeout"
    except Exception as e:
        return False, f"Error: {str(e)}"


def load_recipients() -> List[Dict]:
    """
    Load recipients from JSON file
    
    Returns:
        List[Dict]: List of recipient objects with phoneNumber and name
    """
    try:
        if os.path.exists(RECIPIENTS_FILE):
            with open(RECIPIENTS_FILE, 'r') as f:
                return json.load(f)
    except Exception as e:
        print(f"⚠️  Error loading recipients: {e}")
    
    return []


def save_recipients(recipients: List[Dict]) -> bool:
    """
    Save recipients to JSON file
    
    Args:
        recipients: List of recipient objects
        
    Returns:
        bool: Success status
    """
    try:
        with open(RECIPIENTS_FILE, 'w') as f:
            json.dump(recipients, f, indent=2)
        return True
    except Exception as e:
        print(f"⚠️  Error saving recipients: {e}")
        return False


def format_phone_for_gowa(phone: str) -> str:
    """
    Format phone number for GOWA API
    628xxx -> 628xxx@s.whatsapp.net
    
    Args:
        phone: Phone number (e.g., 628123456789)
        
    Returns:
        str: Formatted phone (e.g., 628123456789@s.whatsapp.net)
    """
    # Remove non-numeric characters
    clean = ''.join(filter(str.isdigit, phone))
    return f"{clean}@s.whatsapp.net"


# ============================================================================
# SEND MESSAGE FUNCTIONS
# ============================================================================

def send_text_message(phone: str, message: str) -> Tuple[bool, str]:
    """
    Send text message via GOWA API
    
    Args:
        phone: Recipient phone number (628xxx)
        message: Message text
        
    Returns:
        Tuple[bool, str]: (success, message)
    """
    try:
        url = f"{get_gowa_url()}/send/message"
        payload = {
            "phone": format_phone_for_gowa(phone),
            "message": message
        }
        
        response = requests.post(
            url,
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=REQUEST_TIMEOUT
        )
        
        data = response.json()
        
        if data.get('code') == 'SUCCESS':
            return True, "Message sent successfully"
        else:
            return False, data.get('message', 'Failed to send')
            
    except requests.exceptions.ConnectionError:
        return False, "GOWA server not running"
    except requests.exceptions.Timeout:
        return False, "Request timeout"
    except Exception as e:
        return False, f"Error: {str(e)}"


def send_image_message(
    phone: str,
    image_path: str,
    caption: str = ""
) -> Tuple[bool, str]:
    """
    Send image with caption via GOWA API
    
    Args:
        phone: Recipient phone number (628xxx)
        image_path: Path to image file
        caption: Optional caption text
        
    Returns:
        Tuple[bool, str]: (success, message)
    """
    try:
        if not os.path.exists(image_path):
            return False, f"Image not found: {image_path}"
        
        url = f"{get_gowa_url()}/send/image"
        
        with open(image_path, 'rb') as f:
            files = {
                'image': (os.path.basename(image_path), f, 'image/jpeg')
            }
            data = {
                'phone': format_phone_for_gowa(phone),
                'caption': caption
            }
            
            response = requests.post(
                url,
                files=files,
                data=data,
                timeout=REQUEST_TIMEOUT
            )
        
        result = response.json()
        
        if result.get('code') == 'SUCCESS':
            return True, "Image sent successfully"
        else:
            return False, result.get('message', 'Failed to send image')
            
    except requests.exceptions.ConnectionError:
        return False, "GOWA server not running"
    except requests.exceptions.Timeout:
        return False, "Request timeout"
    except Exception as e:
        return False, f"Error: {str(e)}"


def send_image_base64(
    phone: str,
    image_base64: str,
    caption: str = ""
) -> Tuple[bool, str]:
    """
    Send base64 encoded image via GOWA API
    
    Args:
        phone: Recipient phone number (628xxx)
        image_base64: Base64 encoded image string
        caption: Optional caption text
        
    Returns:
        Tuple[bool, str]: (success, message)
    """
    try:
        url = f"{get_gowa_url()}/send/image"
        
        # Ensure proper base64 format
        if not image_base64.startswith('data:'):
            image_base64 = f"data:image/jpeg;base64,{image_base64}"
        
        payload = {
            "phone": format_phone_for_gowa(phone),
            "image": image_base64,
            "caption": caption
        }
        
        response = requests.post(
            url,
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=REQUEST_TIMEOUT
        )
        
        data = response.json()
        
        if data.get('code') == 'SUCCESS':
            return True, "Image sent successfully"
        else:
            return False, data.get('message', 'Failed to send image')
            
    except requests.exceptions.ConnectionError:
        return False, "GOWA server not running"
    except requests.exceptions.Timeout:
        return False, "Request timeout"
    except Exception as e:
        return False, f"Error: {str(e)}"


# ============================================================================
# FIRE ALERT FUNCTION
# ============================================================================

def send_fire_alert(
    frame = None,
    confidence: float = 0.0,
    gemini_verified: bool = False,
    gemini_score: float = 0.0,
    gemini_reason: str = "",
    camera_id: str = "ESP32-CAM",
    camera_ip: str = "Unknown",
    snapshot_path: Optional[str] = None,
    recipients: Optional[List[Dict]] = None
) -> Tuple[bool, str]:
    """
    Send fire detection alert to all recipients
    
    Args:
        frame: OpenCV frame (numpy array) - optional if snapshot_path provided
        confidence: YOLO detection confidence
        gemini_verified: Whether Gemini AI verified the fire
        gemini_score: Gemini verification score
        gemini_reason: Gemini's reason/description
        camera_id: Camera identifier
        camera_ip: Camera IP address
        snapshot_path: Path to saved snapshot (optional)
        recipients: List of recipients (optional, loads from file if not provided)
        
    Returns:
        Tuple[bool, str]: (success, message)
    """
    import cv2  # Import here to avoid issues if cv2 not installed
    
    # Check connection first
    connected, conn_msg = check_gowa_connection()
    if not connected:
        return False, f"WhatsApp not connected: {conn_msg}"
    
    # Load recipients if not provided
    if recipients is None:
        recipients = load_recipients()
    
    if not recipients:
        return False, "No recipients configured"
    
    # Build alert message
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    message = f"""🔥 *FIRE DETECTED - ALERT!*

⚠️ *DANGEROUS CONDITION DETECTED*

📊 *Detection Details:*
🎯 YOLO Confidence: *{confidence*100:.1f}%*
🤖 Gemini Verified: *{'Yes ✓' if gemini_verified else 'No'}*
"""
    
    if gemini_verified:
        message += f"""📈 Gemini Score: *{gemini_score*100:.1f}%*
💬 Analysis: _{gemini_reason}_
"""
    
    message += f"""
📹 Camera: {camera_id}
🌐 IP: {camera_ip}
⏰ Time: {timestamp}

*Please check immediately!*"""
    
    # Prepare image
    temp_image_path = None
    
    if snapshot_path and os.path.exists(snapshot_path):
        image_path = snapshot_path
    elif frame is not None:
        # Save frame to temp file
        temp_image_path = f"/tmp/fire_alert_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
        try:
            cv2.imwrite(temp_image_path, frame)
            image_path = temp_image_path
        except Exception as e:
            print(f"⚠️  Failed to save frame: {e}")
            image_path = None
    else:
        image_path = None
    
    # Send to all recipients
    success_count = 0
    fail_count = 0
    errors = []
    
    for recipient in recipients:
        phone = recipient.get('phoneNumber', recipient.get('phone', ''))
        name = recipient.get('name', phone)
        
        if not phone:
            continue
        
        try:
            if image_path:
                # Send image with caption
                success, msg = send_image_message(phone, image_path, message)
            else:
                # Send text only
                success, msg = send_text_message(phone, message)
            
            if success:
                success_count += 1
                print(f"✅ Alert sent to {name} ({phone})")
            else:
                fail_count += 1
                errors.append(f"{name}: {msg}")
                print(f"❌ Failed to send to {name}: {msg}")
                
        except Exception as e:
            fail_count += 1
            errors.append(f"{name}: {str(e)}")
            print(f"❌ Error sending to {name}: {e}")
    
    # Cleanup temp file
    if temp_image_path and os.path.exists(temp_image_path):
        try:
            os.remove(temp_image_path)
        except:
            pass
    
    # Return result
    if success_count > 0:
        return True, f"Alert sent to {success_count}/{len(recipients)} recipients"
    else:
        return False, f"Failed to send: {', '.join(errors[:3])}"


# ============================================================================
# BACKWARD COMPATIBILITY
# ============================================================================

# Alias for old function name
def send_fire_photo_to_whatsapp(
    frame,
    confidence: float,
    gemini_verified: bool = False,
    gemini_score: float = 0.0,
    gemini_reason: str = ""
) -> Tuple[bool, str]:
    """
    Backward compatible function name
    
    This wraps send_fire_alert for compatibility with existing code
    """
    return send_fire_alert(
        frame=frame,
        confidence=confidence,
        gemini_verified=gemini_verified,
        gemini_score=gemini_score,
        gemini_reason=gemini_reason
    )


# ============================================================================
# MAIN (for testing)
# ============================================================================

if __name__ == "__main__":
    print("\n" + "="*60)
    print("🔥 GOWA API Helper - Test Mode")
    print("="*60 + "\n")
    
    # Check connection
    print("Checking GOWA connection...")
    connected, msg = check_gowa_connection()
    print(f"  Status: {'✅ Connected' if connected else '❌ Not connected'}")
    print(f"  Message: {msg}")
    print()
    
    # Load recipients
    recipients = load_recipients()
    print(f"Recipients loaded: {len(recipients)}")
    for r in recipients:
        print(f"  - {r.get('name', 'Unknown')}: {r.get('phoneNumber', 'N/A')}")
    print()
    
    # Test message (uncomment to test)
    # if connected and recipients:
    #     success, msg = send_text_message(
    #         recipients[0]['phoneNumber'],
    #         "🔥 Test message from Fire Detection System"
    #     )
    #     print(f"Test send: {msg}")
