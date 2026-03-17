import 'package:flutter/material.dart';

import '../data/models.dart';
import '../localization/app_localizations.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

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
                  child: Text(strings.skip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: Text(strings.like),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
