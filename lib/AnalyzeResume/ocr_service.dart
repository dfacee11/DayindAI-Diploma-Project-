import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';

class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> extractTextFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    print("=== OCR SERVICE START ===");
    print("FILE PATH: ${imageFile.path}");
    print("BYTES LENGTH: ${bytes.length}");

    if (bytes.isEmpty) {
      throw Exception("Image bytes are empty. File is not readable.");
    }

    final base64Image = base64Encode(bytes);

    print("BASE64 LENGTH: ${base64Image.length}");
    print("BASE64 START: ${base64Image.substring(0, 30)}");

    final callable = _functions.httpsCallable("extractTextFromImage");

    final res = await callable.call({
      "imageBase64": base64Image,
    });

    final text = (res.data["text"] ?? "").toString();

    print("OCR TEXT LENGTH: ${text.length}");
    print("=== OCR SERVICE END ===");

    return text;
  }
}