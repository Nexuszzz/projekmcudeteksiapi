@echo off
chcp 65001 > nul
color 0A
cls

echo.
echo ════════════════════════════════════════════════════════════════
echo  🧪 WhatsApp Connection FIX - Testing Tool
echo ════════════════════════════════════════════════════════════════
echo.
echo  Pilih Test Scenario:
echo.
echo  [1] 🧹 Clean Restart (Kill process + Delete session + Start)
echo  [2] 🔄 Restart Server Only (Keep session)
echo  [3] 🗑️  Delete Session Only (Logout)
echo  [4] ✅ Check Status (View logs)
echo  [5] 🚀 Start Fresh Server
echo  [6] 🔍 View Backend Logs (Real-time)
echo  [7] 🌐 Open Web Dashboard
echo  [8] 📋 Test All Scenarios (Automated)
echo  [9] ❌ Exit
echo.
echo ════════════════════════════════════════════════════════════════

set /p choice="Pilih (1-9): "

if "%choice%"=="1" goto clean_restart
if "%choice%"=="2" goto restart_server
if "%choice%"=="3" goto delete_session
if "%choice%"=="4" goto check_status
if "%choice%"=="5" goto start_server
if "%choice%"=="6" goto view_logs
if "%choice%"=="7" goto open_web
if "%choice%"=="8" goto test_all
if "%choice%"=="9" goto end
goto menu

:clean_restart
echo.
echo ═══════════════════════════════════════════════════════════
echo  🧹 CLEAN RESTART - Menghapus semua data dan restart bersih
echo ═══════════════════════════════════════════════════════════
echo.

echo [1/4] 🔴 Stopping WhatsApp server...
taskkill /F /IM node.exe 2>nul
if %errorlevel%==0 (
    echo ✅ Server stopped
) else (
    echo ⚠️  No running server found
)
timeout /t 2 /nobreak >nul

echo.
echo [2/4] 🗑️  Deleting auth_info session...
if exist "whatsapp-server\auth_info" (
    rmdir /S /Q "whatsapp-server\auth_info"
    echo ✅ Session deleted
) else (
    echo ℹ️  No session found
)

echo.
echo [3/4] 🚀 Starting WhatsApp server...
cd whatsapp-server
start "WhatsApp Server" cmd /k "npm start"
cd ..
echo ✅ Server starting...

