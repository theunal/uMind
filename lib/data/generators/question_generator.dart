import 'dart:math';
import '../models/shape_spec.dart';
import '../models/iq_question.dart';

class QuestionGenerator {
  final Random _rng;

  QuestionGenerator({int seed = 42}) : _rng = Random(seed);

  static const _shapeColors = [
    0xFF818CF8, // indigo-400
    0xFFF472B6, // pink-400
    0xFF34D399, // emerald-400
    0xFFFBBF24, // amber-400
    0xFFFB923C, // orange-400
    0xFF67E8F9, // cyan-300
    0xFFA78BFA, // violet-400
    0xFFF87171, // red-400
  ];

  static const _allShapes = ShapeType.values;

  List<IQQuestion> generateLevel(int level, {int questionsPerLevel = 20}) {
    final questions = <IQQuestion>[];
    final patternTypes = _getPatternTypesForLevel(level);

    for (int i = 0; i < questionsPerLevel; i++) {
      final pattern = patternTypes[i % patternTypes.length];
      final question = _generateQuestion(level, i + 1, pattern);
      questions.add(question);
    }
    return questions;
  }

  List<PatternType> _getPatternTypesForLevel(int level) {
    if (level <= 10) {
      return [PatternType.colorCycle, PatternType.sequence];
    } else if (level <= 20) {
      return [
        PatternType.colorCycle,
        PatternType.sequence,
        PatternType.rotation,
        PatternType.sizeScale,
      ];
    } else if (level <= 40) {
      return [
        PatternType.colorCycle,
        PatternType.rotation,
        PatternType.countPattern,
        PatternType.sizeScale,
        PatternType.matrix3x3,
      ];
    } else if (level <= 60) {
      return [
        PatternType.rotation,
        PatternType.countPattern,
        PatternType.sizeScale,
        PatternType.matrix3x3,
        PatternType.symmetry,
        PatternType.combination,
      ];
    } else if (level <= 80) {
      return [
        PatternType.matrix3x3,
        PatternType.symmetry,
        PatternType.combination,
        PatternType.rotation,
        PatternType.countPattern,
        PatternType.sequence,
      ];
    } else {
      return [
        PatternType.matrix3x3,
        PatternType.symmetry,
        PatternType.combination,
        PatternType.rotation,
        PatternType.countPattern,
        PatternType.sequence,
        PatternType.sizeScale,
        PatternType.colorCycle,
      ];
    }
  }

  IQQuestion _generateQuestion(int level, int order, PatternType pattern) {
    switch (pattern) {
      case PatternType.colorCycle:
        return _generateColorCycle(level, order);
      case PatternType.rotation:
        return _generateRotation(level, order);
      case PatternType.countPattern:
        return _generateCountPattern(level, order);
      case PatternType.sizeScale:
        return _generateSizeScale(level, order);
      case PatternType.matrix3x3:
        return _generateMatrix(level, order);
      case PatternType.sequence:
        return _generateSequence(level, order);
      case PatternType.symmetry:
        return _generateSymmetry(level, order);
      case PatternType.combination:
        return _generateCombination(level, order);
    }
  }

  IQQuestion _generateColorCycle(int level, int order) {
    final shape = _randomShape();
    final cycleLength = level <= 15 ? 3 : (level <= 50 ? 4 : 5);
    final colors = _pickColors(cycleLength);

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      sequence.add(ShapeSpec(
        type: shape,
        colorValue: colors[i % cycleLength],
      ));
    }

    final correctAnswer = ShapeSpec(
      type: shape,
      colorValue: colors[8 % cycleLength],
    );

    final options = _generateOptions(correctAnswer, level, colorOnly: true);
    final correctIndex = options.indexWhere(
        (o) => o.colorValue == correctAnswer.colorValue && o.type == correctAnswer.type);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.colorCycle,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateRotation(int level, int order) {
    final shape = _randomShape();
    final color = _randomColor();
    final stepDeg = level <= 30 ? 90.0 : (level <= 60 ? 45.0 : 30.0);

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      sequence.add(ShapeSpec(
        type: shape,
        colorValue: color,
        rotationDeg: stepDeg * i,
        scale: level > 50 ? 1.0 + (i * 0.05) : 1.0,
      ));
    }

