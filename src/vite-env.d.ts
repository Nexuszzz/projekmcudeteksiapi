/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_MQTT_URL: string
  readonly VITE_MQTT_USERNAME: string
  readonly VITE_MQTT_PASSWORD: string
  readonly VITE_TOPIC_EVENT: string
  readonly VITE_TOPIC_LOG: string
  readonly VITE_TOPIC_STATUS: string
  readonly VITE_TOPIC_ALERT: string
  readonly VITE_TOPIC_CMD: string
  readonly VITE_MAX_DATA_POINTS: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
