import 'shape_spec.dart';

class IQQuestion {
  final String id;
  final int level;
  final int orderInLevel;
  final PatternType pattern;
  final List<ShapeSpec> sequence;
  final List<ShapeSpec> options;
  final int correctOptionIndex;
  final bool isMatrix;

  const IQQuestion({
    required this.id,
    required this.level,
    required this.orderInLevel,
    required this.pattern,
    required this.sequence,
    required this.options,
    required this.correctOptionIndex,
    this.isMatrix = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'orderInLevel': orderInLevel,
        'pattern': pattern.toJson(),
        'sequence': sequence.map((s) => s.toJson()).toList(),
        'options': options.map((s) => s.toJson()).toList(),
        'correctOptionIndex': correctOptionIndex,
        'isMatrix': isMatrix,
      };

  factory IQQuestion.fromJson(Map<String, dynamic> json) => IQQuestion(
        id: json['id'] as String,
        level: json['level'] as int,
        orderInLevel: json['orderInLevel'] as int,
        pattern: PatternType.fromJson(json['pattern'] as String),
        sequence: (json['sequence'] as List)
            .map((s) => ShapeSpec.fromJson(s as Map<String, dynamic>))
            .toList(),
        options: (json['options'] as List)
            .map((s) => ShapeSpec.fromJson(s as Map<String, dynamic>))
            .toList(),
        correctOptionIndex: json['correctOptionIndex'] as int,
        isMatrix: json['isMatrix'] as bool? ?? false,
      );
}
