import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/iq_question.dart';

class QuestionRepository {
  final Map<int, List<IQQuestion>> _cache = {};

  Future<List<IQQuestion>> getQuestionsForLevel(int level) async {
    if (_cache.containsKey(level)) {
      return _cache[level]!;
    }

    final levelStr = level.toString().padLeft(3, '0');
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/questions/level_$levelStr.json',
      );
      final List<dynamic> jsonList = json.decode(jsonStr);
      final questions = jsonList
          .map((q) => IQQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
      _cache[level] = questions;
      return questions;
    } catch (e) {
      throw Exception('Level $level soruları yüklenemedi: $e');
    }
  }
}
