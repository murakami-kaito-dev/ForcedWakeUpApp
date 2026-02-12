import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_type.dart';
import 'angle_calculator.dart';

class ExerciseDetector {
  final ExerciseType exerciseType;

  int _repCount = 0;
  bool _isInDownPosition = false;
  DateTime? _lastRepTime;

  static const _squatDownThreshold = 100.0;
  static const _squatUpThreshold = 160.0;
  static const _pushUpDownThreshold = 90.0;
  static const _pushUpUpThreshold = 160.0;
  static const _debounceMs = 500;

  int get repCount => _repCount;

  ExerciseDetector({required this.exerciseType});

  int processLandmarks(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    switch (exerciseType) {
      case ExerciseType.squat:
        return _processSquat(landmarks);
      case ExerciseType.pushUp:
        return _processPushUp(landmarks);
    }
  }

  double? _tryCalculateAngle(
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    PoseLandmarkType typeA,
    PoseLandmarkType typeB,
    PoseLandmarkType typeC,
  ) {
    final a = landmarks[typeA];
    final b = landmarks[typeB];
    final c = landmarks[typeC];
    if (a == null || b == null || c == null) return null;

    return calculateAngle(
      Point(a.x, a.y),
      Point(b.x, b.y),
      Point(c.x, c.y),
    );
  }

  double? _getKneeAngle(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftAngle = _tryCalculateAngle(
      landmarks,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    );
    final rightAngle = _tryCalculateAngle(
      landmarks,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    );

    if (leftAngle != null && rightAngle != null) {
      return (leftAngle + rightAngle) / 2;
    }
    return leftAngle ?? rightAngle;
  }

  double? _getElbowAngle(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftAngle = _tryCalculateAngle(
      landmarks,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    final rightAngle = _tryCalculateAngle(
      landmarks,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );

    if (leftAngle != null && rightAngle != null) {
      return (leftAngle + rightAngle) / 2;
    }
    return leftAngle ?? rightAngle;
  }

  bool _canCountRep() {
    if (_lastRepTime == null) return true;
    return DateTime.now().difference(_lastRepTime!).inMilliseconds >
        _debounceMs;
  }

  int _processSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final angle = _getKneeAngle(landmarks);
    if (angle == null) return _repCount;

    if (!_isInDownPosition && angle < _squatDownThreshold) {
      _isInDownPosition = true;
    } else if (_isInDownPosition &&
        angle > _squatUpThreshold &&
        _canCountRep()) {
      _isInDownPosition = false;
      _repCount++;
      _lastRepTime = DateTime.now();
    }
    return _repCount;
  }

  int _processPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final angle = _getElbowAngle(landmarks);
    if (angle == null) return _repCount;

    if (!_isInDownPosition && angle < _pushUpDownThreshold) {
      _isInDownPosition = true;
    } else if (_isInDownPosition &&
        angle > _pushUpUpThreshold &&
        _canCountRep()) {
      _isInDownPosition = false;
      _repCount++;
      _lastRepTime = DateTime.now();
    }
    return _repCount;
  }

  void reset() {
    _repCount = 0;
    _isInDownPosition = false;
    _lastRepTime = null;
  }
}
