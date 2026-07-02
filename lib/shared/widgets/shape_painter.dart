import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/shape_spec.dart';

class ShapePainter extends CustomPainter {
  final ShapeSpec spec;

  ShapePainter({required this.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.shortestSide * 0.35 * spec.scale;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spec.rotationDeg * pi / 180);

    if (spec.hasLayers) {
      for (final layer in spec.layers!) {
        final isLine = layer.type == ShapeType.line;
        final layerPaint = Paint()
          ..color = Color(layer.colorValue)
          ..style = (isLine || layer.outlineOnly) ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = isLine ? 3.0 : (layer.outlineOnly ? 3.0 : 0.0)
          ..isAntiAlias = true;
        final layerRadius = baseRadius * layer.scale;
        canvas.save();
        canvas.rotate(layer.rotationDeg * pi / 180);
        _drawShape(canvas, Offset.zero, layerRadius, layer.type, layerPaint);
        if (layer.linePattern != LinePattern.none) {
          final lp = Paint()
            ..color = Color(layer.colorValue)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..isAntiAlias = true;
          _drawLinePattern(canvas, layerRadius, layer.linePattern, lp);
        }
        canvas.restore();
      }
    } else if (spec.count <= 1) {
      _drawShapedCell(canvas, Offset.zero, baseRadius);
    } else {
      final cols = spec.count <= 2 ? spec.count : (spec.count <= 4 ? 2 : 3);
      final rows = (spec.count / cols).ceil();
      final spacing = baseRadius * 2.2;
      final startX = -(cols - 1) * spacing / 2;
      final startY = -(rows - 1) * spacing / 2;
      final smallRadius = baseRadius * 0.5;

      int drawn = 0;
      for (int r = 0; r < rows && drawn < spec.count; r++) {
        for (int c = 0; c < cols && drawn < spec.count; c++) {
          final offset = Offset(startX + c * spacing, startY + r * spacing);
          _drawShape(canvas, offset, smallRadius, spec.type, _fillPaint());
          if (spec.linePattern != LinePattern.none) {
            _drawLinePattern(canvas, smallRadius, spec.linePattern, _linePaint());
          }
          drawn++;
        }
      }
    }

    canvas.restore();
  }

  void _drawShapedCell(Canvas canvas, Offset offset, double radius) {
    _drawShape(canvas, offset, radius, spec.type, _fillPaint());

    if (spec.innerShape != null) {
      final innerRadius = radius * 0.42;
      final innerPaint = Paint()
        ..color = spec.innerColorValue ?? Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      _drawShape(canvas, offset, innerRadius, spec.innerShape!, innerPaint);
    }

    if (spec.linePattern != LinePattern.none) {
      _drawLinePattern(canvas, radius, spec.linePattern, _linePaint());
    }
  }

  Paint _fillPaint() {
    final isLine = spec.type == ShapeType.line;
    return Paint()
      ..color = spec.color
      ..style = (isLine || spec.outlineOnly) ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = isLine ? 3.0 : (spec.outlineOnly ? 3.0 : 0.0)
      ..isAntiAlias = true;
  }

  Paint _linePaint() {
    return Paint()
      ..color = spec.outlineOnly
          ? spec.color
          : spec.color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
  }

  void _drawLinePattern(Canvas canvas, double radius, LinePattern pattern, Paint paint) {
    switch (pattern) {
      case LinePattern.none:
        break;
      case LinePattern.horizontal:
        canvas.drawLine(
          Offset(-radius, 0),
          Offset(radius, 0),
          paint,
        );
        break;
      case LinePattern.vertical:
        canvas.drawLine(
          Offset(0, -radius),
          Offset(0, radius),
          paint,
        );
        break;
      case LinePattern.cross:
        canvas.drawLine(Offset(-radius, 0), Offset(radius, 0), paint);
        canvas.drawLine(Offset(0, -radius), Offset(0, radius), paint);
        break;
      case LinePattern.diagonal:
        canvas.drawLine(
          Offset(-radius * 0.7, -radius * 0.7),
          Offset(radius * 0.7, radius * 0.7),
          paint,
        );
        break;
      case LinePattern.plus:
        final half = radius * 0.5;
        canvas.drawLine(Offset(-half, 0), Offset(half, 0), paint);
        canvas.drawLine(Offset(0, -half), Offset(0, half), paint);
        break;
      case LinePattern.minus:
        final half = radius * 0.5;
        canvas.drawLine(Offset(-half, 0), Offset(half, 0), paint);
        break;
      case LinePattern.times:
        final d = radius * 0.4;
        canvas.drawLine(Offset(-d, -d), Offset(d, d), paint);
        canvas.drawLine(Offset(d, -d), Offset(-d, d), paint);
        break;
      case LinePattern.dot:
        final dotPaint = Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas.drawCircle(Offset.zero, radius * 0.2, dotPaint);
        break;
    }
  }

  void _drawShape(Canvas canvas, Offset offset, double radius, ShapeType type, Paint paint) {
    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(offset, radius, paint);
        break;
      case ShapeType.square:
        final rect = Rect.fromCenter(
            center: offset, width: radius * 1.6, height: radius * 1.6);
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(offset.dx, offset.dy - radius)
          ..lineTo(offset.dx + radius * 0.866, offset.dy + radius * 0.5)
          ..lineTo(offset.dx - radius * 0.866, offset.dy + radius * 0.5)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.pentagon:
        canvas.drawPath(_regularPolygon(offset, radius, 5), paint);
        break;
      case ShapeType.hexagon:
        canvas.drawPath(_regularPolygon(offset, radius, 6), paint);
        break;
      case ShapeType.oval:
        final rect = Rect.fromCenter(
            center: offset, width: radius * 2, height: radius * 1.2);
        canvas.drawOval(rect, paint);
        break;
      case ShapeType.star:
        canvas.drawPath(_star(offset, radius, 5), paint);
        break;
      case ShapeType.diamond:
        final path = Path()
          ..moveTo(offset.dx, offset.dy - radius)
          ..lineTo(offset.dx + radius * 0.6, offset.dy)
          ..lineTo(offset.dx, offset.dy + radius)
          ..lineTo(offset.dx - radius * 0.6, offset.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.line:
        canvas.drawLine(
          Offset(offset.dx - radius, offset.dy),
          Offset(offset.dx + radius, offset.dy),
          paint,
        );
        break;
    }
  }

  Path _regularPolygon(Offset center, double radius, int sides) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (2 * pi * i / sides) - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  Path _star(Offset center, double radius, int points) {
    final path = Path();
    final innerRadius = radius * 0.4;
    for (int i = 0; i < points * 2; i++) {
      final angle = (pi * i / points) - pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final point = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.spec != spec;
  }
}
