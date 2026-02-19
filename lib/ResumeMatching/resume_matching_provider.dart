import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dayindai/AnalyzeResume/ocr_service.dart';
import 'package:dayindai/AnalyzeResume/resume_upload_service.dart';
import 'resume_matching_result.dart';
import 'resume_matching_service.dart';

class ResumeMatchingProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final ResumeUploadService uploadService = ResumeUploadService();
  final ResumeMatchingService _matchingService = ResumeMatchingService();

  File? selectedResumeFile;
  String jobDescription = "";
  bool isMatching = false;
  ResumeMatchingResult? result;

  void setFile(File? file) {
    selectedResumeFile = file;
    notifyListeners();
  }

  void setJobDescription(String value) {
    jobDescription = value;
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

  Future<void> match(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (selectedResumeFile == null) {
      messenger.showSnackBar(const SnackBar(content: Text("Upload a resume")));
      return;
    }

    if (jobDescription.trim().length < 20) {
      messenger.showSnackBar(const SnackBar(content: Text("Paste job description")));
      return;
    }

    isMatching = true;
    result = null;
    notifyListeners();

    try {
      final ext = selectedResumeFile!.path.split('.').last.toLowerCase();
      String resumeText = "";

      if (ext == "jpg" || ext == "jpeg" || ext == "png") {
        resumeText = await _ocrService.extractTextFromImage(selectedResumeFile!);
      } else {
        resumeText = "Resume file is not a picture: $ext";
      }

      final json = await _matchingService.matchWithDeepseek(
        resumeText: resumeText,
        jobDescription: jobDescription,
      );

      result = ResumeMatchingResult.fromJson(json);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      isMatching = false;
      notifyListeners();
    }
  }
}