    final correctAnswer = ShapeSpec(
      type: shape,
      colorValue: color,
      rotationDeg: stepDeg * 8,
      scale: level > 50 ? 1.0 + (8 * 0.05) : 1.0,
    );

    final options = _generateOptions(correctAnswer, level, rotationOnly: true);
    final correctIndex = options.indexWhere(
        (o) => o.rotationDeg == correctAnswer.rotationDeg);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.rotation,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateCountPattern(int level, int order) {
    final shape = _randomShape();
    final color = _randomColor();
    final increment = level <= 30 ? 1 : (level <= 60 ? (_rng.nextBool() ? 1 : 2) : (_rng.nextBool() ? -1 : 2));

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      final count = (1 + i * increment).clamp(1, 5);
      sequence.add(ShapeSpec(
        type: shape,
        colorValue: color,
        count: count,
      ));
    }

    final correctCount = (1 + 8 * increment).clamp(1, 5);
    final correctAnswer = ShapeSpec(
      type: shape,
      colorValue: color,
      count: correctCount,
    );

    final options = _generateOptions(correctAnswer, level, countOnly: true);
    final correctIndex = options.indexWhere((o) => o.count == correctAnswer.count);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.countPattern,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateSizeScale(int level, int order) {
    final shape = _randomShape();
    final color = _randomColor();
    final startScale = 0.6;
    final endScale = 1.8;
    final step = (endScale - startScale) / 7;

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      sequence.add(ShapeSpec(
        type: shape,
        colorValue: color,
        scale: startScale + step * i,
        rotationDeg: level > 50 ? i * 15.0 : 0,
      ));
    }

    final correctScale = startScale + step * 8;
    final correctAnswer = ShapeSpec(
      type: shape,
      colorValue: color,
      scale: correctScale,
      rotationDeg: level > 50 ? 8 * 15.0 : 0,
    );

