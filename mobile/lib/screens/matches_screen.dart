import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';
import '../widgets/error_state.dart';
import 'chat_room_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
  });

  final AppUser currentUser;
  final String authToken;

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _apiClient = ApiClient();
  late Future<_ChatListBundle> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _loadRooms();
  }

  Future<_ChatListBundle> _loadRooms() async {
    final results = await Future.wait([
      _apiClient.fetchChatRooms(token: widget.authToken, roomType: 'admin'),
      _apiClient.fetchChatRooms(token: widget.authToken, roomType: 'user'),
    ]);

    final adminRooms = results[0];
    final userRooms = results[1];
    final fixedOperatorRoom = adminRooms.isNotEmpty ? adminRooms.first : null;

    return _ChatListBundle(
      operatorRoom: fixedOperatorRoom,
      userRooms: userRooms,
    );
  }

  Future<void> _refreshRooms() async {
    final future = _loadRooms();
    setState(() {
      _roomsFuture = future;
    });
    await future;
  }

  Future<void> _openRoom(ChatRoomSummary room) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomDetailScreen(
          currentUser: widget.currentUser,
          authToken: widget.authToken,
          initialRoom: room,
          roomDisplayName: _roomDisplayName(room),
        ),
      ),
    );
    if (!mounted) return;
    await _refreshRooms();
  }

  String _roomDisplayName(ChatRoomSummary room) {
    if (room.roomType == 'admin') {
      return context.strings.operatorRoomName;
    }

    final otherParticipant = room.participants.firstWhere(
      (participant) => participant.userId != widget.currentUser.id,
      orElse: () => room.participants.isNotEmpty
          ? room.participants.first
          : ChatParticipant(
              userId: '',
              name: context.strings.unknownUserLabel,
              role: 'user',
              isSender: false,
            ),
    );
    return otherParticipant.name.isNotEmpty
        ? otherParticipant.name
        : context.strings.unknownUserLabel;
  }

  String _roomSubtitle(ChatRoomSummary room, AppStrings strings) {
    if (room.lastMessage.trim().isNotEmpty) {
      return room.lastMessage;
    }
    return strings.noMessagesYet;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<_ChatListBundle>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorState(
                title: strings.chatRoomsTitle,
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _roomsFuture = _loadRooms();
                  });
                },
              );
            }

            final bundle = snapshot.data ?? const _ChatListBundle();
            final operatorRoom = bundle.operatorRoom;
            final userRooms = bundle.userRooms;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.chatRoomsTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F2323),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.chatRoomsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D5A5A),
                      ),
                ),
                const SizedBox(height: 18),
                _PinnedOperatorRoomCard(
                  strings: strings,
                  room: operatorRoom,
                  onTap: operatorRoom == null ? null : () => _openRoom(operatorRoom),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshRooms,
                    child: userRooms.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 220,
                                child: Center(
                                  child: Text(
                                    strings.noUserChatRooms,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xFF7A6770),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: userRooms.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final room = userRooms[index];
                              return _ChatRoomListTile(
                                title: _roomDisplayName(room),
                                subtitle: _roomSubtitle(room, strings),
                                trailing: _formatRoomTime(room.lastMessageAt),
                                onTap: () => _openRoom(room),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatRoomTime(String value) {
    if (value.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}

class _PinnedOperatorRoomCard extends StatelessWidget {
  const _PinnedOperatorRoomCard({
    required this.strings,
    required this.room,
    required this.onTap,
  });

  final AppStrings strings;
  final ChatRoomSummary? room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0D7D0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0B9AF).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF4A2330),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.operatorRoomName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2F2323),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room == null || room!.lastMessage.trim().isEmpty
                          ? strings.operatorRoomDescription
                          : room!.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5C4545),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF4A2330),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRoomListTile extends StatelessWidget {
  const _ChatRoomListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF6CDD2),
                child: Text(
                  title.isNotEmpty ? title.substring(0, 1) : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A2330),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF4A2330),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7A6770),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trailing.isNotEmpty)
                    Text(
                      trailing,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF7A6770),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9E4E5D),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatListBundle {
  const _ChatListBundle({
    this.operatorRoom,
    this.userRooms = const [],
  });

  final ChatRoomSummary? operatorRoom;
  final List<ChatRoomSummary> userRooms;
}
