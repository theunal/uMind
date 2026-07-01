import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  int currentLevel;

  @HiveField(1)
  int totalScore;

  @HiveField(2)
  int testsCompleted;

  @HiveField(3)
  int bestScore;

  @HiveField(4)
  Map<String, LevelResult> levelResults;

  @HiveField(5)
  DateTime? lastPlayed;

  UserProgress({
    this.currentLevel = 1,
    this.totalScore = 0,
    this.testsCompleted = 0,
    this.bestScore = 0,
    Map<String, LevelResult>? levelResults,
    this.lastPlayed,
  }) : levelResults = levelResults ?? {};
}

@HiveType(typeId: 1)
class LevelResult {
  @HiveField(0)
  final int correct;

  @HiveField(1)
  final int wrong;

  @HiveField(2)
  final int timeSpentMs;

  @HiveField(3)
  final int iqScore;

  const LevelResult({
    required this.correct,
    required this.wrong,
    required this.timeSpentMs,
    required this.iqScore,
  });
}
