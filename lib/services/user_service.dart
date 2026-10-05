import '../core/database/database_helper.dart';
import '../models/user_model.dart';

class UserService {
  final _db = DatabaseHelper.instance;

  Future<UserModel?> getUser() async {
    final rows = await _db.query('users', orderBy: 'id ASC');
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<int> updateUsername(int id, String username) async {
    return await _db.update('users', {'username': username}, 'id = ?', [id]);
  }

  Future<bool> changePassword(int id, String currentPassword, String newPassword) async {
    final rows = await _db.query('users', where: 'id = ? AND password = ?', whereArgs: [id, currentPassword]);
    if (rows.isEmpty) return false;
    await _db.update('users', {'password': newPassword}, 'id = ?', [id]);
    return true;
  }

  Future<String?> getSetting(String key) async {
    final rows = await _db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert('app_settings', {'key': key, 'value': value});
  }
}