    final options = _generateOptions(correctAnswer, level, scaleOnly: true);
    final correctIndex =
        options.indexWhere((o) => (o.scale - correctAnswer.scale).abs() < 0.01);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.sizeScale,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateMatrix(int level, int order) {
    final baseShape = _randomShape();
    final colors = _pickColors(3);
    final shapes = level > 40
        ? [_randomShape(), _randomShape(), _randomShape()]
        : [baseShape, baseShape, baseShape];

    final sequence = <ShapeSpec>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (row == 2 && col == 2) continue;
        sequence.add(ShapeSpec(
          type: shapes[row],
          colorValue: colors[col],
          rotationDeg: level > 60 ? (col * 90.0) : 0,
        ));
      }
    }

    final correctAnswer = ShapeSpec(
      type: shapes[2],
      colorValue: colors[2],
      rotationDeg: level > 60 ? (2 * 90.0) : 0,
    );

    final options = _generateOptions(correctAnswer, level);
    final correctIndex = options.indexWhere(
        (o) => o.type == correctAnswer.type && o.colorValue == correctAnswer.colorValue);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.matrix3x3,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
      isMatrix: true,
    );
  }

  IQQuestion _generateSequence(int level, int order) {
    final cycleLength = level <= 20 ? 2 : (level <= 50 ? 3 : 4);
    final shapes = List.generate(cycleLength, (_) => _randomShape());
    final color = _randomColor();

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      sequence.add(ShapeSpec(
        type: shapes[i % cycleLength],
        colorValue: color,
        scale: level > 60 ? 1.0 + (i % 3) * 0.15 : 1.0,
      ));
    }

    final correctAnswer = ShapeSpec(
      type: shapes[8 % cycleLength],
      colorValue: color,
      scale: level > 60 ? 1.0 + (8 % 3) * 0.15 : 1.0,
    );

    final options = _generateOptions(correctAnswer, level);
    final correctIndex = options.indexWhere(
        (o) => o.type == correctAnswer.type && o.scale == correctAnswer.scale);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.sequence,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateSymmetry(int level, int order) {
    final shape = _randomShape();
    final color = _randomColor();

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      final isMirror = i % 2 == 1;
      sequence.add(ShapeSpec(
        type: shape,
        colorValue: isMirror ? _mirrorColor(color) : color,
        rotationDeg: isMirror ? 180 : 0,
        scale: level > 50 ? (isMirror ? 1.2 : 0.8) : 1.0,
      ));
    }

    final isCorrectMirror = 8 % 2 == 1;
    final correctAnswer = ShapeSpec(
      type: shape,
      colorValue: isCorrectMirror ? _mirrorColor(color) : color,
      rotationDeg: isCorrectMirror ? 180 : 0,
      scale: level > 50 ? (isCorrectMirror ? 1.2 : 0.8) : 1.0,
    );

    final options = _generateOptions(correctAnswer, level);
    final correctIndex = options.indexWhere(
        (o) => o.rotationDeg == correctAnswer.rotationDeg);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.symmetry,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  IQQuestion _generateCombination(int level, int order) {
    final shape1 = _randomShape();
    final shape2 = _randomShape();
    final color1 = _randomColor();
    final color2 = _randomColor();

    final sequence = <ShapeSpec>[];
    for (int i = 0; i < 8; i++) {
      final primaryShape = i % 2 == 0 ? shape1 : shape2;
      final primaryColor = i % 3 == 0 ? color1 : color2;
      sequence.add(ShapeSpec(
        type: primaryShape,
        colorValue: primaryColor,
        rotationDeg: level > 70 ? i * 22.5 : 0,
        scale: level > 60 ? 0.8 + (i % 3) * 0.2 : 1.0,
      ));
    }

    final correctAnswer = ShapeSpec(
      type: 8 % 2 == 0 ? shape1 : shape2,
      colorValue: 8 % 3 == 0 ? color1 : color2,
      rotationDeg: level > 70 ? 8 * 22.5 : 0,
      scale: level > 60 ? 0.8 + (8 % 3) * 0.2 : 1.0,
    );

    final options = _generateOptions(correctAnswer, level);
    final correctIndex = options.indexWhere(
        (o) => o.type == correctAnswer.type && o.colorValue == correctAnswer.colorValue);

    return IQQuestion(
      id: 'L${level}_Q$order',
      level: level,
      orderInLevel: order,
      pattern: PatternType.combination,
      sequence: sequence,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  ShapeType _randomShape() => _allShapes[_rng.nextInt(_allShapes.length)];

  int _randomColor() => _shapeColors[_rng.nextInt(_shapeColors.length)];

  List<int> _pickColors(int count) {
    final shuffled = List<int>.from(_shapeColors)..shuffle(_rng);
    return shuffled.take(count).toList();
  }

  int _mirrorColor(int color) {
    // Simple hue shift by swapping R and B channels
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return (color & 0xFF000000) | (b << 16) | (g << 8) | r;
  }

  List<ShapeSpec> _generateOptions(ShapeSpec correct, int level,
      {bool colorOnly = false,
      bool rotationOnly = false,
      bool countOnly = false,
      bool scaleOnly = false}) {
    final options = <ShapeSpec>[correct];
    final optionCount = 6;

    while (options.length < optionCount) {
      ShapeSpec wrong;
      if (colorOnly) {
        wrong = correct.copyWith(colorValue: _randomColor());
      } else if (rotationOnly) {
        wrong = correct.copyWith(
            rotationDeg: correct.rotationDeg + (_rng.nextInt(3) + 1) * 45.0);
      } else if (countOnly) {
        wrong = correct.copyWith(
            count: (correct.count + _rng.nextInt(3) + 1).clamp(1, 5));
      } else if (scaleOnly) {
        wrong = correct.copyWith(
            scale: correct.scale + (_rng.nextBool() ? 0.2 : -0.2));
      } else {
        wrong = ShapeSpec(
          type: _randomShape(),
          colorValue: _randomColor(),
          rotationDeg: _rng.nextDouble() * 360,
          scale: 0.8 + _rng.nextDouble() * 0.6,
          count: 1,
        );
      }

      final isDuplicate = options.any((o) =>
          o.type == wrong.type &&
          o.colorValue == wrong.colorValue &&
          (o.rotationDeg - wrong.rotationDeg).abs() < 1 &&
          (o.scale - wrong.scale).abs() < 0.01 &&
          o.count == wrong.count);

      if (!isDuplicate) {
        options.add(wrong);
      }
    }

    options.shuffle(_rng);
    return options;
  }
}
