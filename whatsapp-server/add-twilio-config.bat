@echo off
echo.>> .env
echo # Twilio Voice Call Configuration>> .env
echo TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE>> .env
echo TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE>> .env
echo TWILIO_PHONE_NUMBER=+12174398497>> .env
echo TWILIO_VOICE_URL=https://demo.twilio.com/welcome/voice/>> .env
echo.
echo ✅ Twilio credentials added to .env file!
echo.
echo Now restart the whatsapp-server:
echo   npm start
pause
