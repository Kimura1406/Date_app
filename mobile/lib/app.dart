import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth/auth_shell.dart';
import 'localization/app_language.dart';
import 'localization/app_language_controller.dart';
import 'localization/app_localizations.dart';
import 'widgets/app_scene_background.dart';

class KimuraApp extends StatefulWidget {
  const KimuraApp({super.key});

  @override
  State<KimuraApp> createState() => _KimuraAppState();
}

class _KimuraAppState extends State<KimuraApp> {
  late final AppLanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _languageController = AppLanguageController();
    _languageController.load();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocalizationScope(
      controller: _languageController,
      child: AnimatedBuilder(
        animation: _languageController,
        builder: (context, _) {
          final strings = context.strings;
          return MaterialApp(
            title: strings.appTitle,
            debugShowCheckedModeBanner: false,
            locale: _languageController.locale,
            supportedLocales: AppLanguage.values
                .map((language) => language.locale)
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE85D75),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.black,
              useMaterial3: true,
            ),
            home: _languageController.loaded
                ? const AuthShell()
                : const Scaffold(
                    backgroundColor: Colors.black,
                    body: AppSceneBackground(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
