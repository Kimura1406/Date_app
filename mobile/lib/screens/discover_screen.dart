import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
  late Future<List<DiscoverBannerItem>> bannersFuture;
  late final PageController _bannerController;
  Timer? _bannerAutoSlideTimer;

  bool filtersExpanded = false;
  int currentBanner = 0;
  int _bannerCount = 0;
  String? selectedCountry;
  String? selectedJob;
  String? selectedGender;
  int minAge = discoveryMinAge;
  int maxAge = 35;
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.9);
    profilesFuture = _loadProfiles();
    bannersFuture = _loadBanners().then((banners) {
      _configureBannerAutoSlide(banners.length);
      return banners;
    });
  }

  @override
  void dispose() {
    _bannerAutoSlideTimer?.cancel();
    _bannerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _configureBannerAutoSlide(int bannerCount) {
    _bannerAutoSlideTimer?.cancel();
    _bannerCount = bannerCount;

    if (bannerCount <= 1) {
      if (mounted && currentBanner != 0) {
        setState(() {
          currentBanner = 0;
        });
      }
      return;
    }

    _bannerAutoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients || _bannerCount <= 1) {
        return;
      }

      final nextBanner = (currentBanner + 1) % _bannerCount;
      _bannerController.animateToPage(
        nextBanner,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    });
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

  Future<List<DiscoverBannerItem>> _loadBanners() {
    return ApiClient().fetchPublicBanners();
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
    final theme = Theme.of(context);

    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2FAFF),
              Color(0xFFE7F5FF),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF4BA9E8),
                    Color(0xFF2F86D7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x220A4474),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: _DiscoverHeader(
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
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ] else ...[
                      FutureBuilder<List<DiscoverBannerItem>>(
                future: bannersFuture,
                builder: (context, snapshot) {
                  final banners = snapshot.data ?? const <DiscoverBannerItem>[];
                  if (snapshot.connectionState != ConnectionState.done || banners.isEmpty) {
                    return const SizedBox.shrink();
                  }

                          return _DiscoverBannerCarousel(
                            banners: banners,
                            controller: _bannerController,
                            currentBanner: currentBanner,
                            onPageChanged: (value) {
                              setState(() {
                                currentBanner = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                    Text(
                      strings.feedSectionTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2A37),
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6E8297),
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    itemCount: profiles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.66,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverBannerCarousel extends StatelessWidget {
  const _DiscoverBannerCarousel({
    required this.banners,
    required this.controller,
    required this.currentBanner,
    required this.onPageChanged,
  });

  final List<DiscoverBannerItem> banners;
  final PageController controller;
  final int currentBanner;
  final ValueChanged<int> onPageChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox.expand(
                      child: _DiscoverBannerImage(imageUrl: banner.imageUrl),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final active = index == currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF4BA9E8) : Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DiscoverBannerImage extends StatelessWidget {
  const _DiscoverBannerImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final data = _decodeDataUri(imageUrl);
    if (data != null) {
      return Image.memory(data, fit: BoxFit.cover);
    }

    if (imageUrl.isEmpty) {
      return Container(color: const Color(0xFFF5D7DE));
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: const Color(0xFFF5D7DE));
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
          icon: Icons.flag_rounded,
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
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 12,
                  color: const Color(0xFFFACC15),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
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
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
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
