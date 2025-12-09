@echo off
color 0A
title Test NEW Fire Alert Voice Message

cls
echo.
echo ================================================================================
echo              TEST NEW FIRE ALERT VOICE MESSAGE
echo ================================================================================
echo.
echo NEW Voice Message (Indonesian + English):
echo.
echo   [BAHASA INDONESIA - loops 3x]
echo   "Perhatian! Terdeteksi kebakaran di lokasi Anda."
echo   "Segera lakukan evakuasi."
echo   "Ini adalah panggilan darurat otomatis dari sistem deteksi kebakaran."
echo.
echo   [ENGLISH - loops 2x]
echo   "Warning! Fire detected at your location."
echo   "Please evacuate immediately."
echo   "This is an automated emergency call from fire detection system."
echo.
echo ================================================================================
echo.

set /p phone="Enter your phone number to test (with +62): "

echo.
echo Making test call to: %phone%
echo.
echo You should receive a call with INDONESIAN fire alert message!
echo Answer the phone and listen carefully.
echo.
echo ================================================================================
echo.

curl -X POST http://localhost:3002/api/voice-call/test -H "Content-Type: application/json" -d "{\"phoneNumber\":\"%phone%\"}"

echo.
echo.
echo ================================================================================
echo WHAT TO EXPECT:
echo ================================================================================
echo.
echo 1. Phone will ring in 10-30 seconds
echo 2. Answer the call
echo 3. You will hear (in Indonesian):
echo       "Perhatian! Terdeteksi kebakaran..."
echo    This will repeat 3 times
echo 4. Then you'll hear (in English):
echo       "Warning! Fire detected..."
echo    This will repeat 2 times
echo.
echo Total duration: ~30-40 seconds
echo.
echo If you hear this clearly: SUCCESS! ✅
echo.
echo ================================================================================
echo.
echo If you DON'T hear anything or call not received:
echo.
echo 1. Check Twilio logs:
echo    https://console.twilio.com/us1/monitor/logs/calls
echo.
echo 2. Verify destination number (+628967175597) is verified:
echo    https://console.twilio.com/us1/develop/phone-numbers/manage/verified
echo.
echo 3. Check Twilio phone number is correct in .env file
echo.
pause
