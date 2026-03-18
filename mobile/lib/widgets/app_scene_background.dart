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
    final content =
        padding == null ? child : Padding(padding: padding!, child: child);

    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: CustomPaint(
            painter: _WireframeMeshBackgroundPainter(),
          ),
        ),
        if (safeArea) SafeArea(child: content) else content,
      ],
    );
  }
}

class _WireframeMeshBackgroundPainter extends CustomPainter {
  const _WireframeMeshBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020202),
          Color(0xFF070707),
          Color(0xFF121212),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    _paintDust(canvas, size);
    _paintMeshOrb(
      canvas,
      size,
      center: Offset(size.width * 0.1, size.height * -0.08),
      radius: size.shortestSide * 0.34,
      seed: 1406,
      lineAlpha: 0.17,
    );
    _paintMeshOrb(
      canvas,
      size,
      center: Offset(size.width * 1.02, size.height * 0.26),
      radius: size.shortestSide * 0.2,
      seed: 2026,
      lineAlpha: 0.13,
    );
    _paintMeshOrb(
      canvas,
      size,
      center: Offset(size.width * 0.92, size.height * 1.03),
      radius: size.shortestSide * 0.28,
      seed: 3141,
      lineAlpha: 0.15,
    );

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 1.08,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.44),
        ],
        stops: const [0.0, 0.76, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  void _paintDust(Canvas canvas, Size size) {
    final random = math.Random(77);
    final dustPaint = Paint()..style = PaintingStyle.fill;
    final dustCount = (size.width * size.height / 220).round();

    for (var index = 0; index < dustCount; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.25 + random.nextDouble() * 1.1;
      dustPaint.color = Colors.white.withValues(
        alpha: 0.015 + random.nextDouble() * 0.09,
      );
      canvas.drawCircle(Offset(dx, dy), radius, dustPaint);
    }
  }

  void _paintMeshOrb(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required int seed,
    required double lineAlpha,
  }) {
    final random = math.Random(seed);
    final points = <Offset>[];

    for (var index = 0; index < 44; index++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = radius * math.sqrt(random.nextDouble());
      points.add(
        Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        ),
      );
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.55, radius * 0.007)
      ..color = Colors.white.withValues(alpha: lineAlpha);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokePaint.strokeWidth + 0.9
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..color = Colors.white.withValues(alpha: lineAlpha * 0.35);

    for (var index = 0; index < points.length; index++) {
      final start = points[index];
      final nearest = [...points]
        ..sort((a, b) => (a - start).distance.compareTo((b - start).distance));

      for (var linkIndex = 1; linkIndex < math.min(5, nearest.length); linkIndex++) {
        final end = nearest[linkIndex];
        canvas.drawLine(start, end, glowPaint);
        canvas.drawLine(start, end, strokePaint);
      }
    }

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: lineAlpha * 1.8);

    for (final point in points) {
      canvas.drawCircle(point, math.max(0.7, radius * 0.01), nodePaint);
    }

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, radius * 0.01)
      ..color = Colors.white.withValues(alpha: lineAlpha * 0.55);
    canvas.drawCircle(center, radius, outlinePaint);

    final fadePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.32),
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.05));
    canvas.drawCircle(center, radius * 1.05, fadePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
