import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../firebase/firestore_chat_service.dart';
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
  final _firestoreChatService = FirestoreChatService();
  late Future<_ChatListBundle> _roomsFuture;
  late Future<ChatRoomSummary?> _operatorRoomFuture;
  late Stream<List<ChatRoomSummary>> _userRoomsStream;

  @override
  void initState() {
    super.initState();
    if (FirestoreChatService.isSupportedPlatform) {
      _roomsFuture = Future.value(const _ChatListBundle());
      _operatorRoomFuture = _loadOperatorRoom();
      _userRoomsStream = _watchUserRooms();
    } else {
      _roomsFuture = _loadRooms();
      _operatorRoomFuture = Future.value(null);
      _userRoomsStream = const Stream.empty();
    }
  }

  Future<_ChatListBundle> _loadRooms() async {
    final results = await Future.wait([
      _apiClient.fetchChatRooms(token: widget.authToken, roomType: 'admin'),
      _apiClient.fetchChatRooms(token: widget.authToken, roomType: 'user'),
    ]);

    final adminRooms = results[0];
    final userRooms = results[1];
    adminRooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    userRooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    final fixedOperatorRoom = adminRooms.isNotEmpty ? adminRooms.first : null;

    return _ChatListBundle(
      operatorRoom: fixedOperatorRoom,
      userRooms: userRooms,
    );
  }

  Future<ChatRoomSummary?> _loadOperatorRoom() async {
    final adminRooms =
        await _apiClient.fetchChatRooms(token: widget.authToken, roomType: 'admin');
    adminRooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return adminRooms.isNotEmpty ? adminRooms.first : null;
  }

  Stream<List<ChatRoomSummary>> _watchUserRooms() {
    if (FirestoreChatService.isSupportedPlatform) {
      return _firestoreChatService.watchUserRooms(currentUser: widget.currentUser);
    }
    return Stream.value(const <ChatRoomSummary>[]);
  }

  Future<void> _refreshRooms() async {
    if (FirestoreChatService.isSupportedPlatform) {
      final operatorFuture = _loadOperatorRoom();
      setState(() {
        _operatorRoomFuture = operatorFuture;
      });
      await operatorFuture;
      return;
    }
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
    final theme = Theme.of(context);

    if (FirestoreChatService.isSupportedPlatform) {
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
          child: FutureBuilder<ChatRoomSummary?>(
            future: _operatorRoomFuture,
            builder: (context, operatorSnapshot) {
              if (operatorSnapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (operatorSnapshot.hasError) {
                return ErrorState(
                  title: strings.chatRoomsTitle,
                  message: operatorSnapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _operatorRoomFuture = _loadOperatorRoom();
                    });
                  },
                );
              }

              return StreamBuilder<List<ChatRoomSummary>>(
                stream: _userRoomsStream,
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError) {
                    return ErrorState(
                      title: strings.chatRoomsTitle,
                      message: userSnapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          _operatorRoomFuture = _loadOperatorRoom();
                          _userRoomsStream = _watchUserRooms();
                        });
                      },
                    );
                  }

                  final operatorRoom = operatorSnapshot.data;
                  final userRooms = userSnapshot.data ?? const <ChatRoomSummary>[];

                  return _buildChatListBody(
                    strings: strings,
                    theme: theme,
                    operatorRoom: operatorRoom,
                    userRooms: userRooms,
                  );
                },
              );
            },
          ),
        ),
      );
    }

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
            return _buildChatListBody(
              strings: strings,
              theme: theme,
              operatorRoom: bundle.operatorRoom,
              userRooms: bundle.userRooms,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatListBody({
    required AppStrings strings,
    required ThemeData theme,
    required ChatRoomSummary? operatorRoom,
    required List<ChatRoomSummary> userRooms,
  }) {
    return Column(
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
                  strings.chatRoomsTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.chatRoomsSubtitle,
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
            child: RefreshIndicator(
              onRefresh: _refreshRooms,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _PinnedOperatorRoomCard(
                    strings: strings,
                    room: operatorRoom,
                    onTap: operatorRoom == null ? null : () => _openRoom(operatorRoom),
                  ),
                  const SizedBox(height: 14),
                  if (userRooms.isEmpty)
                    SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          strings.noUserChatRooms,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7C91A4),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(userRooms.length, (index) {
                      final room = userRooms[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChatRoomListTile(
                          title: _roomDisplayName(room),
                          subtitle: _roomSubtitle(room, strings),
                          trailing: _formatRoomTime(room.lastMessageAt),
                          unreadCount: room.unreadCount,
                          onTap: () => _openRoom(room),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ],
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
            color: const Color(0xFFF1F8FE),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD8EBF9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0A4474),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCEEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF2F86D7),
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
                            color: const Color(0xFF1F2A37),
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
                            color: const Color(0xFF6E8297),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  if ((room?.unreadCount ?? 0) > 0) ...[
                    _UnreadDot(count: room!.unreadCount),
                    const SizedBox(width: 10),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF4BA9E8),
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

class _ChatRoomListTile extends StatelessWidget {
  const _ChatRoomListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.unreadCount,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final int unreadCount;
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
            border: Border.all(color: const Color(0xFFD9EEF9)),
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
                backgroundColor: const Color(0xFFE3F2FF),
                child: Text(
                  title.isNotEmpty ? title.substring(0, 1) : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2F86D7),
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
                            color: const Color(0xFF1F2A37),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6E8297),
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
                            color: const Color(0xFF8AA0B5),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  const SizedBox(height: 10),
                  if (unreadCount > 0) ...[
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _UnreadDot(count: unreadCount),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF4BA9E8),
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

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFE4475D),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE4475D).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
