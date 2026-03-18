import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class FlowerShopScreen extends StatelessWidget {
  const FlowerShopScreen({super.key});

  static const List<_FlowerGiftItem> _items = [
    _FlowerGiftItem(type: _FlowerGiftType.rose, points: 2, color: Color(0xFFEFA5AE)),
    _FlowerGiftItem(type: _FlowerGiftType.tulip, points: 3, color: Color(0xFFF5C38B)),
    _FlowerGiftItem(type: _FlowerGiftType.lily, points: 4, color: Color(0xFFF3EAD7)),
    _FlowerGiftItem(type: _FlowerGiftType.sunflower, points: 5, color: Color(0xFFF2CF63)),
    _FlowerGiftItem(type: _FlowerGiftType.lavender, points: 6, color: Color(0xFFD9C7F2)),
    _FlowerGiftItem(type: _FlowerGiftType.camellia, points: 8, color: Color(0xFFE7A0C4)),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.flowerShopTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF2F2424),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.flowerShopSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D5A5A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _FlowerGiftCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowerGiftCard extends StatelessWidget {
  const _FlowerGiftCard({required this.item});

  final _FlowerGiftItem item;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE9D7D1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withValues(alpha: 0.92),
                      Colors.white,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  size: 76,
                  color: Color(0xFF6E4A4A),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              strings.flowerGiftName(item.type),
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF241919),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFB86A76),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${item.points}P',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FlowerGiftType {
  rose,
  tulip,
  lily,
  sunflower,
  lavender,
  camellia,
}

class _FlowerGiftItem {
  const _FlowerGiftItem({
    required this.type,
    required this.points,
    required this.color,
  });

  final _FlowerGiftType type;
  final int points;
  final Color color;
}
