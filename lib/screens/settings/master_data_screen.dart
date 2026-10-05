import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../models/category_model.dart';
import '../../models/unit_model.dart';
import '../../models/vendor_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/empty_state.dart';

enum MasterDataType { units, categories, departments, vendors }

class MasterDataScreen extends ConsumerWidget {
  final MasterDataType type;
  const MasterDataScreen({super.key, required this.type});

  String _title(AppStrings s) => switch (type) {
    MasterDataType.units => s.units,
    MasterDataType.categories => s.categories,
    MasterDataType.departments => s.departments,
    MasterDataType.vendors => s.vendors,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AnbarAppBar(
        title: _title(s),
        icon: switch (type) {
          MasterDataType.units => Icons.straighten_rounded,
          MasterDataType.categories => Icons.category_rounded,
          MasterDataType.departments => Icons.warehouse_rounded,
          MasterDataType.vendors => Icons.business_rounded,
        },
      ),
      body: _buildBody(context, ref, s),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, s),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AppStrings s) =>
      switch (type) {
        MasterDataType.units => _UnitsList(s: s),
        MasterDataType.categories => _CategoriesList(s: s),
        MasterDataType.departments => _DepartmentsList(s: s),
        MasterDataType.vendors => _VendorsList(s: s),
      };

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref, AppStrings s,
      {dynamic existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: isEdit ? _nameOf(existing) : '');
    final contactCtrl = TextEditingController(
        text: (existing is VendorModel) ? (existing.contactInfo ?? '') : '');
    final isVendor = type == MasterDataType.vendors;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${isEdit ? s.edit : s.add} ${_title(s)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: s.name),
            ),
            if (isVendor) ...[
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                decoration: InputDecoration(labelText: s.contactInfo),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await _save(ref, nameCtrl.text.trim(), contactCtrl.text.trim(), existing);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEdit ? s.save : s.add),
          ),
        ],
      ),
    );
  }

  String _nameOf(dynamic item) {
    if (item is UnitModel) return item.name;
    if (item is CategoryModel) return item.name;
    if (item is VendorModel) return item.name;
    return (item as dynamic).name as String;
  }

  Future<void> _save(WidgetRef ref, String name, String contact, dynamic existing) async {
    switch (type) {
      case MasterDataType.units:
        existing != null
            ? await ref.read(unitsProvider.notifier).edit((existing as UnitModel).copyWith(name: name))
            : await ref.read(unitsProvider.notifier).add(name);
      case MasterDataType.categories:
        existing != null
            ? await ref.read(categoriesProvider.notifier).edit((existing as CategoryModel).copyWith(name: name))
            : await ref.read(categoriesProvider.notifier).add(name);
      case MasterDataType.departments:
        existing != null
            ? await ref.read(departmentsProvider.notifier).edit((existing as dynamic).copyWith(name: name))
            : await ref.read(departmentsProvider.notifier).add(name);
      case MasterDataType.vendors:
        existing != null
            ? await ref.read(vendorsProvider.notifier).edit(
                (existing as VendorModel).copyWith(name: name, contactInfo: contact.isEmpty ? null : contact))
            : await ref.read(vendorsProvider.notifier).add(
                VendorModel(name: name, contactInfo: contact.isEmpty ? null : contact));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, dynamic item, AppStrings s) async {
    final confirm = await showConfirmDialog(context,
        title: '${s.delete} ${_title(s)}',
        message: '"${_nameOf(item)}"  ${s.deleteConfirm}',
        confirmLabel: s.delete,
        cancelLabel: s.cancel);
    if (!confirm) return;
    switch (type) {
      case MasterDataType.units:
        await ref.read(unitsProvider.notifier).remove((item as UnitModel).id!);
      case MasterDataType.categories:
        await ref.read(categoriesProvider.notifier).remove((item as CategoryModel).id!);
      case MasterDataType.departments:
        await ref.read(departmentsProvider.notifier).remove((item as dynamic).id as int);
      case MasterDataType.vendors:
        await ref.read(vendorsProvider.notifier).remove((item as VendorModel).id!);
    }
  }
}

// ── Per-type list widgets ───────────────────────────────────────────────────

class _UnitsList extends ConsumerWidget {
  final AppStrings s;
  const _UnitsList({required this.s});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = context.findAncestorWidgetOfExactType<MasterDataScreen>()!;
    return ref.watch(unitsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? EmptyState(icon: Icons.straighten_rounded, title: s.noUnitsYet)
          : _list(items.map((u) => _MasterDataTile(
                name: u.name,
                onEdit: () => screen._showAddDialog(context, ref, s, existing: u),
                onDelete: () => screen._delete(context, ref, u, s),
              )).toList()),
    );
  }
}

class _CategoriesList extends ConsumerWidget {
  final AppStrings s;
  const _CategoriesList({required this.s});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = context.findAncestorWidgetOfExactType<MasterDataScreen>()!;
    return ref.watch(categoriesProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? EmptyState(icon: Icons.category_rounded, title: s.noCategoriesYet)
          : _list(items.map((c) => _MasterDataTile(
                name: c.name,
                onEdit: () => screen._showAddDialog(context, ref, s, existing: c),
                onDelete: () => screen._delete(context, ref, c, s),
              )).toList()),
    );
  }
}

class _DepartmentsList extends ConsumerWidget {
  final AppStrings s;
  const _DepartmentsList({required this.s});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = context.findAncestorWidgetOfExactType<MasterDataScreen>()!;
    return ref.watch(departmentsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? EmptyState(icon: Icons.warehouse_rounded, title: s.noDepartmentsYet)
          : _list(items.map((d) => _MasterDataTile(
                name: d.name,
                onEdit: () => screen._showAddDialog(context, ref, s, existing: d),
                onDelete: () => screen._delete(context, ref, d, s),
              )).toList()),
    );
  }
}

class _VendorsList extends ConsumerWidget {
  final AppStrings s;
  const _VendorsList({required this.s});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = context.findAncestorWidgetOfExactType<MasterDataScreen>()!;
    return ref.watch(vendorsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? EmptyState(icon: Icons.business_rounded, title: s.noVendorsYet)
          : _list(items.map((v) => _MasterDataTile(
                name: v.name,
                subtitle: v.contactInfo,
                onEdit: () => screen._showAddDialog(context, ref, s, existing: v),
                onDelete: () => screen._delete(context, ref, v, s),
              )).toList()),
    );
  }
}

Widget _list(List<Widget> tiles) => ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tiles.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (_, i) => tiles[i],
    );

class _MasterDataTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MasterDataTile({required this.name, this.subtitle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ListTile(
        title: Text(name, style: theme.textTheme.titleMedium),
        subtitle: subtitle != null ? Text(subtitle!, style: theme.textTheme.bodySmall) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: AppColors.primary, onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20), color: AppColors.error, onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
