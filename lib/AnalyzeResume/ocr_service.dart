import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> extractTextFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    debugPrint("=== OCR SERVICE START ===");
    debugPrint("FILE PATH: ${imageFile.path}");
    debugPrint("BYTES LENGTH: ${bytes.length}");

    if (bytes.isEmpty) {
      throw Exception("Image bytes are empty. File is not readable.");
    }

    final base64Image = base64Encode(bytes);

    debugPrint("BASE64 LENGTH: ${base64Image.length}");
    debugPrint("BASE64 START: ${base64Image.substring(0, 30)}");

    final callable = _functions.httpsCallable("extractTextFromImage");

    final res = await callable.call({
      "imageBase64": base64Image,
    });

    final text = (res.data["text"] ?? "").toString();

    debugPrint("OCR TEXT LENGTH: ${text.length}");
    debugPrint("=== OCR SERVICE END ===");

    return text;
  }
}
