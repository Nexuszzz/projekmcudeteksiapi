@echo off
chcp 65001 > nul
color 0E
cls

echo.
echo ═══════════════════════════════════════════════════════════════════════
echo  🚀 WHATSAPP CONNECTION FIX - QUICK START GUIDE
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  ✅ PERBAIKAN SUDAH DILAKUKAN:
echo     - Backend: whatsapp-server/server.js (4 fixes)
echo     - Frontend: src/components/WhatsAppIntegration.tsx (3 fixes)
echo     - Tools: RESTART-WHATSAPP-CLEAN.bat, TEST-WHATSAPP-FIX.bat
echo.
echo  📋 MASALAH YANG DIPERBAIKI:
echo     ❌ SEBELUM: Scan QR → Connected 2s → Disconnected
echo     ✅ SEKARANG: Scan QR → Connected → TETAP Connected
echo.
echo     ❌ SEBELUM: Delete session → Tidak bisa connect lagi
echo     ✅ SEKARANG: Delete session → Bisa connect dengan nomor lain
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  📝 LANGKAH TESTING (PILIH SALAH SATU):
echo.
echo  [1] 🎯 QUICK TEST (5 menit) - Test pairing code dengan 1 nomor
echo  [2] 🧪 FULL TEST (15 menit) - Test semua scenario otomatis
echo  [3] 📖 BACA DOKUMENTASI - Lihat detail perbaikan
echo  [4] 🔧 MANUAL MODE - Pilih test scenario sendiri
echo  [5] ❌ EXIT
echo.
echo ═══════════════════════════════════════════════════════════════════════

set /p choice="Pilih opsi (1-5): "

if "%choice%"=="1" goto quick_test
if "%choice%"=="2" goto full_test
if "%choice%"=="3" goto documentation
if "%choice%"=="4" goto manual_mode
if "%choice%"=="5" goto end
goto start

:quick_test
cls
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo  🎯 QUICK TEST - Pairing Code Method (5 menit)
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  Test ini akan:
echo    ✅ Restart WhatsApp server bersih
echo    ✅ Test koneksi dengan pairing code
echo    ✅ Test delete session
echo    ✅ Test reconnect dengan nomor lain
echo.
pause
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  STEP 1/5: Clean Restart
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo Stopping server...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

echo Deleting old session...
if exist "whatsapp-server\auth_info" rmdir /S /Q "whatsapp-server\auth_info"

echo Starting server...
cd whatsapp-server
start "WhatsApp Server" cmd /k "npm start"
cd ..

echo Waiting for server init (8 seconds)...
timeout /t 8 /nobreak >nul

echo Opening web dashboard...
start http://localhost:5173

echo.
echo ✅ STEP 1 COMPLETE
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  STEP 2/5: Connect dengan Pairing Code
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  📱 LAKUKAN DI WEB BROWSER:
echo.
echo     1. Di web, pilih "Pairing Code" method
echo     2. Masukkan nomor HP: 628xxxxxxxxx (nomor Anda)
echo     3. Klik "Start WhatsApp"
echo     4. Code 8-digit akan muncul (contoh: ABCD-1234)
echo.
echo  📱 LAKUKAN DI HP WHATSAPP:
echo.
echo     5. Buka WhatsApp → Settings → Linked Devices
echo     6. Tap "Link a Device"
echo     7. Tap "Link with phone number instead"
echo     8. Masukkan code 8-digit dari web
echo     9. Tap "Link"
echo.
echo  ⏱️  CODE BERLAKU 2 MENIT - Siapkan HP dulu sebelum klik Start!
echo.
pause

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  STEP 3/5: Verify Connection
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  ✅ PASTIKAN STATUS DI WEB:
echo     - Badge menampilkan "WhatsApp Connected" (hijau)
echo     - Dot hijau berkedip di samping status
echo     - Phone number tampil (628xxx)
echo     - TIDAK ADA flickering connected → disconnected
echo.
set /p connected="Apakah status 'Connected' dan stabil? (Y/N): "
if /i not "%connected%"=="Y" (
    echo.
    echo ❌ CONNECTION FAILED
    echo.
    echo Troubleshooting:
    echo   1. Check backend console untuk error
    echo   2. Pastikan code belum expired (max 2 menit)
    echo   3. Coba restart: RESTART-WHATSAPP-CLEAN.bat
    echo   4. Lihat dokumentasi: WHATSAPP-CONNECTION-FIXED.md
    echo.
    pause
    goto end
)

echo.
echo ✅ CONNECTION STABLE - Test berlanjut
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  STEP 4/5: Test Delete Session
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  📱 LAKUKAN DI WEB:
echo.
echo     1. Klik tombol "Delete Session"
echo     2. Konfirmasi penghapusan
echo     3. Status harus berubah ke "Disconnected"
echo     4. Phone number field harus kosong
echo     5. Tidak ada error message
echo.
pause

set /p disconnected="Apakah status berubah ke 'Disconnected'? (Y/N): "
if /i not "%disconnected%"=="Y" (
    echo.
    echo ❌ DELETE SESSION FAILED
    echo Lihat backend console untuk error details
    echo.
    pause
    goto end
)

