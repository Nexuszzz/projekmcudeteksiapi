"""
Test 5 Metode Twilio Voice Call - Backend API Test
====================================================
Script untuk test endpoint /api/voice-call/test-advanced
dengan 5 metode pengujian berbeda.

Metode:
1. Basic TwiML String - Emergency Fire Alert
2. TwiML URL - Demo Twilio Voice
3. TwiML with Status Callbacks
4. Call with Recording Enabled
5. Extended Timeout (120 seconds)
"""

import requests
import time
import json
from typing import Dict, Any

# Configuration
VOICE_CALL_API = "http://localhost:3002/api/voice-call"
TEST_PHONE_NUMBER = input("\n📞 Enter test phone number (format: +628xxx): ").strip()

print("\n" + "=" * 80)
print("🧪 TWILIO 5-METHOD TEST - Backend API Testing")
print("=" * 80)

def test_method(method_num: int, phone_number: str, custom_message: str = None) -> Dict[str, Any]:
    """
    Test single method via backend API
    """
    method_names = [
        "Basic TwiML String - Emergency Fire Alert",
        "TwiML URL - Demo Twilio Voice",
        "TwiML with Status Callbacks",
        "Call with Recording Enabled",
        "Extended Timeout (120 seconds)"
    ]
    
    print(f"\n{'=' * 80}")
    print(f"TEST METHOD {method_num}: {method_names[method_num - 1]}")
    print("=" * 80)
    
    try:
        # Check if voice call server is running
        health_response = requests.get(f"{VOICE_CALL_API.replace('/api/voice-call', '')}/health", timeout=5)
        if health_response.status_code != 200:
            print("❌ Voice call server not responding!")
            return {"success": False, "error": "Server not available"}
            
        print(f"✅ Voice call server is running")
        
        # Prepare request data
        payload = {
            "phoneNumber": phone_number,
            "testMethod": method_num
        }
        
        if custom_message:
            payload["customMessage"] = custom_message
        
        print(f"\n📤 Sending request to: {VOICE_CALL_API}/test-advanced")
        print(f"   Payload: {json.dumps(payload, indent=2)}")
        
        # Make API call
        response = requests.post(
            f"{VOICE_CALL_API}/test-advanced",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        data = response.json()
        
        if response.status_code == 200 and data.get("success"):
            print(f"\n✅ TEST {method_num} SUCCESS!")
            print(f"   📞 Calling: {phone_number}")
            print(f"   🆔 Call SID: {data.get('callSid')}")
            print(f"   📊 Status: {data.get('status')}")
            print(f"   🧪 Test: {data.get('testDescription')}")
            print(f"   📝 Message: {data.get('message')}")
            
            if data.get('additionalInfo'):
                print(f"\n   ℹ️  Additional Info:")
                for key, value in data.get('additionalInfo').items():
                    print(f"      {key}: {value}")
            
            # Wait for call
            print(f"\n   ⏳ Wait 10 seconds for the call...")
            print(f"   📱 Your phone should ring!")
            time.sleep(10)
            
            # Ask for confirmation
            heard = input(f"\n   ❓ Did you RECEIVE and HEAR the call? (y/n): ").strip().lower()
            
            if heard == 'y':
                print(f"   🎉 Method {method_num} VERIFIED!")
                return {
                    "success": True,
                    "verified": True,
                    "callSid": data.get('callSid'),
                    "method": method_num,
                    "methodName": method_names[method_num - 1]
                }
            else:
                print(f"   ⚠️  Method {method_num} API success but call not received")
                print(f"   💡 Check:")
                print(f"      - Is number verified? (trial account)")
                print(f"      - Check Twilio logs: https://console.twilio.com/us1/monitor/logs/calls")
                print(f"      - Call SID: {data.get('callSid')}")
                return {
                    "success": True,
                    "verified": False,
                    "callSid": data.get('callSid'),
                    "method": method_num
                }
        else:
            print(f"\n❌ TEST {method_num} FAILED!")
            print(f"   Error: {data.get('error', 'Unknown error')}")
            
            if "unverified" in str(data.get('error', '')).lower():
                print(f"\n   ⚠️  NUMBER NOT VERIFIED (Trial Account)")
                print(f"   📋 Verify at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified")
            
            return {
                "success": False,
                "error": data.get('error'),
                "method": method_num
            }
            
    except requests.exceptions.ConnectionError:
        print(f"\n❌ Connection Error!")
        print(f"   Cannot connect to voice call server at {VOICE_CALL_API}")
        print(f"   Please ensure voice-call-server is running on port 3002")
        return {"success": False, "error": "Connection error"}
        
    except requests.exceptions.Timeout:
        print(f"\n❌ Request Timeout!")
        print(f"   Request took more than 10 seconds")
        return {"success": False, "error": "Timeout"}
        
    except Exception as e:
        print(f"\n❌ Unexpected Error: {e}")
        return {"success": False, "error": str(e)}

# ============================================================================
# MAIN TEST SEQUENCE
# ============================================================================

print(f"\n📱 Test Configuration:")
print(f"   API: {VOICE_CALL_API}/test-advanced")
print(f"   Phone: {TEST_PHONE_NUMBER}")
print()

confirm = input("🔔 This will make 5 real phone calls. Continue? (y/n): ").strip().lower()

if confirm != 'y':
    print("\n❌ Test cancelled by user")
    exit(0)

results = []

# TEST 1: Basic TwiML
print("\n\n🔥 Starting Test Sequence...")
print("=" * 80)
result1 = test_method(1, TEST_PHONE_NUMBER)
results.append(result1)
time.sleep(3)  # Wait between tests

# TEST 2: TwiML URL
result2 = test_method(2, TEST_PHONE_NUMBER)
results.append(result2)
time.sleep(3)

# TEST 3: Status Callbacks
result3 = test_method(3, TEST_PHONE_NUMBER)
results.append(result3)
time.sleep(3)

# TEST 4: Call Recording
result4 = test_method(4, TEST_PHONE_NUMBER)
results.append(result4)
time.sleep(3)

# TEST 5: Extended Timeout
result5 = test_method(5, TEST_PHONE_NUMBER)
results.append(result5)

# ============================================================================
# SUMMARY
# ============================================================================

print("\n\n" + "=" * 80)
print("📊 TEST SUMMARY - 5 METHODS")
print("=" * 80)

total_tests = len(results)
api_success = len([r for r in results if r.get('success')])
verified = len([r for r in results if r.get('verified')])
failed = len([r for r in results if not r.get('success')])

print(f"\n📈 Results:")
print(f"   Total Tests: {total_tests}")
print(f"   API Success: {api_success}/{total_tests} ({api_success/total_tests*100:.0f}%)")
print(f"   Verified (Call Received): {verified}/{total_tests} ({verified/total_tests*100 if total_tests > 0 else 0:.0f}%)")
print(f"   Failed: {failed}/{total_tests}")

print(f"\n📋 Detailed Results:")
for i, result in enumerate(results, 1):
    method_names = [
        "Basic TwiML",
        "TwiML URL",
        "Status Callbacks",
        "Call Recording",
        "Extended Timeout"
    ]
    
    if result.get('success'):
        if result.get('verified'):
            status = "✅ VERIFIED"
        else:
            status = "⚠️  API OK, Call Not Received"
    else:
        status = "❌ FAILED"
    
    print(f"   Method {i} ({method_names[i-1]}): {status}")
    if result.get('callSid'):
        print(f"      Call SID: {result.get('callSid')}")

print(f"\n🔗 Check Twilio Console:")
print(f"   https://console.twilio.com/us1/monitor/logs/calls")

print(f"\n💡 Recommendations:")
if verified == total_tests:
    print(f"   🎉 PERFECT! All 5 methods working!")
    print(f"   ✅ System ready for production")
elif verified > 0:
    print(f"   ⚠️  Some methods working, some not")
    print(f"   📝 Check failed methods in Twilio Console")
    print(f"   🔍 Verify phone number if trial account")
else:
    print(f"   ❌ No calls received")
    print(f"   🔍 Common issues:")
    print(f"      - Phone number not verified (trial account)")
    print(f"      - Carrier blocking calls")
    print(f"      - Phone signal issue")
    print(f"      - Check Twilio logs for details")

print("\n" + "=" * 80)
print("🎉 Test Complete!")
print("=" * 80)
print()

# Save results to file
try:
    with open('test_5_methods_results.json', 'w') as f:
        json.dump({
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "phone_number": TEST_PHONE_NUMBER,
            "results": results,
            "summary": {
                "total": total_tests,
                "api_success": api_success,
                "verified": verified,
                "failed": failed
            }
        }, f, indent=2)
    print("📄 Results saved to: test_5_methods_results.json")
except Exception as e:
    print(f"⚠️  Could not save results: {e}")
