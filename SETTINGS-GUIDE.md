# ⚙️ Dashboard Settings Guide

Dashboard IoT Fire Detection sekarang memiliki **menu pengaturan lengkap** yang dapat dikustomisasi sesuai kebutuhan Anda!

## 🎯 Cara Mengakses Settings

Ada 2 cara membuka menu Settings:

### 1. **Tombol Settings di Header**
- Klik icon ⚙️ (Settings) di kanan atas header
- Warna biru untuk mudah ditemukan
- Tersedia di semua halaman

### 2. **Keyboard Shortcut** (Coming soon)
- Tekan `Ctrl + ,` atau `Cmd + ,`

## 📋 Kategori Settings

### 1. **Appearance (Tampilan)**

#### Theme
Pilih tema tampilan dashboard:
- **Light** ☀️ - Tema terang (putih)
- **Dark** 🌙 - Tema gelap (hitam)
- **Auto** 🔄 - Ikuti sistem operasi

> **Tips**: Theme Auto akan otomatis menyesuaikan dengan mode gelap/terang sistem Anda

#### Compact Mode
- **Enable**: Mengurangi jarak dan padding untuk menampilkan lebih banyak konten
- **Disable**: Tampilan normal dengan spacing yang nyaman

#### Enable Animations
- **Enable**: Animasi smooth untuk transisi dan effects
- **Disable**: Matikan animasi untuk performa lebih cepat

---

### 2. **Notifications (Notifikasi)**

#### Enable Notifications
- **Enable**: Tampilkan notifikasi saat deteksi api
- **Disable**: Matikan semua notifikasi

> **Note**: Notifikasi browser harus diizinkan untuk fitur ini

#### Enable Sound
- **Enable**: Mainkan alert sound saat ada deteksi api
- **Disable**: Mode silent tanpa suara

---

### 3. **Auto-Refresh**

#### Dashboard Refresh Interval
- **Range**: 5 - 120 detik
- **Default**: 30 detik
- **Fungsi**: Interval refresh data dashboard (metrics, chart, logs)

> **Recommended**: 
> - Network stabil: 10-30 detik
> - Network lambat: 60-120 detik

#### Fire Gallery Refresh
- **Range**: 10 - 300 detik
- **Default**: 30 detik
- **Fungsi**: Interval refresh galeri gambar deteksi api

> **Tips**: 
> - Set lebih tinggi (60-120s) jika bandwidth terbatas
> - Set lebih rendah (10-30s) untuk real-time monitoring

---

### 4. **Fire Detection Gallery**

#### Show Fire Gallery
- **Enable**: Tampilkan section Fire Detection Gallery
- **Disable**: Sembunyikan gallery untuk menghemat bandwidth

#### Max Images to Display
- **Range**: 5 - 50 gambar
- **Default**: 20 gambar
- **Fungsi**: Jumlah maksimal gambar yang ditampilkan dalam gallery

> **Performance Tips**:
> - 5-10 gambar: Untuk koneksi lambat
> - 20-30 gambar: Balanced (recommended)
> - 40-50 gambar: Untuk monitoring intensif

---

## 💾 Penyimpanan Settings

Settings **otomatis tersimpan** di browser menggunakan `localStorage`:

- ✅ **Persistent**: Settings tetap tersimpan meskipun browser ditutup
- ✅ **Per-browser**: Setiap browser memiliki settings sendiri
- ✅ **No account needed**: Tidak perlu login atau akun

## 🔄 Reset Settings

Untuk mengembalikan ke pengaturan default:

1. Buka Settings Panel
2. Klik tombol **"Reset"** di bagian bawah
3. Konfirmasi reset
4. Klik **"Save Changes"**

## ⚡ Quick Settings Presets

### Preset 1: Performance Mode
**Untuk koneksi lambat atau perangkat low-end**
```
✓ Compact Mode: ON
✓ Animations: OFF
✓ Dashboard Refresh: 60s
✓ Gallery Refresh: 120s
✓ Max Images: 10
```

### Preset 2: Real-time Monitoring
**Untuk monitoring aktif dengan koneksi cepat**
```
✓ Compact Mode: OFF
✓ Animations: ON
✓ Dashboard Refresh: 10s
✓ Gallery Refresh: 30s
✓ Max Images: 30
✓ Notifications: ON
✓ Sound: ON
```

