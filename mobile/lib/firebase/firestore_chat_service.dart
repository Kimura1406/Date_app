import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models.dart';

class FirestoreChatService {
  FirestoreChatService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  FirebaseFirestore get _instance => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _instance.collection('chat_rooms');

  String directRoomId(String currentUserId, String targetUserId) {
    final ordered = [currentUserId.trim(), targetUserId.trim()]..sort();
    return 'user-${ordered[0]}-${ordered[1]}';
  }

  Future<ChatRoomSummary> ensureDirectRoom({
    required AppUser currentUser,
    required DatingProfile targetProfile,
  }) async {
    final roomId = directRoomId(currentUser.id, targetProfile.id);
    final roomRef = _rooms.doc(roomId);
    final roomSnapshot = await roomRef.get();

    final participants = [
      {
        'userId': currentUser.id,
        'name': currentUser.name,
        'role': currentUser.role,
      },
      {
        'userId': targetProfile.id,
        'name': targetProfile.name,
        'role': 'user',
      },
    ]..sort((a, b) => (a['userId'] as String).compareTo(b['userId'] as String));

    if (!roomSnapshot.exists) {
      await roomRef.set({
        'roomId': roomId,
        'roomType': 'user',
        'participantIds': participants
            .map((participant) => participant['userId'] as String)
            .toList(),
        'participants': participants,
        'lastMessage': '',
        'lastMessageAt': null,
        'unreadCounts': {
          currentUser.id: 0,
          targetProfile.id: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await roomRef.set({
        'participants': participants,
        'participantIds': participants
            .map((participant) => participant['userId'] as String)
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final refreshed = await roomRef.get();
    return _roomSummaryFromSnapshot(refreshed, currentUser.id);
  }

  Stream<List<ChatRoomSummary>> watchUserRooms({
    required AppUser currentUser,
  }) {
    return _rooms
        .where('participantIds', arrayContains: currentUser.id)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .where((doc) => (doc.data()['roomType'] as String? ?? '') == 'user')
          .map((doc) => _roomSummaryFromSnapshot(doc, currentUser.id))
          .toList();
      items.sort((a, b) => _compareIsoDescending(a.lastMessageAt, b.lastMessageAt));
      return items;
    });
  }

  Stream<ChatRoomDetail> watchRoomDetail({
    required String roomId,
    required AppUser currentUser,
  }) {
    final roomRef = _rooms.doc(roomId);
    return roomRef
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .asyncMap((messagesSnapshot) async {
      final roomSnapshot = await roomRef.get();
      final roomData = roomSnapshot.data() ?? const <String, dynamic>{};
      final participants = _participantsFromRoomData(roomData);
      final messages = messagesSnapshot.docs
          .map((doc) => _messageFromSnapshot(
                doc,
                participants: participants,
              ))
          .toList();
      return ChatRoomDetail(
        roomId: roomId,
        roomType: roomData['roomType'] as String? ?? 'user',
        participants: participants,
        messages: messages,
      );
    });
  }

  Future<void> markRoomAsRead({
    required String roomId,
    required String currentUserId,
  }) async {
    await _rooms.doc(roomId).set({
      'unreadCounts': {
        currentUserId: 0,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendDirectMessage({
    required ChatRoomSummary room,
    required AppUser currentUser,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return;
    }

    final roomRef = _rooms.doc(room.roomId);
    final roomSnapshot = await roomRef.get();
    final roomData = roomSnapshot.data() ?? const <String, dynamic>{};
    final participants = _participantsFromRoomData(roomData).isNotEmpty
        ? _participantsFromRoomData(roomData)
        : room.participants;
    final unreadCounts = Map<String, int>.from(
      ((roomData['unreadCounts'] as Map<String, dynamic>?) ?? const <String, dynamic>{})
          .map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0)),
    );

    for (final participant in participants) {
      if (participant.userId == currentUser.id) {
        unreadCounts[participant.userId] = 0;
      } else {
        unreadCounts[participant.userId] =
            (unreadCounts[participant.userId] ?? 0) + 1;
      }
    }

    final messageRef = roomRef.collection('messages').doc();
    final batch = _instance.batch();
    batch.set(messageRef, {
      'id': messageRef.id,
      'roomId': room.roomId,
      'senderId': currentUser.id,
      'senderName': currentUser.name,
      'body': trimmedBody,
      'sentAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      roomRef,
      {
        'roomId': room.roomId,
        'roomType': 'user',
        'participantIds': participants.map((participant) => participant.userId).toList(),
        'participants': participants
            .map((participant) => {
                  'userId': participant.userId,
                  'name': participant.name,
                  'role': participant.role,
                })
            .toList(),
        'lastMessage': trimmedBody,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCounts': unreadCounts,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  ChatRoomSummary _roomSummaryFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String currentUserId,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final unreadMap = (data['unreadCounts'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final timestamp = data['lastMessageAt'];

    return ChatRoomSummary(
      roomId: data['roomId'] as String? ?? snapshot.id,
      roomType: data['roomType'] as String? ?? 'user',
      participants: _participantsFromRoomData(data),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: _timestampToIsoString(timestamp),
      unreadCount: (unreadMap[currentUserId] as num?)?.toInt() ?? 0,
    );
  }

  List<ChatParticipant> _participantsFromRoomData(Map<String, dynamic> data) {
    final rawParticipants = data['participants'] as List<dynamic>? ?? const [];
    return rawParticipants
        .map((item) {
          final map = item as Map<String, dynamic>? ?? const <String, dynamic>{};
          return ChatParticipant(
            userId: map['userId'] as String? ?? '',
            name: map['name'] as String? ?? '',
            role: map['role'] as String? ?? 'user',
            isSender: false,
          );
        })
        .where((participant) => participant.userId.isNotEmpty)
        .toList();
  }

  ChatMessageItem _messageFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot, {
    required List<ChatParticipant> participants,
  }) {
    final data = snapshot.data();
    final senderId = data['senderId'] as String? ?? '';
    final participant = participants.firstWhere(
      (item) => item.userId == senderId,
      orElse: () => ChatParticipant(
        userId: senderId,
        name: data['senderName'] as String? ?? '',
        role: 'user',
        isSender: true,
      ),
    );

    return ChatMessageItem(
      id: data['id'] as String? ?? snapshot.id,
      roomId: data['roomId'] as String? ?? '',
      senderId: senderId,
      senderName: data['senderName'] as String? ?? '',
      body: data['body'] as String? ?? '',
      sentAt: _timestampToIsoString(data['sentAt']),
      participant: ChatParticipant(
        userId: participant.userId,
        name: participant.name,
        role: participant.role,
        isSender: true,
      ),
    );
  }

  String _timestampToIsoString(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toUtc().toIso8601String();
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is String) {
      return value;
    }
    return '';
  }

  int _compareIsoDescending(String left, String right) {
    final leftDate = DateTime.tryParse(left);
    final rightDate = DateTime.tryParse(right);
    if (leftDate == null && rightDate == null) {
      return 0;
    }
    if (leftDate == null) {
      return 1;
    }
    if (rightDate == null) {
      return -1;
    }
    return rightDate.compareTo(leftDate);
  }
}
