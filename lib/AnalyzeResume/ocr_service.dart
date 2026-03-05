import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> extractText(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      return _extractFromPdfLocally(file);
    } else {
      return _extractFromImage(file);
    }
  }

  Future<String> _extractFromPdfLocally(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    if (bytes.isEmpty) throw Exception("PDF file is empty");

    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();

    if (text.trim().isEmpty) throw Exception("PDF has no readable text");
    return text;
  }

  Future<String> _extractFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) throw Exception("Image file is empty");

    final base64Image = base64Encode(bytes);
    final callable = _functions.httpsCallable("extractTextFromImage");
    final res = await callable.call({"imageBase64": base64Image});
    return (res.data["text"] ?? "").toString();
  }
}