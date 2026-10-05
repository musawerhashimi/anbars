import '../core/database/database_helper.dart';
import '../models/department_model.dart';

class DepartmentService {
  final _db = DatabaseHelper.instance;

  Future<List<DepartmentModel>> getAll() async {
    final rows = await _db.query('departments', orderBy: 'name ASC');
    return rows.map(DepartmentModel.fromMap).toList();
  }

  Future<DepartmentModel?> getById(int id) async {
    final rows = await _db.query('departments', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return DepartmentModel.fromMap(rows.first);
  }

  Future<int> create(String name) async {
    return await _db.insert('departments', {'name': name});
  }

  Future<int> update(DepartmentModel dept) async {
    return await _db.update('departments', dept.toMap(), 'id = ?', [dept.id]);
  }

  Future<int> delete(int id) async {
    return await _db.delete('departments', 'id = ?', [id]);
  }
}
