import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';
import '../widgets/error_state.dart';

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
    final strings = context.strings;

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
              return ErrorState(
                title: strings.cannotLoadMatches,
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
                  strings.matchesTitle,
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.status == 'new'
                                    ? const Color(0xFFFFE2B9)
                                    : const Color(0xFFD9F4DD),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(strings.matchStatus(item.status)),
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
