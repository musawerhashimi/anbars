import '../core/database/database_helper.dart';
import '../models/vendor_model.dart';

class VendorService {
  final _db = DatabaseHelper.instance;

  Future<List<VendorModel>> getAll() async {
    final rows = await _db.query('vendors', orderBy: 'name ASC');
    return rows.map(VendorModel.fromMap).toList();
  }

  Future<VendorModel?> getById(int id) async {
    final rows = await _db.query('vendors', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return VendorModel.fromMap(rows.first);
  }

  Future<int> create(VendorModel vendor) async {
    return await _db.insert('vendors', {'name': vendor.name, 'contact_info': vendor.contactInfo});
  }

  Future<int> update(VendorModel vendor) async {
    return await _db.update('vendors', vendor.toMap(), 'id = ?', [vendor.id]);
  }

  Future<int> delete(int id) async {
    return await _db.delete('vendors', 'id = ?', [id]);
  }
}
