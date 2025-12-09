@echo off
echo ========================================================================
echo 🔍 VOICE CALL SERVER DIAGNOSTIC
echo ========================================================================
echo.

REM Check if curl is available
where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  curl not found, using PowerShell instead...
    set USE_POWERSHELL=1
) else (
    set USE_POWERSHELL=0
)

echo 🔍 Test 1: Check if port 3002 is in use...
netstat -ano | findstr ":3002" >nul
if %errorlevel%==0 (
    echo ✅ Port 3002 is IN USE
    netstat -ano | findstr ":3002"
    echo.
) else (
    echo ❌ Port 3002 is NOT IN USE
    echo.
    echo 🔧 Voice-call-server is NOT RUNNING!
    echo.
    echo Fix:
    echo   Run: START-VOICE-SERVER-ONLY.bat
    echo.
    pause
    exit /b 1
)

echo.
echo 🔍 Test 2: Check /health endpoint...
echo.

if %USE_POWERSHELL%==1 (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/health' -UseBasicParsing; Write-Host '✅ Health endpoint OK'; Write-Host 'Response:'; $response.Content } catch { Write-Host '❌ Health endpoint FAILED'; Write-Host $_.Exception.Message }"
) else (
    curl -s http://localhost:3002/health
    if %errorlevel%==0 (
        echo.
        echo ✅ Health endpoint OK
    ) else (
        echo.
        echo ❌ Health endpoint FAILED
    )
)

echo.
echo.
echo 🔍 Test 3: Check /api/voice-call/config endpoint...
echo.

if %USE_POWERSHELL%==1 (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/voice-call/config' -UseBasicParsing; Write-Host '✅ Config endpoint OK'; Write-Host 'Response:'; $response.Content } catch { Write-Host '❌ Config endpoint FAILED'; Write-Host $_.Exception.Message }"
) else (
    curl -s http://localhost:3002/api/voice-call/config
    if %errorlevel%==0 (
        echo.
        echo ✅ Config endpoint OK
    ) else (
        echo.
        echo ❌ Config endpoint FAILED
    )
)

echo.
echo.
echo 🔍 Test 4: Check /api/voice-call/numbers endpoint...
echo.

if %USE_POWERSHELL%==1 (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3002/api/voice-call/numbers' -UseBasicParsing; Write-Host '✅ Numbers endpoint OK'; Write-Host 'Response:'; $response.Content } catch { Write-Host '❌ Numbers endpoint FAILED'; Write-Host $_.Exception.Message }"
) else (
    curl -s http://localhost:3002/api/voice-call/numbers
    if %errorlevel%==0 (
        echo.
        echo ✅ Numbers endpoint OK
    ) else (
        echo.
        echo ❌ Numbers endpoint FAILED
    )
)

echo.
echo ========================================================================
echo 📊 DIAGNOSTIC SUMMARY
echo ========================================================================
echo.
echo If all tests show ✅ OK:
echo   - Server is running correctly
echo   - Refresh dashboard (Ctrl+R)
echo   - Error should be gone
echo.
echo If any test shows ❌ FAILED:
echo   - Check voice-call-server terminal for errors
echo   - Restart server: START-VOICE-SERVER-ONLY.bat
echo   - Check .env file has correct Twilio credentials
echo.
echo If you see HTML instead of JSON:
echo   - Server is returning wrong content
echo   - Stop server and restart
echo   - Check server.js for syntax errors
echo.
pause
