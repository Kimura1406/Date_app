import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
const authStorageKey = 'kimura_mobile_auth';

void main() {
  runApp(const KimuraApp());
}

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DiscoverScreen(),
      const MatchesScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: screens[currentTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          setState(() {
            currentTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Discover'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline), label: 'Matches'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<DatingProfile>> profilesFuture;

  @override
  void initState() {
    super.initState();
    profilesFuture = ApiClient().fetchProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kimura',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2330),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Find people you actually want to talk to.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6E5960),
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<DatingProfile>>(
                future: profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _ErrorState(
                      title: 'Cannot load profiles',
                      message: snapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          profilesFuture = ApiClient().fetchProfiles();
                        });
                      },
                    );
                  }

                  final profiles = snapshot.data ?? [];
                  if (profiles.isEmpty) {
                    return const Center(child: Text('No profiles yet'));
                  }

                  return ListView.separated(
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        ProfileCard(profile: profiles[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late Future<List<MatchItem>> matchesFuture;

  @override
  void initState() {
    super.initState();
    matchesFuture = ApiClient().fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<MatchItem>>(
          future: matchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                title: 'Cannot load matches',
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    matchesFuture = ApiClient().fetchMatches();
                  });
                },
              );
            }

            final matches = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Matches',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = matches[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF6CDD2),
                          child:
                              Text(item.name.isNotEmpty ? item.name[0] : '?'),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.lastMessage),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item.lastSeen),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.status == 'new'
                                    ? const Color(0xFFFFE2B9)
                                    : const Color(0xFFD9F4DD),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(item.status),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _apiClient = ApiClient();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _countryController = TextEditingController();
  final _prefectureController = TextEditingController();
  final _datingReasonController = TextEditingController();

  AppUser? currentUser;
  String authToken = '';
  String refreshToken = '';
  bool busy = false;
  bool restoringSession = true;
  String statusMessage = 'Create a user or login with an existing account.';

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _birthDateController.dispose();
    _countryController.dispose();
    _prefectureController.dispose();
    _datingReasonController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    await _runAction(() async {
      final user =
          await _apiClient.createUser(_buildPayload(includePassword: true));
      _applyUser(user);
      authToken = '';
      refreshToken = '';
      await _persistSession();
      _showStatus('User created successfully. Please login to receive a JWT.');
    });
  }

  Future<void> _login() async {
    await _runAction(() async {
      final loginResult = await _apiClient.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _applyUser(loginResult.user);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      await _persistSession();
      _showStatus('Login successful.');
    });
  }

  Future<void> _refreshSession() async {
    if (refreshToken.isEmpty) {
      _showStatus('No refresh token available. Please login again.');
      return;
    }

    await _runAction(() async {
      final loginResult = await _apiClient.refresh(refreshToken: refreshToken);
      _applyUser(loginResult.user);
      authToken = loginResult.accessToken;
      refreshToken = loginResult.refreshToken;
      await _persistSession();
      _showStatus('Session refreshed successfully.');
    });
  }

  Future<void> _update() async {
    if (currentUser == null) {
      _showStatus('Please login first before updating.');
      return;
    }

    await _runAction(() async {
      final user = await _apiClient.updateUser(
        currentUser!.id,
        authToken,
        _buildPayload(
            includePassword: _passwordController.text.trim().isNotEmpty),
      );
      _applyUser(user);
      await _persistSession();
      _showStatus('Profile updated successfully.');
    });
  }

  Future<void> _delete() async {
    if (currentUser == null) {
      _showStatus('Please login first before deleting.');
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
      _showStatus('Account deleted successfully.');
    });
  }

  Future<void> _logout() async {
    if (refreshToken.isNotEmpty) {
      await _runAction(() async {
        await _apiClient.logout(refreshToken: refreshToken);
        authToken = '';
        refreshToken = '';
        setState(() {
          currentUser = null;
        });
        await _clearSession();
        _showStatus('Logged out successfully.');
      });
      return;
    }

    authToken = '';
    refreshToken = '';
    setState(() {
      currentUser = null;
    });
    await _clearSession();
    _showStatus('Logged out.');
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
      name: _usernameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      country: _countryController.text.trim(),
      prefecture: _prefectureController.text.trim(),
      datingReason: _datingReasonController.text.trim(),
    );
  }

  void _applyUser(AppUser user) {
    setState(() {
      currentUser = user;
    });
    _emailController.text = user.email;
    _usernameController.text = user.name;
    _birthDateController.text = user.birthDate;
    _countryController.text = user.country;
    _prefectureController.text = user.prefecture;
    _datingReasonController.text = user.datingReason;
    _passwordController.clear();
  }

  Future<void> _restoreSession() async {
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
        statusMessage = 'Session restored successfully.';
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

  void _clearForm({required bool keepAuthFields}) {
    if (!keepAuthFields) {
      _emailController.clear();
      _passwordController.clear();
    }
    _usernameController.clear();
    _birthDateController.clear();
    _countryController.clear();
    _prefectureController.clear();
    _datingReasonController.clear();
  }

  void _showStatus(String message) {
    if (!mounted) return;
    setState(() {
      statusMessage = message;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (restoringSession) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Center',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              currentUser == null
                  ? 'App users can create, login, edit, and delete their own account here.'
                  : 'Logged in as ${currentUser!.name} (${currentUser!.email}) with role ${currentUser!.role}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E5960),
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _ProfileField(
                    label: currentUser == null
                        ? 'Password'
                        : 'Password (leave blank to keep current password)',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  _ProfileField(
                    label: 'ユーザーネーム',
                    controller: _usernameController,
                  ),
                  _ProfileField(
                    label: '生年月日',
                    controller: _birthDateController,
                    hintText: 'YYYY-MM-DD',
                  ),
                  _ProfileField(
                    label: '国',
                    controller: _countryController,
                  ),
                  _ProfileField(
                    label: '都道府県',
                    controller: _prefectureController,
                  ),
                  _ProfileField(
                    label: '付き合う理由',
                    controller: _datingReasonController,
                    maxLines: 3,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: busy ? null : _register,
                        child: Text(busy ? 'Working...' : 'Create user'),
                      ),
                      FilledButton.tonal(
                        onPressed: busy ? null : _login,
                        child: const Text('Login'),
                      ),
                      FilledButton.tonal(
                        onPressed: busy ? null : _refreshSession,
                        child: const Text('Refresh token'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : _update,
                        child: const Text('Edit user'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9B1C31),
                        ),
                        child: const Text('Delete user'),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : _logout,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7A6D72),
                ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBE4E1), Color(0xFFF5D9E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Chip(
              label: Text(profile.distance),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '${profile.name}, ${profile.age}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF45212B),
                ),
          ),
          const SizedBox(height: 8),
          Text(profile.job),
          const SizedBox(height: 12),
          Text(profile.bio),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests
                .map(
                  (interest) => Chip(
                    label: Text(interest),
                    side: BorderSide.none,
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Like'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<DatingProfile>> fetchProfiles() async {
    final response =
        await _client.get(Uri.parse('$apiBaseUrl/api/v1/discovery'));
    if (response.statusCode != 200) {
      throw Exception('Discovery request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => DatingProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MatchItem>> fetchMatches() async {
    final response = await _client.get(Uri.parse('$apiBaseUrl/api/v1/matches'));
    if (response.statusCode != 200) {
      throw Exception('Matches request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => MatchItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser> createUser(CreateUserPayload payload) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    return _parseUserResponse(response, fallback: 'Create user failed');
  }

  Future<AppUser> updateUser(
    String userId,
    String token,
    CreateUserPayload payload,
  ) async {
    final response = await _client.put(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload.toJson()),
    );
    return _parseUserResponse(response, fallback: 'Update user failed');
  }

  Future<void> deleteUser(String userId, String token) async {
    final response = await _client.delete(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Delete user failed'));
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Login failed'));
    }

    return LoginResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<LoginResult> refresh({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Refresh failed'));
    }

    return LoginResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> logout({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Logout failed'));
    }
  }

  AppUser _parseUserResponse(http.Response response,
      {required String fallback}) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response.body, fallback));
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromJson(jsonMap);
  }

  String _extractError(String body, String fallback) {
    try {
      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      return jsonMap['error'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

class DatingProfile {
  DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.job,
    required this.bio,
    required this.distance,
    required this.interests,
  });

  final String id;
  final String name;
  final int age;
  final String job;
  final String bio;
  final String distance;
  final List<String> interests;

  factory DatingProfile.fromJson(Map<String, dynamic> json) {
    return DatingProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      job: json['job'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class MatchItem {
  MatchItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastSeen,
    required this.status,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String lastSeen;
  final String status;

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastSeen: json['lastSeen'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.age,
    required this.job,
    required this.bio,
    required this.distance,
    required this.interests,
    required this.birthDate,
    required this.country,
    required this.prefecture,
    required this.datingReason,
  });

  final String id;
  final String email;
  final String role;
  final String name;
  final int age;
  final String job;
  final String bio;
  final String distance;
  final List<String> interests;
  final String birthDate;
  final String country;
  final String prefecture;
  final String datingReason;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      job: json['job'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      birthDate: json['birthDate'] as String? ?? '',
      country: json['country'] as String? ?? '',
      prefecture: json['prefecture'] as String? ?? '',
      datingReason: json['datingReason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'age': age,
      'job': job,
      'bio': bio,
      'distance': distance,
      'interests': interests,
      'birthDate': birthDate,
      'country': country,
      'prefecture': prefecture,
      'datingReason': datingReason,
    };
  }
}

class CreateUserPayload {
  CreateUserPayload({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    required this.country,
    required this.prefecture,
    required this.datingReason,
  });

  final String email;
  final String password;
  final String name;
  final String birthDate;
  final String country;
  final String prefecture;
  final String datingReason;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate,
      'country': country,
      'prefecture': prefecture,
      'datingReason': datingReason,
    };
  }
}

class LoginResult {
  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>? ?? {};
    return LoginResult(
      accessToken: tokens['accessToken'] as String? ?? '',
      refreshToken: tokens['refreshToken'] as String? ?? '',
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
