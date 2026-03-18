import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../screens/account_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/flower_shop_screen.dart';
import '../screens/login_screen.dart';
import '../screens/matches_screen.dart';
import '../widgets/app_scene_background.dart';

class AuthShell extends StatefulWidget {
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final _apiClient = ApiClient();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '18');
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();
  final _distanceController = TextEditingController();
  final _interestsController = TextEditingController();

  AppUser? currentUser;
  String authToken = '';
  String refreshToken = '';
  String statusMessage = '';
  bool busy = false;
  bool restoringSession = true;
  bool emailTouched = false;
  bool passwordTouched = false;
  bool loginAttempted = false;
  bool obscurePassword = true;
  bool rememberLoginInfo = false;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    _distanceController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  String get _trimmedEmail => _emailController.text.trim();
  String get _trimmedPassword => _passwordController.text.trim();
  bool get _isEmailValid =>
      _trimmedEmail.isNotEmpty && _emailPattern.hasMatch(_trimmedEmail);
  bool get _isPasswordValid => _trimmedPassword.isNotEmpty;
  bool get _isLoginFormValid => _isEmailValid && _isPasswordValid && !busy;

  String? _emailErrorText(AppStrings strings) {
    if (!(emailTouched || loginAttempted)) return null;
    if (_trimmedEmail.isEmpty) return strings.emailRequired;
    if (!_emailPattern.hasMatch(_trimmedEmail)) return strings.emailInvalid;
    return null;
  }

  String? _passwordErrorText(AppStrings strings) {
    if (!(passwordTouched || loginAttempted)) return null;
    if (_trimmedPassword.isEmpty) return strings.passwordRequired;
    return null;
  }

  Future<void> _login() async {
    final strings = context.strings;
    await _runAction(() async {
      final loginResult = await _apiClient.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _applyUser(loginResult.user);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      await _persistRememberedLogin();
      await _persistSession();
      _showStatus(strings.loginSuccessful);
    });
  }

  Future<void> _submitLogin() async {
    setState(() {
      loginAttempted = true;
      emailTouched = true;
      passwordTouched = true;
    });
    if (!_isLoginFormValid) return;
    await _login();
  }

  Future<void> _refreshSession() async {
    final strings = context.strings;
    if (refreshToken.isEmpty) {
      _showStatus(strings.noRefreshToken);
      return;
    }
    await _runAction(() async {
      final loginResult = await _apiClient.refresh(refreshToken: refreshToken);
      _applyUser(loginResult.user);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      await _persistSession();
      _showStatus(strings.sessionRefreshed);
    });
  }

  Future<void> _update() async {
    final strings = context.strings;
    if (currentUser == null) {
      _showStatus(strings.loginBeforeUpdate);
      return;
    }
    await _runAction(() async {
      final user = await _apiClient.updateUser(
        currentUser!.id,
        authToken,
        _buildPayload(
          includePassword: _passwordController.text.trim().isNotEmpty,
        ),
      );
      _applyUser(user);
      await _persistSession();
      _showStatus(strings.profileUpdated);
    });
  }

  Future<void> _delete() async {
    final strings = context.strings;
    if (currentUser == null) {
      _showStatus(strings.loginBeforeDelete);
      return;
    }
    await _runAction(() async {
      await _apiClient.deleteUser(currentUser!.id, authToken);
      authToken = '';
      refreshToken = '';
      setState(() {
        currentUser = null;
      });
      _clearForm(keepAuthFields: false);
      await _clearSession();
      _showStatus(strings.accountDeleted);
    });
  }

  Future<void> _logout() async {
    final strings = context.strings;
    if (refreshToken.isNotEmpty) {
      await _runAction(() async {
        await _apiClient.logout(refreshToken: refreshToken);
        authToken = '';
        refreshToken = '';
        setState(() {
          currentUser = null;
        });
        await _clearSession();
        _showStatus(strings.loggedOutSuccessfully);
      });
      return;
    }
    authToken = '';
    refreshToken = '';
    setState(() {
      currentUser = null;
    });
    await _clearSession();
    _showStatus(strings.loggedOut);
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      busy = true;
    });
    try {
      await action();
    } catch (error) {
      _showStatus(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  CreateUserPayload _buildPayload({required bool includePassword}) {
    return CreateUserPayload(
      email: _emailController.text.trim(),
      password: includePassword ? _passwordController.text.trim() : '',
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      job: _jobController.text.trim(),
      bio: _bioController.text.trim(),
      distance: _distanceController.text.trim(),
      interests: _interestsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }

  void _applyUser(AppUser user) {
    setState(() {
      currentUser = user;
      currentTab = 0;
    });
    _emailController.text = user.email;
    _nameController.text = user.name;
    _ageController.text = user.age.toString();
    _jobController.text = user.job;
    _bioController.text = user.bio;
    _distanceController.text = user.distance;
    _interestsController.text = user.interests.join(', ');
    _passwordController.clear();
  }

  Future<void> _restoreSession() async {
    await _restoreRememberedLogin();
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(authStorageKey);
    if (!mounted) return;

    if (raw == null || raw.isEmpty) {
      setState(() {
        restoringSession = false;
      });
      return;
    }

    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      final storedUser = AppUser.fromJson(
        jsonMap['user'] as Map<String, dynamic>? ?? {},
      );
      authToken = jsonMap['authToken'] as String? ?? '';
      refreshToken = jsonMap['refreshToken'] as String? ?? '';
      if (authToken.isEmpty || refreshToken.isEmpty || storedUser.id.isEmpty) {
        await preferences.remove(authStorageKey);
      } else {
        _applyUser(storedUser);
        statusMessage = context.strings.sessionRestored;
      }
    } catch (_) {
      await preferences.remove(authStorageKey);
    }

    if (!mounted) return;
    setState(() {
      restoringSession = false;
    });
  }

  Future<void> _persistSession() async {
    final preferences = await SharedPreferences.getInstance();
    if (currentUser == null || authToken.isEmpty || refreshToken.isEmpty) {
      await preferences.remove(authStorageKey);
      return;
    }
    await preferences.setString(
      authStorageKey,
      jsonEncode({
        'authToken': authToken,
        'refreshToken': refreshToken,
        'user': currentUser!.toJson(),
      }),
    );
  }

  Future<void> _clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(authStorageKey);
  }

  Future<void> _restoreRememberedLogin() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(rememberedLoginStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      _emailController.text = jsonMap['email'] as String? ?? '';
      _passwordController.text = jsonMap['password'] as String? ?? '';
      rememberLoginInfo = jsonMap['remember'] as bool? ?? false;
    } catch (_) {
      await preferences.remove(rememberedLoginStorageKey);
    }
  }

  Future<void> _persistRememberedLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!rememberLoginInfo) {
      await preferences.remove(rememberedLoginStorageKey);
      return;
    }
    await preferences.setString(
      rememberedLoginStorageKey,
      jsonEncode({
        'email': _trimmedEmail,
        'password': _passwordController.text,
        'remember': true,
      }),
    );
  }

  void _clearForm({required bool keepAuthFields}) {
    if (!keepAuthFields) {
      _emailController.clear();
      _passwordController.clear();
    }
    _nameController.clear();
    _ageController.text = '18';
    _jobController.clear();
    _bioController.clear();
    _distanceController.clear();
    _interestsController.clear();
  }

  void _showStatus(String message) {
    if (!mounted) return;
    setState(() {
      statusMessage = message;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    await context.languageController.setLanguage(language);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    if (restoringSession) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: AppSceneBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (currentUser == null) {
      return LoginScreen(
        selectedLanguage: context.languageController.language,
        onLanguageChanged: _changeLanguage,
        emailController: _emailController,
        passwordController: _passwordController,
        passwordFocusNode: _passwordFocusNode,
        busy: busy,
        obscurePassword: obscurePassword,
        rememberLoginInfo: rememberLoginInfo,
        statusMessage: statusMessage,
        emailErrorText: _emailErrorText(strings),
        passwordErrorText: _passwordErrorText(strings),
        isLoginEnabled: _isLoginFormValid,
        onEmailChanged: (_) {
          if (!emailTouched) emailTouched = true;
          setState(() {});
        },
        onPasswordChanged: (_) {
          if (!passwordTouched) passwordTouched = true;
          setState(() {});
        },
        onEmailSubmitted: () =>
            FocusScope.of(context).requestFocus(_passwordFocusNode),
        onPasswordSubmitted: () async {
          if (_isLoginFormValid) {
            await _submitLogin();
          } else {
            setState(() {
              loginAttempted = true;
              emailTouched = true;
              passwordTouched = true;
            });
          }
        },
        onTogglePasswordVisibility: () {
          setState(() {
            obscurePassword = !obscurePassword;
          });
        },
        onToggleRememberLogin: (value) {
          setState(() {
            rememberLoginInfo = value;
          });
        },
        onSubmit: _submitLogin,
      );
    }

    final screens = [
      DiscoverScreen(currentUser: currentUser!),
      MatchesScreen(
        currentUser: currentUser!,
        authToken: authToken,
      ),
      const FlowerShopScreen(),
      AccountScreen(
        currentUser: currentUser!,
        selectedLanguage: context.languageController.language,
        onLanguageChanged: _changeLanguage,
        statusMessage: statusMessage,
        busy: busy,
        emailController: _emailController,
        passwordController: _passwordController,
        nameController: _nameController,
        ageController: _ageController,
        jobController: _jobController,
        bioController: _bioController,
        distanceController: _distanceController,
        interestsController: _interestsController,
        onRefreshSession: _refreshSession,
        onUpdate: _update,
        onDelete: _delete,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppSceneBackground(
        child: screens[currentTab],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFF4E6E0),
        indicatorColor: const Color(0xFFE7C4BC),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF6D4A4A),
                fontWeight: FontWeight.w600,
              ),
        ),
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          setState(() {
            currentTab = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            label: strings.discoverTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: strings.matchesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_florist_outlined),
            label: strings.flowerShopTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: strings.myPageTab,
          ),
        ],
      ),
    );
  }
}
