import 'package:flutter/material.dart';

/// Official Google "G" icon using SVG-accurate colored paths via CustomPaint.
class GoogleIcon extends StatelessWidget {
  final double size;
  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _OfficialGoogleGPainter()),
    );
  }
}

class _OfficialGoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale helper
    Path scalePath(List<List<double>> points, bool close) {
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final x = points[i][0] / 24 * w;
        final y = points[i][1] / 24 * h;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (close) path.close();
      return path;
    }

    // Blue path — right portion of G + horizontal bar
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Red path — top-left arc
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    // Yellow path — bottom-left arc
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC04)
      ..style = PaintingStyle.fill;

    // Green path — bottom-right arc
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    // Draw using arcs for accuracy
    final center = Offset(w / 2, h / 2);
    final outerRadius = w * 0.46;
    final strokeW = w * 0.19;
    final innerRadius = outerRadius - strokeW;

    final ringRect = Rect.fromCircle(center: center, radius: outerRadius - strokeW / 2);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    const pi = 3.14159265358979;
    double deg(double d) => d * pi / 180;

    // Red: top-left (210° → 330°, sweep 120°)
    arcPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(ringRect, deg(210), deg(120), false, arcPaint);

    // Yellow: bottom-left (330° → 30°, sweep 60°)
    arcPaint.color = const Color(0xFFFBBC04);
    canvas.drawArc(ringRect, deg(330), deg(60), false, arcPaint);

    // Green: bottom-right (30° → 90°, sweep 60°)
    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(ringRect, deg(30), deg(60), false, arcPaint);

    // Blue: right + top-right (90° → 210°, sweep 120°)
    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(ringRect, deg(90), deg(120), false, arcPaint);

    // Blue horizontal bar (the crossbar of the G)
    final barHeight = strokeW * 0.95;
    final barTop = center.dy - barHeight / 2;
    final barLeft = center.dx; // starts from center
    final barRight = center.dx + outerRadius + strokeW * 0.1;

    canvas.drawRect(
      Rect.fromLTRB(barLeft, barTop, barRight, barTop + barHeight),
      bluePaint,
    );

    // White fill the inner circle to make it look like outlined G
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - strokeW * 0.02, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
