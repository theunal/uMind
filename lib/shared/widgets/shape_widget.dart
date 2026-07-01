import 'package:flutter/material.dart';
import '../../data/models/shape_spec.dart';
import 'shape_painter.dart';

class ShapeWidget extends StatelessWidget {
  final ShapeSpec spec;
  final double size;

  const ShapeWidget({
    super.key,
    required this.spec,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(spec: spec),
        size: Size(size, size),
      ),
    );
  }
}
