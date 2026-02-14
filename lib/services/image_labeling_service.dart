import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageLabelingService {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.25),
  );

  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    return await _labeler.processImage(inputImage);
  }

  void dispose() {
    _labeler.close();
  }
}
