class DatingProfile {
  DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.job,
    required this.bio,
    required this.distance,
    required this.interests,
    required this.country,
    required this.gender,
    required this.location,
    required this.imageUrl,
    required this.isNew,
  });

  final String id;
  final String name;
  final int age;
  final String job;
  final String bio;
  final String distance;
  final List<String> interests;
  final String country;
  final String gender;
  final String location;
  final String imageUrl;
  final bool isNew;

  factory DatingProfile.fromJson(Map<String, dynamic> json) {
    return DatingProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      job: json['job'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      country: json['country'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
    );
  }
}

class ProfilePost {
  const ProfilePost({
    required this.id,
    required this.imageUrls,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.giftCount,
  });

  final String id;
  final List<String> imageUrls;
  final String caption;
  final int likeCount;
  final int commentCount;
  final int giftCount;
}

class DiscoveryFilter {
  const DiscoveryFilter({
    this.country,
    this.job,
    this.minAge,
    this.maxAge,
    this.gender,
    this.location,
    this.excludeUserId,
  });

  final String? country;
  final String? job;
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final String? location;
  final String? excludeUserId;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (country != null && country!.isNotEmpty) {
      params['country'] = country!;
    }
    if (job != null && job!.isNotEmpty) {
      params['job'] = job!;
    }
    if (minAge != null) {
      params['minAge'] = minAge!.toString();
    }
    if (maxAge != null) {
      params['maxAge'] = maxAge!.toString();
    }
    if (gender != null && gender!.isNotEmpty) {
      params['gender'] = gender!;
    }
    if (location != null && location!.isNotEmpty) {
      params['location'] = location!;
    }
    if (excludeUserId != null && excludeUserId!.isNotEmpty) {
      params['excludeUserId'] = excludeUserId!;
    }
    return params;
  }
}

class MatchItem {
  MatchItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastSeen,
    required this.status,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String lastSeen;
  final String status;

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastSeen: json['lastSeen'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class FlowerShopItem {
  FlowerShopItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.pricePoints,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int pricePoints;

  factory FlowerShopItem.fromJson(Map<String, dynamic> json) {
    return FlowerShopItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePoints: json['pricePoints'] as int? ?? 0,
    );
  }
}

class DiscoverBannerItem {
  DiscoverBannerItem({
    required this.id,
    required this.imageUrl,
    required this.eventName,
    required this.displayOrder,
    required this.redirectLink,
  });

  final String id;
  final String imageUrl;
  final String eventName;
  final int displayOrder;
  final String redirectLink;

  factory DiscoverBannerItem.fromJson(Map<String, dynamic> json) {
    return DiscoverBannerItem(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      redirectLink: json['redirectLink'] as String? ?? '',
    );
  }
}

class UserLikeSummary {
  UserLikeSummary({
    required this.targetUserId,
    required this.likeCount,
    required this.likedByMe,
  });

  final String targetUserId;
  final int likeCount;
  final bool likedByMe;

  factory UserLikeSummary.fromJson(Map<String, dynamic> json) {
    return UserLikeSummary(
      targetUserId: json['targetUserId'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
    );
  }
}

class ChatParticipant {
  ChatParticipant({
    required this.userId,
    required this.name,
    required this.role,
    required this.isSender,
  });

  final String userId;
  final String name;
  final String role;
  final bool isSender;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isSender: json['isSender'] as bool? ?? false,
    );
  }
}

class ChatRoomSummary {
  ChatRoomSummary({
    required this.roomId,
    required this.roomType,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  final String roomId;
  final String roomType;
  final List<ChatParticipant> participants;
  final String lastMessage;
  final String lastMessageAt;

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    return ChatRoomSummary(
      roomId: json['roomId'] as String? ?? '',
      roomType: json['roomType'] as String? ?? '',
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((item) => ChatParticipant.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] as String? ?? '',
    );
  }
}

class ChatMessageItem {
  ChatMessageItem({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.sentAt,
    required this.participant,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String body;
  final String sentAt;
  final ChatParticipant participant;

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: json['id'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      body: json['body'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
      participant: ChatParticipant.fromJson(
        json['participant'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ChatRoomDetail {
  ChatRoomDetail({
    required this.roomId,
    required this.roomType,
    required this.participants,
    required this.messages,
  });

  final String roomId;
  final String roomType;
  final List<ChatParticipant> participants;
  final List<ChatMessageItem> messages;

  factory ChatRoomDetail.fromJson(Map<String, dynamic> json) {
    return ChatRoomDetail(
      roomId: json['roomId'] as String? ?? '',
      roomType: json['roomType'] as String? ?? '',
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((item) => ChatParticipant.fromJson(item as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((item) => ChatMessageItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.age,
    required this.birthDate,
    required this.gender,
    required this.job,
    required this.bio,
    required this.distance,
    required this.interests,
  });

  final String id;
  final String email;
  final String role;
  final String name;
  final int age;
  final String birthDate;
  final String gender;
  final String job;
  final String bio;
  final String distance;
  final List<String> interests;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      birthDate: json['birthDate'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      job: json['job'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'age': age,
      'birthDate': birthDate,
      'gender': gender,
      'job': job,
      'bio': bio,
      'distance': distance,
      'interests': interests,
    };
  }
}

class CreateUserPayload {
  CreateUserPayload({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.job,
    required this.bio,
    required this.distance,
    required this.interests,
  });

  final String email;
  final String password;
  final String name;
  final int age;
  final String job;
  final String bio;
  final String distance;
  final List<String> interests;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'job': job,
      'bio': bio,
      'distance': distance,
      'interests': interests,
    };
  }
}

class LoginResult {
  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>? ?? {};
    return LoginResult(
      accessToken: tokens['accessToken'] as String? ?? '',
      refreshToken: tokens['refreshToken'] as String? ?? '',
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
