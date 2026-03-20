import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';
import '../widgets/error_state.dart';

class ChatRoomDetailScreen extends StatefulWidget {
  const ChatRoomDetailScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
    required this.initialRoom,
    required this.roomDisplayName,
  });

  final AppUser currentUser;
  final String authToken;
  final ChatRoomSummary initialRoom;
  final String roomDisplayName;

  @override
  State<ChatRoomDetailScreen> createState() => _ChatRoomDetailScreenState();
}

class _ChatRoomDetailScreenState extends State<ChatRoomDetailScreen> {
  final _apiClient = ApiClient();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late Future<ChatRoomDetail> _detailFuture;
  ChatRoomDetail? _cachedDetail;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<ChatRoomDetail> _loadDetail() {
    return _apiClient.fetchChatRoomDetail(
      token: widget.authToken,
      roomId: widget.initialRoom.roomId,
    ).then((detail) {
      _cachedDetail = detail;
      return detail;
    });
  }

  Future<void> _refreshDetail() async {
    final future = _loadDetail();
    setState(() {
      _detailFuture = future;
    });
    await future;
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final sentMessage = await _apiClient.sendChatMessage(
        token: widget.authToken,
        roomId: widget.initialRoom.roomId,
        body: text,
      );
      _messageController.clear();
      if (!mounted) {
        return;
      }

      final currentDetail = _cachedDetail;
      if (currentDetail != null) {
        final updatedDetail = ChatRoomDetail(
          roomId: currentDetail.roomId,
          roomType: currentDetail.roomType,
          participants: currentDetail.participants,
          messages: [...currentDetail.messages, sentMessage],
        );
        setState(() {
          _cachedDetail = updatedDetail;
          _detailFuture = Future.value(updatedDetail);
        });
        _scrollToBottom();
      } else {
        await _refreshDetail();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _subtitle(ChatRoomDetail detail, AppStrings strings) {
    if (widget.initialRoom.roomType == 'admin') {
      return strings.operatorRoomSubtitle;
    }

    final other = detail.participants.firstWhere(
      (participant) => participant.userId != widget.currentUser.id,
      orElse: () => detail.participants.isNotEmpty
          ? detail.participants.first
          : ChatParticipant(
              userId: '',
              name: strings.unknownUserLabel,
              role: 'user',
              isSender: false,
            ),
    );
    return other.name.isNotEmpty ? other.name : strings.unknownUserLabel;
  }

  String _formatTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: FutureBuilder<ChatRoomDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              title: strings.chatRoomDetailTitle(widget.roomDisplayName),
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _detailFuture = _loadDetail();
                });
              },
            );
          }

          final detail = snapshot.data!;
          _cachedDetail = detail;
          final subtitle = _subtitle(detail, strings);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5CA4F2), Color(0xFF4D8DDA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
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
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        child: Icon(
                          widget.initialRoom.roomType == 'admin'
                              ? Icons.support_agent_rounded
                              : Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.roomDisplayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5CA4F2).withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: RefreshIndicator(
                      onRefresh: _refreshDetail,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: detail.messages.length,
                        itemBuilder: (context, index) {
                          final message = detail.messages[index];
                          final isMe = message.senderId == widget.currentUser.id;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.68,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color(0xFFEAF5FF)
                                      : const Color(0xFFF8FBFF),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(22),
                                    topRight: const Radius.circular(22),
                                    bottomLeft: Radius.circular(isMe ? 22 : 8),
                                    bottomRight: Radius.circular(isMe ? 8 : 22),
                                  ),
                                  border: Border.all(
                                    color: isMe
                                        ? const Color(0xFFCFE6FF)
                                        : const Color(0xFFE5EEF8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5CA4F2)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.body,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF1F2A37),
                                            height: 1.45,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(message.sentAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF7C8AA5),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5CA4F2).withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(
                              color: Color(0xFF1F2A37),
                            ),
                            cursorColor: const Color(0xFF4F8DDC),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: strings.chatInputPlaceholder,
                              filled: true,
                              fillColor: const Color(0xFFF6FAFF),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _sending ? null : _sendMessage,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            backgroundColor: const Color(0xFF5CA4F2),
                          ),
                          child: Icon(
                            _sending
                                ? Icons.hourglass_top_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
