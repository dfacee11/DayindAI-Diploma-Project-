import 'dart:io';
import 'package:flutter/material.dart';
import 'ocr_service.dart';
import 'resume_analysis_result.dart';
import 'resume_analysis_service.dart';
import 'resume_upload_service.dart';

class ResumeAnalyzerProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final ResumeUploadService uploadService = ResumeUploadService();
  final ResumeAnalysisService _analysisService = ResumeAnalysisService();

  String? selectedProfession;
  File? selectedResumeFile;
  bool isAnalyzing = false;
  ResumeAnalysisResult? result;

  final List<String> professions = [
    "Flutter Developer",
    "Android Developer",
    "iOS Developer",
    "Frontend Developer",
    "Backend Developer",
    "Fullstack Developer",
    "QA Engineer",
    "Automation QA Engineer",
    "DevOps Engineer",
    "Data Analyst",
    "Data Scientist",
    "UI/UX Designer",
    "Product Manager",
    "Project Manager",
    "Business Analyst",
    "System Analyst",
    "Cybersecurity Specialist",
  ];

  void setProfession(String? value) {
    selectedProfession = value;
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

    if (selectedProfession == null) {
      messenger.showSnackBar(const SnackBar(content: Text("Choose a profession")));
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
      final ext = selectedResumeFile!.path.split('.').last.toLowerCase();
      String text = "";

      if (ext == "jpg" || ext == "jpeg" || ext == "png") {
        text = await _ocrService.extractTextFromImage(selectedResumeFile!);
      } else {
        text = "File is not a picture: $ext";
      }

      final json = await _analysisService.analyzeWithDeepseek(
        text: text,
        profession: selectedProfession!,
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