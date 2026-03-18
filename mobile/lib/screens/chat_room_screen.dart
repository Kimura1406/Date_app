import 'package:flutter/material.dart';

import '../data/models.dart';
import '../localization/app_localizations.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.currentUser,
    required this.profile,
  });

  final AppUser currentUser;
  final DatingProfile profile;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _buildInitialMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_ChatMessage> _buildInitialMessages() {
    final strings = context.strings;
    return [
      _ChatMessage(
        sender: _ChatSender.other,
        text: strings.chatGreeting(widget.profile.name),
        timeLabel: '09:12',
      ),
      _ChatMessage(
        sender: _ChatSender.me,
        text: strings.chatReply(widget.profile.name),
        timeLabel: '09:14',
      ),
      _ChatMessage(
        sender: _ChatSender.other,
        text: strings.chatInviteMessage,
        timeLabel: '09:16',
      ),
    ];
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          sender: _ChatSender.me,
          text: text,
          timeLabel: _currentTimeLabel(),
        ),
      );
      _messageController.clear();
    });

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

  String _currentTimeLabel() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF4A2330),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF3D6DF),
              backgroundImage: widget.profile.imageUrl.isNotEmpty
                  ? NetworkImage(widget.profile.imageUrl)
                  : null,
              child: widget.profile.imageUrl.isEmpty
                  ? Text(widget.profile.name.isNotEmpty
                      ? widget.profile.name[0]
                      : '?')
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2330),
                      ),
                ),
                Text(
                  strings.chatOnlineStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7A6770),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender == _ChatSender.me;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF9E4E5D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isMe
                                        ? Colors.white
                                        : const Color(0xFF4A2330),
                                    height: 1.45,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message.timeLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF7A6770),
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: strings.chatInputPlaceholder,
                        filled: true,
                        fillColor: Colors.white,
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
                    onPressed: _sendMessage,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFF9E4E5D),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChatSender { me, other }

class _ChatMessage {
  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.timeLabel,
  });

  final _ChatSender sender;
  final String text;
  final String timeLabel;
}
