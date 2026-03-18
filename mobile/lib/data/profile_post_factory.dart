import 'models.dart';

const _fallbackPostImages = <String>[
  'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=900&q=80',
];

const _captions = <String>[
  'Coffee, sunset, and a small story from today. Looking for someone who enjoys simple moments and long conversations after midnight.',
  'Weekend look from my favorite corner in town. Good food, good music, and a little bit of chaos always help.',
  'A quiet day, a camera roll full of memories, and the kind of energy that makes me want to meet someone genuine.',
  'Trying a new place, dressing up a little, and keeping space for unexpected connections that feel easy and warm.',
  'This was one of those days where everything felt soft and cinematic. Tell me where you would take me next.',
  'A few frames from lately. I like people who are playful, kind, and can turn an ordinary day into something special.',
];

List<ProfilePost> buildProfilePosts(DatingProfile profile) {
  final seed = profile.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);

  return List<ProfilePost>.generate(5, (index) {
    final imageCount = 2 + ((seed + index) % 3);
    final images = List<String>.generate(imageCount, (imageIndex) {
      if (index == 0 && imageIndex == 0 && profile.imageUrl.isNotEmpty) {
        return profile.imageUrl;
      }
      return _fallbackPostImages[
          (seed + index * 3 + imageIndex) % _fallbackPostImages.length];
    });

    return ProfilePost(
      id: '${profile.id}-post-$index',
      imageUrls: images,
      caption: _captions[(seed + index) % _captions.length],
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
