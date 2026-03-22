import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_shouldInitializeFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const KimuraApp());
}

bool get _shouldInitializeFirebase {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => true,
    TargetPlatform.iOS => true,
    TargetPlatform.fuchsia => false,
    TargetPlatform.macOS => false,
    TargetPlatform.windows => false,
    TargetPlatform.linux => false,
  };
}
