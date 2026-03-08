import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'visa_city_questions.dart'; 

class VisaQuestionsService {
  VisaQuestionsService._();
  static final VisaQuestionsService instance = VisaQuestionsService._();

  
  final Map<String, Map<String, List<String>>> _cache = {};


  Future<List<String>> getQuestions({
    required String cityId,   
    required String type,     
  }) async {
   
    if (_cache[cityId]?[type] != null) {
      debugPrint('VisaQuestions: cache hit $cityId/$type');
      return List<String>.from(_cache[cityId]![type]!);
    }

   
    try {
      final doc = await FirebaseFirestore.instance
          .collection('visa_questions')
          .doc(cityId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
      
        _cache[cityId] = {
          'firstTime': List<String>.from(data['firstTime'] ?? []),
          'returner':  List<String>.from(data['returner']  ?? []),
        };
        debugPrint('VisaQuestions: loaded from Firestore $cityId');
        return List<String>.from(_cache[cityId]![type]!);
      }
    } catch (e) {
      debugPrint('VisaQuestions: Firestore error, using fallback. $e');
    }

  
    return VisaCityQuestions.get(cityId: cityId, type: type);
  }


  Future<void> preload() async {
    await Future.wait([
      getQuestions(cityId: 'astana', type: 'firstTime'),
      getQuestions(cityId: 'astana', type: 'returner'),
      getQuestions(cityId: 'almaty', type: 'firstTime'),
      getQuestions(cityId: 'almaty', type: 'returner'),
    ]);
  }
}