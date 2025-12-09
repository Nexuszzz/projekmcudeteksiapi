@echo off
echo ============================================================================
echo    FIRE DETECTION VIDEO RECORDING - SYSTEM CHECK
echo ============================================================================
echo.

echo [1/6] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo    X Python not found! Install Python 3.8+
    pause
    exit /b 1
) else (
    python --version
    echo    √ Python OK
)
echo.

echo [2/6] Checking required packages...
python -c "import cv2, ultralytics, websocket, requests" 2>nul
if %errorlevel% neq 0 (
    echo    X Missing packages! Run: pip install opencv-python ultralytics websocket-client requests
    pause
    exit /b 1
) else (
    echo    √ All packages installed
)
echo.

echo [3/6] Checking YOLO model...
if exist "D:\zakaiot\fire_yolov8s_ultra_best.pt" (
    echo    √ Model found: fire_yolov8s_ultra_best.pt
) else if exist "D:\zakaiot\fire_training\fire_yolov8n_best.pt" (
    echo    √ Model found: fire_yolov8n_best.pt
) else (
    echo    X YOLO model not found!
    echo      Expected: D:\zakaiot\fire_yolov8s_ultra_best.pt
    pause
    exit /b 1
)
echo.

echo [4/6] Checking recording directories...
if not exist "D:\fire_recordings\" (
    echo    ! Creating D:\fire_recordings\
    mkdir "D:\fire_recordings\"
)
if exist "D:\fire_recordings\" (
    echo    √ Local save dir: D:\fire_recordings\
) else (
    echo    X Cannot create D:\fire_recordings\
    pause
    exit /b 1
)

if not exist "%~dp0proxy-server\recordings\" (
    echo    ! Creating proxy-server\recordings\
    mkdir "%~dp0proxy-server\recordings\"
)
if exist "%~dp0proxy-server\recordings\" (
    echo    √ Upload dir: %~dp0proxy-server\recordings\
) else (
    echo    ! Warning: Upload directory not accessible
)
echo.

echo [5/6] Checking proxy-server status...
netstat -ano | findstr ":8080" >nul 2>&1
if %errorlevel% equ 0 (
    echo    √ Proxy-server running on port 8080
) else (
    echo    X Proxy-server NOT running!
    echo      Start with: cd proxy-server ^&^& npm start
    echo.
    echo    Continue anyway? (Y/N)
    set /p continue=
    if /i not "%continue%"=="Y" exit /b 1
)
echo.

echo [6/6] Checking configuration...
echo    - YOLO Detection Threshold: 0.25
echo    - Fallback YOLO Threshold: 0.60 (high-confidence only)
echo    - Gemini Threshold: 0.40
echo    - Record Duration: 30 seconds
echo    - Record Cooldown: 60 seconds
echo    - Fallback Mode: ENABLED
echo.

echo ============================================================================
echo    SYSTEM STATUS: READY
echo ============================================================================
echo.
echo Files will be saved to:
echo   Local:    D:\fire_recordings\
echo   Uploaded: %~dp0proxy-server\recordings\
echo.
echo Web Dashboard:
echo   http://localhost:5173/live-stream
echo.
echo ============================================================================
echo.
echo Starting fire detection in 3 seconds...
timeout /t 3 >nul

cd /d "%~dp0\python_scripts"
python fire_detect_record_ultimate.py

pause
