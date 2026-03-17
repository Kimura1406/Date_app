import 'package:flutter/material.dart';

import 'auth/auth_shell.dart';

class KimuraApp extends StatelessWidget {
  const KimuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimura Dating',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE85D75),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F6),
        useMaterial3: true,
      ),
      home: const AuthShell(),
    );
  }
}
