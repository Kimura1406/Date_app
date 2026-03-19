import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/discovery_filter_options.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';
import 'user_profile_screen.dart';
import '../widgets/discovery_filter_panel.dart';
import '../widgets/error_state.dart';
import '../widgets/profile_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
  });

  final AppUser currentUser;
  final String authToken;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<DatingProfile>> profilesFuture;

  bool filtersExpanded = false;
  String? selectedCountry;
  String? selectedJob;
  String? selectedGender;
  int minAge = discoveryMinAge;
  int maxAge = 35;
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profilesFuture = _loadProfiles();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<List<DatingProfile>> _loadProfiles() {
    return ApiClient().fetchProfiles(
      filter: DiscoveryFilter(
        country: selectedCountry,
        job: selectedJob,
        minAge: minAge,
        maxAge: maxAge,
        gender: selectedGender,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        excludeUserId: widget.currentUser.id,
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      if (minAge > maxAge) {
        final next = minAge;
        minAge = maxAge;
        maxAge = next;
      }
      profilesFuture = _loadProfiles();
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCountry = null;
      selectedJob = null;
      selectedGender = null;
      minAge = discoveryMinAge;
      maxAge = 35;
      _locationController.clear();
      profilesFuture = _loadProfiles();
    });
  }

  void _openProfile(DatingProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          currentUser: widget.currentUser,
          authToken: widget.authToken,
          profile: profile,
        ),
      ),
    );
  }

  Future<void> _openPlaceholderScreen({
    required String title,
    required IconData icon,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DiscoverPlaceholderScreen(
          title: title,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DiscoverHeader(
              onOpenMission: () => _openPlaceholderScreen(
                title: strings.missionTitle,
                icon: Icons.flag_circle_rounded,
              ),
              onToggleFilter: () {
                setState(() {
                  filtersExpanded = !filtersExpanded;
                });
              },
              onOpenNotifications: () => _openPlaceholderScreen(
                title: strings.notificationsTitle,
                icon: Icons.notifications_active_rounded,
              ),
            ),
            const SizedBox(height: 14),
            if (filtersExpanded) ...[
              DiscoveryFilterPanel(
                expanded: filtersExpanded,
                country: selectedCountry,
                job: selectedJob,
                gender: selectedGender,
                minAge: minAge,
                maxAge: maxAge,
                locationController: _locationController,
                onToggleExpanded: () {
                  setState(() {
                    filtersExpanded = !filtersExpanded;
                  });
                },
                onCountryChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
                onJobChanged: (value) {
                  setState(() {
                    selectedJob = value;
                  });
                },
                onGenderChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                onMinAgeChanged: (value) {
                  setState(() {
                    minAge = value;
                  });
                },
                onMaxAgeChanged: (value) {
                  setState(() {
                    maxAge = value;
                  });
                },
                onReset: _resetFilters,
                onApply: _applyFilters,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              strings.feedSectionTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2323),
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<DatingProfile>>(
                future: profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                      title: strings.cannotLoadProfiles,
                      message: snapshot.error.toString(),
                      onRetry: _applyFilters,
                    );
                  }
                  final profiles = snapshot.data ?? [];
                  if (profiles.isEmpty) {
                    return Center(
                      child: Text(
                        strings.noProfilesYet,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF6D5A5A),
                            ),
                      ),
                    );
                  }
                  return GridView.builder(
                    itemCount: profiles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.67,
                    ),
                    itemBuilder: (context, index) {
                      return ProfileCard(
                        profile: profiles[index],
                        onTap: () => _openProfile(profiles[index]),
                      );
                    },
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

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.onOpenMission,
    required this.onToggleFilter,
    required this.onOpenNotifications,
  });

  final VoidCallback onOpenMission;
  final VoidCallback onToggleFilter;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Row(
      children: [
        _HeaderActionChip(
          icon: Icons.flag_circle_rounded,
          label: 'MISSION',
          onTap: onOpenMission,
        ),
        const Spacer(),
        _HeaderIconButton(
          icon: Icons.tune_rounded,
          tooltip: strings.filterTitle,
          onTap: onToggleFilter,
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: strings.notificationsTitle,
          onTap: onOpenNotifications,
        ),
      ],
    );
  }
}

class _HeaderActionChip extends StatelessWidget {
  const _HeaderActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flag_circle_rounded,
                size: 18,
                color: Color(0xFF4A2330),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A2330),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A2330),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverPlaceholderScreen extends StatelessWidget {
  const _DiscoverPlaceholderScreen({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2F2323),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 68,
                color: const Color(0xFF9E4E5D),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2F2323),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.myPageEmptyPlaceholder,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6D5A5A),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
