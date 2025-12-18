# 📤 Upload YOLO Model to VPS

Model fire detection perlu di-upload ke VPS untuk menjalankan deteksi api.

## Option 1: SCP (Recommended)

Buka terminal/PowerShell dan jalankan:

```powershell
# Upload dari D:\zekk\zakaiot\
scp -i "path/to/your-key.pem" "D:\zekk\zakaiot\fire_yolov8s_ultra_best.pt" ubuntu@3.27.11.106:/home/ubuntu/rtsp-project/python_scripts/
```

## Option 2: Via HTTP Upload

1. Start simple HTTP server di lokal:
```powershell
cd D:\zekk\zakaiot
python -m http.server 8000
```

2. Pastikan port 8000 bisa diakses dari VPS (via ngrok atau port forward)

3. Download dari VPS:
```bash
curl -o /home/ubuntu/rtsp-project/python_scripts/fire_yolov8s_ultra_best.pt http://YOUR_IP:8000/fire_yolov8s_ultra_best.pt
```

## Option 3: Copy ke folder rtsp-main dan commit

1. Copy model ke folder ini:
```powershell
copy "D:\zekk\zakaiot\fire_yolov8s_ultra_best.pt" "D:\rtsp-main\python_scripts\"
```

2. Bisa juga upload via GitHub (model 21MB, max GitHub 100MB)

## After Upload - Test

Setelah upload, test dengan:
```bash
cd /home/ubuntu/rtsp-project/python_scripts
python3 -c "from ultralytics import YOLO; m=YOLO('fire_yolov8s_ultra_best.pt'); print('Model OK')"
```

## Model Files Available

Di laptop kamu ada beberapa model:
- `D:\zekk\zakaiot\fire_yolov8s_ultra_best.pt` (21.5 MB) - **RECOMMENDED**
- `D:\Workspacegabungan\zakaiot\models\fire.pt`
- `D:\yolov10-firedetection\fire.pt`
