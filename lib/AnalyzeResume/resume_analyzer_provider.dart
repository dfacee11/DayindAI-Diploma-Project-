import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dayindai/AnalyzeResume/ocr_service.dart';
import 'package:dayindai/AnalyzeResume/resume_upload_service.dart';
import 'package:dayindai/core/error_handler.dart';
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
    // Validation — простые снекбары (не сетевые ошибки)
    if (profession.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_label(context, 'enterProfession')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (selectedResumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_label(context, 'uploadResume')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
      // Сетевая / серверная ошибка — умный обработчик
      if (context.mounted) ErrorHandler.showSnackbar(context, e);
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  String _label(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRu = lang == 'ru';
    final isKk = lang == 'kk';
    return switch (key) {
      'enterProfession' => isKk ? 'Мамандықты енгіз' : isRu ? 'Введи профессию' : 'Enter a profession',
      'uploadResume'    => isKk ? 'Түйіндемені жүктe' : isRu ? 'Загрузи резюме' : 'Upload a resume',
      _ => '',
    };
  }
}