@echo off
chcp 65001 >nul
echo.
echo ═══════════════════════════════════════════════════════════
echo   🔧 FIX WHATSAPP ERROR 401 - CLEAN RECONNECT
echo ═══════════════════════════════════════════════════════════
echo.
echo Masalah: WhatsApp connect lalu langsung logout (Error 401)
echo Solusi: Hapus session lama dan reconnect dengan pairing baru
echo.
echo ═══════════════════════════════════════════════════════════
echo.

echo [STEP 1] Matikan WhatsApp Server yang sedang berjalan
echo.
echo Tekan Ctrl+C di terminal WhatsApp Server, lalu ketik Y
echo.
pause

echo.
echo [STEP 2] Hapus session lama yang invalid
echo.
cd whatsapp-server
if exist auth_info (
    echo 🗑️  Menghapus folder auth_info...
    rmdir /s /q auth_info
    echo ✅ Session lama berhasil dihapus
) else (
    echo ⚠️  Folder auth_info tidak ditemukan (sudah bersih)
)
echo.
pause

echo.
echo [STEP 3] Restart WhatsApp Server dengan session bersih
echo.
echo 📝 PENTING - Pastikan:
echo    1. Nomor HP sudah dalam format internasional: 628xxx
echo    2. Pairing code langsung dimasukkan (jangan tunggu lama)
echo    3. Internet stabil di HP dan komputer
echo    4. WhatsApp di HP sudah update ke versi terbaru
echo    5. Belum mencapai batas 4 device di multi-device
echo.
pause

echo.
echo [STEP 4] Menjalankan WhatsApp Server...
echo.
start cmd /k "node server.js"

echo.
echo ═══════════════════════════════════════════════════════════
echo   ✅ SERVER STARTED - LAKUKAN PAIRING SEKARANG
echo ═══════════════════════════════════════════════════════════
echo.
echo 📱 CARA PAIRING YANG BENAR:
echo.
echo 1. Buka WhatsApp di HP → Settings → Linked Devices
echo 2. Tap "Link a Device"
echo 3. Masukkan 8-digit pairing code yang muncul di browser
echo 4. Tunggu hingga muncul "✅ WhatsApp Connected Successfully"
echo 5. Jangan logout atau disconnect setelah connected
echo.
echo ⚠️ JANGAN:
echo    - Gunakan pairing code yang sudah expired (>2 menit)
echo    - Disconnect dan reconnect berkali-kali (suspicious activity)
echo    - Gunakan session yang sudah di-logout dari HP
echo.
echo ═══════════════════════════════════════════════════════════
echo.
pause
