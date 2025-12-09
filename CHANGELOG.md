# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-17

### Added

#### Core Features
- ✅ Real-time MQTT data monitoring via WebSocket
- ✅ Multi-series line chart with temperature, humidity, and gas readings
- ✅ Interactive time range selector (Live/1h/6h/24h/All)
- ✅ Remote control panel for buzzer and gas threshold
- ✅ Comprehensive data log table with search and filtering
- ✅ CSV and JSONL data export functionality
- ✅ Browser notification system for fire alarms

#### UI/UX
- ✅ Dark/Light theme toggle with localStorage persistence
- ✅ Responsive design for desktop, tablet, and mobile
- ✅ Real-time connection status indicator
- ✅ Metric cards with semantic colors (alarm = red)
- ✅ Toast notifications for command feedback
- ✅ Accessible UI with ARIA labels and keyboard navigation

#### Technical
- ✅ TypeScript strict mode with full type safety
- ✅ Zod schema validation for MQTT payloads
- ✅ Zustand state management with selectors
- ✅ Sliding window data retention (max 10k points)
- ✅ Chart downsampling for performance (max 1k points)
- ✅ Table pagination (50 items per page)
- ✅ Graceful MQTT reconnection handling
- ✅ Environment variable configuration via .env

#### Developer Experience
- ✅ ESLint + Prettier configuration
- ✅ Vitest unit testing setup
- ✅ Hot module replacement (HMR)
- ✅ Comprehensive documentation (README, API reference, guides)
- ✅ Optional Node.js MQTT proxy server
- ✅ Example ESP32 integration code
- ✅ Deployment guides for multiple platforms

### Technical Stack
- React 18.2
- Vite 5.0
- TypeScript 5.2
- Tailwind CSS 3.3
- Zustand 4.4
- MQTT.js 5.3
- Recharts 2.10
- Zod 3.22
- Lucide React 0.294

### Documentation
- Complete README with setup instructions
- ESP32 integration guide with example code
- Deployment guide (Netlify, Vercel, AWS, Docker, VPS)
- API reference documentation
- Contributing guidelines
- Proxy server documentation

### Security
- No hardcoded credentials (all via .env)
- Payload validation to prevent injection
- HTTPS/WSS support for production
- MQTT authentication support
- Security best practices documentation

### Performance
- Optimized rendering with React.memo
- Efficient state updates with Zustand selectors
- Chart downsampling for large datasets
- Lazy loading and code splitting
- Gzip compression in production

## [Unreleased]

### Planned Features
- [ ] IndexedDB integration for offline data storage
- [ ] Multi-device dashboard with device selector
- [ ] Historical data playback feature
- [ ] Advanced analytics and trends
- [ ] Email/SMS alert integration
- [ ] User authentication system
- [ ] Device management interface
- [ ] Custom threshold per device
- [ ] Scheduled reports
- [ ] Mobile app (React Native)

---

[1.0.0]: https://github.com/your-repo/iot-fire-detection-dashboard/releases/tag/v1.0.0
