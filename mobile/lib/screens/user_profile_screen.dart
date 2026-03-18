import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/profile_post_factory.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';
import 'chat_room_screen.dart';

const _defaultProfileCoverImage =
    'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=80';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
    required this.currentUser,
    required this.profile,
  });

  final AppUser currentUser;
  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final posts = buildProfilePosts(profile);
    final likeCount = buildLikeCount(profile);
    final birthYear = DateTime.now().year - profile.age;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              currentUser: currentUser,
              profile: profile,
              birthYear: birthYear,
              likeCount: likeCount,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    strings.postsSectionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2330),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${posts.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E4E5D),
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                padEnds: false,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _ProfilePostFeedCard(
                      profile: profile,
                      post: posts[index],
                    ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.currentUser,
    required this.profile,
    required this.birthYear,
    required this.likeCount,
  });

  final AppUser currentUser;
  final DatingProfile profile;
  final int birthYear;
  final int likeCount;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Image.network(
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
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.24),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: const Color(0xFF4A2330),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xFFF3D6DF),
                        backgroundImage: profile.imageUrl.isNotEmpty
                            ? NetworkImage(profile.imageUrl)
                            : null,
                        child: profile.imageUrl.isEmpty
                            ? Text(
                                profile.name.isNotEmpty ? profile.name[0] : '?',
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
                    const SizedBox(width: 14),
                    Expanded(
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
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ProfileInfoChip(
                                icon: Icons.cake_outlined,
                                label: '$birthYear',
                              ),
                              _ProfileInfoChip(
                                icon: Icons.wc_outlined,
                                label: strings.genderName(profile.gender),
                              ),
                              _ProfileInfoChip(
                                icon: Icons.favorite_border_rounded,
                                label: '$likeCount',
                              ),
                              _ChatHeaderButton(
                                currentUser: currentUser,
                                profile: profile,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeaderButton extends StatelessWidget {
  const _ChatHeaderButton({
    required this.currentUser,
    required this.profile,
  });

  final AppUser currentUser;
  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                currentUser: currentUser,
                profile: profile,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF9E4E5D),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                strings.chatButtonLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePostFeedCard extends StatefulWidget {
  const _ProfilePostFeedCard({
    required this.profile,
    required this.post,
  });

  final DatingProfile profile;
  final ProfilePost post;

  @override
  State<_ProfilePostFeedCard> createState() => _ProfilePostFeedCardState();
}

class _ProfilePostFeedCardState extends State<_ProfilePostFeedCard> {
  late final PageController _pageController;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: post.imageUrls.length,
            onPageChanged: (value) {
              setState(() {
                _currentImage = value;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                post.imageUrls[index],
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
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.26),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.22, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(post.imageUrls.length, (index) {
                final active = index == _currentImage;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index == post.imageUrls.length - 1 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 110,
            child: Column(
              children: [
                _OverlayActionButton(
                  icon: Icons.favorite_rounded,
                  value: post.likeCount,
                  label: strings.like,
                ),
                const SizedBox(height: 12),
                _OverlayActionButton(
                  icon: Icons.chat_bubble_rounded,
                  value: post.commentCount,
                  label: strings.commentsLabel,
                ),
                const SizedBox(height: 12),
                _OverlayActionButton(
                  icon: Icons.card_giftcard_rounded,
                  value: post.giftCount,
                  label: strings.giftsLabel,
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 86,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.profile.name}, ${widget.profile.age}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.96),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
