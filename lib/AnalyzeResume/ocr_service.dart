import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';

class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> extractText(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      return _extractFromPdf(file);
    } else {
      return _extractFromImage(file);
    }
  }

  Future<String> _extractFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) throw Exception("Image file is empty");

    final base64Image = base64Encode(bytes);
    final callable = _functions.httpsCallable("extractTextFromImage");
    final res = await callable.call({"imageBase64": base64Image});
    return (res.data["text"] ?? "").toString();
  }

  Future<String> _extractFromPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    if (bytes.isEmpty) throw Exception("PDF file is empty");

    final base64Pdf = base64Encode(bytes);
    final callable = _functions.httpsCallable("extractTextFromPdf");
    final res = await callable.call({"pdfBase64": base64Pdf});
    return (res.data["text"] ?? "").toString();
  }
}