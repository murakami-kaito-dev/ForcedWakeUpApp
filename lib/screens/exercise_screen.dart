import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as mlkit_od;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import '../models/mission_type.dart';
import '../services/audio_service.dart';
import '../services/pose_detection_service.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../services/image_labeling_service.dart';
import '../state/alarm_state.dart';
import '../utils/camera_helper.dart';
import '../utils/exercise_detector.dart';
import '../utils/study_detector.dart';
import '../widgets/pose_painter.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  CameraController? _cameraController;
  CameraDescription? _camera;
  PoseDetectionService? _poseService;
  ImageLabelingService? _labelingService;
  mlkit_od.ObjectDetector? _objectDetector;
  final AudioService _audioService = AudioService();

  late MissionType _mission;
  ExerciseDetector? _exerciseDetector;
  StudyDetector? _studyDetector;

  bool _isProcessing = false;
  bool _isCameraReady = false;
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;

  // For duration-based missions
  int _detectedSeconds = 0;
  bool _isCurrentlyDetected = false;
  Timer? _durationTimer;

  // Auto-stop timer (10 minutes)
  static const _autoStopMinutes = 10;
  Timer? _autoStopTimer;
  Timer? _autoStopDisplayTimer;
  late DateTime _autoStopDeadline;
  String _autoStopRemaining = '';

  @override
  void initState() {
    super.initState();
    final alarmState = context.read<AlarmState>();
    _mission = alarmState.missionType;
    _currentDirection = _mission.detectionMode == DetectionMode.durationBased
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    if (_mission.detectionMode == DetectionMode.repBased) {
      _poseService = PoseDetectionService();
      _exerciseDetector = ExerciseDetector(missionId: _mission.id);
    } else {
      _labelingService = ImageLabelingService();
      _studyDetector = StudyDetector(missionId: _mission.id);
      if (_mission.id == 'studying') {
        _objectDetector = mlkit_od.ObjectDetector(
          options: mlkit_od.ObjectDetectorOptions(
            mode: mlkit_od.DetectionMode.stream,
            classifyObjects: false,
            multipleObjects: true,
          ),
        );
      }
      _startDurationTimer();
    }

    final settings = alarmState.settings;
    _audioService.playAlarm(
      soundId: settings.alarmSoundId,
      volume: settings.alarmVolume,
      customSoundPath: settings.customSoundPath,
    );

    _startAutoStopTimer();
    _initCamera();
  }

  void _startAutoStopTimer() {
    _autoStopDeadline =
        DateTime.now().add(const Duration(minutes: _autoStopMinutes));
    _autoStopTimer = Timer(const Duration(minutes: _autoStopMinutes), () {
      _audioService.stopAlarm();
      if (mounted) {
        context.read<AlarmState>().resetAlarm();
        Navigator.pushReplacementNamed(context, '/');
      }
    });
    // Update display every second
    _autoStopDisplayTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _autoStopDeadline.difference(DateTime.now());
      if (remaining.isNegative) return;
      setState(() {
        final m = remaining.inMinutes;
        final s = remaining.inSeconds % 60;
        _autoStopRemaining = '$m:${s.toString().padLeft(2, '0')}';
      });
    });
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_isCurrentlyDetected) {
        _detectedSeconds++;
        final alarmState = context.read<AlarmState>();
        alarmState.updateCount(_detectedSeconds);

        if (_detectedSeconds >= alarmState.targetCount) {
          _audioService.stopAlarm();
          _cameraController?.stopImageStream().catchError((_) {});
          Navigator.pushReplacementNamed(context, '/completion');
        }
      }
    });
  }

  CameraLensDirection _currentDirection = CameraLensDirection.front;

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _camera = cameras.firstWhere(
      (c) => c.lensDirection == _currentDirection,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      _camera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraReady = true;
      _imageSize = Size(
        _cameraController!.value.previewSize!.height,
        _cameraController!.value.previewSize!.width,
      );
    });

    _cameraController!.startImageStream((image) {
      _onCameraFrame(image);
    });
  }

  void _onCameraFrame(CameraImage image) {
    if (_isProcessing || _camera == null) return;
    _isProcessing = true;

    final inputImage = convertCameraImage(image, _camera!);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    if (_mission.detectionMode == DetectionMode.repBased) {
      _processRepBased(inputImage);
    } else {
      _processDurationBased(inputImage);
    }
  }

  void _processRepBased(InputImage inputImage) {
    _poseService!.detectPose(inputImage).then((poses) {
      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (poses.isNotEmpty) {
        final landmarks = poses.first.landmarks;
        final reps = _exerciseDetector!.processLandmarks(landmarks);

        final alarmState = context.read<AlarmState>();
        alarmState.updateCount(reps);

        if (reps >= alarmState.targetCount) {
          _audioService.stopAlarm();
          _cameraController?.stopImageStream().catchError((_) {});
          Navigator.pushReplacementNamed(context, '/completion');
          return;
        }
      }

      setState(() => _poses = poses);
      _isProcessing = false;
    }).catchError((_) {
      _isProcessing = false;
    });
  }

  void _processDurationBased(InputImage inputImage) {
    if (_mission.id == 'studying' && _objectDetector != null) {
      // Studying: use both object detection and image labeling
      Future.wait([
        _objectDetector!.processImage(inputImage),
        _labelingService!.processImage(inputImage),
      ]).then((results) {
        if (!mounted) {
          _isProcessing = false;
          return;
        }
        final objects = results[0] as List<mlkit_od.DetectedObject>;
        final labels = results[1] as List<ImageLabel>;
        final detected =
            _studyDetector!.isElongatedObjectDetected(objects, labels);
        setState(() => _isCurrentlyDetected = detected);
        _isProcessing = false;
      }).catchError((_) {
        _isProcessing = false;
      });
    } else {
      // Reading: use image labeling to find books
      _labelingService!.processImage(inputImage).then((labels) {
        if (!mounted) {
          _isProcessing = false;
          return;
        }
        final detected = _studyDetector!.isBookDetected(labels);
        setState(() => _isCurrentlyDetected = detected);
        _isProcessing = false;
      }).catchError((_) {
        _isProcessing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    _currentDirection = _currentDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await _reloadCamera();
  }

  Future<void> _reloadCamera() async {
    await _cameraController?.stopImageStream().catchError((_) {});
    await _cameraController?.dispose();
    _poseService?.dispose();

    setState(() {
      _isCameraReady = false;
      _poses = [];
    });

    if (_mission.detectionMode == DetectionMode.repBased) {
      _poseService = PoseDetectionService();
    }

    await _initCamera();
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _autoStopDisplayTimer?.cancel();
    _durationTimer?.cancel();
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    _poseService?.dispose();
    _labelingService?.dispose();
    _objectDetector?.close();
    _audioService.dispose();
    super.dispose();
  }

  void _showSkipDetectionDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '検知をスキップしますか？',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        content: const Text(
          '実際に本やペンを用意しているのに検知されない場合、今日は達成扱いにできます。',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('戻る',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _audioService.stopAlarm();
              _cameraController?.stopImageStream().catchError((_) {});
              Navigator.pushReplacementNamed(context, '/completion');
            },
            child: const Text('達成にする',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '本当にやめますか？',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        content: const Text(
          'アラームを停止してホーム画面に戻ります。',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('続ける',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _audioService.stopAlarm();
              _cameraController?.stopImageStream().catchError((_) {});
              context.read<AlarmState>().resetAlarm();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('やめる',
                style: TextStyle(color: Color(0xFFE94560))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final isDurationBased =
        _mission.detectionMode == DetectionMode.durationBased;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (_isCameraReady && _cameraController != null)
              CameraPreview(_cameraController!)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            // Pose overlay (rep-based only)
            if (_isCameraReady && _poses.isNotEmpty)
              CustomPaint(
                painter: PosePainter(
                  poses: _poses,
                  imageSize: _imageSize,
                  isFrontCamera: _camera?.lensDirection == CameraLensDirection.front,
                ),
              ),
            // Top overlay - counter
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _mission.displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isDurationBased) ...[
                      Text(
                        '残り ${alarmState.remainingCount} 秒',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isCurrentlyDetected)
                        const Text(
                          '検出中...',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 16,
                          ),
                        )
                      else
                        const Text(
                          '対象物をカメラに映してください',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 14,
                          ),
                        ),
                    ] else
                      Text(
                        '残り ${alarmState.remainingCount} 回',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Auto-stop remaining time (top-left)
            if (_autoStopRemaining.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 16,
                child: Text(
                  _autoStopRemaining,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            // Camera controls (top-right)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white70, size: 28),
                    onPressed: _switchCamera,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70, size: 28),
                    onPressed: _reloadCamera,
                  ),
                ],
              ),
            ),
            // Bottom overlay - progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  top: 16,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: alarmState.completedCount /
                            alarmState.targetCount,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF533483),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${alarmState.completedCount} / ${alarmState.targetCount}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (isDurationBased) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showSkipDetectionDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'うまく検知できない場合',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showQuitDialog,
                      child: Text(
                        '今日はやめる',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
