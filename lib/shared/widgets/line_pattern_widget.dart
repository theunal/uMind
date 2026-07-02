import 'package:flutter/material.dart';
import '../../data/models/line_spec.dart';
import '../../core/theme/app_colors.dart';

class LinePatternMainWidget extends StatelessWidget {
  final LinePatternData pattern;

  const LinePatternMainWidget({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Container(
        width: 280,
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(280, 210),
                painter: _LinePainter(lines: pattern.lines),
              ),
              Positioned(
                left: pattern.missingX * 280,
                top: pattern.missingY * 210,
                child: Container(
                  width: pattern.missingW * 280,
                  height: pattern.missingH * 210,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinePatternOptionWidget extends StatelessWidget {
  final List<LineSpec> lines;
  final double missingX;
  final double missingY;
  final double missingW;
  final double missingH;

  const LinePatternOptionWidget({
    super.key,
    required this.lines,
    required this.missingX,
    required this.missingY,
    required this.missingW,
    required this.missingH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ClippedLinePainter(
                lines: lines,
                missingX: missingX,
                missingY: missingY,
                missingW: missingW,
                missingH: missingH,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<LineSpec> lines;

  _LinePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(
        Offset(line.x1 * size.width, line.y1 * size.height),
        Offset(line.x2 * size.width, line.y2 * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}

class _ClippedLinePainter extends CustomPainter {
  final List<LineSpec> lines;
  final double missingX;
  final double missingY;
  final double missingW;
  final double missingH;

  _ClippedLinePainter({
    required this.lines,
    required this.missingX,
    required this.missingY,
    required this.missingW,
    required this.missingH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth * 1.1
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(
        Offset(line.x1 * size.width, line.y1 * size.height),
        Offset(line.x2 * size.width, line.y2 * size.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClippedLinePainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}
