import '../core/database/database_helper.dart';
import '../models/unit_model.dart';

class UnitService {
  final _db = DatabaseHelper.instance;

  Future<List<UnitModel>> getAll() async {
    final rows = await _db.query('units', orderBy: 'name ASC');
    return rows.map(UnitModel.fromMap).toList();
  }

  Future<UnitModel?> getById(int id) async {
    final rows = await _db.query('units', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UnitModel.fromMap(rows.first);
  }

  Future<int> create(String name) async {
    return await _db.insert('units', {'name': name});
  }

  Future<int> update(UnitModel unit) async {
    return await _db.update('units', unit.toMap(), 'id = ?', [unit.id]);
  }

  Future<int> delete(int id) async {
    return await _db.delete('units', 'id = ?', [id]);
  }
}
