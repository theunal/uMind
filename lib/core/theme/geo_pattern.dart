import 'package:flutter/material.dart';

class GeoPattern extends StatelessWidget {
  final Widget child;

  const GeoPattern({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeoPatternPainter(),
      size: Size.infinite,
      child: child,
    );
  }
}

class _GeoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x146366F1)
      ..style = PaintingStyle.fill;

    const cellW = 80.0;
    const cellH = 140.0;

    for (double y = -cellH; y < size.height + cellH; y += cellH) {
      for (double x = -cellW; x < size.width + cellW; x += cellW) {
        final path1 = Path()
          ..moveTo(x, y)
          ..lineTo(x + cellW * 0.12, y)
          ..lineTo(x, y + cellH * 0.12)
          ..close();
        canvas.drawPath(path1, paint);

        final path2 = Path()
          ..moveTo(x + cellW, y)
          ..lineTo(x + cellW * 0.88, y)
          ..lineTo(x + cellW, y + cellH * 0.12)
          ..close();
        canvas.drawPath(path2, paint);

        final path3 = Path()
          ..moveTo(x + cellW, y + cellH)
          ..lineTo(x + cellW * 0.88, y + cellH)
          ..lineTo(x + cellW, y + cellH * 0.88)
          ..close();
        canvas.drawPath(path3, paint);

        final path4 = Path()
          ..moveTo(x, y + cellH)
          ..lineTo(x + cellW * 0.12, y + cellH)
          ..lineTo(x, y + cellH * 0.88)
          ..close();
        canvas.drawPath(path4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
