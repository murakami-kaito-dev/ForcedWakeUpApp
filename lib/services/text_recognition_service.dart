import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  // japanese script recognizer supports Japanese, Chinese, Korean AND Latin
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.japanese);

  Future<RecognizedText> processImage(InputImage inputImage) async {
    return await _recognizer.processImage(inputImage);
  }

  void dispose() {
    _recognizer.close();
  }
}
