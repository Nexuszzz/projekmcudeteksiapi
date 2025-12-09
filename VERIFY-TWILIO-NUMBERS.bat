@echo off
color 0E
title Twilio - Verify Emergency Numbers

cls
echo.
echo ================================================================================
echo                    TWILIO TRIAL ACCOUNT - VERIFY NUMBERS
echo ================================================================================
echo.
echo PROBLEM DETECTED:
echo   Your Twilio Trial Account can ONLY call VERIFIED numbers!
echo.
echo Current Error:
echo   "The number +62... is unverified. Trial accounts may only 
echo    make calls to verified numbers."
echo.
echo ================================================================================
echo.

echo SOLUTION: Verify your emergency numbers in Twilio Console
echo.
echo ================================================================================
echo STEP-BY-STEP GUIDE:
echo ================================================================================
echo.

echo 1. Open Twilio Console in browser:
echo.
echo    https://console.twilio.com/us1/develop/phone-numbers/manage/verified
echo.

pause

echo.
echo 2. Click "Add a new Caller ID" button
echo.

pause

echo.
echo 3. Enter your emergency number with country code:
echo.
echo    Example: +6287847529293
echo    Format:  +[country code][number]
echo.
echo    Indonesia: +62
echo    USA:       +1
echo.

pause

echo.
echo 4. Choose verification method: "Call You"
echo.
echo    (Indonesia numbers must use "Call You", not SMS)
echo.

pause

echo.
echo 5. Click "Call Me Now"
echo.
echo    Twilio will call your number immediately.
echo    Answer the phone!
echo.

pause

echo.
echo 6. Listen to the robotic voice
echo.
echo    It will read a 6-digit verification code.
echo    Example: "Your code is: 1-2-3-4-5-6"
echo.

pause

echo.
echo 7. Enter the code in Twilio Console
echo.
echo    Type the 6-digit code you heard.
echo.

pause

echo.
echo 8. Click "Verify"
echo.
echo    Your number is now VERIFIED!
echo.

pause

echo.
echo 9. Repeat for ALL emergency numbers
echo.
echo    List your numbers:
echo    [ ] +6287847529293 (z)
echo    [x] +628967175597 (z1) - Already verified!
echo    [ ] +628123456789 (Security)
echo    [ ] ... (add more)
echo.

pause

echo.
echo ================================================================================
echo TESTING VERIFIED NUMBER:
echo ================================================================================
echo.
echo After verification, test the number:
echo.

set /p test_number="Enter verified number to test (with +62): "

echo.
echo Making test call to %test_number%...
echo.

curl -X POST http://localhost:3002/api/voice-call/test -H "Content-Type: application/json" -d "{\"phoneNumber\":\"%test_number%\"}"

echo.
echo.
echo ================================================================================
echo RESULT:
echo ================================================================================
echo.
echo If you see "success": true and receive a call within 10 seconds:
echo   VERIFICATION SUCCESSFUL!
echo.
echo If you still get "unverified" error:
echo   1. Check number is in verified list in Twilio Console
echo   2. Make sure number format is correct (+62...)
echo   3. Wait a few minutes and try again
echo.
echo ================================================================================
echo.
echo ALTERNATIVE: Upgrade to Paid Account
echo.
echo For production, upgrade to remove verification requirement:
echo   1. Go to: https://console.twilio.com/us1/billing
echo   2. Click "Upgrade"
echo   3. Add payment method
echo   4. Minimum topup: $20
echo   5. No more verification needed!
echo.
echo Cost: Very affordable (~$0.025/minute for Indonesia calls)
echo       About Rp 50,000/month for typical emergency system usage
echo.
echo ================================================================================
echo.

pause
