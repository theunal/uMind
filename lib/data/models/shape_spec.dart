import 'dart:ui';

enum ShapeType {
  circle,
  square,
  triangle,
  pentagon,
  hexagon,
  oval,
  star,
  diamond;

  String toJson() => name;
  static ShapeType fromJson(String json) => values.byName(json);
}

enum PatternType {
  sequence,
  rotation,
  matrix3x3,
  colorCycle,
  countPattern,
  sizeScale,
  symmetry,
  combination;

  String toJson() => name;
  static PatternType fromJson(String json) => values.byName(json);
}

class ShapeSpec {
  final ShapeType type;
  final int colorValue;
  final double rotationDeg;
  final double scale;
  final int count;

  const ShapeSpec({
    required this.type,
    required this.colorValue,
    this.rotationDeg = 0,
    this.scale = 1.0,
    this.count = 1,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
        'color': colorValue,
        'rotationDeg': rotationDeg,
        'scale': scale,
        'count': count,
      };

  factory ShapeSpec.fromJson(Map<String, dynamic> json) => ShapeSpec(
        type: ShapeType.fromJson(json['type'] as String),
        colorValue: json['color'] as int,
        rotationDeg: (json['rotationDeg'] as num).toDouble(),
        scale: (json['scale'] as num).toDouble(),
        count: json['count'] as int? ?? 1,
      );

  ShapeSpec copyWith({
    ShapeType? type,
    int? colorValue,
    double? rotationDeg,
    double? scale,
    int? count,
  }) {
    return ShapeSpec(
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      scale: scale ?? this.scale,
      count: count ?? this.count,
    );
  }
}
