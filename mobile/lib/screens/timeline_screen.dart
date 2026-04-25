import 'package:flutter/material.dart';

import '../data/models.dart';
import '../localization/app_localizations.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    super.key,
    required this.currentUser,
  });

  final AppUser currentUser;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late final List<_TimelinePost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List<_TimelinePost>.generate(
      3,
      (index) => _TimelinePost(
        id: 'mine_$index',
        authorName: widget.currentUser.name,
        authorHandle: '@me',
        body: _myPostBodies[index % _myPostBodies.length],
        imageUrl: _featuredImages[index % _featuredImages.length],
        publishedAtLabel: _buildPublishedAtLabel(index),
        isMine: true,
      ),
    );
  }

  Future<void> _openComposer() async {
    final strings = context.strings;
    final textController = TextEditingController();
    final imageController = TextEditingController();

    final published = await showModalBottomSheet<_TimelinePost>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final canPublish = textController.text.trim().isNotEmpty;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.timelineComposerTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1F2A37),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      maxLines: 5,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: strings.timelineComposerPlaceholder,
                        filled: true,
                        fillColor: const Color(0xFFF2F8FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFD8EBF9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFD8EBF9)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        hintText: strings.timelineImagePlaceholder,
                        filled: true,
                        fillColor: const Color(0xFFF2F8FD),
                        prefixIcon: const Icon(Icons.image_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFD8EBF9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFD8EBF9)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(strings.cancelLabel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: canPublish
                                ? () {
                                    Navigator.of(context).pop(
                                      _TimelinePost(
                                        id: DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString(),
                                        authorName: widget.currentUser.name,
                                        authorHandle: '@me',
                                        body: textController.text.trim(),
                                        imageUrl: imageController.text.trim(),
                                        publishedAtLabel: strings.timelineJustNow,
                                        isMine: true,
                                      ),
                                    );
                                  }
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2F86D7),
                            ),
                            child: Text(strings.timelinePublishButton),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    textController.dispose();
    imageController.dispose();

    if (published == null || !mounted) return;
    setState(() {
      _posts.insert(0, published);
    });
  }

  String _buildPublishedAtLabel(int index) {
    final hour = 8 + (index % 11);
    final minute = (index * 7) % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.timelineTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.timelineSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _TimelineComposerCard(
                      currentUser: widget.currentUser,
                      onTap: _openComposer,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      strings.timelineFeaturedTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1F2A37),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_posts.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _posts.length - 1 ? 12 : 14,
                        ),
                        child: _TimelinePostCard(post: _posts[index]),
                      );
                    }),
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

class _TimelineComposerCard extends StatelessWidget {
  const _TimelineComposerCard({
    required this.currentUser,
    required this.onTap,
  });

  final AppUser currentUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD9EEF9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE3F2FF),
                child: Text(
                  currentUser.name.isNotEmpty ? currentUser.name[0] : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2F86D7),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8FE),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFD8EBF9)),
                  ),
                  child: Text(
                    strings.timelineComposerPlaceholder,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF7C91A4),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.image_outlined,
                color: Color(0xFF4BA9E8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelinePostCard extends StatelessWidget {
  const _TimelinePostCard({
    required this.post,
  });

  final _TimelinePost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9EEF9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE3F2FF),
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2F86D7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1F2A37),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        post.publishedAtLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8AA0B5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              post.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5764),
                height: 1.45,
              ),
            ),
          ),
          if (post.imageUrl.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF2F8FD),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF9AB5C9),
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _PostActionButton(
                  icon: Icons.favorite_border_rounded,
                  label: '\u3044\u3044\u306d',
                ),
                SizedBox(width: 18),
                _PostActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '\u30b3\u30e1\u30f3\u30c8',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF8AA0B5),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF8AA0B5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimelinePost {
  const _TimelinePost({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.body,
    required this.imageUrl,
    required this.publishedAtLabel,
    required this.isMine,
  });

  final String id;
  final String authorName;
  final String authorHandle;
  final String body;
  final String imageUrl;
  final String publishedAtLabel;
  final bool isMine;
}

const _featuredImages = <String>[
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
];

const _myPostBodies = <String>[
  'Today I want to keep things simple, calm, and honest.',
  'A warm drink, a little music, and a good conversation would be perfect.',
  'Posting a small update here before I start chatting tonight.',
];
