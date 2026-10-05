import '../core/database/database_helper.dart';
import '../models/category_model.dart';

class CategoryService {
  final _db = DatabaseHelper.instance;

  Future<List<CategoryModel>> getAll() async {
    final rows = await _db.query('categories', orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final rows = await _db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first);
  }

  Future<int> create(String name) async {
    return await _db.insert('categories', {'name': name});
  }

  Future<int> update(CategoryModel category) async {
    return await _db.update('categories', category.toMap(), 'id = ?', [category.id]);
  }

  Future<int> delete(int id) async {
    return await _db.delete('categories', 'id = ?', [id]);
  }
}
