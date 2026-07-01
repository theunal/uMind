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

    final paint = Paint()
      ..color = spec.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (spec.count <= 1) {
      _drawShape(canvas, Offset.zero, baseRadius, paint);
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
          _drawShape(canvas, offset, smallRadius, paint);
          drawn++;
        }
      }
    }

    canvas.restore();
  }

  void _drawShape(Canvas canvas, Offset offset, double radius, Paint paint) {
    switch (spec.type) {
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
