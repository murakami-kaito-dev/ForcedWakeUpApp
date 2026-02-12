import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/pose_detection_service.dart';
import '../state/alarm_state.dart';
import '../utils/camera_helper.dart';
import '../utils/exercise_detector.dart';
import '../widgets/pose_painter.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  CameraController? _cameraController;
  final PoseDetectionService _poseService = PoseDetectionService();
  final AudioService _audioService = AudioService();
  late ExerciseDetector _exerciseDetector;

  bool _isProcessing = false;
  bool _isCameraReady = false;
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    final alarmState = context.read<AlarmState>();
    _exerciseDetector = ExerciseDetector(
      exerciseType: alarmState.settings.exerciseType,
    );
    _audioService.playAlarm();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
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
      _onCameraFrame(image, frontCamera);
    });
  }

  void _onCameraFrame(CameraImage image, CameraDescription camera) {
    if (_isProcessing) return;
    _isProcessing = true;

    final inputImage = convertCameraImage(image, camera);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    _poseService.detectPose(inputImage).then((poses) {
      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (poses.isNotEmpty) {
        final landmarks = poses.first.landmarks;
        final reps = _exerciseDetector.processLandmarks(landmarks);

        final alarmState = context.read<AlarmState>();
        alarmState.updateReps(reps);

        if (reps >= AlarmState.targetReps) {
          _audioService.stopAlarm();
          _cameraController?.stopImageStream();
          Navigator.pushReplacementNamed(context, '/completion');
          return;
        }
      }

      setState(() {
        _poses = poses;
      });
      _isProcessing = false;
    }).catchError((_) {
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    _poseService.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();

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
            // Pose overlay
            if (_isCameraReady && _poses.isNotEmpty)
              CustomPaint(
                painter: PosePainter(
                  poses: _poses,
                  imageSize: _imageSize,
                  isFrontCamera: true,
                ),
              ),
            // Rep counter overlay
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
                      alarmState.settings.exerciseType.displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '残り ${alarmState.remainingReps} 回',
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
            // Progress bar
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
                        value: alarmState.completedReps / AlarmState.targetReps,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF533483),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${alarmState.completedReps} / ${AlarmState.targetReps}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
