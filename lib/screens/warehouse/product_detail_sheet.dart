import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'add_product_sheet.dart';

class ProductDetailSheet extends ConsumerWidget {
  final ProductModel product;
  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);
    final isLow = product.isLowStock;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Text(s.productDetails, style: theme.textTheme.headlineMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: s.edit,
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddProductSheet(existing: product),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  tooltip: s.delete,
                  onPressed: () async {
                    Navigator.pop(context);
                    final confirm = await showConfirmDialog(context,
                        title: s.deleteProduct,
                        message: '"${product.name}" ${s.deleteConfirmMsg}',
                        confirmLabel: s.delete,
                        cancelLabel: s.cancel);
                    if (confirm) {
                      await ref.read(productsProvider.notifier).remove(product.id!);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                if (isLow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${s.lowStockWarning} ${product.quantity} ${s.remaining}',
                          style: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                Text(product.name, style: theme.textTheme.headlineLarge),
                const SizedBox(height: 6),
                Text(
                  Formatters.currency(product.price),
                  style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                _InfoRow(icon: Icons.numbers_rounded, label: s.quantity,
                    value: '${product.quantity} ${product.unitName ?? ''}'),
                _InfoRow(icon: Icons.category_rounded, label: s.category,
                    value: product.categoryName ?? '—'),
                _InfoRow(icon: Icons.warehouse_rounded, label: s.department,
                    value: product.departmentName ?? '—'),
                _InfoRow(icon: Icons.business_rounded, label: s.vendor,
                    value: product.vendorName ?? '—'),
                if (product.description != null && product.description!.isNotEmpty)
                  _InfoRow(icon: Icons.notes_rounded, label: s.description,
                      value: product.description!),
                if (product.createdAt != null)
                  _InfoRow(icon: Icons.calendar_today_rounded, label: s.added,
                      value: Formatters.date(product.createdAt!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
