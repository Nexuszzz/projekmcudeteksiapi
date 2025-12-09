/**
 * Video Recording Routes for ESP32-CAM
 * Handles start/stop recording, upload, and video retrieval
 */

import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const router = express.Router();

// In-memory storage for active recordings
const activeRecordings = new Map();

// Video storage directory
const VIDEO_DIR = path.join(__dirname, '../recordings');
if (!fs.existsSync(VIDEO_DIR)) {
  fs.mkdirSync(VIDEO_DIR, { recursive: true });
}

// Multer configuration for video upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, VIDEO_DIR);
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const sanitized = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
    cb(null, `esp32cam_${timestamp}_${sanitized}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 500 * 1024 * 1024 }, // 500 MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = /mp4|avi|mkv|mov|webm/;
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.test(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only video files allowed.'));
    }
  }
});

// Video metadata storage (in-memory for now)
const videoMetadata = [];

/**
 * POST /api/video/start-recording
 * Start recording from ESP32-CAM using ffmpeg
 */
router.post('/start-recording', (req, res) => {
  const { cameraIp, duration, quality } = req.body;

  if (!cameraIp) {
    return res.status(400).json({
      success: false,
      error: 'Camera IP required'
    });
  }

  const streamUrl = `http://${cameraIp}:81/stream`;
  const recordingId = `rec_${Date.now()}`;
  const outputPath = path.join(VIDEO_DIR, `${recordingId}.mp4`);

  console.log(`📹 Starting recording: ${recordingId}`);
  console.log(`   Stream URL: ${streamUrl}`);
  console.log(`   Duration: ${duration || 'unlimited'}s`);
  console.log(`   Output: ${outputPath}`);

  // FFmpeg command for MJPEG stream recording
  const ffmpegArgs = [
    '-y',                          // Overwrite output
    '-f', 'mjpeg',                // Input format
    '-i', streamUrl,              // Input URL
    '-c:v', 'libx264',            // Video codec
    '-preset', quality || 'medium', // Encoding preset
    '-crf', '23',                 // Quality (lower = better)
    '-pix_fmt', 'yuv420p',        // Pixel format for compatibility
  ];

  // Add duration if specified
  if (duration && duration > 0) {
    ffmpegArgs.push('-t', duration.toString());
  }

  ffmpegArgs.push(outputPath);

  console.log(`   FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}`);

  // Spawn ffmpeg process
  const ffmpeg = spawn('ffmpeg', ffmpegArgs);

  // Store active recording info
  activeRecordings.set(recordingId, {
    id: recordingId,
    cameraIp,
    streamUrl,
    outputPath,
    startTime: Date.now(),
    duration: duration || null,
    status: 'recording',
    process: ffmpeg
  });

  // Handle ffmpeg stdout
  ffmpeg.stdout.on('data', (data) => {
    console.log(`[FFmpeg stdout] ${data}`);
  });

  // Handle ffmpeg stderr (progress info)
  ffmpeg.stderr.on('data', (data) => {
    const output = data.toString();
    // Only log important lines
    if (output.includes('frame=') || output.includes('time=')) {
      process.stdout.write(`\r[Recording] ${output.trim().substring(0, 100)}`);
    }
  });

  // Handle recording completion
  ffmpeg.on('close', (code) => {
    const recording = activeRecordings.get(recordingId);
    if (!recording) return;

    console.log(`\n📹 Recording stopped: ${recordingId} (exit code: ${code})`);

    if (code === 0 && fs.existsSync(outputPath)) {
      const stats = fs.statSync(outputPath);
      
      // Save metadata
      videoMetadata.push({
        id: recordingId,
        cameraIp,
        filename: path.basename(outputPath),
        size: stats.size,
        startTime: recording.startTime,
        endTime: Date.now(),
        duration: Math.floor((Date.now() - recording.startTime) / 1000),
        path: `/api/video/recordings/${recordingId}.mp4`,
        status: 'completed'
      });

      console.log(`   ✅ Video saved: ${outputPath}`);
      console.log(`   Size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);
    } else {
      console.log(`   ❌ Recording failed or file not found`);
    }

    activeRecordings.delete(recordingId);
  });

  // Handle errors
  ffmpeg.on('error', (err) => {
    console.error(`❌ FFmpeg error for ${recordingId}:`, err);
    activeRecordings.delete(recordingId);
  });

  res.json({
    success: true,
    recordingId,
    streamUrl,
    outputPath,
    message: 'Recording started successfully'
  });
});

/**
 * POST /api/video/stop-recording/:id
 * Stop active recording
 */
router.post('/stop-recording/:id', (req, res) => {
  const { id } = req.params;
  const recording = activeRecordings.get(id);

  if (!recording) {
    return res.status(404).json({
      success: false,
      error: 'Recording not found or already stopped'
    });
  }

  console.log(`⏹️  Stopping recording: ${id}`);

  // Send SIGINT to ffmpeg (graceful stop)
  if (recording.process && !recording.process.killed) {
    recording.process.kill('SIGINT');
  }

  res.json({
    success: true,
    recordingId: id,
    message: 'Recording stop signal sent'
  });
});

/**
 * GET /api/video/recordings
 * List all recorded videos
 */
router.get('/recordings', (req, res) => {
  res.json({
    success: true,
    recordings: videoMetadata.sort((a, b) => b.startTime - a.startTime),
    activeRecordings: Array.from(activeRecordings.values()).map(r => ({
      id: r.id,
      cameraIp: r.cameraIp,
      startTime: r.startTime,
      duration: r.duration,
      status: r.status
    }))
  });
});

/**
 * GET /api/video/recordings/:filename
 * Stream video file
 */
router.get('/recordings/:filename', (req, res) => {
  const { filename } = req.params;
  const filePath = path.join(VIDEO_DIR, filename);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({
      success: false,
      error: 'Video not found'
    });
  }

  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    // Stream video with range support (for seeking)
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const chunksize = (end - start) + 1;
    const file = fs.createReadStream(filePath, { start, end });

    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'video/mp4',
    };

    res.writeHead(206, head);
    file.pipe(res);
  } else {
    // Stream entire video
    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'video/mp4',
    };

    res.writeHead(200, head);
    fs.createReadStream(filePath).pipe(res);
  }
});

/**
 * POST /api/video/upload
 * Upload recorded video from client (Python script)
 */
router.post('/upload', upload.single('video'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'No video file uploaded'
    });
  }

  const { cameraIp, startTime, duration } = req.body;

  console.log(`📤 Video uploaded: ${req.file.filename}`);
  console.log(`   Size: ${(req.file.size / 1024 / 1024).toFixed(2)} MB`);

  // Save metadata
  videoMetadata.push({
    id: path.parse(req.file.filename).name,
    cameraIp: cameraIp || 'unknown',
    filename: req.file.filename,
    size: req.file.size,
    startTime: parseInt(startTime) || Date.now(),
    endTime: Date.now(),
    duration: parseInt(duration) || 0,
    path: `/api/video/recordings/${req.file.filename}`,
    status: 'uploaded'
  });

  res.json({
    success: true,
    file: {
      filename: req.file.filename,
      size: req.file.size,
      path: `/api/video/recordings/${req.file.filename}`
    }
  });
});

/**
 * DELETE /api/video/recordings/:id
 * Delete recorded video
 */
router.delete('/recordings/:id', (req, res) => {
  const { id } = req.params;
  
  const videoIndex = videoMetadata.findIndex(v => v.id === id);
  if (videoIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Video not found'
    });
  }

  const video = videoMetadata[videoIndex];
  const filePath = path.join(VIDEO_DIR, video.filename);

  // Delete file
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  // Remove from metadata
  videoMetadata.splice(videoIndex, 1);

  console.log(`🗑️  Deleted video: ${id}`);

  res.json({
    success: true,
    message: 'Video deleted successfully'
  });
});

/**
 * GET /api/video/status
 * Get recording system status
 */
router.get('/status', (req, res) => {
  const totalSize = videoMetadata.reduce((sum, v) => sum + v.size, 0);
  
  res.json({
    success: true,
    status: {
      totalVideos: videoMetadata.length,
      totalSize: totalSize,
      totalSizeMB: (totalSize / 1024 / 1024).toFixed(2),
      activeRecordings: activeRecordings.size,
      videoDirectory: VIDEO_DIR
    }
  });
});

export default router;