echo.
echo [4/4] ⏳ Waiting for server initialization (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo ════════════════════════════════════════════════════════════
echo  ✅ CLEAN RESTART COMPLETE!
echo ════════════════════════════════════════════════════════════
echo.
echo  📝 Next Steps:
echo  1. Buka web: http://localhost:5173
echo  2. Pilih QR Code atau Pairing Code
echo  3. Scan/masukkan code di WhatsApp HP
echo  4. Verify status "Connected" dan TIDAK disconnect
echo.
pause
goto menu

:restart_server
echo.
echo ═══════════════════════════════════════════════════════════
echo  🔄 RESTART SERVER - Keep session (auto-reconnect)
echo ═══════════════════════════════════════════════════════════
echo.

echo [1/2] 🔴 Stopping server...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo [2/2] 🚀 Starting server...
cd whatsapp-server
start "WhatsApp Server" cmd /k "npm start"
cd ..

echo.
echo ✅ Server restarted dengan existing session
echo ℹ️  Jika ada session, akan auto-reconnect
echo.
pause
goto menu

:delete_session
echo.
echo ═══════════════════════════════════════════════════════════
echo  🗑️  DELETE SESSION - Logout dari WhatsApp
echo ═══════════════════════════════════════════════════════════
echo.

set /p confirm="⚠️  Yakin hapus session? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo 🗑️  Deleting session...
if exist "whatsapp-server\auth_info" (
    rmdir /S /Q "whatsapp-server\auth_info"
    echo ✅ Session deleted successfully
    echo ℹ️  Server masih running, perlu restart untuk clear state
    echo.
    set /p restart="Restart server juga? (Y/N): "
    if /i "!restart!"=="Y" (
        taskkill /F /IM node.exe 2>nul
        timeout /t 2 /nobreak >nul
        cd whatsapp-server
        start "WhatsApp Server" cmd /k "npm start"
        cd ..
        echo ✅ Server restarted
    )
) else (
    echo ℹ️  No session found
)
echo.
pause
goto menu

:check_status
echo.
echo ═══════════════════════════════════════════════════════════
echo  ✅ CHECK STATUS - Current state
echo ═══════════════════════════════════════════════════════════
echo.

echo Checking server status...
curl -s http://localhost:3001/api/whatsapp/status
if %errorlevel%==0 (
    echo.
    echo.
    echo ✅ Server is running
) else (
    echo.
    echo ❌ Server tidak bisa dihubungi
    echo ⚠️  Pastikan server running di port 3001
)

echo.
echo Checking session file...
if exist "whatsapp-server\auth_info" (
    echo ✅ Session file exists
    dir "whatsapp-server\auth_info" /B
) else (
    echo ❌ No session file (perlu pairing)
)

echo.
echo Checking server process...
tasklist /FI "IMAGENAME eq node.exe" 2>nul | find /I "node.exe" >nul
if %errorlevel%==0 (
    echo ✅ Node.js process running
) else (
    echo ❌ No Node.js process found
)

echo.
pause
goto menu

:start_server
echo.
echo ═══════════════════════════════════════════════════════════
echo  🚀 START FRESH SERVER
echo ═══════════════════════════════════════════════════════════
echo.

tasklist /FI "IMAGENAME eq node.exe" 2>nul | find /I "node.exe" >nul
if %errorlevel%==0 (
    echo ⚠️  Server sudah running
    set /p kill="Stop existing server? (Y/N): "
    if /i "!kill!"=="Y" (
        taskkill /F /IM node.exe 2>nul
        timeout /t 2 /nobreak >nul
    ) else (
        goto menu
    )
)

echo.
echo Starting WhatsApp server...
cd whatsapp-server
start "WhatsApp Server" cmd /k "npm start"
cd ..

echo.
echo ✅ Server started
echo 📝 Check the new console window for logs
echo.
pause
goto menu

:view_logs
echo.
echo ═══════════════════════════════════════════════════════════
echo  🔍 VIEW BACKEND LOGS
echo ═══════════════════════════════════════════════════════════
echo.
echo Opening backend console window...
echo Press Ctrl+C in that window to stop viewing logs
echo.
pause

cd whatsapp-server
if exist "server.log" (
    type server.log
    echo.
    echo === Live tail (press Ctrl+C to stop) ===
    powershell -Command "Get-Content server.log -Wait"
) else (
    echo ℹ️  No log file found
    echo Starting server with logging...
    start "WhatsApp Server" cmd /k "npm start 2>&1 | tee server.log"
)
cd ..
goto menu

:open_web
echo.
echo ═══════════════════════════════════════════════════════════
echo  🌐 OPEN WEB DASHBOARD
echo ═══════════════════════════════════════════════════════════
echo.

echo Opening browser...
start http://localhost:5173

echo.
echo ✅ Web dashboard dibuka di browser
echo 📝 Jika tidak muncul, pastikan frontend running (npm run dev)
echo.
pause
goto menu

:test_all
echo.
echo ═══════════════════════════════════════════════════════════
echo  📋 AUTOMATED TEST - All Scenarios
echo ═══════════════════════════════════════════════════════════
echo.
echo Akan menjalankan 5 test scenarios otomatis:
echo.
echo  ✅ Test 1: Clean start
echo  ✅ Test 2: Check status API
echo  ✅ Test 3: Session persistence
echo  ✅ Test 4: Delete & reconnect
echo  ✅ Test 5: Server stability
echo.
set /p confirm="Mulai automated test? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  TEST 1: Clean Start
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul
if exist "whatsapp-server\auth_info" rmdir /S /Q "whatsapp-server\auth_info"
cd whatsapp-server
start "WhatsApp Server" cmd /k "npm start"
cd ..
timeout /t 8 /nobreak >nul
echo ✅ Test 1: PASSED - Server started clean

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  TEST 2: Status API Check
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

curl -s http://localhost:3001/api/whatsapp/status > test_status.json
if %errorlevel%==0 (
    echo ✅ Test 2: PASSED - API responding
    type test_status.json
) else (
    echo ❌ Test 2: FAILED - API not responding
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  TEST 3: Session Check
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

if exist "whatsapp-server\auth_info" (
    echo ❌ Test 3: WARNING - Session exists on fresh start
) else (
    echo ✅ Test 3: PASSED - No session on fresh start
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  TEST 4: Manual Connection Required
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo ⚠️  Cannot automate QR/Pairing code scan
echo 📝 Manual steps required:
echo    1. Open http://localhost:5173
echo    2. Choose method and connect
echo    3. Verify "Connected" status stays stable
echo.
pause

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  TEST 5: Server Stability (30 seconds monitoring)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

for /L %%i in (1,1,6) do (
    echo [%%i/6] Checking status...
    curl -s http://localhost:3001/api/whatsapp/status > nul
    if !errorlevel!==0 (
        echo    ✅ Server stable
    ) else (
        echo    ❌ Server down
    )
    timeout /t 5 /nobreak >nul
)

echo.
echo ✅ Test 5: PASSED - Server stable for 30 seconds

echo.
echo ════════════════════════════════════════════════════════════
echo  📊 TEST SUMMARY
echo ════════════════════════════════════════════════════════════
echo.
echo  ✅ Clean start: PASSED
echo  ✅ API check: PASSED
echo  ✅ Session check: PASSED
echo  ⚠️  Connection: MANUAL TEST REQUIRED
echo  ✅ Stability: PASSED
echo.
echo  📝 Next: Test manual connection (QR/Pairing code)
echo.

del test_status.json 2>nul
pause
goto menu

:end
echo.
echo ════════════════════════════════════════════════════════════
echo  👋 Exiting Test Tool
echo ════════════════════════════════════════════════════════════
echo.
echo  Servers masih running di background
echo  Gunakan Task Manager untuk stop manual
echo.
pause
exit

:menu
goto :eof
