import '../core/database/database_helper.dart';
import '../models/sale_model.dart';
import '../models/sold_product_model.dart';

class SaleService {
  final _db = DatabaseHelper.instance;

  /// Creates a sale and its items in a single transaction,
  /// then deducts stock from products.
  Future<int> createSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await _db.database;

    return await db.transaction((txn) async {
      final saleId = await txn.insert('sales', {
        'total_amount': sale.totalAmount,
        'note': sale.note,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        });

        // Deduct stock
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ?, updated_at = ? WHERE id = ?',
          [item.quantity, DateTime.now().toIso8601String(), item.productId],
        );
      }

      return saleId;
    });
  }

  Future<List<SaleModel>> getAll() async {
    final rows = await _db.rawQuery('''
      SELECT s.*,
             COUNT(si.id) AS item_count,
             COALESCE(SUM(si.quantity), 0) AS total_qty
      FROM sales s
      LEFT JOIN sale_items si ON si.sale_id = s.id
      GROUP BY s.id
      ORDER BY s.created_at DESC
    ''');
    return rows.map(SaleModel.fromMap).toList();
  }

  Future<List<SaleModel>> getSalesToday() async {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final end = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();
    final rows = await _db.rawQuery(
      "SELECT * FROM sales WHERE created_at BETWEEN ? AND ? ORDER BY created_at DESC",
      [start, end],
    );
    return rows.map(SaleModel.fromMap).toList();
  }

  Future<List<SaleModel>> getSalesThisMonth() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(
      now.year,
      now.month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();
    final rows = await _db.rawQuery(
      "SELECT * FROM sales WHERE created_at BETWEEN ? AND ? ORDER BY created_at DESC",
      [start, end],
    );
    return rows.map(SaleModel.fromMap).toList();
  }

  Future<List<SaleItemModel>> getItemsForSale(int saleId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT si.*, p.name AS product_name
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''',
      [saleId],
    );
    return rows.map(SaleItemModel.fromMap).toList();
  }

  /// Every product sold since [from] (all time when null), best sellers first.
  Future<List<SoldProductModel>> getSoldProducts({DateTime? from}) async {
    final rows = await _db.rawQuery(
      '''
      SELECT si.product_id,
             p.name AS product_name,
             u.name AS unit_name,
             SUM(si.quantity) AS qty,
             SUM(si.quantity * si.price) AS total,
             COUNT(DISTINCT si.sale_id) AS sale_count
      FROM sale_items si
      JOIN sales s ON s.id = si.sale_id
      LEFT JOIN products p ON p.id = si.product_id
      LEFT JOIN units u ON u.id = p.unit_id
      ${from != null ? 'WHERE s.created_at >= ?' : ''}
      GROUP BY si.product_id
      ORDER BY total DESC
    ''',
      [if (from != null) from.toIso8601String()],
    );
    return rows.map(SoldProductModel.fromMap).toList();
  }

  Future<double> getTotalSalesToday() async {
    final sales = await getSalesToday();
    return sales.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
  }

  Future<double> getTotalSalesThisMonth() async {
    final sales = await getSalesThisMonth();
    return sales.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
  }

  Future<int> getTransactionCountToday() async {
    final sales = await getSalesToday();
    return sales.length;
  }
}
