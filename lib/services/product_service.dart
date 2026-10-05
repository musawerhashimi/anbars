import '../core/database/database_helper.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = DatabaseHelper.instance;

  static const _joinQuery = '''
    SELECT
      p.*,
      u.name  AS unit_name,
      c.name  AS category_name,
      d.name  AS department_name,
      v.name  AS vendor_name
    FROM products p
    LEFT JOIN units      u ON p.unit_id       = u.id
    LEFT JOIN categories c ON p.category_id   = c.id
    LEFT JOIN departments d ON p.department_id = d.id
    LEFT JOIN vendors    v ON p.vendor_id      = v.id
  ''';

  Future<List<ProductModel>> getAll() async {
    final rows = await _db.rawQuery('$_joinQuery ORDER BY p.name ASC');
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    final rows = await _db.rawQuery(
      '$_joinQuery WHERE p.name LIKE ? ORDER BY p.name ASC',
      ['%$query%'],
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> filterBy({
    int? categoryId,
    int? departmentId,
    int? vendorId,
  }) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (categoryId != null) {
      conditions.add('p.category_id = ?');
      args.add(categoryId);
    }
    if (departmentId != null) {
      conditions.add('p.department_id = ?');
      args.add(departmentId);
    }
    if (vendorId != null) {
      conditions.add('p.vendor_id = ?');
      args.add(vendorId);
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final rows = await _db.rawQuery('$_joinQuery $where ORDER BY p.name ASC', args);
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getLowStock({int threshold = 5}) async {
    final rows = await _db.rawQuery(
      '$_joinQuery WHERE p.quantity <= ? ORDER BY p.quantity ASC',
      [threshold],
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel?> getById(int id) async {
    final rows = await _db.rawQuery('$_joinQuery WHERE p.id = ?', [id]);
    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }

  Future<int> create(ProductModel product) async {
    final now = DateTime.now().toIso8601String();
    final map = product.toMap()
      ..['created_at'] = now
      ..['updated_at'] = now
      ..remove('id');
    return await _db.insert('products', map);
  }

  Future<int> update(ProductModel product) async {
    final map = product.toMap()..['updated_at'] = DateTime.now().toIso8601String();
    return await _db.update('products', map, 'id = ?', [product.id]);
  }

  Future<int> updateQuantity(int id, int newQuantity) async {
    return await _db.update(
      'products',
      {'quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()},
      'id = ?',
      [id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete('products', 'id = ?', [id]);
  }

  Future<int> getTotalCount() async {
    final rows = await _db.rawQuery('SELECT COUNT(*) as count FROM products');
    return rows.first['count'] as int? ?? 0;
  }

  Future<int> getLowStockCount({int threshold = 5}) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE quantity <= ?',
      [threshold],
    );
    return rows.first['count'] as int? ?? 0;
  }
}
