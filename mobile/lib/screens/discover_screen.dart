import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';
import '../widgets/error_state.dart';
import '../widgets/profile_card.dart';

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
    final strings = context.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.discoverTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2330),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.discoverSubtitle,
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
                    return ErrorState(
                      title: strings.cannotLoadProfiles,
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
                    return Center(child: Text(strings.noProfilesYet));
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
