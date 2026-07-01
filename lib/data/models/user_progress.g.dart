// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      currentLevel: fields[0] as int,
      totalScore: fields[1] as int,
      testsCompleted: fields[2] as int,
      bestScore: fields[3] as int,
      levelResults: (fields[4] as Map?)?.cast<String, LevelResult>(),
      lastPlayed: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.currentLevel)
      ..writeByte(1)
      ..write(obj.totalScore)
      ..writeByte(2)
      ..write(obj.testsCompleted)
      ..writeByte(3)
      ..write(obj.bestScore)
      ..writeByte(4)
      ..write(obj.levelResults)
      ..writeByte(5)
      ..write(obj.lastPlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LevelResultAdapter extends TypeAdapter<LevelResult> {
  @override
  final int typeId = 1;

  @override
  LevelResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelResult(
      correct: fields[0] as int,
      wrong: fields[1] as int,
      timeSpentMs: fields[2] as int,
      iqScore: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LevelResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.correct)
      ..writeByte(1)
      ..write(obj.wrong)
      ..writeByte(2)
      ..write(obj.timeSpentMs)
      ..writeByte(3)
      ..write(obj.iqScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
