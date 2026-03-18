import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppSceneBackground extends StatelessWidget {
  const AppSceneBackground({
    super.key,
    required this.child,
    this.safeArea = true,
    this.padding,
  });

  final Widget child;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = padding == null ? child : Padding(padding: padding!, child: child);

    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: CustomPaint(
            painter: _HeartDustBackgroundPainter(),
          ),
        ),
        if (safeArea) SafeArea(child: content) else content,
      ],
    );
  }
}

class _HeartDustBackgroundPainter extends CustomPainter {
  const _HeartDustBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030303),
          Color(0xFF0A0A0A),
          Color(0xFF161616),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final random = math.Random(1406);
    final dustPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.08);

    final dustCount = (size.width * size.height / 180).round();
    for (var i = 0; i < dustCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.3 + random.nextDouble() * 1.2;
      dustPaint.color = Colors.white.withValues(
        alpha: 0.03 + random.nextDouble() * 0.12,
      );
      canvas.drawCircle(Offset(dx, dy), radius, dustPaint);
    }

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);

    final heartStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.96);

    final hearts = <({Offset center, double size, double stroke})>[
      (center: Offset(size.width * 0.18, size.height * 0.18), size: size.shortestSide * 0.1, stroke: 4),
      (center: Offset(size.width * 0.78, size.height * 0.28), size: size.shortestSide * 0.06, stroke: 3),
      (center: Offset(size.width * 0.50, size.height * 0.43), size: size.shortestSide * 0.11, stroke: 4),
      (center: Offset(size.width * 0.11, size.height * 0.56), size: size.shortestSide * 0.055, stroke: 3),
      (center: Offset(size.width * 0.45, size.height * 0.78), size: size.shortestSide * 0.065, stroke: 3),
      (center: Offset(size.width * 0.95, size.height * 0.84), size: size.shortestSide * 0.11, stroke: 4),
    ];

    for (final heart in hearts) {
      heartStroke.strokeWidth = heart.stroke;
      final path = _buildHeartPath(heart.center, heart.size);
      canvas.drawPath(path, heartStroke);
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = heart.stroke + 2
        ..color = Colors.white.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glow);
    }
  }

  Path _buildHeartPath(Offset center, double size) {
    final path = Path();
    final topCurveHeight = size * 0.35;
    path.moveTo(center.dx, center.dy + size * 0.42);
    path.cubicTo(
      center.dx + size * 0.55,
      center.dy,
      center.dx + size * 0.45,
      center.dy - topCurveHeight,
      center.dx,
      center.dy - size * 0.18,
    );
    path.cubicTo(
      center.dx - size * 0.45,
      center.dy - topCurveHeight,
      center.dx - size * 0.55,
      center.dy,
      center.dx,
      center.dy + size * 0.42,
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
