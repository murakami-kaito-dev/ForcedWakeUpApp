import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    hide DetectionMode;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class StudyDetector {
  final String missionId;

  // Reading: detect book-like objects via image labeling
  static const _bookLabels = [
    'paper',
    // 'book',
    // 'publication',
    // 'document',
    // 'text',
    // 'page',
    // 'notebook',
  ];

  // Reading: minimum number of recognized characters to count as "text present"
  static const _minTextLength = 20;

  // Studying: detect pen/writing tool via image labeling
  static const _studyLabels = [
    'pen',
    'pencil',
    'writing',
    'stationery',
    'office supplies',
  ];

  StudyDetector({required this.missionId});

  /// Reading: check image labels for book-related items AND text presence
  bool isBookDetected(List<ImageLabel> labels, RecognizedText recognizedText) {
    final labelNames = labels.map((l) => l.label.toLowerCase()).toList();
    final hasPaper = _hasAnyMatch(labelNames, _bookLabels);
    final hasText = recognizedText.text.trim().length >= _minTextLength;
    return hasPaper && hasText;
  }

  /// Studying: check if any detected object has an elongated shape
  /// Uses both object detection AND image labeling to avoid false positives
  bool isElongatedObjectDetected(
      List<DetectedObject> objects, List<ImageLabel> labels) {
    // First check: if image labeling detects pen/writing directly, trust it
    final labelNames = labels.map((l) => l.label.toLowerCase()).toList();
    if (_hasAnyMatch(labelNames, _studyLabels)) {
      return true;
    }

    // Second check: look for elongated objects that are NOT fingers/hands
    // Fingers are small elongated objects; pens are larger relative to image
    for (final obj in objects) {
      final rect = obj.boundingBox;
      final w = rect.width;
      final h = rect.height;
      if (w == 0 || h == 0) continue;

      final aspectRatio = w > h ? w / h : h / w;
      final shortSide = w < h ? w : h;

      // Elongated (aspect ratio > 2.5) AND not too thin (short side > 15px)
      // Fingers typically have short side < 15px, pens are thicker in frame
      if (aspectRatio > 2.5 && shortSide > 15) {
        return true;
      }
    }

    return false;
  }

  /// Returns true if any of [labelNames] exactly matches any of [targets].
  /// Used to check ML Kit labels against predefined target labels.
  bool _hasAnyMatch(List<String> labelNames, List<String> targets) {
    for (final name in labelNames) {
      for (final target in targets) {
        // Partioal Match
        // if (name.contains(target)) return true;

        // Exact Match
        if (name == target) return true;
      }
    }
    return false;
  }
}
