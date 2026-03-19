import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import 'models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<DatingProfile>> fetchProfiles({
    DiscoveryFilter filter = const DiscoveryFilter(),
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/v1/discovery').replace(
      queryParameters: filter.toQueryParameters(),
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Discovery request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => DatingProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MatchItem>> fetchMatches() async {
    final response = await _client.get(Uri.parse('$apiBaseUrl/api/v1/matches'));
    if (response.statusCode != 200) {
      throw Exception('Matches request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => MatchItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FlowerShopItem>> fetchFlowers() async {
    final response = await _client.get(Uri.parse('$apiBaseUrl/api/v1/flowers'));
    if (response.statusCode != 200) {
      throw Exception('Flowers request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => FlowerShopItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoverBannerItem>> fetchPublicBanners() async {
    final response = await _client.get(Uri.parse('$apiBaseUrl/api/v1/banners'));
    if (response.statusCode != 200) {
      throw Exception('Banners request failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => DiscoverBannerItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserLikeSummary> fetchUserLikeSummary({
    required String token,
    required String userId,
  }) async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId/likes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Load likes failed'));
    }

    return UserLikeSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<UserLikeSummary> toggleUserLike({
    required String token,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId/likes/toggle'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Toggle like failed'));
    }

    return UserLikeSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<ChatRoomSummary>> fetchChatRooms({
    required String token,
    required String roomType,
  }) async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/api/v1/chat-rooms?type=$roomType'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          _extractError(response.body, 'Chat rooms request failed'));
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => ChatRoomSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatRoomDetail> fetchChatRoomDetail({
    required String token,
    required String roomId,
  }) async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/api/v1/chat-rooms/$roomId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Chat room detail request failed'),
      );
    }

    return ChatRoomDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ChatRoomDetail> ensureDirectChatRoom({
    required String token,
    required String targetUserId,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/chat-direct/$targetUserId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Ensure direct chat room request failed'),
      );
    }

    return ChatRoomDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ChatMessageItem> sendChatMessage({
    required String token,
    required String roomId,
    required String body,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/chat-rooms/$roomId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'body': body.trim()}),
    );
    if (response.statusCode != 201) {
      throw Exception(_extractError(response.body, 'Send message failed'));
    }

    return ChatMessageItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AppUser> updateUser(
    String userId,
    String token,
    CreateUserPayload payload,
  ) async {
    final response = await _client.put(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload.toJson()),
    );
    return _parseUserResponse(response, fallback: 'Update user failed');
  }

  Future<void> deleteUser(String userId, String token) async {
    final response = await _client.delete(
      Uri.parse('$apiBaseUrl/api/v1/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Delete user failed'));
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password.trim(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Login failed'));
    }

    return LoginResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<LoginResult> refresh({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Refresh failed'));
    }

    return LoginResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> logout({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/v1/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, 'Logout failed'));
    }
  }

  AppUser _parseUserResponse(http.Response response,
      {required String fallback}) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response.body, fallback));
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromJson(jsonMap);
  }

  String _extractError(String body, String fallback) {
    try {
      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      return jsonMap['error'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
