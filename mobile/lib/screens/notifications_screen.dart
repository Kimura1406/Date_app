import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../firebase/firestore_chat_service.dart';
import '../localization/app_localizations.dart';
import 'chat_room_detail_screen.dart';
import 'user_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
  });

  final AppUser currentUser;
  final String authToken;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final _apiClient = ApiClient();
  final _firestoreChatService = FirestoreChatService();
  late final TabController _tabController;
  late Future<List<NotificationItem>> _notificationsFuture;
  Stream<List<ChatRoomSummary>>? _userRoomsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notificationsFuture = _apiClient.fetchNotifications(token: widget.authToken);
    if (FirestoreChatService.isSupportedPlatform) {
      _userRoomsStream = _firestoreChatService.watchUserRooms(
        currentUser: widget.currentUser,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = _apiClient.fetchNotifications(token: widget.authToken);
    setState(() {
      _notificationsFuture = future;
    });
    await future;
  }

  Future<void> _openProfileFromNotification(NotificationItem item) async {
    if (item.actorUserId.isEmpty) {
      return;
    }

    final user = await _apiClient.fetchUserById(
      token: widget.authToken,
      userId: item.actorUserId,
    );
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          currentUser: widget.currentUser,
          authToken: widget.authToken,
          profile: DatingProfile(
            id: user.id,
            name: user.name,
            age: user.age,
            job: user.job,
            bio: user.bio,
            distance: user.distance,
            interests: user.interests,
            country: user.country,
            gender: user.gender,
            location: user.prefecture,
            imageUrl: '',
            isNew: false,
          ),
        ),
      ),
    );
  }

  Future<void> _openChatRoom({
    required String roomId,
    required String roomType,
    required String roomDisplayName,
  }) async {
    if (roomId.isEmpty) {
      return;
    }

    final detail = await _apiClient.fetchChatRoomDetail(
      token: widget.authToken,
      roomId: roomId,
    );
    if (!mounted) return;

    final lastMessage = detail.messages.isNotEmpty ? detail.messages.last : null;
    final room = ChatRoomSummary(
      roomId: detail.roomId,
      roomType: roomType,
      participants: detail.participants,
      lastMessage: lastMessage?.body ?? '',
      lastMessageAt: lastMessage?.sentAt ?? '',
      unreadCount: 0,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomDetailScreen(
          currentUser: widget.currentUser,
          authToken: widget.authToken,
          initialRoom: room,
          roomDisplayName: roomDisplayName,
        ),
      ),
    );
  }

  String _formatTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return '';
    }
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF4BA9E8), Color(0xFF2F86D7)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.20),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          strings.notificationsTitle,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(text: 'all noti'),
                        Tab(text: 'system noti'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NotificationItem>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(snapshot.error.toString()),
                    ),
                  );
                }

                final backendItems = snapshot.data ?? const <NotificationItem>[];
                final systemItems =
                    backendItems.where((item) => item.isSystem).toList();
                final profileItems = backendItems
                    .where((item) => item.type == 'profile_view')
                    .map(
                      (item) => _NotificationEntry(
                        title: item.actorUserName.isEmpty
                            ? 'profile'
                            : item.actorUserName,
                        message: item.message,
                        createdAt: item.createdAt,
                        onTap: () => _openProfileFromNotification(item),
                      ),
                    )
                    .toList();
                final backendMessageItems = backendItems
                    .where((item) => item.type == 'user_message')
                    .map(
                      (item) => _NotificationEntry(
                        title: item.actorUserName.isEmpty
                            ? 'chat'
                            : item.actorUserName,
                        message: item.message,
                        createdAt: item.createdAt,
                        onTap: () => _openChatRoom(
                          roomId: item.roomId,
                          roomType: item.roomType.isEmpty ? 'user' : item.roomType,
                          roomDisplayName: item.actorUserName.isEmpty
                              ? 'chat'
                              : item.actorUserName,
                        ),
                      ),
                    )
                    .toList();

                final listBody = FirestoreChatService.isSupportedPlatform
                    ? StreamBuilder<List<ChatRoomSummary>>(
                        stream: _userRoomsStream,
                        builder: (context, roomSnapshot) {
                          final userMessageItems =
                              _buildUserMessageNotifications(roomSnapshot.data ?? const []);
                          final allItems = [
                            ...profileItems,
                            ...backendMessageItems,
                            ...userMessageItems,
                          ]
                            ..sort((a, b) => _sortNotificationTime(
                                  a.createdAt,
                                  b.createdAt,
                                ));
                          return _buildTabs(
                            allItems: allItems,
                            systemItems: systemItems,
                          );
                        },
                      )
                    : _buildTabs(
                        allItems: [...profileItems, ...backendMessageItems]
                          ..sort((a, b) => _sortNotificationTime(
                                a.createdAt,
                                b.createdAt,
                              )),
                        systemItems: systemItems,
                      );

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: listBody,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs({
    required List<_NotificationEntry> allItems,
    required List<NotificationItem> systemItems,
  }) {
    return TabBarView(
      controller: _tabController,
      children: [
        _NotificationListView(
          children: allItems
              .map((item) => _NotificationCard(
                    title: item.title,
                    message: item.message,
                    timeLabel: _formatTime(item.createdAt),
                    onTap: item.onTap,
                  ))
              .toList(),
        ),
        _NotificationListView(
          children: systemItems
              .map((item) => _NotificationCard(
                    title: item.type == 'welcome' ? 'system noti' : 'admin',
                    message: item.message,
                    timeLabel: _formatTime(item.createdAt),
                    onTap: item.type == 'admin_message'
                        ? () => _openChatRoom(
                              roomId: item.roomId,
                              roomType: item.roomType.isEmpty ? 'admin' : item.roomType,
                              roomDisplayName: context.strings.operatorRoomName,
                            )
                        : null,
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<_NotificationEntry> _buildUserMessageNotifications(
    List<ChatRoomSummary> rooms,
  ) {
    return rooms
        .where((room) => room.unreadCount > 0 && room.lastMessageAt.isNotEmpty)
        .map((room) {
          final other = room.participants.firstWhere(
            (participant) => participant.userId != widget.currentUser.id,
            orElse: () => ChatParticipant(
              userId: '',
              name: 'Unknown',
              role: 'user',
              isSender: false,
            ),
          );
          return _NotificationEntry(
            title: other.name,
            message: '${other.name} đã gửi tin nhắn cho bạn',
            createdAt: room.lastMessageAt,
            onTap: () => _openChatRoom(
              roomId: room.roomId,
              roomType: room.roomType,
              roomDisplayName: other.name,
            ),
          );
        })
        .toList();
  }

  int _sortNotificationTime(String left, String right) {
    final leftDate = DateTime.tryParse(left);
    final rightDate = DateTime.tryParse(right);
    if (leftDate == null && rightDate == null) return 0;
    if (leftDate == null) return 1;
    if (rightDate == null) return -1;
    return rightDate.compareTo(leftDate);
  }
}

class _NotificationListView extends StatelessWidget {
  const _NotificationListView({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(child: Text('No notifications yet')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: children.length,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.message,
    required this.timeLabel,
    this.onTap,
  });

  final String title;
  final String message;
  final String timeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD9EEF9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1F2A37),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  if (timeLabel.isNotEmpty)
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF7C91A4),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5E7488),
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationEntry {
  const _NotificationEntry({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.onTap,
  });

  final String title;
  final String message;
  final String createdAt;
  final VoidCallback onTap;
}
