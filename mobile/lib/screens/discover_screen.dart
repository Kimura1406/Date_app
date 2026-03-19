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
  });

  final AppUser currentUser;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<DatingProfile>> profilesFuture;

  bool filtersExpanded = true;
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
          profile: profile,
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
