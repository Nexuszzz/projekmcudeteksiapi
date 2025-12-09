@echo off
color 0E
title Twilio - Debug No Calls Received

cls
echo.
echo ================================================================================
echo                 TWILIO DEBUG - NO CALLS RECEIVED
echo ================================================================================
echo.
echo PROBLEM: Server says call initiated, but no call received
echo.
echo Let's debug step by step...
echo.
echo ================================================================================
echo.

echo [Step 1] Checking Voice Call Server Status...
echo.
curl -s http://localhost:3002/api/voice-call/config
echo.
echo.

pause

echo.
echo ================================================================================
echo [Step 2] Checking Twilio Account Status
echo ================================================================================
echo.
echo Open this URL in browser to check your Twilio account:
echo.
echo https://console.twilio.com/us1/monitor/logs/calls
echo.
echo Look for recent call attempts.
echo If NO calls appear there, the problem is with Twilio account setup.
echo.

pause

echo.
echo ================================================================================
echo [Step 3] Verify Twilio Phone Number Status
echo ================================================================================
echo.
echo Your Twilio Phone Number: +12174398497
echo.
echo Open this URL to check if phone number is active:
echo.
echo https://console.twilio.com/us1/develop/phone-numbers/manage/active
echo.
echo Check:
echo   1. Phone number is listed
echo   2. Status is ACTIVE
echo   3. Voice configuration is set
echo.

pause

echo.
echo ================================================================================
echo [Step 4] Check Account Balance
echo ================================================================================
echo.
echo Open this URL to check credits:
echo.
echo https://console.twilio.com/us1/billing
echo.
echo Trial account should have ~$15.50 free credits.
echo If balance is $0.00, you cannot make calls!
echo.

pause

echo.
echo ================================================================================
echo [Step 5] Test Call with Curl (Direct to Twilio API)
echo ================================================================================
echo.
echo Let's make a test call directly using Twilio API to see exact error.
echo.

set /p test_to="Enter phone number to call (with +62): "

echo.
echo Making direct API call to Twilio...
echo.

REM Replace YOUR_ACCOUNT_SID and YOUR_AUTH_TOKEN with your actual Twilio credentials
curl -X POST "https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Calls.json" ^
  --data-urlencode "To=%test_to%" ^
  --data-urlencode "From=+12174398497" ^
  --data-urlencode "Url=https://demo.twilio.com/welcome/voice/" ^
  -u "YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN"

echo.
echo.

pause

echo.
echo ================================================================================
echo [Step 6] Analyze Results
echo ================================================================================
echo.
echo Look at the response above:
echo.
echo If you see ERROR:
echo   - "Invalid phone number" = Check To/From number format
echo   - "Insufficient funds" = Add credits to account
echo   - "Phone number not verified" = Verify in console
echo   - "Invalid credentials" = Check Account SID/Auth Token
echo   - "Phone number not owned" = +12174398497 not in your account!
echo.
echo If you see SUCCESS with "sid", "status": "queued":
echo   - Wait 10-30 seconds for phone to ring
echo   - Check Twilio logs for call status
echo   - If still no call, check phone number country/carrier
echo.

pause

echo.
echo ================================================================================
echo COMMON ISSUES:
echo ================================================================================
echo.
echo 1. WRONG TWILIO PHONE NUMBER
echo    - Your .env has: +12174398497
echo    - But this might not be YOUR number!
echo    - Check your actual Twilio phone number in console:
echo      https://console.twilio.com/us1/develop/phone-numbers/manage/active
echo.
echo 2. TRIAL ACCOUNT RESTRICTIONS
echo    - Can only call verified numbers
echo    - Calls prefixed with test message
echo    - Limited to certain countries
echo.
echo 3. PHONE NUMBER NOT ACTIVE
echo    - Number might be released/expired
echo    - Need to purchase/assign number
echo.
echo 4. INSUFFICIENT CREDITS
echo    - Trial credits used up
echo    - Need to add funds
echo.

pause

echo.
echo ================================================================================
echo RECOMMENDED ACTIONS:
echo ================================================================================
echo.
echo ACTION 1: Verify YOUR Twilio Phone Number
echo    1. Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/active
echo    2. Copy YOUR actual phone number
echo    3. Update voice-call-server\.env:
echo       TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
echo    4. Restart voice-call server
echo.
echo ACTION 2: Check Trial Account Limitations
echo    1. Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
echo    2. Verify destination number (+628967175597)
echo    3. Try test call again
echo.
echo ACTION 3: Check Twilio Call Logs
echo    1. Go to: https://console.twilio.com/us1/monitor/logs/calls
echo    2. Look for recent attempts
echo    3. Check error messages
echo.

pause
