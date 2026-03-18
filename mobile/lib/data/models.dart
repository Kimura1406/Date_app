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
  });

  final String? country;
  final String? job;
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final String? location;

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

class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.age,
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
