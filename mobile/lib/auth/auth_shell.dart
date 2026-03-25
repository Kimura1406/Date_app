import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/api_client.dart';
import '../data/models.dart';
import '../firebase/firestore_chat_service.dart';
import '../firebase/push_notification_service.dart';
import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../screens/account_screen.dart';
import '../screens/chat_room_detail_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/login_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/user_profile_screen.dart';
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
  final _firestoreChatService = FirestoreChatService();
  final _pushNotificationService = PushNotificationService();
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
    _pushNotificationService.dispose();
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
      _applyUser(loginResult.user, resetTab: true);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      await _persistRememberedLogin();
      await _persistSession();
      await _syncPushNotificationToken();
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
      await _syncPushNotificationToken();
      _showStatus(strings.sessionRefreshed);
    });
  }

  Future<void> _syncLatestUserSilently() async {
    if (refreshToken.isEmpty) {
      return;
    }

    try {
      final loginResult = await _apiClient.refresh(refreshToken: refreshToken);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      _applyUser(loginResult.user);
      await _persistSession();
      await _syncPushNotificationToken();
    } catch (_) {
      // Best effort sync for point balance and latest profile state.
    }
  }

  Future<void> _syncPushNotificationToken() async {
    if (authToken.trim().isEmpty) {
      return;
    }

    await _pushNotificationService.initialize(
      authToken: authToken,
      authTokenProvider: () => authToken,
      onForegroundMessage: _handleForegroundPushMessage,
      onMessageOpenedApp: _handlePushNavigation,
    );
  }

  Future<void> _handleForegroundPushMessage(RemoteMessage message) async {
    if (!mounted || currentUser == null) {
      return;
    }

    final notification = message.notification;
    final title = notification?.title?.trim().isNotEmpty == true
        ? notification!.title!.trim()
        : context.strings.notificationsTitle;
    final body = notification?.body?.trim().isNotEmpty == true
        ? notification!.body!.trim()
        : (message.data['body']?.toString().trim().isNotEmpty == true
            ? message.data['body']!.toString().trim()
            : message.data['message']?.toString().trim() ?? '');

    if (body.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 4),
            Text(body),
          ],
        ),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            _handlePushNavigation(message);
          },
        ),
      ),
    );
  }

  Future<void> _handlePushNavigation(RemoteMessage message) async {
    if (!mounted || currentUser == null || authToken.trim().isEmpty) {
      return;
    }

    final data = message.data;
    final type = (data['type'] ?? data['notificationType'] ?? '').toString();
    final roomId = (data['roomId'] ?? '').toString();
    final roomType = (data['roomType'] ?? '').toString();
    final actorUserId = (data['actorUserId'] ??
            data['userId'] ??
            data['senderUserId'] ??
            data['targetUserId'] ??
            '')
        .toString();
    final actorUserName = (data['actorUserName'] ??
            data['userName'] ??
            data['senderName'] ??
            '')
        .toString();

    if (type == 'profile_like' || type == 'profile_view') {
      await _openUserProfileFromPush(actorUserId);
      return;
    }

    if (type == 'user_message' ||
        type == 'admin_message' ||
        type == 'chat_message' ||
        roomId.isNotEmpty) {
      await _openChatRoomFromPush(
        roomId: roomId,
        roomType: roomType.isEmpty ? 'user' : roomType,
        actorUserId: actorUserId,
        actorUserName: actorUserName,
      );
      return;
    }

    await _openNotificationsScreen();
  }

  Future<void> _openNotificationsScreen() async {
    if (!mounted || currentUser == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          currentUser: currentUser!,
          authToken: authToken,
        ),
      ),
    );
  }

  Future<void> _openUserProfileFromPush(String userId) async {
    if (!mounted || currentUser == null || userId.trim().isEmpty) {
      return;
    }

    final signedInUser = currentUser!;
    final user = await _apiClient.fetchUserById(
      token: authToken,
      userId: userId,
    );
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          currentUser: signedInUser,
          authToken: authToken,
          profile: DatingProfile(
            id: user.id,
            name: user.name,
            age: user.age,
            job: user.job,
            bio: user.bio,
            distance: user.distance,
            interests: user.interests,
            country: user.country,
            gender: user.gender,
            location: user.prefecture,
            imageUrl: '',
            isNew: false,
          ),
        ),
      ),
    );
  }

  Future<void> _openChatRoomFromPush({
    required String roomId,
    required String roomType,
    required String actorUserId,
    required String actorUserName,
  }) async {
    if (!mounted || currentUser == null) {
      return;
    }

    final signedInUser = currentUser!;
    final strings = context.strings;
    ChatRoomSummary? room;
    var roomDisplayName = actorUserName.trim();

    if (roomType == 'user' &&
        FirestoreChatService.isSupportedPlatform &&
        roomId.trim().isNotEmpty) {
      room = await _firestoreChatService.fetchRoomSummary(
        roomId: roomId,
        currentUserId: signedInUser.id,
      );
      if (room != null && roomDisplayName.isEmpty) {
        final roomParticipants = room.participants;
        final other = room.participants.firstWhere(
          (participant) => participant.userId != signedInUser.id,
          orElse: () => roomParticipants.isNotEmpty
              ? roomParticipants.first
              : ChatParticipant(
                  userId: '',
                  name: strings.unknownUserLabel,
                  role: 'user',
                  isSender: false,
                ),
        );
        roomDisplayName = other.name.isNotEmpty ? other.name : strings.unknownUserLabel;
      }
    }

    if (room == null && actorUserId.trim().isNotEmpty && roomType == 'user') {
      final user = await _apiClient.fetchUserById(
        token: authToken,
        userId: actorUserId,
      );
      final profile = DatingProfile(
        id: user.id,
        name: user.name,
        age: user.age,
        job: user.job,
        bio: user.bio,
        distance: user.distance,
        interests: user.interests,
        country: user.country,
        gender: user.gender,
        location: user.prefecture,
        imageUrl: '',
        isNew: false,
      );
      room = await _firestoreChatService.ensureDirectRoom(
        currentUser: signedInUser,
        targetProfile: profile,
      );
      roomDisplayName = profile.name;
    }

    if (room == null && roomId.trim().isNotEmpty) {
      final detail = await _apiClient.fetchChatRoomDetail(
        token: authToken,
        roomId: roomId,
      );
      final lastMessage =
          detail.messages.isNotEmpty ? detail.messages.last : null;
      room = ChatRoomSummary(
        roomId: detail.roomId,
        roomType: detail.roomType,
        participants: detail.participants,
        lastMessage: lastMessage?.body ?? '',
        lastMessageAt: lastMessage?.sentAt ?? '',
        unreadCount: 0,
      );
      if (roomDisplayName.isEmpty) {
        roomDisplayName = roomType == 'admin'
            ? strings.operatorRoomName
            : strings.chatRoomsTitle;
      }
    }

    if (!mounted || room == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomDetailScreen(
          currentUser: signedInUser,
          authToken: authToken,
          initialRoom: room!,
          roomDisplayName:
              roomDisplayName.isEmpty ? strings.chatRoomsTitle : roomDisplayName,
        ),
      ),
    );
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

  void _applyUser(AppUser user, {bool resetTab = false}) {
    setState(() {
      currentUser = user;
      if (resetTab) {
        currentTab = 0;
      }
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

  void _applyUserAndPersist(AppUser user) {
    _applyUser(user);
    _persistSession();
  }

  Future<void> _restoreSession() async {
    await _restoreRememberedLogin();
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(authStorageKey);
    if (!mounted) return;
    final restoredMessage = context.strings.sessionRestored;

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
        await _syncLatestUserSilently();
        statusMessage = restoredMessage;
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
      DiscoverScreen(
        currentUser: currentUser!,
        authToken: authToken,
      ),
      TimelineScreen(
        currentUser: currentUser!,
      ),
      MatchesScreen(
        currentUser: currentUser!,
        authToken: authToken,
      ),
      AccountScreen(
        currentUser: currentUser!,
        authToken: authToken,
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
          if (index == 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _syncLatestUserSilently();
            });
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            label: strings.discoverTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.dynamic_feed_outlined),
            label: strings.timelineTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: strings.matchesTab,
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
