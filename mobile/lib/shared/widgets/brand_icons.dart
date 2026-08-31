import 'package:flutter/material.dart';

/// Pixel-perfect, authentic Google 'G' multi-color vector logo matching official brand specifications.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Blue (Horizontal bar and right quadrant)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.60, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.50, 32.16, 36.20)
      ..lineTo(39.89, 42.20)
      ..cubicTo(44.40, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green (Bottom arch)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.49, 24.0, 38.49)
      ..cubicTo(17.74, 38.49, 12.43, 34.27, 10.53, 28.58)
      ..lineTo(2.55, 34.77)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow (Left arch)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(10.53, 28.58)
      ..cubicTo(10.05, 27.13, 9.77, 25.59, 9.77, 23.99)
      ..cubicTo(9.77, 22.39, 10.05, 20.85, 10.53, 19.40)
      ..lineTo(2.55, 13.21)
      ..cubicTo(0.92, 16.45, 0.0, 20.11, 0.0, 23.99)
      ..cubicTo(0.0, 27.87, 0.92, 31.53, 2.55, 34.77)
      ..lineTo(10.53, 28.58)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red (Top arch)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(24.0, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.90, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.55, 13.22)
      ..lineTo(10.53, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Facebook App Icon with vivid sky-to-royal-blue gradient and authentic 'f' geometry.
class FacebookLogo extends StatelessWidget {
  const FacebookLogo({super.key, this.size = 20, this.isCircular = false});

  final double size;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _FacebookLogoPainter(isCircular: isCircular),
      ),
    );
  }
}

class _FacebookLogoPainter extends CustomPainter {
  const _FacebookLogoPainter({this.isCircular = false});
  final bool isCircular;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Beautiful Gradient Background (Sky Blue to Royal Navy Blue)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF18ACFE), Color(0xFF0866FF), Color(0xFF0052D4)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    if (isCircular) {
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);
    } else {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.22),
      );
      canvas.drawRRect(rrect, bgPaint);
    }

    // Clip to background bounds so 'f' base touches bottom seamlessly
    canvas.save();
    if (isCircular) {
      canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, w, h)));
    } else {
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          Radius.circular(w * 0.22),
        ),
      );
    }

    // 2. Official Vector 'f' path scaled to w and h
    final fPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final sx = w / 100.0;
    final sy = h / 100.0;

    path.moveTo(61.0 * sx, 100.0 * sy);
    path.lineTo(61.0 * sx, 55.0 * sy);
    path.lineTo(75.5 * sx, 55.0 * sy);
    path.lineTo(78.0 * sx, 38.0 * sy);
    path.lineTo(61.0 * sx, 38.0 * sy);
    path.lineTo(61.0 * sx, 27.5 * sy);
    path.cubicTo(
      61.0 * sx,
      22.5 * sy,
      63.5 * sx,
      18.5 * sy,
      72.0 * sx,
      18.5 * sy,
    );
    path.lineTo(78.5 * sx, 18.5 * sy);
    path.lineTo(78.5 * sx, 3.0 * sy);
    path.cubicTo(74.5 * sx, 2.0 * sy, 68.0 * sx, 1.0 * sy, 60.5 * sx, 1.0 * sy);
    path.cubicTo(
      43.5 * sx,
      1.0 * sy,
      34.0 * sx,
      11.5 * sy,
      34.0 * sx,
      29.5 * sy,
    );
    path.lineTo(34.0 * sx, 38.0 * sy);
    path.lineTo(20.0 * sx, 38.0 * sy);
    path.lineTo(20.0 * sx, 55.0 * sy);
    path.lineTo(34.0 * sx, 55.0 * sy);
    path.lineTo(34.0 * sx, 100.0 * sy);
    path.close();

    canvas.drawPath(path, fPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FacebookLogoPainter oldDelegate) =>
      oldDelegate.isCircular != isCircular;
}

/// Official VieGym Logo matching app_icon design (Neon Red 'V' + Barbell).
class VieGymLogo extends StatelessWidget {
  const VieGymLogo({
    super.key,
    this.size = 40,
    this.borderRadius,
    this.showGlow = true,
  });

  final double size;
  final double? borderRadius;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.24);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFFF2E54).withValues(alpha: 0.35),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              size: Size(size, size),
              painter: _VieGymLogoPainter(),
            );
          },
        ),
      ),
    );
  }
}

class _VieGymLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark metallic background
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF262A33), Color(0xFF0D0F12)],
        center: Alignment.center,
        radius: 0.85,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final neonPaint = Paint()
      ..color = const Color(0xFFFF2E54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0xFFFF2E54).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Scaling coordinates relative to 100x100
    final sx = w / 100.0;
    final sy = h / 100.0;

    // 1. Draw Barbell horizontal bar
    final barPath = Path()
      ..moveTo(20 * sx, 50 * sy)
      ..lineTo(80 * sx, 50 * sy);

    // 2. Draw 'V' Shape
    final vPath = Path()
      ..moveTo(28 * sx, 28 * sy)
      ..lineTo(50 * sx, 75 * sy)
      ..lineTo(72 * sx, 28 * sy);

    // 3. Weight plates (left and right)
    final platesPath = Path()
      // Left plates
      ..moveTo(20 * sx, 42 * sy)
      ..lineTo(20 * sx, 58 * sy)
      ..moveTo(24 * sx, 38 * sy)
      ..lineTo(24 * sx, 62 * sy)
      ..moveTo(28 * sx, 34 * sy)
      ..lineTo(28 * sx, 66 * sy)
      // Right plates
      ..moveTo(72 * sx, 34 * sy)
      ..lineTo(72 * sx, 66 * sy)
      ..moveTo(76 * sx, 38 * sy)
      ..lineTo(76 * sx, 62 * sy)
      ..moveTo(80 * sx, 42 * sy)
      ..lineTo(80 * sx, 58 * sy);

    // Render glow
    canvas.drawPath(vPath, glowPaint);
    canvas.drawPath(barPath, glowPaint);
    canvas.drawPath(platesPath, glowPaint);

    // Render core neon strokes
    canvas.drawPath(vPath, neonPaint);
    canvas.drawPath(barPath, neonPaint);
    canvas.drawPath(platesPath, neonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
