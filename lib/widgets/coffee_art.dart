import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Decorative illustration, drawn locally without pretending to be a cafe photo.
class CoffeeArt extends StatelessWidget {
  const CoffeeArt({super.key, this.size = 170});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CoffeePainter()),
    ),
  );
}

class _CoffeePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 200);
    final fill = Paint()..color = const Color(0xFFECE0C9);
    final stroke = Paint()
      ..color = SeduhColors.coffee
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(100, 100), 91, fill);
    canvas.save();
    canvas.translate(100, 100);
    canvas.rotate(-math.pi / 14);
    canvas.translate(-100, -100);
    canvas.drawOval(const Rect.fromLTWH(42, 139, 120, 19), stroke);
    canvas.drawArc(
      const Rect.fromLTWH(125, 89, 36, 40),
      -1.6,
      3.4,
      false,
      stroke,
    );
    final cup = Path()
      ..moveTo(54, 88)
      ..lineTo(65, 137)
      ..quadraticBezierTo(98, 159, 130, 137)
      ..lineTo(141, 88);
    canvas.drawPath(cup, Paint()..color = const Color(0xFFFAF7F0));
    canvas.drawPath(cup, stroke);
    canvas.drawOval(
      const Rect.fromLTWH(54, 78, 87, 23),
      Paint()..color = const Color(0xFFC49B70),
    );
    canvas.drawOval(const Rect.fromLTWH(54, 78, 87, 23), stroke);
    canvas.drawOval(
      const Rect.fromLTWH(86, 83, 23, 12),
      Paint()..color = SeduhColors.paper,
    );
    for (final x in [80.0, 98.0, 116.0]) {
      final steam = Path()
        ..moveTo(x, 66)
        ..cubicTo(x - 12, 56, x + 10, 47, x, 37);
      canvas.drawPath(steam, stroke..strokeWidth = 2);
    }
    canvas.restore();
    canvas.drawLine(const Offset(158, 41), const Offset(164, 30), stroke);
    canvas.drawLine(const Offset(167, 49), const Offset(179, 47), stroke);
    canvas.drawOval(const Rect.fromLTWH(32, 41, 12, 21), stroke);
    canvas.drawLine(const Offset(39, 43), const Offset(36, 60), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
