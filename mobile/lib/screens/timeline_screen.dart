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
                            color: const Color(0xFF2F2323),
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
                        fillColor: const Color(0xFFF9F3F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        hintText: strings.timelineImagePlaceholder,
                        filled: true,
                        fillColor: const Color(0xFFF9F3F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
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
                                        id: DateTime.now().microsecondsSinceEpoch.toString(),
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.timelineTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2F2323),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.timelineSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D5A5A),
                  ),
            ),
            const SizedBox(height: 16),
            _TimelineComposerCard(
              currentUser: widget.currentUser,
              onTap: _openComposer,
            ),
            const SizedBox(height: 16),
            Text(
              strings.timelineFeaturedTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2F2323),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _TimelinePostCard(post: _posts[index]);
                },
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
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
                radius: 24,
                backgroundColor: const Color(0xFFF3D6DF),
                child: Text(
                  currentUser.name.isNotEmpty ? currentUser.name[0] : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A2330),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F3F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    strings.timelineComposerPlaceholder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A7378),
                        ),
                  ),
                ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
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
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    post.isMine ? const Color(0xFFF0D7D0) : const Color(0xFFE8D9FF),
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0] : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A2330),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2F2323),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      post.publishedAtLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A7378),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A3A3D),
                  height: 1.45,
                ),
          ),
          if (post.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF9F3F0),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF9E4E5D),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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
