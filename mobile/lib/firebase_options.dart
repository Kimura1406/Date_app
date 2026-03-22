import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_TGn2FSejOhDIgRZYeUqqeXm4w-YhC68',
    appId: '1:568193353719:android:576ef39ecdf9b77599d0f2',
    messagingSenderId: '568193353719',
    projectId: 'dating-a8b07',
    storageBucket: 'dating-a8b07.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDa6xYDCPWxHJGmTK24A7v7ZVXw8HC4puk',
    appId: '1:568193353719:ios:04365ca8127d005899d0f2',
    messagingSenderId: '568193353719',
    projectId: 'dating-a8b07',
    storageBucket: 'dating-a8b07.firebasestorage.app',
    iosBundleId: 'dating.kimhouse.com',
  );
}
