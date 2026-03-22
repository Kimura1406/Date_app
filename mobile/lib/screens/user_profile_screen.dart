import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../data/profile_post_factory.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';
import '../widgets/app_scene_background.dart';
import 'chat_room_detail_screen.dart';

const _defaultProfileCoverImage =
    'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=80';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
    required this.profile,
  });

  final AppUser currentUser;
  final String authToken;
  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final posts = buildProfilePosts(profile);
    final birthYear = DateTime.now().year - profile.age;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppSceneBackground(
        child: Column(
          children: [
            _ProfileHeader(
              currentUser: currentUser,
              authToken: authToken,
              profile: profile,
              birthYear: birthYear,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    strings.postsSectionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2F2323),
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
    required this.authToken,
    required this.profile,
    required this.birthYear,
  });

  final AppUser currentUser;
  final String authToken;
  final DatingProfile profile;
  final int birthYear;

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
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.34),
                        Colors.white.withValues(alpha: 0.82),
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
                top: 14,
                right: 14,
                child: _ProfileActionMenu(
                  authToken: authToken,
                  profile: profile,
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
                                      color: const Color(0xFF4A2330),
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
                                  color: const Color(0xFF2F2323),
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
                              _LikeHeaderChip(
                                currentUser: currentUser,
                                authToken: authToken,
                                profile: profile,
                              ),
                              _ChatHeaderButton(
                                currentUser: currentUser,
                                authToken: authToken,
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
    required this.authToken,
    required this.profile,
  });

  final AppUser currentUser;
  final String authToken;
  final DatingProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            final detail = await ApiClient().ensureDirectChatRoom(
              token: authToken,
              targetUserId: profile.id,
            );
            if (!context.mounted) return;

            final lastMessage = detail.messages.isNotEmpty ? detail.messages.last : null;
            final initialRoom = ChatRoomSummary(
              roomId: detail.roomId,
              roomType: detail.roomType,
              participants: detail.participants,
              lastMessage: lastMessage?.body ?? '',
              lastMessageAt: lastMessage?.sentAt ?? '',
              unreadCount: 0,
            );

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatRoomDetailScreen(
                  currentUser: currentUser,
                  authToken: authToken,
                  initialRoom: initialRoom,
                  roomDisplayName: profile.name,
                ),
              ),
            );
          } catch (error) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0D7D0),
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
                color: Color(0xFF4A2330),
              ),
              const SizedBox(width: 8),
              Text(
                strings.chatButtonLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4A2330),
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

class _ProfileActionMenu extends StatelessWidget {
  const _ProfileActionMenu({
    required this.authToken,
    required this.profile,
  });

  final String authToken;
  final DatingProfile profile;

  Future<void> _openReportDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${profile.name}を通報する'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '理由',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLength: 100,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '理由を入力してください',
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () async {
                    final reason = controller.text.trim();
                    if (reason.isEmpty) {
                      setDialogState(() {
                        errorText = '通報理由を入力してください';
                      });
                      return;
                    }
                    await ApiClient().reportUser(
                      token: authToken,
                      userId: profile.id,
                      reason: reason,
                    );
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('通報しました')),
                    );
                  },
                  child: const Text('通報する'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openBlockConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${profile.name}をブロック'),
          content: Text('${profile.name}をブロックしてもよろしいですか'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('はい'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await ApiClient().blockUser(
      token: authToken,
      userId: profile.id,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${profile.name}をブロックしました')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        try {
          if (value == 'block') {
            await _openBlockConfirm(context);
          } else if (value == 'report') {
            await _openReportDialog(context);
          }
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'block',
          child: Text('ブロック'),
        ),
        PopupMenuItem<String>(
          value: 'report',
          child: Text('通報'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withValues(alpha: 0.96),
      icon: const Icon(Icons.more_horiz_rounded),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        foregroundColor: const Color(0xFF4A2330),
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
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4A2330)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A2330),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _LikeHeaderChip extends StatefulWidget {
  const _LikeHeaderChip({
    required this.currentUser,
    required this.authToken,
    required this.profile,
  });

  final AppUser currentUser;
  final String authToken;
  final DatingProfile profile;

  @override
  State<_LikeHeaderChip> createState() => _LikeHeaderChipState();
}

class _LikeHeaderChipState extends State<_LikeHeaderChip> {
  final ApiClient _apiClient = ApiClient();
  UserLikeSummary? _summary;
  bool _loading = true;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _apiClient.fetchUserLikeSummary(
        token: widget.authToken,
        userId: widget.profile.id,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _summary = UserLikeSummary(
          targetUserId: widget.profile.id,
          likeCount: 0,
          likedByMe: false,
        );
        _loading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_toggling || widget.currentUser.id == widget.profile.id) {
      return;
    }

    setState(() {
      _toggling = true;
    });

    try {
      final summary = await _apiClient.toggleUserLike(
        token: widget.authToken,
        userId: widget.profile.id,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _toggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final likedByMe = summary?.likedByMe ?? false;
    final likeCount = summary?.likeCount ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading ? null : _toggleLike,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: likedByMe
                ? const Color(0xFFFFEDF1)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: likedByMe
                  ? const Color(0xFFE8A9B7)
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_toggling)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16,
                  color: likedByMe
                      ? const Color(0xFFD94162)
                      : const Color(0xFF4A2330),
                ),
              const SizedBox(width: 6),
              Text(
                '$likeCount',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4A2330),
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
                    Colors.white.withValues(alpha: 0.02),
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.48),
                    Colors.white.withValues(alpha: 0.92),
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
                          ? const Color(0xFF4A2330)
                          : const Color(0xFFB7928E),
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
                        color: const Color(0xFF2F2323),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5C4545),
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
            color: Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: Icon(icon, color: const Color(0xFF4A2330), size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A2330),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6D5A5A),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
