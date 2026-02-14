import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';

class ExerciseDetector {
  final String missionId;

  int _repCount = 0;
  bool _isInDownPosition = false;
  DateTime? _lastRepTime;

  // Squat thresholds
  static const _squatDownThreshold = 100.0;
  static const _squatUpThreshold = 160.0;

  // Push-up thresholds
  static const _pushUpDownThreshold = 90.0;
  static const _pushUpUpThreshold = 160.0;

  // Burpee thresholds (shoulder-to-hip Y ratio)
  static const _burpeeDownRatio = 0.85;
  static const _burpeeUpRatio = 0.55;

  static const _debounceMs = 500;

  int get repCount => _repCount;

  ExerciseDetector({required this.missionId});

  int processLandmarks(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    switch (missionId) {
      case 'squat':
        return _processSquat(landmarks);
      case 'pushUp':
        return _processPushUp(landmarks);
      case 'burpee':
        return _processBurpee(landmarks);
      default:
        return _repCount;
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

  int _processBurpee(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftHip == null ||
        rightHip == null) return _repCount;

    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final avgHipY = (leftHip.y + rightHip.y) / 2;

    if (avgHipY == 0) return _repCount;

    // In image coordinates, Y increases downward
    // When prone, shoulder Y approaches hip Y (ratio close to 1)
    final ratio = avgShoulderY / avgHipY;

    if (!_isInDownPosition && ratio > _burpeeDownRatio) {
      _isInDownPosition = true;
    } else if (_isInDownPosition &&
        ratio < _burpeeUpRatio &&
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
