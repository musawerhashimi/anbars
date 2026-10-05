import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../models/category_model.dart';
import '../../models/department_model.dart';
import '../../models/product_model.dart';
import '../../models/unit_model.dart';
import '../../models/vendor_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/vendor_provider.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  final ProductModel? existing;
  const AddProductSheet({super.key, this.existing});

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _unitId, _categoryId, _departmentId, _vendorId;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.existing!;
      _nameCtrl.text = p.name;
      _qtyCtrl.text = '${p.quantity}';
      _priceCtrl.text = '${p.price}';
      _descCtrl.text = p.description ?? '';
      _unitId = p.unitId;
      _categoryId = p.categoryId;
      _departmentId = p.departmentId;
      _vendorId = p.vendorId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppStrings s) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final now = DateTime.now().toIso8601String();
    final parsedQty = int.parse(_qtyCtrl.text.trim());
    final product = ProductModel(
      id: widget.existing?.id,
      name: _nameCtrl.text.trim(),
      quantity: parsedQty,
      initialQuantity: widget.existing?.initialQuantity ?? parsedQty,
      price: double.parse(_priceCtrl.text.trim()),
      unitId: _unitId,
      categoryId: _categoryId,
      departmentId: _departmentId,
      vendorId: _vendorId,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    if (_isEdit) {
      await ref.read(productsProvider.notifier).edit(product);
    } else {
      await ref.read(productsProvider.notifier).add(product);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);
    final units = ref.watch(unitsProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final departments = ref.watch(departmentsProvider).valueOrNull ?? [];
    final vendors = ref.watch(vendorsProvider).valueOrNull ?? [];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(_isEdit ? s.editProduct : s.addProduct,
                      style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _field(_nameCtrl, s.productName, Icons.inventory_2_outlined,
                        validator: (v) =>
                            v!.trim().isEmpty ? s.nameRequired : null),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            _qtyCtrl, s.quantity, Icons.numbers_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v!.trim().isEmpty) return s.required;
                              if (int.tryParse(v.trim()) == null) return s.invalidNumber;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _field(
                            _priceCtrl, s.price, Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.trim().isEmpty) return s.required;
                              if (double.tryParse(v.trim()) == null) return s.invalidPrice;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _dropdown<UnitModel>(
                      s: s, label: s.unit, icon: Icons.straighten_rounded,
                      items: units, value: units.where((u) => u.id == _unitId).firstOrNull,
                      itemLabel: (u) => u.name,
                      onChanged: (u) => setState(() => _unitId = u?.id),
                      onAddNew: () => _addDialog(context, s, s.unit, (name) async {
                        await ref.read(unitServiceProvider).create(name);
                        ref.invalidate(unitsProvider);
                      }),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<CategoryModel>(
                      s: s, label: s.category, icon: Icons.category_outlined,
                      items: categories,
                      value: categories.where((c) => c.id == _categoryId).firstOrNull,
                      itemLabel: (c) => c.name,
                      onChanged: (c) => setState(() => _categoryId = c?.id),
                      onAddNew: () => _addDialog(context, s, s.category, (name) async {
                        await ref.read(categoryServiceProvider).create(name);
                        ref.invalidate(categoriesProvider);
                      }),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<DepartmentModel>(
                      s: s, label: s.department, icon: Icons.warehouse_outlined,
                      items: departments,
                      value: departments.where((d) => d.id == _departmentId).firstOrNull,
                      itemLabel: (d) => d.name,
                      onChanged: (d) => setState(() => _departmentId = d?.id),
                      onAddNew: () => _addDialog(context, s, s.department, (name) async {
                        await ref.read(departmentServiceProvider).create(name);
                        ref.invalidate(departmentsProvider);
                      }),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<VendorModel>(
                      s: s, label: s.vendor, icon: Icons.business_outlined,
                      items: vendors,
                      value: vendors.where((v) => v.id == _vendorId).firstOrNull,
                      itemLabel: (v) => v.name,
                      onChanged: (v) => setState(() => _vendorId = v?.id),
                      onAddNew: () => _addDialog(context, s, s.vendor, (name) async {
                        await ref.read(vendorServiceProvider).create(VendorModel(name: name));
                        ref.invalidate(vendorsProvider);
                      }),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: s.description,
                        prefixIcon: const Icon(Icons.notes_rounded),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : () => _save(s),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52)),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_isEdit ? s.saveChanges : s.addProduct),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget _dropdown<T>({
    required AppStrings s,
    required String label,
    required IconData icon,
    required List<T> items,
    required T? value,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    required VoidCallback onAddNew,
  }) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text('${s.select} $label',
                    style: theme.textTheme.bodyMedium),
                items: items
                    .map((item) => DropdownMenuItem<T>(
                        value: item, child: Text(itemLabel(item))))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary, size: 20),
            onPressed: onAddNew,
            tooltip: '${s.addNew} $label',
          ),
        ],
      ),
    );
  }

  Future<void> _addDialog(BuildContext context, AppStrings s, String title,
      Future<void> Function(String) onCreate) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${s.newLabel} $title'),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(hintText: '${s.name} $title')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await onCreate(ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(s.add),
          ),
        ],
      ),
    );
  }
}
