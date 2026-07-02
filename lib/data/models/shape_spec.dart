import 'dart:ui';

enum ShapeType {
  circle,
  square,
  triangle,
  pentagon,
  hexagon,
  oval,
  star,
  diamond,
  line;

  String toJson() => name;
  static ShapeType fromJson(String json) => values.byName(json);
}

enum PatternType {
  // === GRUP A: Temel (14) ===
  countIncrement,
  countAlternating,
  outlineToggle,
  colorCycle,
  linePatternCycle,
  innerShapeEvolution,
  scaleProgression,
  scaleColorPair,
  mirrorSymmetry,
  symmetryOutline,
  simpleMatrix2x2,
  simpleMatrix3x3,
  rotationBasic,
  countdownShrink,

  // === GRUP B: Orta (10) ===
  nestedShapeOutline,
  gridConvergence,
  shapeLineMatrix,
  colorOutlineProgression,
  rotationInnerShape,
  rowColumnRelation,
  alternatingPairCombo,
  sizeColorInverse,
  countTypeSwap,
  partialMatrixRelation,

  // === GRUP C: İleri (6) ===
  fullAttributeMatrix,
  transformationChain,
  multiVariableChain,
  matrixWithException,
  crossMatrixRelation,
  weightedComboChallenge,

  // === GRUP D: Mimari Uyarlamalı (3) ===
  xorLogic,
  additiveOverlay,
  hiddenRuleDeduction,

  // === Eski isimler (geriye uyumluluk) ===
  sequence,
  rotation,
  matrix3x3,
  countPattern,
  sizeScale,
  symmetry,
  combination,

  // === Yeni: Çizgi Kayıp Parça ===
  linePattern;

  String toJson() => name;
  static PatternType fromJson(String json) => values.byName(json);
}

enum LinePattern {
  none,
  horizontal,
  vertical,
  cross,
  diagonal,
  plus,
  minus,
  times,
  dot;

  String toJson() => name;
  static LinePattern fromJson(String json) =>
      values.firstWhere((e) => e.name == json, orElse: () => LinePattern.none);
}

enum ShapePosition {
  topLeft,
  topCenter,
  topRight,
  middleLeft,
  center,
  middleRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  String toJson() => name;
  static ShapePosition fromJson(String json) => values.firstWhere(
    (e) => e.name == json,
    orElse: () => ShapePosition.center,
  );
}

class ShapeLayer {
  final ShapeType type;
  final int colorValue;
  final double rotationDeg;
  final double scale;
  final bool outlineOnly;
  final LinePattern linePattern;

  const ShapeLayer({
    required this.type,
    required this.colorValue,
    this.rotationDeg = 0,
    this.scale = 1.0,
    this.outlineOnly = false,
    this.linePattern = LinePattern.none,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'type': type.toJson(),
    'color': colorValue,
    if (rotationDeg != 0) 'rotationDeg': rotationDeg,
    if (scale != 1.0) 'scale': scale,
    if (outlineOnly) 'outlineOnly': true,
    if (linePattern != LinePattern.none) 'linePattern': linePattern.toJson(),
  };

  factory ShapeLayer.fromJson(Map<String, dynamic> json) => ShapeLayer(
    type: ShapeType.fromJson(json['type'] as String),
    colorValue: json['color'] as int,
    rotationDeg: (json['rotationDeg'] as num?)?.toDouble() ?? 0,
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    outlineOnly: json['outlineOnly'] as bool? ?? false,
    linePattern: json['linePattern'] != null
        ? LinePattern.fromJson(json['linePattern'] as String)
        : LinePattern.none,
  );
}

class ShapeSpec {
  final ShapeType type;
  final int colorValue;
  final double rotationDeg;
  final double scale;
  final int count;
  final bool outlineOnly;
  final ShapeType? innerShape;
  final int? innerColor;
  final LinePattern linePattern;
  final ShapePosition? position;
  final List<ShapeLayer>? layers;

  const ShapeSpec({
    required this.type,
    required this.colorValue,
    this.rotationDeg = 0,
    this.scale = 1.0,
    this.count = 1,
    this.outlineOnly = false,
    this.innerShape,
    this.innerColor,
    this.linePattern = LinePattern.none,
    this.position,
    this.layers,
  });

  Color get color => Color(colorValue);
  Color? get innerColorValue => innerColor != null ? Color(innerColor!) : null;
  bool get hasLayers => layers != null && layers!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'type': type.toJson(),
    'color': colorValue,
    'rotationDeg': rotationDeg,
    'scale': scale,
    'count': count,
    if (outlineOnly) 'outlineOnly': true,
    if (innerShape != null) 'innerShape': innerShape!.toJson(),
    if (innerColor != null) 'innerColor': innerColor,
    if (linePattern != LinePattern.none) 'linePattern': linePattern.toJson(),
    if (position != null) 'position': position!.toJson(),
    if (layers != null) 'layers': layers!.map((l) => l.toJson()).toList(),
  };

  factory ShapeSpec.fromJson(Map<String, dynamic> json) => ShapeSpec(
    type: ShapeType.fromJson(json['type'] as String),
    colorValue: json['color'] as int,
    rotationDeg: (json['rotationDeg'] as num).toDouble(),
    scale: (json['scale'] as num).toDouble(),
    count: json['count'] as int? ?? 1,
    outlineOnly: json['outlineOnly'] as bool? ?? false,
    innerShape: json['innerShape'] != null
        ? ShapeType.fromJson(json['innerShape'] as String)
        : null,
    innerColor: json['innerColor'] as int?,
    linePattern: json['linePattern'] != null
        ? LinePattern.fromJson(json['linePattern'] as String)
        : LinePattern.none,
    position: json['position'] != null
        ? ShapePosition.fromJson(json['position'] as String)
        : null,
    layers: json['layers'] != null
        ? (json['layers'] as List)
              .map((l) => ShapeLayer.fromJson(l as Map<String, dynamic>))
              .toList()
        : null,
  );

  ShapeSpec copyWith({
    ShapeType? type,
    int? colorValue,
    double? rotationDeg,
    double? scale,
    int? count,
    bool? outlineOnly,
    ShapeType? innerShape,
    int? innerColor,
    LinePattern? linePattern,
    ShapePosition? position,
    List<ShapeLayer>? layers,
    bool clearInnerShape = false,
    bool clearInnerColor = false,
    bool clearPosition = false,
    bool clearLayers = false,
  }) {
    return ShapeSpec(
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      scale: scale ?? this.scale,
      count: count ?? this.count,
      outlineOnly: outlineOnly ?? this.outlineOnly,
      innerShape: clearInnerShape ? null : (innerShape ?? this.innerShape),
      innerColor: clearInnerColor ? null : (innerColor ?? this.innerColor),
      linePattern: linePattern ?? this.linePattern,
      position: clearPosition ? null : (position ?? this.position),
      layers: clearLayers ? null : (layers ?? this.layers),
    );
  }
}
