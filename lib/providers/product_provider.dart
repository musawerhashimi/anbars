import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

// ─── Active filter state ────────────────────────────────────────────────────

class ProductFilter {
  final String searchQuery;
  final int? categoryId;
  final int? departmentId;
  final int? vendorId;

  const ProductFilter({
    this.searchQuery = '',
    this.categoryId,
    this.departmentId,
    this.vendorId,
  });

  ProductFilter copyWith({
    String? searchQuery,
    int? categoryId,
    int? departmentId,
    int? vendorId,
    bool clearCategory = false,
    bool clearDepartment = false,
    bool clearVendor = false,
  }) =>
      ProductFilter(
        searchQuery: searchQuery ?? this.searchQuery,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
        vendorId: clearVendor ? null : (vendorId ?? this.vendorId),
      );

  bool get hasActiveFilter =>
      searchQuery.isNotEmpty || categoryId != null || departmentId != null || vendorId != null;
}

final productFilterProvider = NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setCategory(int? id) => state = id == null ? state.copyWith(clearCategory: true) : state.copyWith(categoryId: id);
  void setDepartment(int? id) => state = id == null ? state.copyWith(clearDepartment: true) : state.copyWith(departmentId: id);
  void setVendor(int? id) => state = id == null ? state.copyWith(clearVendor: true) : state.copyWith(vendorId: id);
  void clearAll() => state = const ProductFilter();
}

// ─── Products list (reacts to filter changes) ───────────────────────────────

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<ProductModel>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    final filter = ref.watch(productFilterProvider);
    final service = ref.read(productServiceProvider);

    if (filter.searchQuery.isNotEmpty) {
      return service.search(filter.searchQuery);
    }

    if (filter.hasActiveFilter) {
      return service.filterBy(
        categoryId: filter.categoryId,
        departmentId: filter.departmentId,
        vendorId: filter.vendorId,
      );
    }

    return service.getAll();
  }

  Future<void> add(ProductModel product) async {
    await ref.read(productServiceProvider).create(product);
    ref.invalidateSelf();
  }

  Future<void> edit(ProductModel product) async {
    await ref.read(productServiceProvider).update(product);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(productServiceProvider).delete(id);
    ref.invalidateSelf();
  }

  void refresh() => ref.invalidateSelf();
}

// ─── Dashboard stats (derived from productsProvider — always in sync) ────────

final totalProductsProvider = Provider<int>((ref) {
  return ref.watch(productsProvider).valueOrNull?.length ?? 0;
});

final lowStockCountProvider = Provider<int>((ref) {
  return ref.watch(productsProvider).valueOrNull?.where((p) => p.isLowStock).length ?? 0;
});