### Preset 3: Bandwidth Saver
**Untuk menghemat data/bandwidth**
```
✓ Show Fire Gallery: OFF
✓ Dashboard Refresh: 120s
✓ Notifications: OFF
✓ Sound: OFF
```

## 🎨 UI Features

### Design
- ✨ **Slide-in panel** dari kanan
- 🌓 **Dark mode** support penuh
- 📱 **Responsive** - works on mobile
- 🎯 **Intuitive** - mudah digunakan

### Interactions
- 🎚️ **Sliders** untuk interval settings
- 🔘 **Toggle switches** untuk boolean options
- 🎨 **Visual theme selector** dengan icon
- 💾 **Save indicator** - tahu kapan ada perubahan

### Feedback
- ✅ **Toast notifications** saat save
- ⚠️ **Confirm dialog** saat reset
- 📊 **Real-time preview** untuk theme changes

## 🔧 Technical Details

### Settings Schema

```typescript
interface SettingsConfig {
  // Appearance
  theme: 'light' | 'dark' | 'auto'
  compactMode: boolean
  enableAnimations: boolean
  
  // Notifications
  enableNotifications: boolean
  enableSound: boolean
  
  // Auto-refresh
  autoRefreshInterval: number      // seconds
  galleryRefreshInterval: number   // seconds
  
  // Fire Gallery
  showFireGallery: boolean
  maxGalleryImages: number
}
```

### Default Values

```javascript
{
  theme: 'auto',
  autoRefreshInterval: 30,
  enableNotifications: true,
  enableSound: true,
  showFireGallery: true,
  galleryRefreshInterval: 30,
  maxGalleryImages: 20,
  enableAnimations: true,
  compactMode: false
}
```

### Storage Key
```
localStorage key: 'dashboard-settings'
```

## 🎯 Use Cases

### Use Case 1: 24/7 Monitoring Station
```
Scenario: Dashboard berjalan 24/7 di monitor besar
Settings:
- Theme: Dark (nyaman untuk mata)
- Refresh Interval: 30s (balanced)
- Notifications: OFF (hindari distraksi)
- Gallery: ON dengan 30 images
```

### Use Case 2: Mobile Monitoring
```
Scenario: Monitoring via smartphone/tablet
Settings:
- Compact Mode: ON (hemat space)
- Animations: OFF (hemat battery)
- Max Images: 10-15 (hemat bandwidth)
- Refresh: 60s (hemat data)
```

### Use Case 3: Emergency Response
```
Scenario: Fast response untuk fire detection
Settings:
- Refresh: 10s (real-time)
- Notifications: ON
- Sound: ON
- Gallery: ON dengan 20 images
- Theme: Auto
```

## 📱 Responsive Behavior

### Desktop (≥1024px)
- Full width settings panel (480px)
- Semua fitur visible
- Smooth animations

### Tablet (768px - 1023px)
- Settings panel 480px atau full width jika lebih kecil
- Semua fitur tetap accessible

### Mobile (<768px)
- Settings panel full screen
- Touch-optimized controls
- Scrollable content

## 🎉 Benefits

✅ **Personalization** - Sesuaikan dengan kebutuhan Anda  
✅ **Performance** - Optimize untuk koneksi/device Anda  
✅ **User Experience** - Interface yang nyaman  
✅ **Accessibility** - Theme dan compact mode untuk berbagai kondisi  
✅ **Bandwidth Control** - Hemat data dengan refresh interval  
✅ **Battery Saving** - Disable animations untuk hemat battery  

## 🔜 Coming Soon

Fitur settings yang akan ditambahkan:

- [ ] Keyboard shortcuts customization
- [ ] Export/Import settings (JSON)
- [ ] Settings presets (save multiple configurations)
- [ ] Alert sound customization
- [ ] Language selection
- [ ] Chart time range preferences
- [ ] Log filter preferences
- [ ] Notification position preferences

---

**Enjoy your customized dashboard!** ⚙️🔥

Jika ada saran untuk settings baru, silakan submit feature request!
