import 'package:flutter/material.dart';

import '../localization/app_language.dart';

class LanguageSelectorField extends StatelessWidget {
  const LanguageSelectorField({
    super.key,
    required this.label,
    required this.language,
    required this.onChanged,
  });

  final String label;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
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
          DropdownButtonFormField<AppLanguage>(
            initialValue: language,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: AppLanguage.values
                .map(
                  (item) => DropdownMenuItem<AppLanguage>(
                    value: item,
                    child: Text(item.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
