import 'package:flutter/material.dart';

import '../data/discovery_filter_options.dart';
import '../localization/app_localizations.dart';
import '../localization/discovery_strings.dart';

class DiscoveryFilterPanel extends StatelessWidget {
  const DiscoveryFilterPanel({
    super.key,
    required this.expanded,
    required this.country,
    required this.job,
    required this.gender,
    required this.minAge,
    required this.maxAge,
    required this.locationController,
    required this.onToggleExpanded,
    required this.onCountryChanged,
    required this.onJobChanged,
    required this.onGenderChanged,
    required this.onMinAgeChanged,
    required this.onMaxAgeChanged,
    required this.onReset,
    required this.onApply,
  });

  final bool expanded;
  final String? country;
  final String? job;
  final String? gender;
  final int minAge;
  final int maxAge;
  final TextEditingController locationController;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onJobChanged;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<int> onMinAgeChanged;
  final ValueChanged<int> onMaxAgeChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.filterTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A2330),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expanded ? strings.hideFilters : strings.showFilters,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8C737A),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 18),
            _DropdownField(
              label: strings.countryFilter,
              value: country,
              anyLabel: strings.anyOption,
              items: discoveryCountryCodes
                  .map(
                    (code) => _OptionItem(
                      value: code,
                      label: strings.countryName(code),
                    ),
                  )
                  .toList(),
              onChanged: onCountryChanged,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: strings.jobFilter,
              value: job,
              anyLabel: strings.anyOption,
              items: discoveryJobCodes
                  .map(
                    (code) => _OptionItem(
                      value: code,
                      label: strings.jobName(code),
                    ),
                  )
                  .toList(),
              onChanged: onJobChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AgeDropdownField(
                    label: strings.ageFrom,
                    value: minAge,
                    onChanged: onMinAgeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AgeDropdownField(
                    label: strings.ageTo,
                    value: maxAge,
                    onChanged: onMaxAgeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: strings.genderFilter,
              value: gender,
              anyLabel: strings.anyOption,
              items: discoveryGenderCodes
                  .map(
                    (code) => _OptionItem(
                      value: code,
                      label: strings.genderName(code),
                    ),
                  )
                  .toList(),
              onChanged: onGenderChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: strings.locationFilter,
                hintText: strings.locationPlaceholder,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReset,
                    child: Text(strings.resetFilters),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApply,
                    child: Text(strings.applyFilters),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.anyLabel,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String anyLabel;
  final List<_OptionItem> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(anyLabel),
        ),
        ...items.map(
          (item) => DropdownMenuItem<String?>(
            value: item.value,
            child: Text(item.label),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _AgeDropdownField extends StatelessWidget {
  const _AgeDropdownField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (var age = discoveryMinAge; age <= discoveryMaxAge; age++)
          DropdownMenuItem<int>(
            value: age,
            child: Text('$age'),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}