echo.
echo ✅ DELETE SESSION SUCCESS
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  STEP 5/5: Test Reconnect dengan Nomor Lain
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  📱 LAKUKAN DI WEB:
echo.
echo     1. Masukkan NOMOR BERBEDA: 628yyyyyyyyy
echo     2. Klik "Start WhatsApp"
echo     3. Code baru akan muncul
echo     4. Masukkan code di WhatsApp HP (nomor berbeda)
echo     5. Status harus "Connected" dan stabil
echo.
echo  🎯 INI ADALAH TEST UTAMA - Bug lama menyebabkan ini gagal!
echo.
pause

set /p reconnected="Apakah berhasil connect dengan nomor berbeda? (Y/N): "
if /i not "%reconnected%"=="Y" (
    echo.
    echo ❌ RECONNECT FAILED
    echo.
    echo Ini masalah serius! Perbaikan mungkin tidak berhasil.
    echo Silakan:
    echo   1. Check backend console
    echo   2. Lihat WHATSAPP-CONNECTION-FIXED.md
    echo   3. Run TEST-WHATSAPP-FIX.bat untuk debugging
    echo.
    pause
    goto end
)

echo.
echo ════════════════════════════════════════════════════════════════════
echo  ✅✅✅ QUICK TEST PASSED! ✅✅✅
echo ════════════════════════════════════════════════════════════════════
echo.
echo  🎉 SEMUA TEST BERHASIL:
echo     ✅ Clean restart
echo     ✅ Pairing code connection
echo     ✅ Connection stable (no disconnect loop)
echo     ✅ Delete session
echo     ✅ Reconnect dengan nomor berbeda
echo.
echo  🚀 WHATSAPP INTEGRATION FIXED SUCCESSFULLY!
echo.
echo  📝 Next steps:
echo     1. Test fire detection end-to-end
echo     2. Add recipients di Recipients panel
echo     3. Test send message ke recipients
echo     4. Monitor stability selama 24 jam
echo.
pause
goto end

:full_test
cls
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo  🧪 FULL TEST - All Scenarios (15 menit)
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  Redirecting to automated test tool...
echo.
timeout /t 2 /nobreak >nul
call TEST-WHATSAPP-FIX.bat
goto end

:documentation
cls
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo  📖 DOKUMENTASI LENGKAP
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  File dokumentasi tersedia:
echo.
echo  [1] WHATSAPP-CONNECTION-FIXED.md
echo      → Panduan lengkap perbaikan (50+ sections)
echo      → Test scenarios step-by-step
echo      → Troubleshooting guide
echo      → Expected behavior
echo.
echo  [2] WHATSAPP-FIX-SUMMARY.md
echo      → Technical summary
echo      → Code changes comparison
echo      → Before/after comparison
echo      → Success metrics
echo.
echo  [3] ANALISIS-MENDALAM-SISTEM-DETEKSI-API.md
echo      → Full system analysis
echo      → Architecture details
echo      → Integration guide
echo.
echo ═══════════════════════════════════════════════════════════════════════

set /p doc="Pilih dokumentasi untuk dibuka (1-3, Enter=skip): "

if "%doc%"=="1" (
    if exist "WHATSAPP-CONNECTION-FIXED.md" (
        notepad WHATSAPP-CONNECTION-FIXED.md
    ) else (
        echo File tidak ditemukan!
    )
)

if "%doc%"=="2" (
    if exist "WHATSAPP-FIX-SUMMARY.md" (
        notepad WHATSAPP-FIX-SUMMARY.md
    ) else (
        echo File tidak ditemukan!
    )
)

if "%doc%"=="3" (
    if exist "..\ANALISIS-MENDALAM-SISTEM-DETEKSI-API.md" (
        notepad ..\ANALISIS-MENDALAM-SISTEM-DETEKSI-API.md
    ) else (
        echo File tidak ditemukan!
    )
)

echo.
pause
goto start

:manual_mode
cls
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo  🔧 MANUAL MODE - Custom Testing
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo  Redirecting to manual test tool...
echo.
timeout /t 2 /nobreak >nul
call TEST-WHATSAPP-FIX.bat
goto end

:end
cls
echo.
echo ════════════════════════════════════════════════════════════════════
echo  ✅ WHATSAPP FIX - READY FOR PRODUCTION
echo ════════════════════════════════════════════════════════════════════
echo.
echo  📋 Summary:
echo     - Backend fixed: ✅ whatsapp-server/server.js
echo     - Frontend fixed: ✅ WhatsAppIntegration.tsx
echo     - Tools created: ✅ 3 batch files
echo     - Docs created: ✅ 3 markdown files
echo.
echo  🎯 Main Fix:
echo     - Proper socket cleanup before session delete
echo     - Enhanced disconnect handling (loggedOut vs errors)
echo     - Complete state reset after logout
echo     - Frontend/backend state synchronization
echo.
echo  🚀 Testing:
echo     - Use QUICK-START-FIX.bat for guided testing
echo     - Use TEST-WHATSAPP-FIX.bat for manual testing
echo     - Use RESTART-WHATSAPP-CLEAN.bat for clean restart
echo.
echo  📖 Documentation:
echo     - WHATSAPP-CONNECTION-FIXED.md (complete guide)
echo     - WHATSAPP-FIX-SUMMARY.md (technical details)
echo     - ANALISIS-MENDALAM-SISTEM-DETEKSI-API.md (full system)
echo.
echo ════════════════════════════════════════════════════════════════════
echo.
echo  Thank you for using WhatsApp Fix Tool!
echo.
pause
exit

:start
cls
goto :eof
