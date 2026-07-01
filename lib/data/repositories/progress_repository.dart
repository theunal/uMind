import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_progress.dart';

class ProgressRepository {
  static const _boxName = 'user_progress';
  static const _key = 'progress';

  late Box<UserProgress> _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LevelResultAdapter());
    }
    _box = await Hive.openBox<UserProgress>(_boxName);
  }

  UserProgress getProgress() {
    return _box.get(_key) ?? UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _box.put(_key, progress);
  }

  Future<void> updateLevelResult(int level, LevelResult result) async {
    final progress = getProgress();
    progress.levelResults[level.toString()] = result;
    progress.totalScore += result.iqScore;
    progress.testsCompleted++;
    if (result.iqScore > progress.bestScore) {
      progress.bestScore = result.iqScore;
    }
    if (result.correct >= 12) {
      if (level >= progress.currentLevel) {
        progress.currentLevel = level + 1;
      }
    }
    progress.lastPlayed = DateTime.now();
    await saveProgress(progress);
  }

  int calculateIQScore({
    required int correctCount,
    required int totalQuestions,
    required int timeSpentMs,
    required int level,
  }) {
    final baseScore = (correctCount / totalQuestions) * 100;
    const avgTimeLimitMs = 30000;
    final avgTimePerQuestion = timeSpentMs / totalQuestions;
    final timeBonus =
        (0 - (avgTimePerQuestion - avgTimeLimitMs) / avgTimeLimitMs * 20)
            .clamp(0.0, 20.0);
    final levelMultiplier = 1 + (level - 1) * 0.02;
    return ((baseScore + timeBonus) * levelMultiplier).round();
  }
}
