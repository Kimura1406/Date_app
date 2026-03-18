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

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: safeArea ? SafeArea(child: content) : content,
    );
  }
}
