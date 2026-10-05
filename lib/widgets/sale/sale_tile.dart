import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';

/// "Today", "Yesterday", or a short date.
String saleDayLabel(DateTime date, AppStrings s) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return s.today;
  if (diff == 1) return s.yesterday;
  return Formatters.dayMonth(date);
}

class SaleTile extends StatelessWidget {
  final SaleModel sale;
  final AppStrings s;
  final VoidCallback? onTap;
  final bool showDay;

  const SaleTile({
    super.key,
    required this.sale,
    required this.s,
    this.onTap,
    this.showDay = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = sale.date;
    final meta = [
      s.itemsCount(Formatters.number(sale.itemCount)),
      if (date != null) Formatters.time(date),
    ].join('  ·  ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.saleNumber(Formatters.number(sale.id ?? 0)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${Formatters.currency(sale.totalAmount)}',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (showDay && date != null) ...[
                  const SizedBox(height: 2),
                  Text(saleDayLabel(date, s), style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
