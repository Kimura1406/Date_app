import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../localization/app_localizations.dart';

class FlowerShopScreen extends StatefulWidget {
  const FlowerShopScreen({
    super.key,
    required this.currentUser,
    required this.authToken,
    required this.onUserChanged,
  });

  final AppUser currentUser;
  final String authToken;
  final ValueChanged<AppUser> onUserChanged;

  @override
  State<FlowerShopScreen> createState() => _FlowerShopScreenState();
}

class _FlowerShopScreenState extends State<FlowerShopScreen> {
  late Future<List<FlowerShopItem>> _flowersFuture;
  final ApiClient _apiClient = ApiClient();
  bool? _sortAscending;
  String? _processingFlowerId;

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

  Future<void> _openInsufficientPointsGuide(FlowerShopItem item) async {
    final strings = context.strings;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FlowerGuideScreen(
          title: strings.flowerShopInsufficientTitle,
          message: strings.flowerShopInsufficientMessage(
            item.pricePoints,
            widget.currentUser.pointBalance,
          ),
        ),
      ),
    );
  }

  Future<void> _acquireFlower(FlowerShopItem item) async {
    if (_processingFlowerId != null) {
      return;
    }

    if (widget.currentUser.pointBalance < item.pricePoints) {
      await _openInsufficientPointsGuide(item);
      return;
    }

    setState(() {
      _processingFlowerId = item.id;
    });

    try {
      final result = await _apiClient.acquireFlower(
        token: widget.authToken,
        flowerId: item.id,
      );
      widget.onUserChanged(result.user);
      _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.flowerShopAcquiredMessage(
              result.flower.name,
              result.user.pointBalance,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message == 'insufficient points') {
        await _openInsufficientPointsGuide(item);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingFlowerId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2FAFF),
              Color(0xFFE7F5FF),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF4BA9E8),
                    Color(0xFF2F86D7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x220A4474),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.flowerShopTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${strings.flowerShopPointsLabel}:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8D24B),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${widget.currentUser.pointBalance}P',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF204A72),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _sortAscending = !(_sortAscending ?? false);
                              });
                            },
                            tooltip: _sortAscending == true
                                ? strings.flowerShopSortHighToLow
                                : strings.flowerShopSortLowToHigh,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.16),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(42, 42),
                            ),
                            icon: Icon(
                              _sortAscending == true
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                strings.flowerShopSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4F82AA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                      sortedItems.sort(
                        (a, b) => a.pricePoints.compareTo(b.pricePoints),
                      );
                      if (_sortAscending == false) {
                        sortedItems.setAll(0, sortedItems.reversed);
                      }
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.73,
                      ),
                      itemCount: sortedItems.length,
                      itemBuilder: (context, index) {
                        final item = sortedItems[index];
                        return _FlowerGiftCard(
                          item: item,
                          strings: strings,
                          busy: _processingFlowerId == item.id,
                          onAcquire: () => _acquireFlower(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowerGiftCard extends StatelessWidget {
  const _FlowerGiftCard({
    required this.item,
    required this.strings,
    required this.busy,
    required this.onAcquire,
  });

  final FlowerShopItem item;
  final AppStrings strings;
  final bool busy;
  final VoidCallback onAcquire;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD9EEF9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B4A7A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7FF),
                  ),
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
                color: const Color(0xFF24262F),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF717A87),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4BA9E8),
                              Color(0xFF2F86D7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x224BA9E8),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.pricePoints}P',
                          style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: busy ? null : onAcquire,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE1535D),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFD2D7E0),
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(strings.flowerShopAcquireButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

class _FlowerGuideScreen extends StatelessWidget {
  const _FlowerGuideScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFA),
        foregroundColor: const Color(0xFF2F2424),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 56,
                color: Color(0xFFB86A76),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2F2424),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6D5A5A),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
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
