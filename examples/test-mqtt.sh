#!/bin/bash

# MQTT Test Script for IoT Fire Detection Dashboard
# This script sends test payloads to MQTT broker for testing

# Configuration
MQTT_HOST="localhost"
MQTT_PORT="1883"
TOPIC_TELEMETRY="nimak/deteksi-api/telemetry"
TOPIC_CMD="nimak/deteksi-api/cmd"
TOPIC_STATUS="nimak/deteksi-api/status"

echo "========================================="
echo "IoT Fire Detection - MQTT Test Script"
echo "========================================="
echo ""
echo "MQTT Broker: $MQTT_HOST:$MQTT_PORT"
echo "Topics: $TOPIC_TELEMETRY, $TOPIC_CMD, $TOPIC_STATUS"
echo ""

# Check if mosquitto_pub is available
if ! command -v mosquitto_pub &> /dev/null; then
    echo "Error: mosquitto_pub not found!"
    echo "Install with: sudo apt-get install mosquitto-clients"
    exit 1
fi

# Function to publish telemetry
publish_telemetry() {
    local id=$1
    local temp=$2
    local humidity=$3
    local gas=$4
    local gasD=$5
    local alarm=$6
    
    local payload="{\"id\":\"$id\",\"t\":$temp,\"h\":$humidity,\"gasA\":$gas,\"gasD\":$gasD,\"alarm\":$alarm}"
    
    echo "Publishing: $payload"
    mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TOPIC_TELEMETRY" -m "$payload"
}

# Function to send command
send_command() {
    local cmd=$1
    echo "Sending command: $cmd"
    mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TOPIC_CMD" -m "$cmd"
}

# Menu
echo "Select test scenario:"
echo "1. Normal reading"
echo "2. High temperature alarm"
echo "3. Gas detected alarm"
echo "4. Full fire alarm"
echo "5. Continuous normal data (10 readings)"
echo "6. Gradual fire simulation"
echo "7. Send BUZZER_ON command"
echo "8. Send BUZZER_OFF command"
echo "9. Set gas threshold to 2500"
echo "0. Subscribe to all topics (monitoring mode)"
echo ""
read -p "Enter choice (1-9, 0): " choice

case $choice in
    1)
        echo "Sending normal reading..."
        publish_telemetry "ESP32-TEST001" 27.5 62.0 1200 0 false
        ;;
    2)
        echo "Sending high temperature alarm..."
        publish_telemetry "ESP32-TEST001" 52.3 55.0 1500 0 true
        ;;
    3)
        echo "Sending gas detected alarm..."
        publish_telemetry "ESP32-TEST001" 28.0 60.0 3200 1 true
        ;;
    4)
        echo "Sending full fire alarm..."
        publish_telemetry "ESP32-TEST001" 55.0 45.0 3900 1 true
        ;;
    5)
        echo "Sending 10 normal readings (2 sec interval)..."
        for i in {1..10}; do
            temp=$(awk -v min=26 -v max=30 'BEGIN{srand(); print min+rand()*(max-min)}')
            humidity=$(awk -v min=58 -v max=65 'BEGIN{srand(); print min+rand()*(max-min)}')
            gas=$(shuf -i 1100-1400 -n 1)
            
            publish_telemetry "ESP32-TEST001" "$temp" "$humidity" "$gas" 0 false
            echo "Progress: $i/10"
            sleep 2
        done
        ;;
    6)
        echo "Simulating gradual fire development..."
        echo "Step 1: Normal (27°C, gas: 1200)"
        publish_telemetry "ESP32-TEST001" 27.5 62.0 1200 0 false
        sleep 3
        
        echo "Step 2: Temperature rising (35°C, gas: 1800)"
        publish_telemetry "ESP32-TEST001" 35.0 58.0 1800 0 false
        sleep 3
        
        echo "Step 3: Gas detected (42°C, gas: 2800)"
        publish_telemetry "ESP32-TEST001" 42.0 52.0 2800 1 true
        sleep 3
        
        echo "Step 4: Full alarm (55°C, gas: 3900)"
        publish_telemetry "ESP32-TEST001" 55.0 45.0 3900 1 true
        ;;
    7)
        send_command "BUZZER_ON"
        ;;
    8)
        send_command "BUZZER_OFF"
        ;;
    9)
        send_command "THR=2500"
        ;;
    0)
        echo "Subscribing to all topics... (Press Ctrl+C to stop)"
        mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TOPIC_TELEMETRY" -t "$TOPIC_CMD" -t "$TOPIC_STATUS" -v
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "Done!"
echo "========================================="
