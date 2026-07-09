import 'package:flutter/material.dart';

/// A custom-painted Google "G" icon using official Google brand colors.
/// No external package or network request needed — always renders correctly.
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // --- Draw background circle (white) ---
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // --- Four colored arcs of the Google "G" ring ---
    final ringWidth = r * 0.38;
    final ringRadius = r * 0.72;
    final ringRect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: ringRadius,
    );
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.butt;

    // Red (top-left arc) — from ~195° to ~330° (sweep ~135°)
    ringPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(ringRect, _deg(195), _deg(135), false, ringPaint);

    // Yellow (bottom arc) — from ~330° to ~15° (sweep ~45°)
    ringPaint.color = const Color(0xFFFBBC04);
    canvas.drawArc(ringRect, _deg(330), _deg(45), false, ringPaint);

    // Green (right arc) — from ~15° to ~75° (sweep ~60°)
    ringPaint.color = const Color(0xFF34A853);
    canvas.drawArc(ringRect, _deg(15), _deg(60), false, ringPaint);

    // Blue (top-right arc) — from ~75° to ~195° (sweep ~120°)
    ringPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(ringRect, _deg(75), _deg(120), false, ringPaint);

    // --- Blue horizontal bar of the "G" ---
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barLeft = cx; // starts at center
    final barRight = cx + ringRadius + ringWidth * 0.5;
    final barTop = cy - ringWidth * 0.5;
    final barBottom = cy + ringWidth * 0.5;

    canvas.drawRect(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      barPaint,
    );

    // --- White circle in center (to hollow out the ring) ---
    final innerR = ringRadius - ringWidth * 0.5;
    final whiteFill = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), innerR, whiteFill);
  }

  double _deg(double degrees) => degrees * 3.14159265 / 180.0;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
