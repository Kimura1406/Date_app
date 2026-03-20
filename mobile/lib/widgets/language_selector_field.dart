import 'package:flutter/material.dart';

import '../localization/app_language.dart';

class LanguageSelectorField extends StatelessWidget {
  const LanguageSelectorField({
    super.key,
    required this.label,
    required this.language,
    required this.onChanged,
    this.compact = false,
  });

  final String label;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<AppLanguage>(
      value: language,
      decoration: compact
          ? const InputDecoration(border: InputBorder.none)
          : const InputDecoration(border: OutlineInputBorder()),
      icon: const Icon(Icons.expand_more),
      items: AppLanguage.values
          .map((item) => DropdownMenuItem<AppLanguage>(
                value: item,
                child: Row(
                  children: [
                    Text(item.flag),
                    const SizedBox(width: 8),
                    Text(item.label),
                  ],
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white70),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<AppLanguage>(
            value: language,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            items: AppLanguage.values
                .map(
                  (item) => DropdownMenuItem<AppLanguage>(
                    value: item,
                    child: Row(
                      children: [
                        Text(item.flag),
                        const SizedBox(width: 8),
                        Text(item.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) => AppLanguage.values
                .map(
                  (item) => Center(
                    child: Text(
                      item.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7A6D72),
                ),
          ),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }
}
