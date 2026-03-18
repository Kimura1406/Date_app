import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/profile_post_factory.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';

const _defaultProfileCoverImage =
    'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=80';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
    required this.profile,
  });

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final posts = buildProfilePosts(profile);
    final likeCount = buildLikeCount(profile);
    final birthYear = DateTime.now().year - profile.age;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 260,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.88),
                foregroundColor: const Color(0xFF4A2330),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _defaultProfileCoverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF6D7DF), Color(0xFFE6D8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.24),
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -46),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: const Color(0xFFF3D6DF),
                          backgroundImage: profile.imageUrl.isNotEmpty
                              ? NetworkImage(profile.imageUrl)
                              : null,
                          child: profile.imageUrl.isEmpty
                              ? Text(
                                  profile.name.isNotEmpty
                                      ? profile.name[0]
                                      : '?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2330),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _ProfileInfoChip(
                                icon: Icons.cake_outlined,
                                label: '${strings.birthYearLabel}: $birthYear',
                              ),
                              _ProfileInfoChip(
                                icon: Icons.wc_outlined,
                                label:
                                    '${strings.genderProfileLabel}: ${strings.genderName(profile.gender)}',
                              ),
                              _ProfileInfoChip(
                                icon: Icons.favorite_border_rounded,
                                label: '${strings.likesCountLabel}: $likeCount',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.bio,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.45,
                                      color: const Color(0xFF6E5960),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.postsSectionTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A2330),
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return _ProfilePostCard(post: post);
                },
                childCount: posts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoChip extends StatelessWidget {
  const _ProfileInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9E4E5D)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6E5960),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({
    required this.post,
  });

  final ProfilePost post;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF6D7DF), Color(0xFFE5C5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _PostMetricRow(
                  icon: Icons.favorite_rounded,
                  label: strings.like,
                  value: post.likeCount,
                ),
                const SizedBox(height: 8),
                _PostMetricRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: strings.commentsLabel,
                  value: post.commentCount,
                ),
                const SizedBox(height: 8),
                _PostMetricRow(
                  icon: Icons.card_giftcard_rounded,
                  label: strings.giftsLabel,
                  value: post.giftCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMetricRow extends StatelessWidget {
  const _PostMetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E4E5D)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6E5960),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A2330),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
