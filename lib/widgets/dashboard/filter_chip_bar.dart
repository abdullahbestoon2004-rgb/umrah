import 'package:flutter/material.dart';
import '../tag_chip.dart';
import 'dashboard_scaffold.dart';

class FilterOption<T> {
  final T value;
  final String label;
  const FilterOption(this.value, this.label);
}

/// Horizontally scrollable row of selectable filter chips, built on the
/// existing TagChip so filters look identical everywhere.
class FilterChipBar<T> extends StatelessWidget {
  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelect;

  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: kDashPagePad),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TagChip(
                label: option.label,
                active: option.value == selected,
                onTap: () => onSelect(option.value),
              ),
            ),
        ],
      ),
    );
  }
}
