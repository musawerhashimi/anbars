import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';
import '../../providers/sale_provider.dart';

void showSaleDetails(BuildContext context, SaleModel sale) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SaleDetailSheet(sale: sale),
  );
}

class SaleDetailSheet extends ConsumerWidget {
  final SaleModel sale;
  const SaleDetailSheet({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);
    final items = ref.watch(saleItemsProvider(sale.id!));
    final date = sale.date;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Receipt header ───────────────────────────────────────────
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.brandGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.saleNumber(Formatters.number(sale.id ?? 0)),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            if (date != null)
              Text(
                '${Formatters.longDate(date)}  ·  ${Formatters.time(date)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Text(
              Formatters.currency(sale.totalAmount),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(s.items, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  s.itemsCount(Formatters.number(sale.itemCount)),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Line items ───────────────────────────────────────────────
            Flexible(
              child: items.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('${s.error}: $e'),
                data: (list) => ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _LineItem(item: list[i]),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    s.total,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.currency(sale.totalAmount),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final SaleItemModel item;
  const _LineItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              Formatters.number(item.quantity),
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? '#${item.productId}',
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${Formatters.number(item.quantity)} × ${Formatters.currency(item.price)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            Formatters.currency(item.subtotal),
            textDirection: TextDirection.ltr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
