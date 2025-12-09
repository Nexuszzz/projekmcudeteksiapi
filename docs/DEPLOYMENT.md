# 🚀 Deployment Guide

Panduan deployment aplikasi IoT Fire Detection Dashboard ke production.

## 📋 Prerequisites

- Node.js v18+ installed
- MQTT broker accessible (with WebSocket support)
- Domain name (opsional untuk production)
- SSL certificate (untuk HTTPS/WSS)

## 🏗️ Build Production

### 1. Update Environment Variables

Buat file `.env` untuk production:

```env
VITE_MQTT_URL=wss://mqtt.yourdomain.com:9001/mqtt
VITE_MQTT_USERNAME=prod_user
VITE_MQTT_PASSWORD=secure_password
VITE_TOPIC_EVENT=lab/zaks/event
VITE_TOPIC_LOG=lab/zaks/log
VITE_TOPIC_STATUS=lab/zaks/status
VITE_TOPIC_ALERT=lab/zaks/alert
VITE_MAX_DATA_POINTS=10000
```

**⚠️ IMPORTANT**: Gunakan `wss://` (WebSocket Secure) untuk production!

### 2. Build Application

```bash
npm run build
```

Output akan tersimpan di folder `dist/`:

```
dist/
├── assets/
│   ├── index-[hash].css
│   └── index-[hash].js
├── index.html
└── fire-icon.svg
```

## 🌐 Deployment Options

## Option 1: Netlify (Recommended untuk Static Sites)

### Deploy via Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod --dir=dist
```

### Deploy via Git

1. Push code ke GitHub repository
2. Connect repository di [Netlify](https://app.netlify.com)
3. Configure build settings:
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
4. Add environment variables di Netlify dashboard
5. Deploy!

**Netlify Configuration** (`netlify.toml`):

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  NODE_VERSION = "18"
```

## Option 2: Vercel

### Deploy via Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

### Deploy via Git

1. Import repository di [Vercel](https://vercel.com)
2. Configure:
   - **Framework Preset**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
3. Add environment variables
4. Deploy!

## Option 3: AWS S3 + CloudFront

### 1. Build Application

```bash
npm run build
```

### 2. Create S3 Bucket

```bash
aws s3 mb s3://iot-dashboard-bucket
```

### 3. Enable Static Website Hosting

```bash
aws s3 website s3://iot-dashboard-bucket \
  --index-document index.html \
  --error-document index.html
```

### 4. Upload Files

```bash
aws s3 sync dist/ s3://iot-dashboard-bucket --delete
```

### 5. Create CloudFront Distribution

```bash
# Via AWS Console or CLI
# Set Origin: S3 bucket
# Set Default Root Object: index.html
# Enable HTTPS
```

## Option 4: Docker + VPS

### Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### nginx.conf

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### Build and Run

```bash
# Build image
docker build -t iot-dashboard .

# Run container
docker run -d -p 80:80 --name dashboard iot-dashboard
```

### Docker Compose

```yaml
version: '3.8'

services:
  dashboard:
    build: .
    ports:
      - "80:80"
    restart: unless-stopped
    environment:
      - NODE_ENV=production
```

## Option 5: Traditional VPS (Nginx)

### 1. Upload Build Files

```bash
# SCP to server
scp -r dist/* user@server:/var/www/iot-dashboard/
```

### 2. Nginx Configuration

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    root /var/www/iot-dashboard;
    index index.html;

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 3. Enable HTTPS with Let's Encrypt

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo systemctl enable certbot.timer
```

## 🔒 MQTT Broker Setup (Production)

### Mosquitto with SSL/TLS

#### 1. Generate SSL Certificates

```bash
# Self-signed (for testing)
openssl req -new -x509 -days 365 -extensions v3_ca \
  -keyout ca.key -out ca.crt

openssl genrsa -out server.key 2048
openssl req -new -out server.csr -key server.key
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt -days 365
```

#### 2. Mosquitto Configuration

```conf
# mosquitto.conf

# MQTT over TCP
listener 1883
protocol mqtt

# MQTT over WebSocket (Secure)
listener 9001
protocol websockets
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key

# Authentication
allow_anonymous false
password_file /etc/mosquitto/passwd

# Logging
log_dest file /var/log/mosquitto/mosquitto.log
log_type all
```

#### 3. Create Users

```bash
# Create password file
sudo mosquitto_passwd -c /etc/mosquitto/passwd username

# Add more users
sudo mosquitto_passwd /etc/mosquitto/passwd another_user
```

#### 4. Restart Mosquitto

```bash
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto
```

## 🔐 Security Checklist

- [ ] Use HTTPS (SSL/TLS) for web dashboard
- [ ] Use WSS (WebSocket Secure) for MQTT
- [ ] Enable MQTT authentication
- [ ] Use strong passwords
- [ ] Configure firewall (UFW/iptables)
- [ ] Enable rate limiting
- [ ] Implement CORS properly
- [ ] Keep dependencies updated
- [ ] Monitor logs regularly
- [ ] Backup configuration

## 📊 Monitoring

### PM2 (for Node.js proxy)

```bash
# Install PM2
npm install -g pm2

# Start proxy server
cd proxy-server
pm2 start server.js --name mqtt-proxy

# Monitoring
pm2 monit

# Logs
pm2 logs mqtt-proxy

# Auto-start on boot
pm2 startup
pm2 save
```

### Uptime Monitoring

Tools:
- **UptimeRobot**: Free monitoring service
- **Pingdom**: Professional monitoring
- **StatusCake**: Uptime & performance

### Log Monitoring

```bash
# Mosquitto logs
sudo tail -f /var/log/mosquitto/mosquitto.log

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🚨 Backup Strategy

### 1. MQTT Configuration Backup

```bash
# Backup mosquitto config
sudo tar -czf mosquitto-backup-$(date +%Y%m%d).tar.gz \
  /etc/mosquitto/
```

### 2. Database Backup (if using IndexedDB export)

Implement periodic export via dashboard:
- Automated CSV/JSONL export
- Upload to S3/Cloud Storage

## 📈 Performance Optimization

### 1. Enable Gzip Compression

Already configured in nginx examples above.

### 2. CDN (Content Delivery Network)

- Use CloudFlare for free CDN
- CloudFront for AWS deployments

### 3. Code Splitting

Already handled by Vite build.

### 4. Lazy Loading

Images and heavy components loaded on demand.

## 🧪 Testing Production Build

### Local Testing

```bash
# Build
npm run build

# Preview
npm run preview
```

### Load Testing

```bash
# Install Apache Bench
sudo apt install apache2-utils

# Test 1000 requests, 10 concurrent
ab -n 1000 -c 10 https://yourdomain.com/
```

## 📞 Post-Deployment

1. **Test all features**:
   - MQTT connection
   - Real-time data updates
   - Control panel (buzzer, threshold)
   - Export functionality
   - Dark mode toggle

2. **Monitor logs** for errors

3. **Test on multiple devices**:
   - Desktop browsers
   - Mobile browsers
   - Different screen sizes

4. **Setup alerts**:
   - Uptime monitoring
   - Error tracking (Sentry)

## 🆘 Rollback Plan

```bash
# Keep previous builds
cp -r dist dist-backup-$(date +%Y%m%d)

# Rollback if needed
rm -rf dist
mv dist-backup-YYYYMMDD dist
```

---

**Deployment Complete! 🎉**
