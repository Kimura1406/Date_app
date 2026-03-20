import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';
import '../widgets/language_selector_field.dart';
import '../widgets/profile_field.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.statusMessage,
    required this.busy,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.ageController,
    required this.jobController,
    required this.bioController,
    required this.distanceController,
    required this.interestsController,
    required this.onRefreshSession,
    required this.onUpdate,
    required this.onDelete,
    required this.onLogout,
  });

  final AppUser currentUser;
  final String authToken;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final String statusMessage;
  final bool busy;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController jobController;
  final TextEditingController bioController;
  final TextEditingController distanceController;
  final TextEditingController interestsController;
  final Future<void> Function() onRefreshSession;
  final Future<void> Function() onUpdate;
  final Future<void> Function() onDelete;
  final Future<void> Function() onLogout;

  Future<void> _openLogoutConfirm(BuildContext context) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.myPageLogoutConfirmTitle),
          content: Text(strings.myPageLogoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onLogout();
    }
  }

  void _openPlaceholder(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SimplePlaceholderScreen(
          title: title,
          description: description ?? context.strings.myPageEmptyPlaceholder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5CA4F2), Color(0xFF4D8DDA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.myPageTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF5CA4F2).withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFE8F3FF),
                          child: Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name.substring(0, 1)
                                : '?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF4F8DDC),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF1F2A37),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${strings.myPageBirthDateLabel}: ${currentUser.birthDate.isNotEmpty ? currentUser.birthDate : strings.notSetLabel}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7C8AA5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${strings.myPageGenderLabel}: ${currentUser.gender.isNotEmpty ? strings.genderName(currentUser.gender) : strings.notSetLabel}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7C8AA5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _MyPageLikeCountChip(authToken: authToken),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MyPageStatsSection(
                    authToken: authToken,
                    selectedLanguage: selectedLanguage,
                    onLanguageChanged: onLanguageChanged,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF5CA4F2).withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _MyPageMenuTile(
                          title: strings.myPageProfileEdit,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _MyAccountEditScreen(
                                  selectedLanguage: selectedLanguage,
                                  onLanguageChanged: onLanguageChanged,
                                  statusMessage: statusMessage,
                                  busy: busy,
                                  emailController: emailController,
                                  passwordController: passwordController,
                                  nameController: nameController,
                                  ageController: ageController,
                                  jobController: jobController,
                                  bioController: bioController,
                                  distanceController: distanceController,
                                  interestsController: interestsController,
                                  onRefreshSession: onRefreshSession,
                                  onUpdate: onUpdate,
                                  onDelete: onDelete,
                                ),
                              ),
                            );
                          },
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.myPageMyHome,
                          onTap: () => _openPlaceholder(
                            context,
                            title: strings.myPageMyHome,
                          ),
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.myPageBlockList,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _BlockListScreen(
                                  title: strings.myPageBlockList,
                                  token: authToken,
                                ),
                              ),
                            );
                          },
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.myPageTerms,
                          onTap: () => _openPlaceholder(
                            context,
                            title: strings.myPageTerms,
                          ),
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.myPagePrivacy,
                          onTap: () => _openPlaceholder(
                            context,
                            title: strings.myPagePrivacy,
                          ),
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.myPageSettings,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _SettingsScreen(
                                  title: strings.myPageSettings,
                                  selectedLanguage: selectedLanguage,
                                  onLanguageChanged: onLanguageChanged,
                                  onRefreshSession: onRefreshSession,
                                ),
                              ),
                            );
                          },
                        ),
                        _MyPageDivider(),
                        _MyPageMenuTile(
                          title: strings.logout,
                          danger: true,
                          onTap: () => _openLogoutConfirm(context),
                        ),
                      ],
                    ),
                  ),
                  if (statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5FF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFCFE6FF)),
                      ),
                      child: Text(
                        statusMessage,
                        style: const TextStyle(
                          color: Color(0xFF4F8DDC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPageStatsSection extends StatefulWidget {
  const _MyPageStatsSection({
    required this.authToken,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final String authToken;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<_MyPageStatsSection> createState() => _MyPageStatsSectionState();
}

class _MyPageStatsSectionState extends State<_MyPageStatsSection> {
  final ApiClient _apiClient = ApiClient();
  late Future<int> _giftCountFuture;

  @override
  void initState() {
    super.initState();
    _giftCountFuture = _loadGiftCount();
  }

  @override
  void didUpdateWidget(covariant _MyPageStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authToken != widget.authToken) {
      _giftCountFuture = _loadGiftCount();
    }
  }

  Future<int> _loadGiftCount() async {
    final myFlowers = await _apiClient.fetchMyFlowers(
      token: widget.authToken,
    );
    return [
      ...myFlowers.purchased,
      ...myFlowers.gifted,
    ].fold<int>(0, (total, item) => total + item.ownedCount);
  }

  void _openMyFlowers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MyFlowersScreen(token: widget.authToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return FutureBuilder<int>(
      future: _giftCountFuture,
      builder: (context, snapshot) {
        final giftCount = snapshot.data ?? 0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MyPageStatCard(
                label: strings.giftsLabel,
                value: giftCount.toString(),
                onTap: () => _openMyFlowers(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MyPageLanguageCard(
                selectedLanguage: widget.selectedLanguage,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyAccountEditScreen extends StatelessWidget {
  const _MyAccountEditScreen({
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.statusMessage,
    required this.busy,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.ageController,
    required this.jobController,
    required this.bioController,
    required this.distanceController,
    required this.interestsController,
    required this.onRefreshSession,
    required this.onUpdate,
    required this.onDelete,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final String statusMessage;
  final bool busy;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController jobController;
  final TextEditingController bioController;
  final TextEditingController distanceController;
  final TextEditingController interestsController;
  final Future<void> Function() onRefreshSession;
  final Future<void> Function() onUpdate;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const _SubScreenGradientHeader(),
        title: Text(strings.myPageProfileEdit),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _SubScreenCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language is now selected in main MyPage header, so hide in edit form to avoid duplicate.
                ProfileField(
                  label: strings.emailLabel,
                  controller: emailController,
                ),
                ProfileField(
                  label: strings.passwordKeepCurrent,
                  controller: passwordController,
                  obscureText: true,
                ),
                ProfileField(
                  label: strings.displayName,
                  controller: nameController,
                ),
                ProfileField(
                  label: strings.age,
                  controller: ageController,
                  keyboardType: TextInputType.number,
                ),
                ProfileField(label: strings.job, controller: jobController),
                ProfileField(
                  label: strings.distance,
                  controller: distanceController,
                ),
                ProfileField(
                  label: strings.bio,
                  controller: bioController,
                  maxLines: 3,
                ),
                ProfileField(
                  label: strings.interests,
                  controller: interestsController,
                  hintText: strings.interestsHint,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonal(
                      onPressed: busy ? null : () async => onRefreshSession(),
                      child: Text(strings.refreshToken),
                    ),
                    FilledButton(
                      onPressed: busy ? null : () async => onUpdate(),
                      child: Text(strings.editUser),
                    ),
                    OutlinedButton(
                      onPressed: busy ? null : () async => onDelete(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9B1C31),
                      ),
                      child: Text(strings.deleteUser),
                    ),
                  ],
                ),
                if (statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCFE6FF)),
                    ),
                    child: Text(
                      statusMessage,
                      style: const TextStyle(
                        color: Color(0xFF4F8DDC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({
    required this.title,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.onRefreshSession,
  });

  final String title;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Future<void> Function() onRefreshSession;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const _SubScreenGradientHeader(),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _SubScreenCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(
                  onPressed: () async => onRefreshSession(),
                  child: Text(strings.refreshToken),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlockListScreen extends StatelessWidget {
  const _BlockListScreen({
    required this.title,
    required this.token,
  });

  final String title;
  final String token;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const _SubScreenGradientHeader(),
        title: Text(title),
      ),
      body: SafeArea(
        child: FutureBuilder<List<BlockedUserItem>>(
          future: ApiClient().fetchBlockedUsers(token: token),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _SubScreenCard(
                  child: Center(
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7C8AA5),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final items = snapshot.data ?? const <BlockedUserItem>[];
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _SubScreenCard(
                  child: Center(
                    child: Text(
                      strings.myPageEmptyPlaceholder,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7C8AA5),
                          ),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _SubScreenCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE8F3FF),
                        child: Text(
                          item.name.isNotEmpty ? item.name[0] : '?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF4F8DDC),
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF1F2A37),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.birthDate} · ${item.country}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF7C8AA5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SimplePlaceholderScreen extends StatelessWidget {
  const _SimplePlaceholderScreen({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const _SubScreenGradientHeader(),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: _SubScreenCard(
            child: Center(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF7C8AA5),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyPageStatCard extends StatelessWidget {
  const _MyPageStatCard({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.98),
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5CA4F2).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7C8AA5),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1F2A37),
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPageLanguageCard extends StatelessWidget {
  const _MyPageLanguageCard({
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CA4F2).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          LanguageSelectorField(
            label: '',
            language: selectedLanguage,
            onChanged: onLanguageChanged,
            compact: true,
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _MyPageLikeCountChip extends StatefulWidget {
  const _MyPageLikeCountChip({
    required this.authToken,
  });

  final String authToken;

  @override
  State<_MyPageLikeCountChip> createState() => _MyPageLikeCountChipState();
}

class _MyPageLikeCountChipState extends State<_MyPageLikeCountChip> {
  final ApiClient _apiClient = ApiClient();
  late Future<int> _likeCountFuture;

  @override
  void initState() {
    super.initState();
    _likeCountFuture = _loadLikeCount();
  }

  @override
  void didUpdateWidget(covariant _MyPageLikeCountChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authToken != widget.authToken) {
      _likeCountFuture = _loadLikeCount();
    }
  }

  Future<int> _loadLikeCount() async {
    final likedUsers = await _apiClient.fetchUsersWhoLikedMe(
      token: widget.authToken,
    );
    return likedUsers.length;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return FutureBuilder<int>(
      future: _likeCountFuture,
      builder: (context, snapshot) {
        final likeCount = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFCFE6FF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 16,
                color: Color(0xFF4F8DDC),
              ),
              const SizedBox(width: 6),
              Text(
                '${strings.likesCountLabel} $likeCount',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4F8DDC),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyFlowersScreen extends StatelessWidget {
  const _MyFlowersScreen({
    required this.token,
  });

  final String token;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final apiClient = ApiClient();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: const _SubScreenGradientHeader(),
          title: Text(strings.myFlowersTitle),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: strings.purchasedFlowersTab),
              Tab(text: strings.giftedFlowersTab),
            ],
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<MyFlowersResponse>(
            future: apiClient.fetchMyFlowers(token: token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: _SubScreenCard(
                    child: Center(
                      child: Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF7C8AA5),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              final response = snapshot.data ??
                  MyFlowersResponse(purchased: const [], gifted: const []);

              return TabBarView(
                children: [
                  _MyFlowerListView(
                    items: response.purchased,
                    emptyLabel: strings.noPurchasedFlowers,
                  ),
                  _MyFlowerListView(
                    items: response.gifted,
                    emptyLabel: strings.noGiftedFlowers,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MyFlowerListView extends StatelessWidget {
  const _MyFlowerListView({
    required this.items,
    required this.emptyLabel,
  });

  final List<OwnedFlowerItem> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6D5A5A),
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _FlowerImage(imageUrl: item.flower.imageUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.flower.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2F2323),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.flower.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6D5A5A),
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E7E1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.strings.ownedFlowerCountLabel(item.ownedCount),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFFB86A76),
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PointGuideScreen extends StatelessWidget {
  const _PointGuideScreen();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const _SubScreenGradientHeader(),
        title: Text(strings.pointGuideTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _SubScreenCard(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.pointGuideDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4F6380),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 18),
                _PointGuideItem(text: strings.pointGuideStepMission),
                const SizedBox(height: 12),
                _PointGuideItem(text: strings.pointGuideStepEvents),
                const SizedBox(height: 12),
                _PointGuideItem(text: strings.pointGuideStepAdmin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PointGuideItem extends StatelessWidget {
  const _PointGuideItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFB86A76),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4D3B3D),
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

class _FlowerImage extends StatelessWidget {
  const _FlowerImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final data = _decodeDataUri(imageUrl);
    if (data != null) {
      return Image.memory(data, fit: BoxFit.cover);
    }

    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.local_florist_rounded,
          size: 40,
          color: Color(0xFF6E4A4A),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.local_florist_rounded,
            size: 40,
            color: Color(0xFF6E4A4A),
          ),
        );
      },
    );
  }

  Uint8List? _decodeDataUri(String value) {
    if (!value.startsWith('data:image')) {
      return null;
    }

    final commaIndex = value.indexOf(',');
    if (commaIndex < 0) {
      return null;
    }

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}

class _SubScreenGradientHeader extends StatelessWidget {
  const _SubScreenGradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5CA4F2), Color(0xFF4D8DDA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _SubScreenCard extends StatelessWidget {
  const _SubScreenCard({
    required this.child,
    this.padding,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CA4F2).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MyPageMenuTile extends StatelessWidget {
  const _MyPageMenuTile({
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textColor =
        danger ? const Color(0xFFE15656) : const Color(0xFF1F2A37);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textColor,
      ),
      onTap: onTap,
    );
  }
}

class _MyPageDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Color(0xFFEAF2FB),
      indent: 22,
      endIndent: 22,
    );
  }
}
