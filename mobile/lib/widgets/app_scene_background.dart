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
            painter: _WireframeHeartsBackgroundPainter(),
          ),
        ),
        if (safeArea) SafeArea(child: content) else content,
      ],
    );
  }
}

class _WireframeHeartsBackgroundPainter extends CustomPainter {
  const _WireframeHeartsBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF010101),
          Color(0xFF060606),
          Color(0xFF101010),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    _paintDust(canvas, size);

    final tileWidth = size.width / 3;
    final tileHeight = size.height / 4.2;
    final random = math.Random(1406);

    for (var row = -1; row <= 4; row++) {
      for (var col = -1; col <= 3; col++) {
        final baseX = col * tileWidth + tileWidth * 0.5;
        final baseY = row * tileHeight + tileHeight * 0.5;
        final jitterX = (random.nextDouble() - 0.5) * tileWidth * 0.24;
        final jitterY = (random.nextDouble() - 0.5) * tileHeight * 0.24;
        final heartSize =
            size.shortestSide * (0.13 + random.nextDouble() * 0.045);
        final alpha = 0.11 + random.nextDouble() * 0.08;
        final rotation = (random.nextDouble() - 0.5) * 0.14;

        _paintWireHeart(
          canvas,
          center: Offset(baseX + jitterX, baseY + jitterY),
          size: heartSize,
          lineAlpha: alpha,
          seed: row * 10 + col + 77,
          rotation: rotation,
        );
      }
    }

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 1.1,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.16),
          Colors.black.withValues(alpha: 0.38),
        ],
        stops: const [0.0, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  void _paintDust(Canvas canvas, Size size) {
    final random = math.Random(44);
    final dustPaint = Paint()..style = PaintingStyle.fill;
    final dustCount = (size.width * size.height / 240).round();

    for (var index = 0; index < dustCount; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.25 + random.nextDouble() * 1.0;
      dustPaint.color = Colors.white.withValues(
        alpha: 0.01 + random.nextDouble() * 0.06,
      );
      canvas.drawCircle(Offset(dx, dy), radius, dustPaint);
    }
  }

  void _paintWireHeart(
    Canvas canvas, {
    required Offset center,
    required double size,
    required double lineAlpha,
    required int seed,
    required double rotation,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final points = _buildHeartPoints(size);
    final random = math.Random(seed);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.45, size * 0.015)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: lineAlpha);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = linePaint.strokeWidth + 0.85
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
      ..color = Colors.white.withValues(alpha: lineAlpha * 0.32);

    final outlinePath = Path()..addPolygon(points, true);
    canvas.drawPath(outlinePath, glowPaint);
    canvas.drawPath(outlinePath, linePaint);

    for (var index = 0; index < points.length; index++) {
      final start = points[index];
      final linked = <int>{};
      while (linked.length < 4) {
        final target = random.nextInt(points.length);
        if (target == index) continue;
        linked.add(target);
      }

      for (final targetIndex in linked) {
        final end = points[targetIndex];
        canvas.drawLine(start, end, glowPaint);
        canvas.drawLine(start, end, linePaint);
      }
    }

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: lineAlpha * 1.9);
    for (final point in points) {
      canvas.drawCircle(point, math.max(0.45, size * 0.013), nodePaint);
    }

    canvas.restore();
  }

  List<Offset> _buildHeartPoints(double size) {
    final points = <Offset>[];
    final scale = size * 0.07;

    for (var degree = 0; degree < 360; degree += 8) {
      final t = degree * math.pi / 180;
      final x = 16 * math.pow(math.sin(t), 3);
      final y = 13 * math.cos(t) -
          5 * math.cos(2 * t) -
          2 * math.cos(3 * t) -
          math.cos(4 * t);
      points.add(
        Offset(
          x.toDouble() * scale,
          -y.toDouble() * scale + size * 0.04,
        ),
      );
    }

    return points;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
