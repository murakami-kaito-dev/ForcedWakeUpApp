import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      model: PoseDetectionModel.base,
      mode: PoseDetectionMode.stream,
    ),
  );

  Future<List<Pose>> detectPose(InputImage inputImage) async {
    return await _poseDetector.processImage(inputImage);
  }

  void dispose() {
    _poseDetector.close();
  }
}
