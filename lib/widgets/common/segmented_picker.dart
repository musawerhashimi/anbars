import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const SegmentOption(this.value, this.label, this.icon);
}

class SegmentedPicker<T> extends StatelessWidget {
  final T value;
  final List<SegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  const SegmentedPicker({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: o.value == value
                        ? (isDark ? AppColors.darkBorder : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: o.value == value && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (o.icon != null) ...[
                        Icon(
                          o.icon,
                          size: 18,
                          color: o.value == value
                              ? AppColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: o.value == value
                                ? AppColors.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: o.value == value
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
