import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui';

InputImage? convertCameraImage(CameraImage image, CameraDescription camera) {
  const format = InputImageFormat.bgra8888;
  final plane = image.planes.first;

  final inputImageMetadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: _rotationFromSensorOrientation(camera.sensorOrientation),
    format: format,
    bytesPerRow: plane.bytesPerRow,
  );

  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: inputImageMetadata,
  );
}

InputImageRotation _rotationFromSensorOrientation(int sensorOrientation) {
  switch (sensorOrientation) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      return InputImageRotation.rotation270deg;
    default:
      return InputImageRotation.rotation0deg;
  }
}
