import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dayindai/AnalyzeResume/ocr_service.dart';
import 'package:dayindai/AnalyzeResume/resume_upload_service.dart';
import 'resume_analysis_result.dart';
import 'resume_analysis_service.dart';

class ResumeAnalyzerProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final ResumeUploadService uploadService = ResumeUploadService();
  final ResumeAnalysisService _analysisService = ResumeAnalysisService();

  String profession = "";
  File? selectedResumeFile;
  bool isAnalyzing = false;
  ResumeAnalysisResult? result;

  void setProfession(String value) {
    profession = value;
    notifyListeners();
  }

  void setFile(File? file) {
    selectedResumeFile = file;
    notifyListeners();
  }

  Future<void> pickResumeFile() async {
    final file = await uploadService.pickResumeFile();
    if (file != null) setFile(file);
  }

  Future<void> pickFromGallery() async {
    final file = await uploadService.pickResumeImageFromGallery();
    if (file != null) setFile(file);
  }

  Future<void> takePhoto() async {
    final file = await uploadService.takeResumePhoto();
    if (file != null) setFile(file);
  }

  Future<void> analyze(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (profession.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text("Enter a profession")));
      return;
    }
    if (selectedResumeFile == null) {
      messenger.showSnackBar(const SnackBar(content: Text("Upload a resume")));
      return;
    }

    isAnalyzing = true;
    result = null;
    notifyListeners();

    try {
      final text = await _ocrService.extractText(selectedResumeFile!);
      final json = await _analysisService.analyzeWithGpt(
        text: text,
        profession: profession.trim(),
      );
      result = ResumeAnalysisResult.fromJson(json);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }
}