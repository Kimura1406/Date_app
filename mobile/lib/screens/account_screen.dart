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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.myPageTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2323),
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFF0D7D0),
                    child: Text(
                      currentUser.name.isNotEmpty
                          ? currentUser.name.substring(0, 1)
                          : '?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF4A2330),
                            fontWeight: FontWeight.w800,
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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF2F2323),
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${strings.myPageBirthDateLabel}: ${currentUser.birthDate.isNotEmpty ? currentUser.birthDate : strings.notSetLabel}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6D5A5A),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${strings.myPageGenderLabel}: ${currentUser.gender.isNotEmpty ? strings.genderName(currentUser.gender) : strings.notSetLabel}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6D5A5A),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _MyPageStatsSection(
              authToken: authToken,
              pointBalance: currentUser.pointBalance,
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
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
                  color: const Color(0xFFFFF0E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusMessage,
                  style: const TextStyle(color: Color(0xFF4A2330)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyPageStatsSection extends StatefulWidget {
  const _MyPageStatsSection({
    required this.authToken,
    required this.pointBalance,
  });

  final String authToken;
  final int pointBalance;

  @override
  State<_MyPageStatsSection> createState() => _MyPageStatsSectionState();
}

class _MyPageStatsSectionState extends State<_MyPageStatsSection> {
  final ApiClient _apiClient = ApiClient();
  late Future<_MyPageStatsData> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  @override
  void didUpdateWidget(covariant _MyPageStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authToken != widget.authToken ||
        oldWidget.pointBalance != widget.pointBalance) {
      _statsFuture = _loadStats();
    }
  }

  Future<_MyPageStatsData> _loadStats() async {
    final likedUsers = await _apiClient.fetchUsersWhoLikedMe(
      token: widget.authToken,
    );
    final myFlowers = await _apiClient.fetchMyFlowers(
      token: widget.authToken,
    );
    final giftCount = [
      ...myFlowers.purchased,
      ...myFlowers.gifted,
    ].fold<int>(0, (total, item) => total + item.ownedCount);

    return _MyPageStatsData(
      likeCount: likedUsers.length,
      giftCount: giftCount,
    );
  }

  void _openLikedUsers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LikedUsersScreen(token: widget.authToken),
      ),
    );
  }

  void _openMyFlowers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MyFlowersScreen(token: widget.authToken),
      ),
    );
  }

  void _openPointGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PointGuideScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return FutureBuilder<_MyPageStatsData>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            const _MyPageStatsData(
              likeCount: 0,
              giftCount: 0,
            );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MyPageStatCard(
                label: strings.likesCountLabel,
                value: stats.likeCount.toString(),
                onTap: () => _openLikedUsers(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MyPageStatCard(
                label: strings.giftsLabel,
                value: stats.giftCount.toString(),
                onTap: () => _openMyFlowers(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MyPageStatCard(
                label: strings.myPagePoints,
                value: '${widget.pointBalance}P',
                onTap: () => _openPointGuide(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyPageStatsData {
  const _MyPageStatsData({
    required this.likeCount,
    required this.giftCount,
  });

  final int likeCount;
  final int giftCount;
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
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(strings.myPageProfileEdit),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LanguageSelectorField(
                  label: strings.changeLanguage,
                  language: selectedLanguage,
                  onChanged: onLanguageChanged,
                ),
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
                      color: const Color(0xFFFFF0E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusMessage,
                      style: const TextStyle(color: Color(0xFF4A2330)),
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
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LanguageSelectorField(
                  label: strings.changeLanguage,
                  language: selectedLanguage,
                  onChanged: onLanguageChanged,
                ),
                const SizedBox(height: 12),
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
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            strings.myPageEmptyPlaceholder,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6D5A5A),
                ),
          ),
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
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6D5A5A),
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
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6D5A5A),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2F2323),
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

class _LikedUsersScreen extends StatelessWidget {
  const _LikedUsersScreen({
    required this.token,
  });

  final String token;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final apiClient = ApiClient();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(strings.myPageLikedUsersTitle),
      ),
      body: SafeArea(
        child: FutureBuilder<List<UserLikerItem>>(
          future: apiClient.fetchUsersWhoLikedMe(token: token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D5A5A),
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final items = snapshot.data ?? const <UserLikerItem>[];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  strings.myPageNoLikedUsers,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6D5A5A),
                      ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFF0D7D0),
                        child: Text(
                          item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
                          style: const TextStyle(
                            color: Color(0xFF4A2330),
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
                                    color: const Color(0xFF2F2323),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.birthDate} • ${item.country}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF6D5A5A)),
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
          foregroundColor: const Color(0xFF2F2323),
          elevation: 0,
          title: Text(strings.myFlowersTitle),
          bottom: TabBar(
            labelColor: const Color(0xFF6D4751),
            unselectedLabelColor: const Color(0xFF8A797B),
            indicatorColor: const Color(0xFFB86A76),
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
                return Center(
                  child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6D5A5A),
                        ),
                    textAlign: TextAlign.center,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6D5A5A),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.ownedCount} • ${item.flower.pricePoints}P',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFFB86A76),
                            fontWeight: FontWeight.w800,
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
        foregroundColor: const Color(0xFF2F2323),
        elevation: 0,
        title: Text(strings.pointGuideTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.pointGuideDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4D3B3D),
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
        danger ? const Color(0xFF9B1C31) : const Color(0xFF2F2323);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
    return Divider(
      height: 1,
      color: Colors.black.withValues(alpha: 0.08),
      indent: 18,
      endIndent: 18,
    );
  }
}
