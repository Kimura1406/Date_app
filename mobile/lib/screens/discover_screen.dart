import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
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
                    return ErrorState(
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
