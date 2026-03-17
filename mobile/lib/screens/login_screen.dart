import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
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
    return Scaffold(
      body: SafeArea(
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
                        'ログイン',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2330),
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'メールアドレスとパスワードでログインしてください',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6E5960),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'メールアドレス',
                              style:
                                  Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFF7A6D72),
                                      ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              maxLength: 50,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'メールアドレスを入力',
                                counterText: '',
                                errorText: emailErrorText,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: onEmailChanged,
                              onFieldSubmitted: (_) => onEmailSubmitted(),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'パスワード',
                              style:
                                  Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFF7A6D72),
                                      ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: passwordController,
                              focusNode: passwordFocusNode,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'パスワードを入力',
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
                                    const Expanded(
                                      child: Text('ログイン情報を記憶する'),
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
                                child: Text(busy ? 'ログイン中...' : 'ログイン'),
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
