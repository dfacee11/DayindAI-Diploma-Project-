import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';

class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> extractTextFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    if (bytes.isEmpty) throw Exception("Image bytes are empty. File is not readable.");

    final base64Image = base64Encode(bytes);
    final callable = _functions.httpsCallable("extractTextFromImage");
    final res = await callable.call({"imageBase64": base64Image});

    return (res.data["text"] ?? "").toString();
  }
}