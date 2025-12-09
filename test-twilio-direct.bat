@echo off
echo ================================================================================
echo TWILIO DIRECT API TEST - Check if phone number is correct
echo ================================================================================
echo.
echo This will test your Twilio setup by making a direct API call.
echo.

set /p phone="Enter phone number to call (with +62): "

echo.
echo Testing with:
echo   From: +12174398497
echo   To: %phone%
echo   Account: YOUR_ACCOUNT_SID_HERE
echo.
echo Making API call...
echo.

curl -X POST "https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID_HERE/Calls.json" --data-urlencode "To=%phone%" --data-urlencode "From=+12174398497" --data-urlencode "Url=https://demo.twilio.com/welcome/voice/" -u "YOUR_ACCOUNT_SID_HERE:YOUR_AUTH_TOKEN_HERE"

echo.
echo.
echo ================================================================================
echo RESULTS ANALYSIS:
echo ================================================================================
echo.
echo If you see ERROR with code 21606 "From phone number not valid":
echo   - The number +12174398497 is NOT yours!
echo   - You need to get YOUR actual Twilio phone number
echo   - Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/active
echo   - Copy YOUR number and update voice-call-server\.env
echo.
echo If you see "sid" and "status": "queued":
echo   - SUCCESS! Call is being made
echo   - Wait 10-30 seconds for phone to ring
echo   - If phone still doesn't ring, check:
echo     1. Destination number verified in Twilio
echo     2. Phone has signal
echo     3. Phone not blocking unknown numbers
echo.
echo If you see ERROR 21608 "not verified":
echo   - Destination number needs verification
echo   - Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
echo.
pause
