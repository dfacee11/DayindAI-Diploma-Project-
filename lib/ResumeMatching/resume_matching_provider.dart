import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dayindai/AnalyzeResume/ocr_service.dart';
import 'package:dayindai/AnalyzeResume/resume_upload_service.dart';
import 'package:dayindai/core/error_handler.dart';
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
    // Validation
    if (selectedResumeFile == null) {
      _showInfo(context, _label(context, 'uploadResume'));
      return;
    }
    if (jobDescription.trim().length < 20) {
      _showInfo(context, _label(context, 'pasteJob'));
      return;
    }

    isMatching = true;
    result = null;
    notifyListeners();

    try {
      final text = await _ocrService.extractText(selectedResumeFile!);
      final json = await _matchingService.matchWithGpt(
        resumeText: text,
        jobDescription: jobDescription,
      );
      result = ResumeMatchingResult.fromJson(json);
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackbar(context, e);
    } finally {
      isMatching = false;
      notifyListeners();
    }
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _label(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRu = lang == 'ru';
    final isKk = lang == 'kk';
    return switch (key) {
      'uploadResume' => isKk ? 'Түйіндемені жүктe'        : isRu ? 'Загрузи резюме'             : 'Upload a resume',
      'pasteJob'     => isKk ? 'Жұмыс сипаттамасын қос'   : isRu ? 'Вставь описание вакансии'   : 'Paste job description',
      _ => '',
    };
  }
}