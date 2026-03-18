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
        const Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF7F3EA),
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF6DDD5),
                ),
              ),
            ),
          ],
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x14000000),
                Color(0x08000000),
              ],
            ),
          ),
        ),
        if (safeArea) SafeArea(child: content) else content,
      ],
    );
  }
}
