import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../widgets/app_scene_background.dart';
import '../widgets/language_selector_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.busy,
    required this.obscurePassword,
    required this.rememberLoginInfo,
    required this.statusMessage,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.isLoginEnabled,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onEmailSubmitted,
    required this.onPasswordSubmitted,
    required this.onTogglePasswordVisibility,
    required this.onToggleRememberLogin,
    required this.onSubmit,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool busy;
  final bool obscurePassword;
  final bool rememberLoginInfo;
  final String statusMessage;
  final String? emailErrorText;
  final String? passwordErrorText;
  final bool isLoginEnabled;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onEmailSubmitted;
  final Future<void> Function() onPasswordSubmitted;
  final VoidCallback onTogglePasswordVisibility;
  final ValueChanged<bool> onToggleRememberLogin;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppSceneBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.loginTitle,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.loginSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LanguageSelectorField(
                              label: strings.changeLanguage,
                              language: selectedLanguage,
                              onChanged: onLanguageChanged,
                            ),
                            Text(
                              strings.emailLabel,
                              style:
                                  Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFF6A5D62),
                                      ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: emailController,
                              style: const TextStyle(
                                color: Color(0xFF20181B),
                              ),
                              cursorColor: const Color(0xFF9E4E5D),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              maxLength: 50,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: strings.emailPlaceholder,
                                counterText: '',
                                errorText: emailErrorText,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: onEmailChanged,
                              onFieldSubmitted: (_) => onEmailSubmitted(),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              strings.passwordLabel,
                              style:
                                  Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFF6A5D62),
                                      ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: passwordController,
                              focusNode: passwordFocusNode,
                              style: const TextStyle(
                                color: Color(0xFF20181B),
                              ),
                              cursorColor: const Color(0xFF9E4E5D),
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: strings.passwordPlaceholder,
                                errorText: passwordErrorText,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: onTogglePasswordVisibility,
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              onChanged: onPasswordChanged,
                              onFieldSubmitted: (_) async =>
                                  onPasswordSubmitted(),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  onToggleRememberLogin(!rememberLoginInfo),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: rememberLoginInfo,
                                      onChanged: (value) =>
                                          onToggleRememberLogin(
                                        value ?? false,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(strings.rememberLogin),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: isLoginEnabled
                                    ? () async => onSubmit()
                                    : null,
                                child: Text(
                                  busy
                                      ? strings.signingIn
                                      : strings.loginButton,
                                ),
                              ),
                            ),
                            if (statusMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(statusMessage),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (busy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
