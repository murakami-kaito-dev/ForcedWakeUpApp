import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({
    required this.poses,
    required this.imageSize,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 8
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw landmarks
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(landmark, size);
        canvas.drawCircle(point, 4, pointPaint);
      }

      // Draw skeleton connections
      _drawLine(canvas, pose, PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftElbow, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftElbow,
          PoseLandmarkType.leftWrist, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.rightElbow,
          PoseLandmarkType.rightWrist, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftHip, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightHip, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftHip,
          PoseLandmarkType.rightHip, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftHip,
          PoseLandmarkType.leftKnee, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.leftKnee,
          PoseLandmarkType.leftAnkle, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.rightHip,
          PoseLandmarkType.rightKnee, size, paint);
      _drawLine(canvas, pose, PoseLandmarkType.rightKnee,
          PoseLandmarkType.rightAnkle, size, paint);
    }
  }

  Offset _translatePoint(PoseLandmark landmark, Size canvasSize) {
    final scaleX = canvasSize.width / imageSize.width;
    final scaleY = canvasSize.height / imageSize.height;

    double x = landmark.x * scaleX;
    final y = landmark.y * scaleY;

    if (isFrontCamera) {
      x = canvasSize.width - x;
    }

    return Offset(x, y);
  }

  void _drawLine(Canvas canvas, Pose pose, PoseLandmarkType type1,
      PoseLandmarkType type2, Size size, Paint paint) {
    final landmark1 = pose.landmarks[type1];
    final landmark2 = pose.landmarks[type2];
    if (landmark1 == null || landmark2 == null) return;

    canvas.drawLine(
      _translatePoint(landmark1, size),
      _translatePoint(landmark2, size),
      paint,
    );
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) => true;
}
