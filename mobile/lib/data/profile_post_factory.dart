import 'models.dart';

const _fallbackPostImages = <String>[
  'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
];

List<ProfilePost> buildProfilePosts(DatingProfile profile) {
  final seed = profile.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);

  return List<ProfilePost>.generate(6, (index) {
    final imageUrl = index == 0 && profile.imageUrl.isNotEmpty
        ? profile.imageUrl
        : _fallbackPostImages[(seed + index) % _fallbackPostImages.length];

    return ProfilePost(
      id: '${profile.id}-post-$index',
      imageUrl: imageUrl,
      likeCount: 120 + ((seed * (index + 3)) % 860),
      commentCount: 8 + ((seed + index * 11) % 96),
      giftCount: 2 + ((seed + index * 7) % 24),
    );
  });
}

int buildLikeCount(DatingProfile profile) {
  final seed = profile.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return 800 + (seed % 9200);
}
