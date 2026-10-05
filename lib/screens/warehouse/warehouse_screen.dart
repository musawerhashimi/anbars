import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/pdf_builder.dart';
import '../../models/product_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/app_search_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/gradient_pill_button.dart';
import 'add_product_sheet.dart';
import 'product_detail_sheet.dart';

class WarehouseScreen extends ConsumerWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final filter = ref.watch(productFilterProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AnbarAppBar(
        title: s.warehouse,
        icon: Icons.warehouse_rounded,
        showBack: false,
        actions: [_WarehouseReportButton(s: s)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchBar(
              hint: s.searchProducts,
              onChanged: (q) =>
                  ref.read(productFilterProvider.notifier).setSearch(q),
            ),
          ),
          _FilterChips(filter: filter, s: s),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: filter.hasActiveFilter
                        ? s.noMatchingProducts
                        : s.noProductsYet,
                    subtitle: filter.hasActiveFilter
                        ? s.tryClearingFilters
                        : s.tapToAddProduct,
                    actionLabel: filter.hasActiveFilter ? s.clearFilters : null,
                    onAction: filter.hasActiveFilter
                        ? () => ref
                              .read(productFilterProvider.notifier)
                              .clearAll()
                        : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _ProductCard(product: list[i], s: s),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: FloatingActionButton.extended(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddProductSheet(),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(s.addProduct),
        ),
      ),
    );
  }
}

// ── Warehouse Report (PDF) button ───────────────────────────────────────────

class _WarehouseReportButton extends ConsumerStatefulWidget {
  final AppStrings s;
  const _WarehouseReportButton({required this.s});

  @override
  ConsumerState<_WarehouseReportButton> createState() =>
      _WarehouseReportButtonState();
}

class _WarehouseReportButtonState
    extends ConsumerState<_WarehouseReportButton> {
  bool _busy = false;

  Future<void> _export() async {
    final s = widget.s;
    final messenger = ScaffoldMessenger.of(context);
    final products = ref.read(productsProvider).valueOrNull ?? [];
    if (products.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.noProductsToExport)));
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await PdfBuilder.build(products, s);
      await PdfPrinter.print(bytes);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${s.pdfExportFailed} $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientPillButton(
      icon: Icons.picture_as_pdf_rounded,
      iconColor: AppColors.accent,
      label: widget.s.warehouseReport,
      tooltip: widget.s.exportPdf,
      busy: _busy,
      onTap: _export,
    );
  }
}

// ── Filter Chips ────────────────────────────────────────────────────────────

class _FilterChips extends ConsumerWidget {
  final ProductFilter filter;
  final AppStrings s;
  const _FilterChips({required this.filter, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final departments = ref.watch(departmentsProvider).valueOrNull ?? [];
    final vendors = ref.watch(vendorsProvider).valueOrNull ?? [];
    final notifier = ref.read(productFilterProvider.notifier);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (filter.hasActiveFilter)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(s.clearAll),
                avatar: const Icon(Icons.close_rounded, size: 14),
                onPressed: () => notifier.clearAll(),
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          _DropdownChip(
            label: filter.categoryId != null
                ? (categories
                          .where((c) => c.id == filter.categoryId)
                          .firstOrNull
                          ?.name ??
                      s.category)
                : s.category,
            isActive: filter.categoryId != null,
            items: categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            allLabel: s.all,
            value: filter.categoryId,
            onChanged: (id) => notifier.setCategory(id),
          ),
          const SizedBox(width: 8),
          _DropdownChip(
            label: filter.departmentId != null
                ? (departments
                          .where((d) => d.id == filter.departmentId)
                          .firstOrNull
                          ?.name ??
                      s.department)
                : s.department,
            isActive: filter.departmentId != null,
            items: departments
                .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                .toList(),
            allLabel: s.all,
            value: filter.departmentId,
            onChanged: (id) => notifier.setDepartment(id),
          ),
          const SizedBox(width: 8),
          _DropdownChip(
            label: filter.vendorId != null
                ? (vendors
                          .where((v) => v.id == filter.vendorId)
                          .firstOrNull
                          ?.name ??
                      s.vendor)
                : s.vendor,
            isActive: filter.vendorId != null,
            items: vendors
                .map((v) => DropdownMenuItem(value: v.id, child: Text(v.name)))
                .toList(),
            allLabel: s.all,
            value: filter.vendorId,
            onChanged: (id) => notifier.setVendor(id),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final List<DropdownMenuItem<int>> items;
  final String allLabel;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _DropdownChip({
    required this.label,
    required this.isActive,
    required this.items,
    required this.allLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : theme.colorScheme.outline,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: isActive
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            title: Text(allLabel),
            onTap: () {
              onChanged(null);
              Navigator.pop(ctx);
            },
          ),
          ...items.map(
            (item) => ListTile(
              title: item.child,
              selected: item.value == value,
              selectedColor: AppColors.primary,
              onTap: () {
                onChanged(item.value);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ────────────────────────────────────────────────────────────

class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  final AppStrings s;
  const _ProductCard({required this.product, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLow = product.isLowStock;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProductDetailSheet(product: product),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLow
                ? AppColors.warning.withValues(alpha: 0.5)
                : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLow
                    ? AppColors.warning.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isLow ? Icons.warning_amber_rounded : Icons.inventory_2_rounded,
                color: isLow ? AppColors.warning : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (product.categoryName != null)
                        _Tag(product.categoryName!, AppColors.blue),
                      if (product.departmentName != null)
                        _Tag(product.departmentName!, AppColors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(product.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isLow
                        ? AppColors.warning.withValues(alpha: 0.12)
                        : AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.quantity} ${product.unitName ?? s.pcs}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLow ? AppColors.warning : AppColors.success,
                    ),
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

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
