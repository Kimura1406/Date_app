import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../data/api_client.dart';

typedef RemoteMessageHandler = Future<void> Function(RemoteMessage message);

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    ApiClient? apiClient,
  })  : _messaging = messaging,
        _apiClient = apiClient ?? ApiClient();

  final FirebaseMessaging? _messaging;
  final ApiClient _apiClient;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  RemoteMessageHandler? _onForegroundMessage;
  RemoteMessageHandler? _onMessageOpenedApp;
  String? _handledInitialMessageId;

  bool get _isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  FirebaseMessaging get _instance => _messaging ?? FirebaseMessaging.instance;

  Future<void> initialize({
    required String authToken,
    required String Function() authTokenProvider,
    RemoteMessageHandler? onForegroundMessage,
    RemoteMessageHandler? onMessageOpenedApp,
  }) async {
    if (!_isSupportedPlatform || authToken.trim().isEmpty) {
      return;
    }

    _onForegroundMessage = onForegroundMessage;
    _onMessageOpenedApp = onMessageOpenedApp;

    try {
      await _instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _registerCurrentToken(authToken);

      _tokenRefreshSubscription ??=
          _instance.onTokenRefresh.listen((token) async {
        if (token.trim().isEmpty) {
          return;
        }
        try {
          final latestAuthToken = authTokenProvider().trim();
          if (latestAuthToken.isEmpty) {
            return;
          }
          await _apiClient.registerDeviceToken(
            token: latestAuthToken,
            deviceToken: token,
            platform: 'android',
          );
        } catch (error) {
          debugPrint('FCM token refresh sync failed: $error');
        }
      });

      _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
        (message) async {
          final handler = _onForegroundMessage;
          if (handler == null) {
            return;
          }
          await handler(message);
        },
      );

      _messageOpenedSubscription ??=
          FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        final handler = _onMessageOpenedApp;
        if (handler == null) {
          return;
        }
        await handler(message);
      });

      final initialMessage = await _instance.getInitialMessage();
      if (initialMessage != null &&
          initialMessage.messageId != _handledInitialMessageId) {
        _handledInitialMessageId = initialMessage.messageId;
        final handler = _onMessageOpenedApp;
        if (handler != null) {
          await handler(initialMessage);
        }
      }
    } catch (error) {
      debugPrint('Push notification setup failed: $error');
    }
  }

  Future<void> _registerCurrentToken(String authToken) async {
    final token = await _instance.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _apiClient.registerDeviceToken(
      token: authToken,
      deviceToken: token,
      platform: 'android',
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
    _messageOpenedSubscription = null;
  }
}
