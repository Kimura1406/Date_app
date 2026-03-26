import 'package:flutter/foundation.dart';

const _localBackendLanBaseUrl = 'http://192.168.1.12:8080';

String get apiBaseUrl {
  const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (configuredBaseUrl.isNotEmpty) {
    return configuredBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:8080';
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => _localBackendLanBaseUrl,
    TargetPlatform.iOS => _localBackendLanBaseUrl,
    TargetPlatform.fuchsia => 'http://localhost:8080',
    TargetPlatform.macOS => 'http://localhost:8080',
    TargetPlatform.windows => 'http://localhost:8080',
    TargetPlatform.linux => 'http://localhost:8080',
  };
}

const authStorageKey = 'kimura_mobile_auth';
const rememberedLoginStorageKey = 'kimura_mobile_login_form';
const languageStorageKey = 'kimura_app_language';
