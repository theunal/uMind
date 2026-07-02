import 'dart:ui';

class LineSpec {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final int colorValue;
  final double strokeWidth;

  const LineSpec({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.colorValue,
    this.strokeWidth = 3.0,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'color': colorValue,
        'strokeWidth': strokeWidth,
      };

  factory LineSpec.fromJson(Map<String, dynamic> json) => LineSpec(
        x1: (json['x1'] as num).toDouble(),
        y1: (json['y1'] as num).toDouble(),
        x2: (json['x2'] as num).toDouble(),
        y2: (json['y2'] as num).toDouble(),
        colorValue: json['color'] as int,
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      );

  LineSpec clipToRegion(double rx, double ry, double rw, double rh) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final xMax = rx + rw;
    final yMax = ry + rh;

    double tEnter = 0.0, tLeave = 1.0;

    if (!_lbEdge(-dx, x1 - rx, (v) => tEnter = v, (v) => tLeave = v, () => tEnter, () => tLeave) ||
        !_lbEdge(dx, xMax - x1, (v) => tEnter = v, (v) => tLeave = v, () => tEnter, () => tLeave) ||
        !_lbEdge(-dy, y1 - ry, (v) => tEnter = v, (v) => tLeave = v, () => tEnter, () => tLeave) ||
        !_lbEdge(dy, yMax - y1, (v) => tEnter = v, (v) => tLeave = v, () => tEnter, () => tLeave)) {
      return LineSpec(x1: 0, y1: 0, x2: 0, y2: 0, colorValue: colorValue, strokeWidth: strokeWidth);
    }

    return LineSpec(
      x1: x1 + dx * tEnter,
      y1: y1 + dy * tEnter,
      x2: x1 + dx * tLeave,
      y2: y1 + dy * tLeave,
      colorValue: colorValue,
      strokeWidth: strokeWidth,
    );
  }

  static bool _lbEdge(double p, double q, void Function(double) setE, void Function(double) setL,
      double Function() getE, double Function() getL) {
    if (p == 0.0) return q >= 0;
    final r = q / p;
    if (p < 0) {
      if (r > getL()) return false;
      if (r > getE()) setE(r);
    } else {
      if (r < getE()) return false;
      if (r < getL()) setL(r);
    }
    return true;
  }

  LineSpec copyWith({
    double? x1,
    double? y1,
    double? x2,
    double? y2,
    int? colorValue,
    double? strokeWidth,
  }) {
    return LineSpec(
      x1: x1 ?? this.x1,
      y1: y1 ?? this.y1,
      x2: x2 ?? this.x2,
      y2: y2 ?? this.y2,
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  static LineSpec shiftLine(LineSpec line, double dx, double dy) {
    return LineSpec(
      x1: (line.x1 + dx).clamp(0.0, 1.0),
      y1: (line.y1 + dy).clamp(0.0, 1.0),
      x2: (line.x2 + dx).clamp(0.0, 1.0),
      y2: (line.y2 + dy).clamp(0.0, 1.0),
      colorValue: line.colorValue,
      strokeWidth: line.strokeWidth,
    );
  }

  static LineSpec changeColor(LineSpec line, int newColor) {
    return LineSpec(
      x1: line.x1,
      y1: line.y1,
      x2: line.x2,
      y2: line.y2,
      colorValue: newColor,
      strokeWidth: line.strokeWidth,
    );
  }
}

class LinePatternData {
  final List<LineSpec> lines;
  final double missingX;
  final double missingY;
  final double missingW;
  final double missingH;

  const LinePatternData({
    required this.lines,
    required this.missingX,
    required this.missingY,
    required this.missingW,
    required this.missingH,
  });

  Map<String, dynamic> toJson() => {
        'lines': lines.map((l) => l.toJson()).toList(),
        'missingX': missingX,
        'missingY': missingY,
        'missingW': missingW,
        'missingH': missingH,
      };

  factory LinePatternData.fromJson(Map<String, dynamic> json) =>
      LinePatternData(
        lines: (json['lines'] as List)
            .map((l) => LineSpec.fromJson(l as Map<String, dynamic>))
            .toList(),
        missingX: (json['missingX'] as num).toDouble(),
        missingY: (json['missingY'] as num).toDouble(),
        missingW: (json['missingW'] as num).toDouble(),
        missingH: (json['missingH'] as num).toDouble(),
      );
}
