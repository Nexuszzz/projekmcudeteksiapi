@echo off
REM MQTT Test Script for IoT Fire Detection Dashboard (Windows)
REM This script sends test payloads to MQTT broker for testing

SET MQTT_HOST=localhost
SET MQTT_PORT=1883
SET TOPIC_TELEMETRY=nimak/deteksi-api/telemetry
SET TOPIC_CMD=nimak/deteksi-api/cmd
SET TOPIC_STATUS=nimak/deteksi-api/status

echo =========================================
echo IoT Fire Detection - MQTT Test Script
echo =========================================
echo.
echo MQTT Broker: %MQTT_HOST%:%MQTT_PORT%
echo Topics: %TOPIC_TELEMETRY%, %TOPIC_CMD%, %TOPIC_STATUS%
echo.

REM Check if mosquitto_pub is available
where mosquitto_pub >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: mosquitto_pub not found!
    echo Install Mosquitto from: https://mosquitto.org/download/
    echo Make sure to add to PATH
    pause
    exit /b 1
)

echo Select test scenario:
echo 1. Normal reading
echo 2. High temperature alarm
echo 3. Gas detected alarm
echo 4. Full fire alarm
echo 5. Send BUZZER_ON command
echo 6. Send BUZZER_OFF command
echo 7. Set gas threshold to 2500
echo 8. Subscribe to all topics (monitoring)
echo.

set /p choice="Enter choice (1-8): "

if "%choice%"=="1" (
    echo Sending normal reading...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_TELEMETRY% -m "{\"id\":\"ESP32-TEST001\",\"t\":27.5,\"h\":62.0,\"gasA\":1200,\"gasD\":0,\"alarm\":false}"
)

if "%choice%"=="2" (
    echo Sending high temperature alarm...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_TELEMETRY% -m "{\"id\":\"ESP32-TEST001\",\"t\":52.3,\"h\":55.0,\"gasA\":1500,\"gasD\":0,\"alarm\":true}"
)

if "%choice%"=="3" (
    echo Sending gas detected alarm...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_TELEMETRY% -m "{\"id\":\"ESP32-TEST001\",\"t\":28.0,\"h\":60.0,\"gasA\":3200,\"gasD\":1,\"alarm\":true}"
)

if "%choice%"=="4" (
    echo Sending full fire alarm...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_TELEMETRY% -m "{\"id\":\"ESP32-TEST001\",\"t\":55.0,\"h\":45.0,\"gasA\":3900,\"gasD\":1,\"alarm\":true}"
)

if "%choice%"=="5" (
    echo Sending BUZZER_ON command...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_CMD% -m "BUZZER_ON"
)

if "%choice%"=="6" (
    echo Sending BUZZER_OFF command...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_CMD% -m "BUZZER_OFF"
)

if "%choice%"=="7" (
    echo Setting gas threshold to 2500...
    mosquitto_pub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_CMD% -m "THR=2500"
)

if "%choice%"=="8" (
    echo Subscribing to all topics... (Press Ctrl+C to stop)
    mosquitto_sub -h %MQTT_HOST% -p %MQTT_PORT% -t %TOPIC_TELEMETRY% -t %TOPIC_CMD% -t %TOPIC_STATUS% -v
)

echo.
echo Done!
echo =========================================
pause
