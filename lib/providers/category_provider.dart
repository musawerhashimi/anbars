import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) => CategoryService());

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() => ref.read(categoryServiceProvider).getAll();

  Future<void> add(String name) async {
    await ref.read(categoryServiceProvider).create(name);
    ref.invalidateSelf();
  }

  Future<void> edit(CategoryModel category) async {
    await ref.read(categoryServiceProvider).update(category);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(categoryServiceProvider).delete(id);
    ref.invalidateSelf();
  }
}
