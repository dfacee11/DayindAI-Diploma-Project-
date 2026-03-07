import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

enum CoverLetterLanguage { english, russian, kazakh }

extension CoverLetterLanguageExt on CoverLetterLanguage {
  String get flag => switch (this) {
    CoverLetterLanguage.english => "🇺🇸",
    CoverLetterLanguage.russian => "🇷🇺",
    CoverLetterLanguage.kazakh  => "🇰🇿",
  };

  String get label => switch (this) {
    CoverLetterLanguage.english => "English",
    CoverLetterLanguage.russian => "Русский",
    CoverLetterLanguage.kazakh  => "Қазақша",
  };

  String get code => switch (this) {
    CoverLetterLanguage.english => "en",
    CoverLetterLanguage.russian => "ru",
    CoverLetterLanguage.kazakh  => "kk",
  };
}

class CoverLetterProvider extends ChangeNotifier {
  String jobTitle      = '';
  String company       = '';
  String jobDesc       = '';
  String aboutMe       = '';
  CoverLetterLanguage language = CoverLetterLanguage.english;

  bool   isGenerating  = false;
  String? result;
  String? error;

  bool get canGenerate =>
      jobTitle.trim().isNotEmpty && company.trim().isNotEmpty;

  void setJobTitle(String v)  { jobTitle = v; notifyListeners(); }
  void setCompany(String v)   { company = v;  notifyListeners(); }
  void setJobDesc(String v)   { jobDesc = v;  notifyListeners(); }
  void setAboutMe(String v)   { aboutMe = v;  notifyListeners(); }
  void setLanguage(CoverLetterLanguage v) { language = v; notifyListeners(); }

  void reset() {
    result = null;
    error  = null;
    notifyListeners();
  }

  Future<void> generate() async {
    if (!canGenerate) return;

    isGenerating = true;
    result = null;
    error  = null;
    notifyListeners();

    try {
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('generateCoverLetter');

      final res = await callable.call({
        'jobTitle':  jobTitle.trim(),
        'company':   company.trim(),
        'jobDesc':   jobDesc.trim(),
        'aboutMe':   aboutMe.trim(),
        'language':  language.code,
      });

      result = res.data['letter'] as String?;
    } catch (e) {
      error = e.toString();
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}