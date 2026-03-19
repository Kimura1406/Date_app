import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';

class FlowerShopScreen extends StatefulWidget {
  const FlowerShopScreen({super.key});

  @override
  State<FlowerShopScreen> createState() => _FlowerShopScreenState();
}

class _FlowerShopScreenState extends State<FlowerShopScreen> {
  late Future<List<FlowerShopItem>> _flowersFuture;
  final ApiClient _apiClient = ApiClient();
  bool? _sortAscending;

  @override
  void initState() {
    super.initState();
    _flowersFuture = _apiClient.fetchFlowers();
  }

  void _reload() {
    setState(() {
      _flowersFuture = _apiClient.fetchFlowers();
    });
  }

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.flowerShopTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2F2424),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _sortAscending = !(_sortAscending ?? false);
                    });
                  },
                  tooltip: _sortAscending == true
                      ? strings.flowerShopSortHighToLow
                      : strings.flowerShopSortLowToHigh,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E1DC),
                    foregroundColor: const Color(0xFF6D4751),
                  ),
                  icon: Icon(
                    _sortAscending == true
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                  ),
                ),
              ],
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
              child: FutureBuilder<List<FlowerShopItem>>(
                future: _flowersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _FlowerShopError(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    );
                  }

                  final items = snapshot.data ?? const <FlowerShopItem>[];
                  if (items.isEmpty) {
                    return _FlowerShopEmpty(onRetry: _reload);
                  }

                  final sortedItems = [...items];
                  if (_sortAscending != null) {
                    sortedItems.sort((a, b) => a.pricePoints.compareTo(b.pricePoints));
                    if (_sortAscending == false) {
                      sortedItems.setAll(0, sortedItems.reversed);
                    }
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      return _FlowerGiftCard(item: sortedItems[index]);
                    },
                  );
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

  final FlowerShopItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9D7D1)),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5E9E6),
                  child: _FlowerImage(imageUrl: item.imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF241919),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6D5A5A),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFB86A76),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${item.pricePoints}P',
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

class _FlowerImage extends StatelessWidget {
  const _FlowerImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final data = _decodeDataUri(imageUrl);
    if (data != null) {
      return Image.memory(data, fit: BoxFit.cover);
    }

    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.local_florist_rounded,
          size: 64,
          color: Color(0xFF6E4A4A),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.local_florist_rounded,
            size: 64,
            color: Color(0xFF6E4A4A),
          ),
        );
      },
    );
  }

  Uint8List? _decodeDataUri(String value) {
    if (!value.startsWith('data:image')) {
      return null;
    }

    final commaIndex = value.indexOf(',');
    if (commaIndex < 0) {
      return null;
    }

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}

class _FlowerShopError extends StatelessWidget {
  const _FlowerShopError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.flowerShopLoadError,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2F2424),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6D5A5A),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}

class _FlowerShopEmpty extends StatelessWidget {
  const _FlowerShopEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.flowerShopEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2F2424),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}
