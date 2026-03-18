import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VinScanService {
  static final RegExp _vinPattern = RegExp(r'[A-HJ-NPR-Z0-9]{17}');

  static Future<String?> extractVinFromImagePath(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final result = await recognizer.processImage(inputImage);

      final direct = _findVin(result.text);
      if (direct != null) return direct;

      for (final block in result.blocks) {
        final fromBlock = _findVin(block.text);
        if (fromBlock != null) return fromBlock;
      }

      return null;
    } finally {
      await recognizer.close();
    }
  }

  static String? _findVin(String raw) {
    final normalized = raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), ' ');
    final compact = raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    final direct = _vinPattern.firstMatch(normalized);
    if (direct != null) return direct.group(0);

    final compactMatch = _vinPattern.firstMatch(compact);
    if (compactMatch != null) return compactMatch.group(0);

    return null;
  }
}
